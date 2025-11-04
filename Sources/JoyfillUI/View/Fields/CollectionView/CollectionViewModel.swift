//
//  File.swift
//  Joyfill
//
//  Created by Vivek on 14/02/25.
//

import Foundation
import SwiftUI
import JoyfillModel

class CollectionViewModel: ObservableObject, TableDataViewModelProtocol {
    @Published var tableDataModel: TableDataModel
    
    @Published var shouldShowAddRowButton: Bool = false
    @Published var showRowSelector: Bool = false
    @Published var nestedTableCount: Int = 0
    @Published var collectionWidth: CGFloat = 0.0
    @Published var rowToValueElementMap: [String: ValueElement] = [:]
    @Published var columnsMap: [String: FieldTableColumn] = [:]
    @Published var isLoading: Bool = false
    @Published var isBulkLoading: Bool = false
    @Published var isSearching: Bool = false
    private var requiredColumnIds: [String] = []
    var rootSchemaKey: String = ""
    let dispatchQueue = DispatchQueue(label: "Collection", qos: .userInitiated)
    @Published var uuid = UUID()
    
    init(tableDataModel: TableDataModel) {
        self.tableDataModel = tableDataModel
        self.tableDataModel.schema.forEach { key, value in
            if value.root == true {
                self.rootSchemaKey = key
            }
        }
        self.isLoading = true
        self.initializeAsync(tableDataModel: tableDataModel)
    }
    
    func initializeAsync(tableDataModel: TableDataModel) {
        dispatchQueue.async {
            let columnsMap = self.getTableColumns(tableDataModel: tableDataModel)
            let rowToValueElementMap = self.getBuildRowToValueElementMap(tableDataModel: tableDataModel)
            let cellModels = self.getCellModels(tableDataModel: tableDataModel)
            let collectionWidth = self.getCollectionWidth(tableDataModel: tableDataModel)

            DispatchQueue.main.async {
                self.columnsMap = columnsMap
                self.rowToValueElementMap = rowToValueElementMap
                self.tableDataModel.filteredcellModels = cellModels
                self.collectionWidth = collectionWidth
                
                
                self.showRowSelector = self.tableDataModel.mode == .fill
                self.shouldShowAddRowButton = self.tableDataModel.mode == .fill
                self.nestedTableCount = self.tableDataModel.childrens.count
                
                self.requiredColumnIds = self.tableDataModel.tableColumns
                    .filter { $0.required == true }
                    .compactMap { $0.id }
                self.tableDataModel.documentEditor?.registerDelegate(self, for: self.tableDataModel.fieldIdentifier.fieldID)
                
                self.isLoading = false
            }
        }
    }
    
    func getTableColumns(tableDataModel: TableDataModel) -> [String : FieldTableColumn] {
        var map: [String: FieldTableColumn] = [:]
        for (key, _) in tableDataModel.schema {
            let tableColumns = tableDataModel.filterTableColumns(key: key)
            for column in tableColumns {
                if let id = column.id, map[id] == nil {
                    map[id] = column
                }
            }
        }
        return map
    }
    
    func getOrderedSchemaKeys() -> [String] {
        return tableDataModel.schemaChainMap[rootSchemaKey] ?? []
    }
    
    func selectUpperRow() {
        guard let currentRowID = tableDataModel.selectedRows.first,
              let currentIndex = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == currentRowID }) else {
            return
        }
        
        let currentRow = tableDataModel.filteredcellModels[currentIndex]
        
        for i in stride(from: currentIndex - 1, through: 0, by: -1) {
            let priviousRow = tableDataModel.filteredcellModels[i]
            switch priviousRow.rowType {
            case .row(index: let index):
                if priviousRow.rowType.level == currentRow.rowType.level {
                    tableDataModel.selectedRows = [priviousRow.rowID]
                    return
                }
            case .nestedRow(level: let level, index: let index, parentID: let parentID, parentSchemaKey: let parentSchemaKey):
                if priviousRow.rowType.level == currentRow.rowType.level {
                    tableDataModel.selectedRows = [priviousRow.rowID]
                    return
                }
            default:
                break
            }
        }
    }

    func selectBelowRow() {
        guard let currentRowID = tableDataModel.selectedRows.first,
              let currentIndex = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == currentRowID }) else {
            return
        }
        
        let currentRow = tableDataModel.filteredcellModels[currentIndex]
        
        for i in (currentIndex + 1)..<tableDataModel.filteredcellModels.count {
            let nextRow = tableDataModel.filteredcellModels[i]
            switch nextRow.rowType {
            case .row(index: let index):
                if nextRow.rowType.level == currentRow.rowType.level {
                    tableDataModel.selectedRows = [nextRow.rowID]
                    return
                }
            case .nestedRow(level: let level, index: let index, parentID: let parentID, parentSchemaKey: let parentSchemaKey):
                if nextRow.rowType.level == currentRow.rowType.level {
                    tableDataModel.selectedRows = [nextRow.rowID]
                    return
                }
            default:
                break
            }
        }
    }
    
    func insertBelowFromBulkEdit() {
        if let newRowID = insertBelow() {
            tableDataModel.selectedRows = [newRowID]
        }
    }
    
    func getThreeRowsForQuickView() -> [RowDataModel] {
        return Array(tableDataModel.filteredcellModels.filter { $0.rowType.isRow }.prefix(3))
    }
    
    func getTableColumnsForSelectedRows() -> [FieldTableColumn] {
        guard let firstSelectedRow = tableDataModel.selectedRows.first else {
            Log("No row selected", type: .error)
            return []
        }
        
        let indexOfFirstSelectedRow = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == firstSelectedRow } ) ?? 0
        
        let tableColumns = getTableColumnsByIndex(indexOfFirstSelectedRow)
        if tableColumns.count > 0 {
            return tableColumns
        } else {
            return tableDataModel.tableColumns
        }
        
    }
    
    func isRootSchemaValid() -> Bool {
        if tableDataModel.fieldRequired {
            let rows = tableDataModel.valueToValueElements ?? []
            let nonDeletedRows = rows.filter { !($0.deleted ?? false) }
            if nonDeletedRows.isEmpty {
                return false
            }
            return true
        } else {
            return true
        }
    }
    
    func isOnlySchemaValid(schemaID: String, valueElements: [ValueElement]) -> Bool {
        guard let schema = tableDataModel.schema[schemaID],
              let required = schema.required,
              required else {
            return true
        }
        
        // Check if there's at least one non-deleted row
        let nonDeletedRows = valueElements.filter { !($0.deleted ?? false) }
        if nonDeletedRows.isEmpty {
            return false
        }
        return true
    }
        
    func sortRowsIfNeeded() {
        guard tableDataModel.sortModel.order != .none else { return }
        guard tableDataModel.sortModel.colID != "" else { return }
        guard tableDataModel.sortModel.schemaKey != "" else { return }
        
        let columns = tableDataModel.filterTableColumns(key: tableDataModel.sortModel.schemaKey)
        guard let colIndex = columns.firstIndex(where: { $0.id == tableDataModel.sortModel.colID }) else { return }

        tableDataModel.filteredcellModels = tableDataModel.filteredcellModels.sorted { row1, row2 in
            
            let sameParent = row1.rowType.parentID?.rowID == row2.rowType.parentID?.rowID
            let sameSchema = row1.rowType.parentSchemaKey == row2.rowType.parentSchemaKey
            if sameParent && sameSchema {
                guard row1.cells.indices.contains(colIndex), row2.cells.indices.contains(colIndex) else {
                    return false
                }
                let cell1 = row1.cells[colIndex].data
                let cell2 = row2.cells[colIndex].data

                // Only compare if types match
                guard cell1.type == cell2.type else {
                    return false
                }

                switch cell1.type {
                case .text:
                    switch tableDataModel.sortModel.order {
                    case .ascending:
                        return (cell1.title ?? "") < (cell2.title ?? "")
                    case .descending:
                        return (cell1.title ?? "") > (cell2.title ?? "")
                    case .none:
                        return true
                    }
                case .dropdown:
                    switch tableDataModel.sortModel.order {
                    case .ascending:
                        return (cell1.selectedOptionText ?? "") < (cell2.selectedOptionText ?? "")
                    case .descending:
                        return (cell1.selectedOptionText ?? "") > (cell2.selectedOptionText ?? "")
                    case .none:
                        return true
                    }
                case .number:
                    switch tableDataModel.sortModel.order {
                    case .ascending:
                        return (cell1.number ?? 0) < (cell2.number ?? 0)
                    case .descending:
                        return (cell1.number ?? 0) > (cell2.number ?? 0)
                    case .none:
                        return true
                    }
                case .barcode:
                    switch tableDataModel.sortModel.order {
                    case .ascending:
                        return (cell1.title ?? "") < (cell2.title ?? "")
                    case .descending:
                        return (cell1.title ?? "") > (cell2.title ?? "")
                    case .none:
                        return true
                    }
                default:
                    return false
                }
            } else {
                return false
            }
        }
    }
        
    private func isRequiredColumnsValid(schemaID: String, valueElements: [ValueElement]) -> Bool {
        let validColumns = tableDataModel.filterTableColumns(key: schemaID)
        let requiredColumns = validColumns.filter({ $0.required == true })

        for requiredColumn in requiredColumns {
            let columnID = requiredColumn.id ?? ""
            let allRowsHaveValue = valueElements.allSatisfy { valueElement in
                if let cell = valueElement.cells?[columnID] {
                    switch requiredColumn.type {
                    case .text, .dropdown, .barcode, .signature, .block:
                        return !(cell.text?.isEmpty ?? true)
                    case .number:
                        return cell.number != nil
                    case .date:
                        return cell.number != nil
                    case .multiSelect:
                        return !(cell.stringArray?.isEmpty ?? true)
                    case .image:
                        return !(cell.valueElements?.isEmpty ?? true)
                    default:
                        return false
                    }
                }
                return false
            }

            if !allRowsHaveValue {
                return false
            }
        }

        return true
    }
    
    func buildRowToValueElementMap() {
        rowToValueElementMap.removeAll()
        rowToValueElementMap = getBuildRowToValueElementMap(tableDataModel: tableDataModel)
    }
    
    func getBuildRowToValueElementMap(tableDataModel: TableDataModel) -> [String: ValueElement] {
        var rowToValueElementMap: [String: ValueElement] = [:]
        let valueElements = tableDataModel.valueToValueElements ?? []
        for element in valueElements {
            populateRowMap(from: element, rowToValueElementMap: &rowToValueElementMap)
        }
        return rowToValueElementMap
    }

    private func populateRowMap(from element: ValueElement, rowToValueElementMap: inout [String: ValueElement]) {
        if let id = element.id {
            rowToValueElementMap[id] = element
        }
        if let childrens = element.childrens {
            for childGroup in childrens.values {
                for child in childGroup.valueToValueElements ?? [] {
                    populateRowMap(from: child, rowToValueElementMap: &rowToValueElementMap)
                }
            }
        }
    }
    
    func isRowValid(for rowID: String, parentSchemaID: String) -> Bool {
        var childsvalidities: [Bool] = []
        let schema = tableDataModel.schema[parentSchemaID]
        //check the all required columns are filled
        if let valueElement = rowToValueElementMap[rowID] {
            if !isRequiredColumnsValid(schemaID: parentSchemaID, valueElements: [valueElement]) {
                return false
            }
        }
        
        // Check required columns have at least one value across non-deleted rows
        for id in schema?.children ?? [] {
            let childSchema = tableDataModel.schema[id]
            var valueElements = tableDataModel.valueToValueElements ?? []
            let schemaID = id
            //IF a child is hiiden its valid
            let shouldShow = shouldShowSchema(rowID: rowID, schemaID: schemaID)
            if !shouldShow {
                childsvalidities.append(true)
                continue
            }
            let children = rowToValueElementMap[rowID]?.childrens ?? [:]
            let childValueElements = children[schemaID]?.valueToValueElements ?? []
            if isOnlySchemaValid(schemaID: schemaID, valueElements: childValueElements ?? []) {
                //IF schema is valid then we need to check its nested rows is valid or not
                let nonDeletedRows = childValueElements.filter { !($0.deleted ?? false) } ?? []
                for row in nonDeletedRows {
                    if !isRowValid(for: row.id ?? "", parentSchemaID: schemaID) {
                        childsvalidities.append(false)
                    }
                }
            } else {
                //IF schema id not valid means parent row is invalid just return(It doesnt have any row)
                return false
            }
        }
        return childsvalidities.allSatisfy{ $0 }
    }
    
    func shouldShowSchema(rowID: String, schemaID: String) -> Bool {
        let rowSchemaID = RowSchemaID(rowID: rowID, schemaID: schemaID)
        if let shouldShow = tableDataModel.documentEditor?.shouldShowSchema(for: tableDataModel.fieldIdentifier.fieldID, rowSchemaID: rowSchemaID) {
            return shouldShow
        }
        return true
    }
    
    func rowWidth(_ tableColumns: [FieldTableColumn], _ level: Int) -> CGFloat {
        return Utility.getWidthForExpanderRow(columns: tableColumns, showSelector: showRowSelector) + Utility.getTotalTableScrollWidth(level: level)
    }
    
    func getCollectionWidth(tableDataModel: TableDataModel) -> CGFloat {
        return tableDataModel.filteredcellModels
            .map { $0.rowWidth }
            .max() ?? 0
    }
    
    func updateCollectionWidth() {
        collectionWidth = getCollectionWidth(tableDataModel: tableDataModel)
    }
    
    func addNestedCellModel(rowID: String, index: Int, valueElement: ValueElement, columns: [FieldTableColumn], level: Int, childrens: [String : Children] = [:], rowType: RowType, schemaKey: String) {
        var rowCellModels = [TableCellModel]()
        let rowDataModels = tableDataModel.buildAllCellsForNestedRow(tableColumns: columns, valueElement, schemaKey: schemaKey)
            for rowDataModel in rowDataModels {
                
                let cellModel = TableCellModel(rowID: rowID,
                                               timezoneId: valueElement.tz,
                                               data: rowDataModel,
                                               documentEditor: tableDataModel.documentEditor,
                                               fieldIdentifier: tableDataModel.fieldIdentifier,
                                               viewMode: .modalView,
                                               editMode: tableDataModel.mode) { cellDataModel in
                    let columnIndex = columns.firstIndex(where: { column in
                        column.id == cellDataModel.id
                    })
                    self.cellDidChange(rowId: rowID, colIndex: columnIndex ?? 0, cellDataModel: cellDataModel, isNestedCell: true)
                }
                rowCellModels.append(cellModel)
            }
        if self.tableDataModel.filteredcellModels.count > (index - 1) {
            let rowDataModel = RowDataModel(rowID: rowID,
                                            cells: rowCellModels,
                                            rowType: rowType,
                                            childrens: childrens, rowWidth: rowWidth(columns, level))
            
            self.tableDataModel.filteredcellModels.insert(rowDataModel, at: index)
        } else {
            self.tableDataModel.filteredcellModels.append(RowDataModel(rowID: rowID,
                                                               cells: rowCellModels,
                                                               rowType: rowType,
                                                               childrens: childrens,
                                                               rowWidth: rowWidth(columns, level)))
        }
        tableDataModel.documentEditor?.updateSchemaVisibilityOnNewRow(collectionFieldID: tableDataModel.fieldIdentifier.fieldID, rowID: rowID, valueElement: rowToValueElementMap[rowID])
        updateCollectionWidth()
    }
    
    func getProgress(rowId: String) -> (Int, Int) {
        guard let rowCells = tableDataModel.filteredcellModels
            .first(where: { $0.rowID == rowId })?.cells else {
            return (0,0)
        }
        
        let filledCount = rowCells.filter { cellModel in
            requiredColumnIds.contains(cellModel.data.id) && cellModel.data.isCellFilled
        }.count
        
        return (filledCount, requiredColumnIds.count)
    }
    
    func isColumnFilled(columnId: String) -> Bool {
        for rowDataModel in tableDataModel.filteredcellModels {
            if let cellDataModel = rowDataModel.cells.first(where: { $0.data.id == columnId }) {
                if !cellDataModel.data.isCellFilled {
                    return false
                }
            }
        }
        return true
    }
    
    func setupCellModels() {
        tableDataModel.filteredcellModels = getCellModels(tableDataModel: tableDataModel)
    }
    
    func getCellModels(tableDataModel: TableDataModel) -> [RowDataModel] {
        var cellModels = [RowDataModel]()
        let rowDataMap = setupRows()
        let rowToChildrenMap = setupRowsChildrens()
        tableDataModel.valueToValueElements?.forEach { valueElement in
            if valueElement.deleted ?? false { return }
            guard let rowID = valueElement.id else {
                Log("Could not find rowID for valueElement", type: .error)
                return
            }
            var rowCellModels = [TableCellModel]()
            let childrens = rowToChildrenMap[rowID] ?? [:]
            tableDataModel.tableColumns.enumerated().forEach { colIndex, column in
                let columnModel = rowDataMap[rowID]?[colIndex]
                if let columnModel = columnModel {
                    
                    let cellModel = TableCellModel(rowID: rowID,
                                                   timezoneId: valueElement.tz,
                                                   data: columnModel,
                                                   documentEditor: tableDataModel.documentEditor,
                                                   fieldIdentifier: tableDataModel.fieldIdentifier,
                                                   viewMode: .modalView,
                                                   editMode: tableDataModel.mode) { cellDataModel in
                        self.cellDidChange(rowId: rowID, colIndex: colIndex, cellDataModel: cellDataModel, isNestedCell: false)
                    }
                    rowCellModels.append(cellModel)
                }
            }
            cellModels.append(RowDataModel(rowID: rowID, cells: rowCellModels, rowType: .row(index: cellModels.count + 1), childrens: childrens, rowWidth: rowWidth(tableDataModel.tableColumns, 0)))
        }
        return cellModels
    }
    
    @MainActor
    func setupAllCellModels(targetSchema: String) async {
        isSearching = true
        tableDataModel.emptySelection()
        tableDataModel.filteredcellModels = []
        
        let cellModels: [RowDataModel] = await withCheckedContinuation { cont in
            dispatchQueue.async { [tableDataModel, rootSchemaKey] in
                var result = [RowDataModel]()
                let rowDataMap = self.setupRows()
                let rowToChildrenMap = self.setupRowsChildrens()
                
                let rootRows = tableDataModel.valueToValueElements?.filter { !($0.deleted ?? false) } ?? []
                var displayIndex = 1
                for valueElement in rootRows {
                    guard let rowID = valueElement.id else {
                        Log("Could not find rowID for valueElement", type: .error)
                        continue
                    }
                    var rowCellModels = [TableCellModel]()
                    let childrens = rowToChildrenMap[rowID] ?? [:]
                    tableDataModel.tableColumns.enumerated().forEach { colIndex, column in
                        let columnModel = rowDataMap[rowID]?[colIndex]
                        if let columnModel = columnModel {
                            
                            let cellModel = TableCellModel(rowID: rowID,
                                                           timezoneId: valueElement.tz,
                                                           data: columnModel,
                                                           documentEditor: tableDataModel.documentEditor,
                                                           fieldIdentifier: tableDataModel.fieldIdentifier,
                                                           viewMode: .modalView,
                                                           editMode: tableDataModel.mode) { cellDataModel in
                                self.cellDidChange(rowId: rowID, colIndex: colIndex, cellDataModel: cellDataModel, isNestedCell: false)
                            }
                            rowCellModels.append(cellModel)
                        }
                    }
                    
                    let rootRowModel = RowDataModel(rowID: rowID,
                                                    cells: rowCellModels,
                                                    rowType: .row(index: displayIndex),
                                                    isExpanded: targetSchema != rootSchemaKey ? true : false,
                                                    childrens: childrens,
                                                    rowWidth: self.rowWidth(tableDataModel.tableColumns, 0))
                    if self.shouldShowRowAccToFilters(schemaKey: rootSchemaKey, row: rootRowModel) {
                        result.append(rootRowModel)
                        displayIndex += 1
                        // Add all nested rows for this root row
                        if targetSchema != rootSchemaKey {
                            self.addAllSchemasRecursively(to: &result,
                                                     parentRowID: rowID,
                                                     level: 0,
                                                     parentSchemaKey: rootSchemaKey,
                                                     parentID: ("", rowID),
                                                     targetSchema: targetSchema)
                        }
                    }
                }
                cont.resume(returning: result)
            }
        }
        
        tableDataModel.filteredcellModels = cellModels
        updateCollectionWidth()
        isSearching = false
    }
    
    fileprivate func addAllNestedRowsRecursively(_ childValueElements: [ValueElement], _ filteredTableColumns: [FieldTableColumn], _ childSchemaKey: String, _ level: Int, _ parentID: (columnID: String, rowID: String), _ targetSchema: String, _ cellModels: inout [RowDataModel]) {
        // Add all nested rows for this schema
        let nonDeletedChildRows = childValueElements.filter { !($0.deleted ?? false) }
        var displayIndex = 1
        for childRow in nonDeletedChildRows {
            guard let childRowID = childRow.id else { continue }
            guard let childValueElement = rowToValueElementMap[childRowID] else { continue }
            
            // Build cells for this nested row
            let cellDataModels = tableDataModel.buildAllCellsForNestedRow(tableColumns: filteredTableColumns,
                                                                          childValueElement,
                                                                          schemaKey: childSchemaKey)
            var nestedCells: [TableCellModel] = []
            for cellDataModel in cellDataModels {
                let cellModel = TableCellModel(rowID: childRowID,
                                               timezoneId: childRow.tz,
                                               data: cellDataModel,
                                               documentEditor: tableDataModel.documentEditor,
                                               fieldIdentifier: tableDataModel.fieldIdentifier,
                                               viewMode: .modalView,
                                               editMode: tableDataModel.mode) { cellDataModel in
                    let columnIndex = filteredTableColumns.firstIndex(where: { column in
                        column.id == cellDataModel.id
                    })
                    self.cellDidChange(rowId: childRowID, colIndex: columnIndex ?? 0, cellDataModel: cellDataModel, isNestedCell: true)
                }
                nestedCells.append(cellModel)
            }
            
            // Create the nested row
            let nestedRowModel = RowDataModel(rowID: childRowID,
                                              cells: nestedCells,
                                              rowType: .nestedRow(level: level + 1,
                                                                  index: displayIndex,
                                                                  parentID: parentID,
                                                                  parentSchemaKey: childSchemaKey),
                                              isExpanded: targetSchema != childSchemaKey ? true : false,
                                              childrens: childValueElement.childrens ?? [:],
                                              rowWidth: rowWidth(filteredTableColumns, level + 1))
            if shouldShowRowAccToFilters(schemaKey: childSchemaKey, row: nestedRowModel) {
                cellModels.append(nestedRowModel)
                displayIndex += 1
                // Recursively add nested rows for this child (if it has children)
                if targetSchema != childSchemaKey {
                    addAllSchemasRecursively(to: &cellModels,
                                             parentRowID: childRowID,
                                             level: level + 1,
                                             parentSchemaKey: childSchemaKey,
                                             parentID: ("", childRowID),
                                             targetSchema: targetSchema)
                }
            }
        }
    }
    
    /// Recursively adds all nested rows maintaining the proper hierarchical order
    private func addAllSchemasRecursively(to cellModels: inout [RowDataModel],
                                           parentRowID: String,
                                           level: Int,
                                           parentSchemaKey: String,
                                             parentID: (columnID: String, rowID: String),
                                             targetSchema: String) {
        
        // Get the schema for the parent to find its children
        guard let schema = tableDataModel.schema[parentSchemaKey],
              let childrenKeys = schema.children, !childrenKeys.isEmpty else {
            return
        }
        
        // Get the children data for the parent row
        let parentChildren = rowToValueElementMap[parentRowID]?.childrens ?? [:]
        
        // Process each child schema
        for childSchemaKey in childrenKeys {
            let rowSchemaID = RowSchemaID(rowID: parentRowID, schemaID: childSchemaKey)
            if let shouldShow = tableDataModel.documentEditor?.shouldShowSchema(for: tableDataModel.fieldIdentifier.fieldID, rowSchemaID: rowSchemaID), shouldShow {
                if tableDataModel.shouldShowSchemaAccToFilters(schemaID: childSchemaKey) {
                    guard let childSchema = tableDataModel.schema[childSchemaKey] else {
                        continue
                    }
                    
                    // Add table expander for this schema
                    let expanderRowID = UUID().uuidString
                    let filteredTableColumns = tableDataModel.filterTableColumns(key: childSchemaKey)
                    let expanderRow = RowDataModel(rowID: expanderRowID,
                                                   cells: [],
                                                   rowType: .tableExpander(schemaValue: (childSchemaKey, childSchema),
                                                                           level: level,
                                                                           parentID: parentID,
                                                                           rowWidth: Utility.getWidthForExpanderRow(columns: filteredTableColumns, showSelector: showRowSelector)),
                                                   isExpanded: true, // Mark as expanded since we're showing content
                                                   rowWidth: rowWidth(filteredTableColumns, level))
                    cellModels.append(expanderRow)
                    
                    // Add header row for the nested table
                    let headerRowID = UUID().uuidString
                    let headerRow = RowDataModel(rowID: headerRowID,
                                                 cells: [],
                                                 rowType: .header(level: level + 1, tableColumns: filteredTableColumns),
                                                 rowWidth: rowWidth(filteredTableColumns, level + 1))
                    cellModels.append(headerRow)
                    
                    guard let childValueElements = parentChildren[childSchemaKey]?.valueToValueElements else {
                        continue
                    }
                    
                    addAllNestedRowsRecursively(childValueElements, filteredTableColumns, childSchemaKey, level, parentID, targetSchema, &cellModels)
                }
            }
        }
    }

    private func setupRows() -> [String: [CellDataModel]] {
        guard let valueElements = tableDataModel.valueToValueElements, !valueElements.isEmpty else {
            return [:]
        }

        let nonDeletedRows = valueElements.filter { !($0.deleted ?? false) }
        let tableColumns = tableDataModel.tableColumns
        var rowToCellMap = [String: [CellDataModel]]()
        for row in nonDeletedRows {
            guard let rowID = row.id else {
                Log("rowID is nil", type: .error)
                continue
            }
            let cellRowModel = tableDataModel.buildAllCellsForNestedRow(tableColumns: tableColumns, row, schemaKey: rootSchemaKey)
            rowToCellMap[rowID] = cellRowModel
        }
        return rowToCellMap
    }
    
    private func setupRowsChildrens() -> [String: [String : Children]] {
        guard let valueElements = tableDataModel.valueToValueElements, !valueElements.isEmpty else {
            return [:]
        }

        let nonDeletedRows = valueElements.filter { !($0.deleted ?? false) }
        var rowToChildrenMap = [String: [String : Children]]()
        for row in nonDeletedRows {
            guard let rowID = row.id else {
                Log("rowID is nil", type: .error)
                continue
            }
            rowToChildrenMap[rowID] = row.childrens
        }
        return rowToChildrenMap
    }

    var rowTitle: String {
        "\(tableDataModel.selectedRows.count) " + (tableDataModel.selectedRows.count > 1 ? "rows": "row")
    }
        
    fileprivate func collapseATable(_ index: Int, _ rowDataModel: RowDataModel) {
        // Close all the nested rows for a particular row
        var indicesToRemoveArray: [Int] = tableDataModel.childrensForASpecificRow(index, rowDataModel)
        
        var rowIDsToRemove: Set<String> = []
        for i in indicesToRemoveArray {
            rowIDsToRemove.insert(tableDataModel.filteredcellModels[i].rowID)
        }

        for i in indicesToRemoveArray.reversed() {
//            tableDataModel.filteredcellModels.remove(at: i)
            tableDataModel.filteredcellModels.remove(at: i)
        }
        //Remove selections for the rows that are removed(Closed) from the table.
        tableDataModel.selectedRows.removeAll(where: { rowIDsToRemove.contains($0) })
    }
    
    func expendSpecificTable(rowDataModel: RowDataModel, parentID: (columnID: String, rowID: String), level: Int) {
        guard let index = tableDataModel.filteredcellModels.firstIndex(of: rowDataModel) else { return }
        if rowDataModel.isExpanded {
            collapseATable(index, rowDataModel)
        } else {
            var cellModels = [RowDataModel]()
            
            switch rowDataModel.rowType {
            case .tableExpander(schemaValue: let schemaValue, level: let level, parentID: let parentID, _):
                let schemaTableColumns = schemaValue?.1.tableColumns ?? []
                let filteredTableColumns = tableDataModel.filterTableColumns(key: schemaValue?.0 ?? "")
                cellModels.append(RowDataModel(rowID: UUID().uuidString,
                                               cells: [],
                                               rowType: .header(level: level + 1,
                                                                tableColumns: filteredTableColumns),
                                               rowWidth: rowWidth(filteredTableColumns, level + 1)))
                let childrens = rowToValueElementMap[parentID?.rowID ?? ""]?.childrens ?? [:]
                let valueToValueElements = childrens[schemaValue?.0 ?? ""]?.valueToValueElements?.filter { valueElement in
                    !(valueElement.deleted ?? false)
                } ?? []
                
                var displayIndex = 1
                for valueElement in valueToValueElements {
                    guard let row = rowToValueElementMap[valueElement.id ?? ""] else { continue }
                    let cellDataModels = tableDataModel.buildAllCellsForNestedRow(tableColumns: filteredTableColumns, row, schemaKey: schemaValue?.0 ?? "")
                    var subCells: [TableCellModel] = []
                    for cellDataModel in cellDataModels {
                        let cellModel = TableCellModel(rowID: row.id ?? "",
                                                       timezoneId: valueElement.tz,
                                                       data: cellDataModel,
                                                       documentEditor: tableDataModel.documentEditor,
                                                       fieldIdentifier: tableDataModel.fieldIdentifier,
                                                       viewMode: .modalView,
                                                       editMode: tableDataModel.mode) { cellDataModel in
                            let columnIndex = filteredTableColumns.firstIndex(where: { column in
                                column.id == cellDataModel.id
                            })
                            self.cellDidChange(rowId: row.id ?? "", colIndex: columnIndex ?? 0, cellDataModel: cellDataModel, isNestedCell: true)
                        }
                        subCells.append(cellModel)
                    }
                    let newRowDataModel = RowDataModel(rowID: row.id ?? "",
                                                       cells: subCells,
                                                       rowType: .nestedRow(level: level + 1,
                                                                           index: displayIndex,
                                                                           parentID: parentID,
                                                                           parentSchemaKey: schemaValue?.0 ?? ""),
                                                       childrens: row.childrens ?? [:],
                                                       rowWidth: rowWidth(filteredTableColumns, level + 1)
                    )
                    if shouldShowRowAccToFilters(schemaKey: schemaValue?.0 ?? "", row: newRowDataModel) {
                        cellModels.append(newRowDataModel)
                        displayIndex += 1
                   }
                }
            default:
                break
            }
            tableDataModel.filteredcellModels.insert(contentsOf: cellModels, at: index+1)
        }
        updateCollectionWidth()
    }
    
    fileprivate func collapseTables(_ index: Int, _ rowDataModel: RowDataModel, _ level: Int) {
        var indicesToRemove: [Int] = tableDataModel.childrensForRows(index, rowDataModel, level)
           
        var rowIDsToRemove: Set<String> = []
        for i in indicesToRemove {
            rowIDsToRemove.insert(tableDataModel.filteredcellModels[i].rowID)
        }
        
        for i in indicesToRemove.reversed() {
//            tableDataModel.filteredcellModels.remove(at: i)
            tableDataModel.filteredcellModels.remove(at: i)
        }
        //Remove selections for the rows that are removed from the table.
        tableDataModel.selectedRows.removeAll(where: { rowIDsToRemove.contains($0) })
    }
            
    func expandTables(rowDataModel: RowDataModel, level: Int) {
        guard let index = tableDataModel.filteredcellModels.firstIndex(of: rowDataModel) else { return }
        if rowDataModel.isExpanded {
            collapseTables(index, rowDataModel, level)
            tableDataModel.filteredcellModels[index].isExpanded.toggle()
        } else {
            var cellModels = [RowDataModel]()
            let parentSchemaKey = rowDataModel.rowType.isRow ? rootSchemaKey : rowDataModel.rowType.parentSchemaKey
            let parentRowID = rowDataModel.rowType.parentID?.rowID
            let parentCellModel = cellModels.first(where: { $0.rowID == parentRowID })
            let ids = tableDataModel.schema[parentSchemaKey]?.children ?? []
            
            
            for id in ids {
                let rowSchemaID = RowSchemaID(rowID: rowDataModel.rowID, schemaID: id)
                if let shouldShowAccToLogic = tableDataModel.documentEditor?.shouldShowSchema(for: tableDataModel.fieldIdentifier.fieldID, rowSchemaID: rowSchemaID), shouldShowAccToLogic {
                    if tableDataModel.shouldShowSchemaAccToFilters(schemaID: id) {
                        var childrens: [String: Children] = [:]
                        if let children = parentCellModel?.childrens[id] {
                            childrens = [id : children]
                        }
                        
                        let newRowID = UUID().uuidString
                        if let schemaValue = tableDataModel.schema[id] {
                            let schemaTablecolumns = schemaValue.tableColumns ?? []
                            let filteredTableColumns = tableDataModel.filterTableColumns(key: id)
                            var rowDataModel = RowDataModel(rowID: newRowID,
                                                            cells: rowDataModel.cells,
                                                            rowType: .tableExpander(schemaValue: (id, schemaValue),
                                                                                    level: level,
                                                                                    parentID: (columnID: "", rowID: rowDataModel.rowID),
                                                                                    rowWidth: Utility.getWidthForExpanderRow(columns: filteredTableColumns, showSelector: showRowSelector)),
                                                            childrens: childrens,
                                                            rowWidth: rowWidth(filteredTableColumns, level)
                            )
                            rowDataModel.isExpanded = false
                            cellModels.append(rowDataModel)
                            
                        }
                    }
                }
            }
//            tableDataModel.filteredcellModels.insert(contentsOf: cellModels, at: index+1)
            tableDataModel.filteredcellModels.insert(contentsOf: cellModels, at: index+1)
            for cellModel in cellModels {
                expendSpecificTable(rowDataModel: cellModel, parentID: (columnID: "", rowID: cellModel.rowID), level: level)
            }
            tableDataModel.filteredcellModels[index].isExpanded.toggle()
        }
//        tableDataModel.filterCollectionRowsIfNeeded()
        sortRowsIfNeeded()
        updateCollectionWidth()
    }
    
    func deleteSelectedRow() {
        guard let firstSelectedRowID = tableDataModel.selectedRows.first else {
            Log("No row selected", type: .error)
            return
        }
        
        guard let firstSelectedRow = tableDataModel.filteredcellModels.first(where: { $0.rowID == firstSelectedRowID }) else {
            return
        }
        switch firstSelectedRow.rowType {
        case .row(index: let index):
            deleteSelectedNestedRow(parentRowId: "", nestedKey: rootSchemaKey)
        case .nestedRow(level: let level, index: let index, parentID: let parentID, parentSchemaKey: let parentSchemaKey):
            deleteSelectedNestedRow(parentRowId: parentID?.rowID ?? "", nestedKey: parentSchemaKey)
        default:
            return
        }
        
        tableDataModel.emptySelection()
    }
    
    func deleteSelectedNestedRow(rowIDs: [String]? = nil, parentRowId: String, nestedKey: String, shouldSendEvent: Bool = true) {
        let selectedRows = rowIDs ?? tableDataModel.selectedRows
        let valueToValueElements = tableDataModel.documentEditor?.deleteNestedRows(rowIDs: selectedRows,
                                                                                   fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                                   rootSchemaKey: rootSchemaKey,
                                                                                   nestedKey: nestedKey,
                                                                                   parentRowId: parentRowId,
                                                                                   shouldSendEvent: shouldSendEvent)
        self.tableDataModel.valueToValueElements = valueToValueElements
        buildRowToValueElementMap()
        
        var deletedRowLevel: Int?
        var deletedRowSchemaKey: String?
        if let firstSelectedRowID = selectedRows.first,
           let firstSelectedRow = tableDataModel.filteredcellModels.first(where: { $0.rowID == firstSelectedRowID }) {
            deletedRowLevel = firstSelectedRow.rowType.level
            deletedRowSchemaKey = firstSelectedRow.rowType.parentSchemaKey
        }
        
        for rowID in selectedRows {
            if let index = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == rowID }) {
                deleteRow(at: index, rowID: rowID, isNested: true)
            }
        }
        
        if let level = deletedRowLevel, let schemaKey = deletedRowSchemaKey {
            for row in tableDataModel.filteredcellModels {
                if row.rowType.level == level &&
                   row.rowType.parentSchemaKey == schemaKey &&
                   (row.rowType.isRow || row.rowType.isNestedRow) {
                    reIndexingRows(rowDataModel: row)
                    break
                }
            }
        }
    }
    
    fileprivate func getTableColumnsByIndex(_ indexOfFirstSelectedRow: Int) -> [FieldTableColumn] {
        for indexOfCurrentRow in stride(from: indexOfFirstSelectedRow, through: 0, by: -1) {
            switch tableDataModel.filteredcellModels[indexOfCurrentRow].rowType {
            case .header(level: let level, tableColumns: let tableColumns):
                if level == tableDataModel.filteredcellModels[indexOfFirstSelectedRow].rowType.level {
                    return tableColumns
                } else {
                    continue
                }
            default:
                continue
            }
        }
        return []
    }
    
    func duplicateRow() {
        guard let firstSelectedRowID = tableDataModel.selectedRows.first else {
            Log("No row selected", type: .error)
            return
        }
        guard let firstSelectedRow = tableDataModel.filteredcellModels.first(where: { $0.rowID == firstSelectedRowID }) else {
            return
        }
        switch firstSelectedRow.rowType {
        case .row(index: let index):
            duplicateNestedRow(parentID: ("",""), level: 0, isNested: false, tableColumns: tableDataModel.tableColumns, parentSchemaKey: rootSchemaKey)
        case .nestedRow(level: let level, index: let index, parentID: let parentID, parentSchemaKey: let parentSchemaKey):
            let indexOfFirstSelectedRow = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == firstSelectedRowID } ) ?? 0
            var headerTableColumns: [FieldTableColumn] = tableDataModel.schema[parentSchemaKey]?.tableColumns ?? []
            
            duplicateNestedRow(parentID: parentID, level: level, isNested: true, tableColumns: headerTableColumns, parentSchemaKey: parentSchemaKey)
        default:
            return
        }
        
        tableDataModel.emptySelection()
    }
    
    func duplicateNestedRow(parentID: (columnID: String, rowID: String)?, level: Int, isNested: Bool, tableColumns: [FieldTableColumn], parentSchemaKey: String) {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        
        guard let result = tableDataModel.documentEditor?.duplicateNestedRows(selectedRowIds: tableDataModel.selectedRows,
                                                                              fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                              rootSchemaKey: rootSchemaKey,
                                                                              nestedKey: parentSchemaKey,
                                                                              parentRowId: parentID?.rowID ?? "") else { return }
        
        self.tableDataModel.valueToValueElements = result.1
        buildRowToValueElementMap()
        
        let sortedChanges = result.0.sorted { $0.key < $1.key }
        
        let sortedSelectedRows = tableDataModel.selectedRows.sorted { (rowID1, rowID2) in
            guard let index1 = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == rowID1 }),
                  let index2 = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == rowID2 }) else {
                return false
            }
            return index1 < index2
        }
        
        for (offset, change) in sortedChanges.enumerated() {
            let startingIndex = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == sortedSelectedRows[offset] }) ?? 0
            let rowDataModel = tableDataModel.filteredcellModels[startingIndex]
            let atIndex = startingIndex + 1 + tableDataModel.childrensForRows(startingIndex, rowDataModel, rowDataModel.rowType.level).count
            let valueElement = change.value
            let childrens = change.value.childrens ?? [:]
            if isNested {
                addNestedCellModel(rowID: valueElement.id ?? "",
                                   index: atIndex,
                                   valueElement: valueElement,
                                   columns: tableColumns,
                                   level: level,
                                   childrens: childrens,
                                   rowType: .nestedRow(level: level,index: rowDataModel.rowType.index + 1,parentID: parentID, parentSchemaKey: rowDataModel.rowType.parentSchemaKey),
                                   schemaKey: parentSchemaKey)
            } else {
                addNestedCellModel(rowID: valueElement.id ?? "",
                                   index: atIndex,
                                   valueElement: valueElement,
                                   columns: tableColumns,
                                   level: level,
                                   childrens: childrens,
                                   rowType: .row(index: rowDataModel.rowType.index + 1),
                                   schemaKey: parentSchemaKey)
            }
//            tableDataModel.filterCollectionRowsIfNeeded()
            sortRowsIfNeeded()
        }
        
        guard let rowDataModel = tableDataModel.filteredcellModels.first(where: { $0.rowID == sortedSelectedRows[0] }) else {
            Log("Could not find rowDataModel", type: .error)
            return
        }
        reIndexingRows(rowDataModel: rowDataModel)
        tableDataModel.emptySelection()
    }
            
    func reIndexingRows(rowDataModel: RowDataModel) {
        // find upperMost item of this level
        var startingIndex = 0
        guard let currentIndex = tableDataModel.filteredcellModels.firstIndex(of: rowDataModel) else {
            return
        }
        for i in stride(from: currentIndex, through: 0, by: -1) {
            let model = tableDataModel.filteredcellModels[i]
            
            if model.rowType.level < rowDataModel.rowType.level {
                break
            }
            if model.rowType.level > rowDataModel.rowType.level {
                continue
            }
            startingIndex = i
        }
        
        var currentRowIndex = 1
        for i in startingIndex..<tableDataModel.filteredcellModels.count {
            var model = tableDataModel.filteredcellModels[i]
            //Stop if find another level of rows
            if model.rowType.level < rowDataModel.rowType.level {
                break
            }
            if model.rowType.level > rowDataModel.rowType.level {
                continue
            }
            switch model.rowType {
            case .row(index: let rowIndex):
                model.rowType = .row(index: currentRowIndex)
                currentRowIndex += 1
            case .nestedRow(level: let level, index: let index, parentID: let parentID, parentSchemaKey: let parentSchemaKey):
                model.rowType = .nestedRow(level: level, index: currentRowIndex, parentID: parentID, parentSchemaKey: parentSchemaKey)
                currentRowIndex += 1
            default:
                break
            }
            tableDataModel.filteredcellModels[i] = model
        }
//        tableDataModel.filterCollectionRowsIfNeeded()
        sortRowsIfNeeded()
    }
    
    func insertBelow() -> String? {
        guard let firstSelectedRowID = tableDataModel.selectedRows.first else {
            Log("No row selected", type: .error)
            return nil
        }
        
        guard let firstSelectedRow = tableDataModel.filteredcellModels.first(where: { $0.rowID == firstSelectedRowID }) else {
            return nil
        }
        switch firstSelectedRow.rowType {
        case .row(index: let index):
           return insertRowBelow()
        case .nestedRow(level: let level, index: let index, parentID: let parentID, parentSchemaKey: let parentSchemaKey):
           return insertNestedBelow(parentRowID: parentID?.rowID ?? "", nestedKey: parentSchemaKey)
        default:
            return nil
        }
//        tableDataModel.filterCollectionRowsIfNeeded()
        sortRowsIfNeeded()
        tableDataModel.emptySelection()
    }
    
    func insertRowBelow() -> String? {
        let cellValues = getCellValues(columns: tableDataModel.tableColumns)
        guard let result = tableDataModel.documentEditor?.insertBelowNestedRow(selectedRowID: tableDataModel.selectedRows[0],
                                                                               cellValues: cellValues,
                                                                               fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                               childrenKeys: tableDataModel.schema[rootSchemaKey]?.children,
                                                                               rootSchemaKey: rootSchemaKey,
                                                                               nestedKey: rootSchemaKey,
                                                                               parentRowId: "") else { return nil }
        let valueElement = result.inserted
        self.tableDataModel.valueToValueElements = result.all
        buildRowToValueElementMap()
        //updateCellModels
        guard let selecteRowIndex = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == tableDataModel.selectedRows[0] }) else {
            return nil
        }
        let selectedRow = tableDataModel.filteredcellModels[selecteRowIndex]
        let placeAtIndex = selecteRowIndex + tableDataModel.childrensForRows(selecteRowIndex, selectedRow, selectedRow.rowType.level).count + 1
        guard let newRowID = valueElement.id else {
            return nil
        }
        addNestedCellModel(rowID: newRowID,
                           index: placeAtIndex,
                           valueElement: valueElement,
                           columns: tableDataModel.tableColumns,
                           level: selectedRow.rowType.level,
                           childrens: getChildrensBy(rootSchemaKey),
                           rowType: .row(index: selecteRowIndex + 1),
                           schemaKey: rootSchemaKey)
        
        reIndexingRows(rowDataModel: tableDataModel.filteredcellModels[selecteRowIndex])
        return newRowID
    }
    
    func insertNestedBelow(parentRowID: String, nestedKey: String) -> String? {
        guard let selecteRowIndex = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == tableDataModel.selectedRows[0] }) else {
            return nil
        }
        
        let tableColumns: [FieldTableColumn] = tableDataModel.schema[nestedKey]?.tableColumns ?? []
        let cellValues = getCellValues(columns: tableColumns)
        let selectedRow = tableDataModel.filteredcellModels[selecteRowIndex]
        
        guard let rowData = tableDataModel.documentEditor?.insertBelowNestedRow(selectedRowID: tableDataModel.selectedRows[0],
                                                                                cellValues: cellValues,
                                                                                fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                                childrenKeys: tableDataModel.schema[selectedRow.rowType.parentSchemaKey]?.children,
                                                                                rootSchemaKey: rootSchemaKey,
                                                                                nestedKey: nestedKey,
                                                                                parentRowId: parentRowID) else { return nil }
        self.tableDataModel.valueToValueElements = rowData.all
        buildRowToValueElementMap()
                
        let placeAtIndex = selecteRowIndex + tableDataModel.childrensForRows(selecteRowIndex, selectedRow, selectedRow.rowType.level).count + 1
        
        guard let newRowID = rowData.inserted.id else {
            Log("Could not insert nested row", type: .error)
            return nil
        }
        addNestedCellModel(rowID: newRowID,
                           index: placeAtIndex,
                           valueElement: rowData.inserted,
                           columns: tableColumns,
                           level: selectedRow.rowType.level,
                           childrens: getChildrensBy(selectedRow.rowType.parentSchemaKey),
                           rowType: .nestedRow(level: selectedRow.rowType.level,
                                               index: selecteRowIndex + 1,
                                               parentID: selectedRow.rowType.parentID, parentSchemaKey: selectedRow.rowType.parentSchemaKey),
                           schemaKey: nestedKey)
        
        reIndexingRows(rowDataModel: tableDataModel.filteredcellModels[selecteRowIndex])
        return newRowID
    }

    func moveUP(rowIDs: [String]? = nil, shouldSendEvent: Bool = true) {
        let selectedRows = rowIDs ?? tableDataModel.selectedRows
        guard let firstSelectedRowID = selectedRows.first else {
            Log("No row selected", type: .error)
            return
        }
        
        guard let firstSelectedRow = tableDataModel.filteredcellModels.first(where: { $0.rowID == firstSelectedRowID }) else {
            return
        }
        switch firstSelectedRow.rowType {
        case .row(index: let index):
            moveNestedUP(rowIDs: selectedRows, parentRowId: "", nestedKey: rootSchemaKey, isNested: false, shouldSendEvent: shouldSendEvent)
        case .nestedRow(level: let level, index: let index, parentID: let parentID, parentSchemaKey: let parentSchemaKey):
            moveNestedUP(rowIDs: selectedRows, parentRowId: parentID?.rowID ?? "", nestedKey: parentSchemaKey, isNested: true, shouldSendEvent: shouldSendEvent)
        default:
            return
        }
        reIndexingRows(rowDataModel: firstSelectedRow)
    }
    
    func moveNestedUP(rowIDs: [String]? = nil, parentRowId: String, nestedKey: String, isNested: Bool, shouldSendEvent: Bool = true) {
        let selectedRows = rowIDs ?? tableDataModel.selectedRows
        guard let firstSelectedRowID = selectedRows.first else {
            Log("No row selected", type: .error)
            return
        }
        self.tableDataModel.valueToValueElements = tableDataModel.documentEditor?.moveNestedRowUp(rowID: firstSelectedRowID,
                                                                                                  fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                                                  rootSchemaKey: rootSchemaKey,
                                                                                                  nestedKey: nestedKey,
                                                                                                  parentRowId: parentRowId,
                                                                                                  shouldSendEvent: shouldSendEvent)
        buildRowToValueElementMap()
        guard let lastRowIndex = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == firstSelectedRowID }) else {
            Log("Could not find the row", type: .error)
            return
        }
        moveNestedUP(at: lastRowIndex, rowID: firstSelectedRowID, isNested: isNested)
    }

    func moveDown(rowIDs: [String]? = nil, shouldSendEvent: Bool = true) {
        let selectedRows = rowIDs ?? tableDataModel.selectedRows
        guard let firstSelectedRowID = selectedRows.first else {
            Log("No row selected", type: .error)
            return
        }
        
        guard let firstSelectedRow = tableDataModel.filteredcellModels.first(where: { $0.rowID == firstSelectedRowID }) else {
            return
        }
        switch firstSelectedRow.rowType {
        case .row(index: let index):
            moveNestedDown(rowIDs: selectedRows, parentRowId: "", nestedKey: rootSchemaKey, shouldSendEvent: shouldSendEvent)
        case .nestedRow(level: let level, index: let index, parentID: let parentID, parentSchemaKey: let parentSchemaKey):
            moveNestedDown(rowIDs: selectedRows, parentRowId: parentID?.rowID ?? "", nestedKey: parentSchemaKey, shouldSendEvent: shouldSendEvent)
        default:
            return
        }
        reIndexingRows(rowDataModel: firstSelectedRow)
    }
    
    func moveNestedDown(rowIDs: [String]? = nil, parentRowId: String, nestedKey: String, shouldSendEvent: Bool = true) {
        let selectedRows = rowIDs ?? tableDataModel.selectedRows

        guard let firstSelectedRowID = selectedRows.first else {
            Log("No row selected", type: .error)
            return
        }
        self.tableDataModel.valueToValueElements = tableDataModel.documentEditor?.moveNestedRowDown(rowID: firstSelectedRowID,
                                                                                                    fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                                                    rootSchemaKey: rootSchemaKey,
                                                                                                    nestedKey: nestedKey,
                                                                                                    parentRowId: parentRowId,
                                                                                                    shouldSendEvent: shouldSendEvent)
        buildRowToValueElementMap()
        guard let lastRowIndex = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == firstSelectedRowID }) else {
            Log("Unable to find row with ID: \(firstSelectedRowID)", type: .error)
            return
        }
        moveNestedDown(at: lastRowIndex, rowID: firstSelectedRowID)
    }
    
    fileprivate func deleteRow(at index: Int, rowID: String, isNested: Bool) {
        let currentRow = tableDataModel.filteredcellModels[index]
        if currentRow.isExpanded {
            collapseTables(index, currentRow, currentRow.rowType.level)
        }
        self.tableDataModel.filteredcellModels.remove(at: index)
//        tableDataModel.filterCollectionRowsIfNeeded()
        sortRowsIfNeeded()
    }
    
    func getUpperRowIndex(startingIndex: Int) -> Int {
        var upperRowIndex = 0
        for i in stride(from: startingIndex, through: 0, by: -1) {
            switch tableDataModel.filteredcellModels[i].rowType {
            case .row:
                upperRowIndex = i
                break
            default:
                continue
            }
            break
        }
        return upperRowIndex
    }
    
    func getUpperNestedRowIndex(startingIndex: Int, level: Int) -> Int {
        var upperRowIndex = 0
        for i in stride(from: startingIndex, through: 0, by: -1) {
            switch tableDataModel.filteredcellModels[i].rowType {
            case .nestedRow(level: let nestedLevel, index: let index, parentID: _, _):
                if nestedLevel != level {
                    continue
                } else {
                    upperRowIndex = i
                    break
                }
            default:
                continue
            }
            break
        }
        return upperRowIndex
    }
    
    fileprivate func moveNestedUP(at index: Int, rowID: String, isNested: Bool) {
        let currentRow = tableDataModel.filteredcellModels[index]
        var currentRowIndicesToMove: [Int] = []
        var upperRowIndicesToMove: [Int] = []
        //we need to count the upper row childrens if upper row is aslo expanded
        var upperRowIndex = 0
        
        if isNested {
            upperRowIndex = getUpperNestedRowIndex(startingIndex: index - 1, level: currentRow.rowType.level)
        } else {
            upperRowIndex = getUpperRowIndex(startingIndex: index - 1)
        }
        
        upperRowIndicesToMove = tableDataModel.childrensForRows(upperRowIndex, tableDataModel.filteredcellModels[upperRowIndex], tableDataModel.filteredcellModels[upperRowIndex].rowType.level)
        upperRowIndicesToMove.append(upperRowIndex)
        
        if currentRow.isExpanded {
            currentRowIndicesToMove = tableDataModel.childrensForRows(index, currentRow, currentRow.rowType.level)
            currentRowIndicesToMove.append(index)
            self.tableDataModel.filteredcellModels.moveItems(from: currentRowIndicesToMove.sorted(), to: upperRowIndicesToMove.sorted())
        } else {
            self.tableDataModel.filteredcellModels.moveItems(from: [index], to: upperRowIndicesToMove.sorted())
        }
//        tableDataModel.filterCollectionRowsIfNeeded()
        sortRowsIfNeeded()
    }
    
    fileprivate func moveNestedDown(at index: Int, rowID: String) {
        let currentRow = tableDataModel.filteredcellModels[index]
        var currentRowIndicesToMove: [Int] = []
        var lowerRowIndicesToMove: [Int] = []
        
        currentRowIndicesToMove = tableDataModel.childrensForRows(index, currentRow, currentRow.rowType.level)
        currentRowIndicesToMove.append(index)
        
        let lowerRow = tableDataModel.filteredcellModels[index + currentRowIndicesToMove.count]
        lowerRowIndicesToMove = tableDataModel.childrensForRows(index + currentRowIndicesToMove.count, lowerRow, lowerRow.rowType.level)
        lowerRowIndicesToMove.append(index + currentRowIndicesToMove.count)
        
        if currentRow.isExpanded {
            self.tableDataModel.filteredcellModels.moveItems(from: lowerRowIndicesToMove.sorted(), to: currentRowIndicesToMove.sorted())
        } else {
            self.tableDataModel.filteredcellModels.moveItems(from: lowerRowIndicesToMove.sorted(), to: [index])
        }
//        tableDataModel.filterCollectionRowsIfNeeded()
        sortRowsIfNeeded()
    }

    fileprivate func getChildrensBy(_ schemaKey: String) -> [String : Children] {
        var childrens: [String : Children] = [:]
        if let childrenKeys = tableDataModel.schema[schemaKey]?.children, !childrenKeys.isEmpty {
            for childrenKey in childrenKeys {
                childrens[childrenKey] = Children(dictionary: [:])
            }
        }
        return childrens
    }
    
    func addRow(with rowID: String? = nil, and cellValues: [String: ValueUnion]? = nil, shouldSendEvent: Bool = true) {
        let id = rowID ?? generateObjectId()
        let cellValues = cellValues ?? getCellValues(columns: tableDataModel.tableColumns)
        
        if let rowData = tableDataModel.documentEditor?.insertRowWithFilter(id: id,
                                                                            cellValues: cellValues,
                                                                            fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                            schemaKey: rootSchemaKey,
                                                                            childrenKeys: tableDataModel.schema[rootSchemaKey]?.children,
                                                                            rootSchemaKey: rootSchemaKey,
                                                                            shouldSendEvent: shouldSendEvent) {
            let index = tableDataModel.filteredcellModels.count
            tableDataModel.valueToValueElements = rowData.all
            buildRowToValueElementMap()
            let valueElement = rowData.inserted
            guard let newRowID = valueElement.id else {
                Log("Could not find id for new row", type: .error)
                return
            }
            let rowIndex = tableDataModel.filteredcellModels.filter({$0.rowType.isRow}).count + 1
            addNestedCellModel(rowID: newRowID,
                               index: index,
                               valueElement: valueElement,
                               columns: tableDataModel.tableColumns,
                               level: 0,
                               childrens: getChildrensBy(rootSchemaKey),
                               rowType: .row(index: rowIndex),
                               schemaKey: rootSchemaKey)
//            self.tableDataModel.filterCollectionRowsIfNeeded()
            sortRowsIfNeeded()
        }
    }
    
    func addRowWithIndex(with rowID: String? = nil, and cellValues: [String: ValueUnion]? = nil, shouldSendEvent: Bool = true, index: Int?, nestedKey: String? = nil, parentRowID: String? = nil) {
        let id = rowID ?? generateObjectId()
        let cellValues = cellValues ?? getCellValues(columns: tableDataModel.tableColumns)
        if let rowData = tableDataModel.documentEditor?.insertRowWithFilterWithAnyIndex(id: id,
                                                                             cellValues: cellValues,
                                                                             fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                             parentRowId: parentRowID,
                                                                             schemaKey: nestedKey,
                                                                             childrenKeys: tableDataModel.schema[rootSchemaKey]?.children,
                                                                             rootSchemaKey: rootSchemaKey,
                                                                             index: index) {
            tableDataModel.valueToValueElements = rowData.all
            buildRowToValueElementMap()
            let valueElement = rowData.inserted
            guard let newRowID = valueElement.id else {
                Log("Could not find id for new row", type: .error)
                return
            }
            let rowIndex = tableDataModel.filteredcellModels.filter({$0.rowType.isRow}).count + 1
            if let parentRowID = parentRowID, let nestedKey = nestedKey {
                refreshCollectionSchema(rowID: parentRowID)
            } else {
                let insertAtIndex = calculateIndexForInsertRow(index: index ?? (tableDataModel.valueToValueElements?.count ?? 0))
                addNestedCellModel(rowID: newRowID,
                                   index: insertAtIndex,
                                   valueElement: valueElement,
                                   columns: tableDataModel.tableColumns,
                                   level: 0,
                                   childrens: getChildrensBy(rootSchemaKey),
                                   rowType: .row(index: rowIndex),
                                   schemaKey: rootSchemaKey)
                reIndexingRows(rowDataModel: tableDataModel.filteredcellModels[insertAtIndex])
            }
            sortRowsIfNeeded()
        }
    }
    
    func calculateIndexForInsertRow(index: Int) -> Int {
        var finalUIIndex = index
        var rootRowsCount: Int = 0
        for i in tableDataModel.filteredcellModels.indices {
            let rowDataModel = tableDataModel.filteredcellModels[i]
            if rowDataModel.isExpanded {
                finalUIIndex += tableDataModel.childrensForRows(i, rowDataModel, 0).count
            }
            
            if rowDataModel.rowType.isRow {
                rootRowsCount += 1
            }
            
            if rootRowsCount == index {
                break
            }
        }
        return finalUIIndex
    }
    
    func addNestedRow(schemaKey: String, level: Int, startingIndex: Int, parentID: (columnID: String, rowID: String)) {
        let id = generateObjectId()
        let schemaTableColumns = tableDataModel.schema[schemaKey]?.tableColumns ?? []
        let filteredTableColumns = tableDataModel.filterTableColumns(key: schemaKey)
        let cellValues = getCellValues(columns: filteredTableColumns)
                
        if let rowData = tableDataModel.documentEditor?.insertRowWithFilter(id: id,
                                                                            cellValues: cellValues,
                                                                            fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                            parentRowId: parentID.rowID,
                                                                            schemaKey: schemaKey,
                                                                            childrenKeys: tableDataModel.schema[schemaKey]?.children,
                                                                            rootSchemaKey: rootSchemaKey) {
            //Update valueToValueElements
            self.tableDataModel.valueToValueElements = rowData.all
            buildRowToValueElementMap()
            
            //Index where we append new row in tableDataModel.filteredcellModels
            var atNestedIndex = 0
            let rowDataModel = tableDataModel.filteredcellModels[startingIndex]
            var placeAtIndex: Int = tableDataModel.childrensForASpecificRow(startingIndex, rowDataModel).count
            guard let newRowID = rowData.inserted.id else {
                Log("Could not get new row ID", type: .error)
                return
            }
            addNestedCellModel(rowID: newRowID,
                               index: placeAtIndex + startingIndex + 1,
                               valueElement: rowData.inserted,
                               columns: filteredTableColumns,
                               level: level + 1,
                               childrens: getChildrensBy(schemaKey),
                               rowType: .nestedRow(level: level + 1,
                                                   index: 1,
                                                   parentID: parentID,
                                                   parentSchemaKey: schemaKey),
                               schemaKey: schemaKey)
            
            let rowDataModelForIndexing = tableDataModel.filteredcellModels[startingIndex + 2]
            reIndexingRows(rowDataModel: rowDataModelForIndexing)
//            self.tableDataModel.filterCollectionRowsIfNeeded()
            sortRowsIfNeeded()
        }
    }
    
    func getCellValues(columns: [FieldTableColumn]) -> [String: ValueUnion] {
        var cellValues: [String: ValueUnion] = [:]
        
        for filterModel in tableDataModel.filterModels {
            let change = filterModel.filterText
            let columnId = filterModel.colID ?? ""
            
            if change.isEmpty {
                // No filter Applied, Extract default value if present
                if let defaultValue = columns.first(where: { $0.id == columnId })?.value {
                    cellValues[columnId] = defaultValue
                }
            } else {
                // Filter Applied based on column type
                switch filterModel.type {
                case .text:
                    cellValues[columnId] = ValueUnion.string(change)
                case .dropdown:
                    cellValues[columnId] = ValueUnion.string(change)
                case .number:
                    if let doubleChange = Double(change) {
                        cellValues[columnId] = ValueUnion.double(doubleChange)
                    } else {
                        cellValues[columnId] = ValueUnion.null
                    }
                case .multiSelect:
                    cellValues[columnId] = ValueUnion.array([change])
                case .barcode:
                    cellValues[columnId] = ValueUnion.string(change)
                case .signature:
                    cellValues[columnId] = ValueUnion.string(change)
                default:
                    break
                }
            }
        }
        return cellValues
    }

    func cellDidChange(rowId: String, colIndex: Int, cellDataModel: CellDataModel, isNestedCell: Bool, callOnChange: Bool = true) {
//        tableDataModel.updateCellModelForNested(rowId: rowId, colIndex: colIndex, cellDataModel: cellDataModel, isBulkEdit: false)
        
        let currentRowModel = tableDataModel.filteredcellModels.first(where: { $0.rowID == rowId })
        let nestedKey = currentRowModel?.rowType.parentSchemaKey == "" ? rootSchemaKey : currentRowModel?.rowType.parentSchemaKey ?? rootSchemaKey
        let result = tableDataModel.documentEditor?.nestedCellDidChange(rowId: rowId,
                                                                  cellDataModel: cellDataModel,
                                                                  fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                  rootSchemaKey: rootSchemaKey,
                                                                        nestedKey: nestedKey,
                                                                        parentRowId: currentRowModel?.rowType.parentID?.rowID ?? "",
                                                                        callOnChange: callOnChange) ?? ([], nil)
        self.tableDataModel.valueToValueElements = result.0
        if let valueElement = result.1 {
            self.rowToValueElementMap[rowId] = valueElement
        }
        
        tableDataModel.documentEditor?.updateSchemaVisibilityOnCellChange(collectionFieldID: tableDataModel.fieldIdentifier.fieldID, columnID: cellDataModel.id, rowID: rowId, valueElement: rowToValueElementMap[rowId])
        if let shouldRefreshSchema = tableDataModel.documentEditor?.shouldRefreshSchema(for: tableDataModel.fieldIdentifier.fieldID, columnID: cellDataModel.id), shouldRefreshSchema {
            refreshCollectionSchema(rowID: rowId)
        }
    }
    
    func refreshCollectionSchema(rowID: String) {
        //Close and open the nested table to refresh
        guard let index = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == rowID }) else {
            return
        }
        
        var rowDataModel = tableDataModel.filteredcellModels[index]
        
        if rowDataModel.isExpanded {
            expandTables(rowDataModel: rowDataModel, level: rowDataModel.rowType.level ?? 0)
            rowDataModel.isExpanded = false
            expandTables(rowDataModel: rowDataModel, level: rowDataModel.rowType.level ?? 0)
            rowDataModel.isExpanded = true
            
            tableDataModel.filteredcellModels[index] = rowDataModel
        }
//        tableDataModel.filterCollectionRowsIfNeeded()
        sortRowsIfNeeded()
    }
    
    @MainActor
    fileprivate func updateJSON(_ columnIDChanges: [String: [String : ValueUnion]]) async {
        var parentRowID = ""
        var nestedSchemaKey = ""
        
        if let firstSelectedRowID = tableDataModel.selectedRows.first {
            let rowIndex = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == firstSelectedRowID }) ?? 0
            let rowDataModel = tableDataModel.filteredcellModels[rowIndex]
            
            parentRowID = rowDataModel.rowType.parentID?.rowID ?? ""
            nestedSchemaKey = rowDataModel.rowType.parentSchemaKey == "" ? rootSchemaKey : rowDataModel.rowType.parentSchemaKey ?? rootSchemaKey
        }
        
        // Await the async operation - main thread waits but stays free for UI
        let result = await tableDataModel.documentEditor?.bulkEditForNested(changes: columnIDChanges,
                                                                            selectedRows: tableDataModel.selectedRows,
                                                                            fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                            parentRowId: parentRowID,
                                                                            nestedKey: nestedSchemaKey,
                                                                            rootSchemaKey: rootSchemaKey)
        // Update UI - already on MainActor
        tableDataModel.valueToValueElements = result?.0
        for (key, value) in result?.1 ?? [:] {
            rowToValueElementMap[key] = value
        }
    }
    
    fileprivate func makeChangeDict(_ newChanges: inout [String : [String : ValueUnion]], _ columnIDChanges: [String : ValueUnion], _ tableColumns: [FieldTableColumn]) {
        for rowId in tableDataModel.selectedRows {
            let rowIndex = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == rowId }) ?? 0
            var rowDataModel = tableDataModel.filteredcellModels[rowIndex]
            var perRowChanges: [String: ValueUnion] = newChanges[rowId] ?? [:]
            for (key,value) in columnIDChanges {
                if let column = tableColumns.first(where: { $0.id == key }) {
                    if column.type == .date && tableDataModel.selectedRows.count > 1 {
                        let sourceTimeZone = TimeZone.current
                        let targetTimeZone = TimeZone(identifier: rowDataModel.cells.first?.timezoneId ?? TimeZone.current.identifier) ?? .current
                        if let epochMillis = value.number {
                            let format = DateFormatType(rawValue: column.format ?? "")
                            let converted = Utility.convertEpochBetweenTimezones(epochMillis: epochMillis,
                                                                         from: sourceTimeZone,
                                                                         to: targetTimeZone,
                                                                         format: format)
                            perRowChanges[key] = ValueUnion.double(converted)
                        }
                    } else {
                        perRowChanges[key] = value
                    }
                }
            }
            if !perRowChanges.isEmpty {
                newChanges[rowId] = perRowChanges
            }
        }
    }
    
    @MainActor
    func bulkEdit(changes: [Int: ValueUnion]) async {
        isBulkLoading = true
        
        let tableColumns = getTableColumnsForSelectedRows()
        var columnIDChanges = [String: ValueUnion]()
        changes.forEach { (colIndex: Int, value: ValueUnion) in
            guard let cellDataModelId = tableColumns[colIndex].id else { return }
            columnIDChanges[cellDataModelId] = value
        }
        
        var newChanges: [String: [String: ValueUnion]] = [:]
        makeChangeDict(&newChanges, columnIDChanges, tableColumns)
        
        await updateJSON(newChanges)

        for rowId in tableDataModel.selectedRows {
            let rowIndex = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == rowId }) ?? 0
            var rowDataModel = tableDataModel.filteredcellModels[rowIndex]
            tableColumns.enumerated().forEach { colIndex, column in
                var cellDataModel = rowDataModel.cells[colIndex].data
                guard let change = newChanges[rowId]?[column.id ?? ""] else { return }
                switch cellDataModel.type {
                case .dropdown:
                    cellDataModel.selectedOptionText =  cellDataModel.options?.filter { $0.id == change.text }.first?.value ?? ""
                    cellDataModel.defaultDropdownSelectedId = change.text
                case .text:
                    cellDataModel.title = change.text ?? ""
                case .date:
                    cellDataModel.date = change.number
                case .number:
                    cellDataModel.number = change.number
                case .multiSelect:
                    cellDataModel.multiSelectValues = change.stringArray
                case .barcode:
                    cellDataModel.title = change.text ?? ""
                case .image:
                    cellDataModel.valueElements = change.valueElements ?? []
                case .signature:
                    cellDataModel.title = change.text ?? ""
                default:
                    break
                }
                rowDataModel.cells[colIndex].data = cellDataModel
                rowDataModel.cells[colIndex].id = UUID()
                                
                tableDataModel.documentEditor?.updateSchemaVisibilityOnCellChange(collectionFieldID: tableDataModel.fieldIdentifier.fieldID, columnID: cellDataModel.id, rowID: rowId, valueElement: rowToValueElementMap[rowId])
                if let shouldRefreshSchema = tableDataModel.documentEditor?.shouldRefreshSchema(for: tableDataModel.fieldIdentifier.fieldID, columnID: cellDataModel.id), shouldRefreshSchema {
                    refreshCollectionSchema(rowID: rowId)
                }
            }
            tableDataModel.filteredcellModels[rowIndex] = rowDataModel
        }
        isBulkLoading = false
        sortRowsIfNeeded()
    }
    
    func sendEventsIfNeeded() {
        if tableDataModel.mode == .fill {
            tableDataModel.documentEditor?.onChange(fieldIdentifier: tableDataModel.fieldIdentifier)
        }
    }
    
    func getFilteredColumns(for schemaKey: String) -> [FieldTableColumn] {
        let tableColumns = tableDataModel.filterTableColumns(key: schemaKey)
        return tableColumns.filter { column in
            switch column.type {
            case .text, .dropdown, .multiSelect, .number, .barcode:
                return true
            default:
                return false
            }
        }
    }
    
    func shouldShowRowAccToFilters(schemaKey: String, row: RowDataModel) -> Bool {
        guard !tableDataModel.filterModels.noFilterApplied else {
            return true
        }
        
        let activeSchema = tableDataModel.getActiveFiltersSchemaID() ?? ""
        
        // If the current schema is the one being filtered, apply the filter directly
        if schemaKey == activeSchema {
            return tableDataModel.rowMatchesFilter(row, filters: tableDataModel.getActiveFilters())
        }

        if let chain = tableDataModel.schemaChainMap[activeSchema],
           let index = chain.firstIndex(of: activeSchema) {
            let rightSide = Array(chain[(index+1)...])
            if rightSide.contains(schemaKey) {
                return true
            }
        }
            
        // Otherwise, check if this schema contains the active schema in its descendant chain
        // and if any of its children rows pass the filter
        if let schemaChain = tableDataModel.schemaChainMap[schemaKey], schemaChain.contains(activeSchema) {
            // Look up children from this row and recursively check them
            for childSchemaKey in schemaChain where childSchemaKey != schemaKey {
                if let childrens = row.childrens[childSchemaKey]?.valueToValueElements {
                    let tableColumns = tableDataModel.filterTableColumns(key: childSchemaKey)
                    for (index, child) in childrens.enumerated() {
                        guard let childRow = rowToValueElementMap[child.id ?? ""] else { continue }
                        let cellDataModels = tableDataModel.buildAllCellsForNestedRow(tableColumns: tableColumns, childRow, schemaKey: childSchemaKey)
                        let cells: [TableCellModel] = cellDataModels.map { cellData in
                            TableCellModel(
                                rowID: child.id ?? UUID().uuidString,
                                timezoneId: child.tz,
                                data: cellData,
                                documentEditor: tableDataModel.documentEditor,
                                fieldIdentifier: tableDataModel.fieldIdentifier,
                                viewMode: .modalView,
                                editMode: tableDataModel.mode,
                                didChange: { _ in }
                            )
                        }
                        let childRowModel = RowDataModel(
                            rowID: child.id ?? UUID().uuidString,
                            cells: cells,
                            rowType: .nestedRow(level: 0, index: index, parentID: row.rowType.parentID, parentSchemaKey: childSchemaKey),
                            childrens: childRow.childrens ?? [:]
                        )
                        if let shouldShow = tableDataModel.documentEditor?.shouldShowSchema(for: tableDataModel.fieldIdentifier.fieldID, rowSchemaID: RowSchemaID(rowID: row.rowID, schemaID: childSchemaKey)), shouldShow {
                            if shouldShowRowAccToFilters(schemaKey: childSchemaKey, row: childRowModel) {
                                return true
                            }
                        }
                    }
                }
            }
            return false
        }

        // If schema is unrelated to the active filtered schema, do not show
        return false
    }
}

extension Array {
    mutating func moveItems(from sourceIndices: [Int], to destinationIndices: [Int]) {
        guard !sourceIndices.isEmpty,
              !destinationIndices.isEmpty,
              sourceIndices.allSatisfy({ 0 <= $0 && $0 < count }) else {
            return
        }

        let sortedSource = sourceIndices.sorted()
        let elements = sortedSource.map { self[$0] }

        for idx in sortedSource.reversed() {
            remove(at: idx)
        }

        let minCount = Swift.min(elements.count, destinationIndices.count)

        for i in 0..<minCount {
            let dest = destinationIndices[i]
            let safeDest = dest < count ? dest : count
            insert(elements[i], at: safeDest)
        }

        if elements.count > destinationIndices.count {

            var insertionIndex = destinationIndices[minCount - 1]
            if insertionIndex >= count { insertionIndex = count - 1 }

            for i in minCount..<elements.count {
                insertionIndex += 1
                if insertionIndex > count { insertionIndex = count }
                insert(elements[i], at: insertionIndex)
            }
        }
    }
}
extension CollectionViewModel {
    /// Merges the change payload into a cached ValueElement, returning the updated row.
    private func mergedRow(from change: Change, existingRow: ValueElement) -> ValueElement {
        var updatedRow = existingRow
        guard let rowDict = change.change?["row"] as? [String: Any],
              let cellsDict = rowDict["cells"] as? [String: Any] else {
            return updatedRow
        }
        for (key, value) in cellsDict {
            updatedRow.cells?[key] = ValueUnion(value: value)
        }
        return updatedRow
    }

    /// Updates UI models for a given ValueElement row.
    private func updateUIModels(for rowID: String, schemaID: String, using row: ValueElement) {
        let columns = tableDataModel.filterTableColumns(key: schemaID)
        let cellDataModels = tableDataModel.buildAllCellsForRow(tableColumns: columns, row)
        for cell in cellDataModels {
            let colIndex = columns.firstIndex(where: { $0.id == cell.id }) ?? 0
            tableDataModel.updateCellModelForNested(
                rowId: rowID,
                colIndex: colIndex,
                cellDataModel: cell,
                isBulkEdit: true
            )
            cellDidChange(
                rowId: rowID,
                colIndex: colIndex,
                cellDataModel: cell,
                isNestedCell: true,
                callOnChange: false
            )
            
        }
    }
    
    func getParenthPath(rowId: String) -> (String, String) {
        let rowDataModel = tableDataModel.filteredcellModels.first { $0.rowID == rowId }
        let parentPath = tableDataModel.documentEditor?.computeParentPath(targetParentId: rowDataModel?.rowType.parentID?.rowID ?? "", nestedKey: rowDataModel?.rowType.parentSchemaKey ?? "", in: [rootSchemaKey : tableDataModel.valueToValueElements ?? []])
        let schemaKey = rowDataModel?.rowType.parentSchemaKey == "" ? rootSchemaKey : rowDataModel?.rowType.parentSchemaKey ?? ""
        return (parentPath ?? "", schemaKey)
    }
}

// MARK: - DocumentEditorDelegate methods
extension CollectionViewModel: DocumentEditorDelegate {
    
    func applyRowEditChanges(change: Change) {
        guard let rowID = change.change?["rowId"] as? String,
              let existingRow = rowToValueElementMap[rowID] else {
            Log("RowID not found or no cached ValueElement", type: .error)
            return
        }
        let associatedSchemaID: String = change.change?["schemaId"] as! String
        // Merge payload into model
        let merged = mergedRow(from: change, existingRow: existingRow)
        rowToValueElementMap[rowID] = merged
        // Update UI based on merged model
        updateUIModels(for: rowID, schemaID: associatedSchemaID == "" ? rootSchemaKey : associatedSchemaID, using: merged)
        uuid = UUID()
    }

    func decodeParentPath(parentPath: String) -> String? {
        let parts = parentPath.split(separator: ".").map(String.init)
        
        guard parts.count >= 2, parts.count % 2 == 0 else {
            return nil
        }
        
        guard let rootIndex = Int(parts[0]) else {
            return nil
        }
        
        guard let rootElements = tableDataModel.valueToValueElements,
              rootIndex >= 0, rootIndex < rootElements.count else {
            return nil
        }
        
        var currentNode: ValueElement? = rootElements[rootIndex]

        for i in stride(from: 1, to: parts.count - 2, by: 2) {
            let schemaId = parts[i]
            guard let childIndex = Int(parts[i + 1]),
                  let childrenBranch = currentNode?.childrens?[schemaId],
                  childIndex >= 0,
                  let nextNode = childrenBranch.valueToValueElements?[childIndex] else {
                return nil
            }
            currentNode = nextNode
        }

        return currentNode?.id
    }
    
    func insertRow(for change: Change) {
        var cellValues: [String: ValueUnion] = [:]
        var newRowDict = change.change?["row"] as? [String : Any] ?? [:]
        let newRow = ValueElement(dictionary: newRowDict)
        cellValues = newRow.cells ?? [:]
        guard let newRowID = newRow.id else { return }
        if let schemaID = change.change?["schemaId"] as? String, schemaID != "", schemaID != rootSchemaKey {
            let parentPath = change.change?["parentPath"] as? String ?? ""
            let parentID = decodeParentPath(parentPath: parentPath)
            
            let targetRowIndex = change.change?["targetRowIndex"] as? Int
            addRowWithIndex(with: newRowID, and: cellValues, shouldSendEvent: false, index: targetRowIndex, nestedKey: schemaID, parentRowID: parentID ?? "")
        } else {
            let targetRowIndex = change.change?["targetRowIndex"] as? Int
            addRowWithIndex(with: newRowID, and: cellValues, shouldSendEvent: false, index: targetRowIndex)
        }
    }

    func deleteRow(for change: Change) {
        guard let rowID = change.change?["rowId"] as? String
        else {
            Log("RowID not found or no cached ValueElement", type: .error)
            return
        }
        deleteSelectedNestedRow(rowIDs: [rowID], parentRowId: "", nestedKey: "", shouldSendEvent: false)
    }
    
    fileprivate func moveNestedRows(_ targetRowIndex: Int, _ rowIndex: inout Int, _ rowID: String, _ schemaID: String, _ parentID: String) {
        if targetRowIndex > rowIndex {
            while targetRowIndex > rowIndex {
                rowIndex += 1
                self.tableDataModel.valueToValueElements = tableDataModel.documentEditor?.moveNestedRowDown(rowID: rowID,
                                                                                                            fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                                                            rootSchemaKey: rootSchemaKey,
                                                                                                            nestedKey: schemaID,
                                                                                                            parentRowId: parentID,
                                                                                                            shouldSendEvent: false)
                buildRowToValueElementMap()
                if let rowDataModel = tableDataModel.filteredcellModels.first(where: { $0.rowID == parentID }) {
                    if rowDataModel.isExpanded {
                        refreshCollectionSchema(rowID: parentID ?? "")
                    }
                }
            }
        } else if targetRowIndex < rowIndex {
            while targetRowIndex < rowIndex {
                rowIndex -= 1
                self.tableDataModel.valueToValueElements = tableDataModel.documentEditor?.moveNestedRowUp(rowID: rowID,
                                                                                                          fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                                                          rootSchemaKey: rootSchemaKey,
                                                                                                          nestedKey: schemaID,
                                                                                                          parentRowId: parentID,
                                                                                                          shouldSendEvent: false)
                buildRowToValueElementMap()
                if let rowDataModel = tableDataModel.filteredcellModels.first(where: { $0.rowID == parentID }) {
                    if rowDataModel.isExpanded {
                        refreshCollectionSchema(rowID: parentID ?? "")
                    }
                }
            }
        }
    }
    
    fileprivate func moveRootRows(_ targetRowIndex: Int, _ rowIndex: inout Int, _ rowID: String) {
        if targetRowIndex > rowIndex {
            while targetRowIndex > rowIndex {
                rowIndex += 1
                moveDown(rowIDs: [rowID], shouldSendEvent: false)
            }
        } else if targetRowIndex < rowIndex {
            while targetRowIndex < rowIndex {
                rowIndex -= 1
                moveUP(rowIDs: [rowID], shouldSendEvent: false)
            }
        }
    }
    
    func moveRow(for change: Change) {
        guard let rowID = change.change?["rowId"] as? String else {
            Log("RowID not found or no cached ValueElement", type: .error)
            return
        }
        
        guard var targetRowIndex = change.change?["targetRowIndex"] as? Int else { return }
        
        let schemaID = change.change?["schemaId"] as? String ?? rootSchemaKey
        let parentPath = change.change?["parentPath"] as? String ?? ""
        let parentID = decodeParentPath(parentPath: parentPath) ?? ""
        
        let targetElement = rowToValueElementMap[parentID]
        var rowIndex: Int?
        if let schemaID = change.change?["schemaId"] as? String, schemaID != "", schemaID != rootSchemaKey {
            rowIndex = targetElement?.childrens?[schemaID]?.valueToValueElements?.firstIndex(where: { $0.id == rowID })
            guard var rowIndex = rowIndex else { return }
            moveNestedRows(targetRowIndex, &rowIndex, rowID, schemaID, parentID)
        } else {
            rowIndex = tableDataModel.valueToValueElements?.firstIndex(where: { $0.id == rowID })
            guard var rowIndex = rowIndex else { return }
            moveRootRows(targetRowIndex, &rowIndex, rowID)
        }
    }
}

protocol TableDataViewModelProtocol {
    var tableDataModel: TableDataModel { get }
    func getParenthPath(rowId: String) -> (String, String)
}
