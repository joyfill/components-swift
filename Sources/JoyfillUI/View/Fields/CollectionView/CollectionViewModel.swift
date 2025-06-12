//
//  File.swift
//  Joyfill
//
//  Created by Vivek on 14/02/25.
//

import Foundation
import SwiftUI
import JoyfillModel

class CollectionViewModel: ObservableObject {
    @Published var tableDataModel: TableDataModel
    
    @Published var shouldShowAddRowButton: Bool = false
    @Published var showRowSelector: Bool = false
    @Published var nestedTableCount: Int = 0
    @Published var collectionWidth: CGFloat = 0.0
    @Published var blockLongestTextMap: [String: String] = [:]
    @Published var cellWidthMap: [String: CGFloat] = [:] // columnID as key and width as value
    private var requiredColumnIds: [String] = []
    var rootSchemaKey: String = ""

    @Published var uuid = UUID()
    
    init(tableDataModel: TableDataModel) {
        self.tableDataModel = tableDataModel
        self.tableDataModel.schema.forEach { key, value in
            if value.root == true {
                self.rootSchemaKey = key
            }
        }
        self.showRowSelector = tableDataModel.mode == .fill
        self.shouldShowAddRowButton = tableDataModel.mode == .fill
        self.nestedTableCount = tableDataModel.childrens.count
        cellWidthMapping()
        setupCellModels()
        updateCollectionWidth()
        self.tableDataModel.filterRowsIfNeeded()
        self.requiredColumnIds = tableDataModel.tableColumns
            .filter { $0.required == true }
            .compactMap { $0.id }
        
    }
        
    func getLongestBlockTextRecursive(columnID: String, valueElements: [ValueElement]) -> String { 
        var longestText = ""
        
        for valueElement in valueElements {
            if let cell = valueElement.cells?.first(where: { $0.key == columnID })?.value,
               let text = cell.text {
                if text.count > longestText.count {
                    longestText = text
                }
            }
            
            if let childrenDict = valueElement.childrens {
                for (_, child) in childrenDict {
                    if let nestedValueElements = child.valueToValueElements {
                        let nestedLongest = getLongestBlockTextRecursive(columnID: columnID, valueElements: nestedValueElements)
                        if nestedLongest.count > longestText.count {
                            longestText = nestedLongest
                        }
                    }
                }
            }
        }
        
        return longestText
    }
    
    func cellWidthMapping() {
        var widthMap = [String: CGFloat]()
        
        for (key, schema) in tableDataModel.schema {
            let tableColumns = tableDataModel.filterTableColumns(key: key)

            for column in tableColumns {
                guard let colID = column.id else { continue }
                var longestTextForWidth = ""
                if column.type == .block {
                    if let rootValueElements = tableDataModel.valueToValueElements {
                        longestTextForWidth = getLongestBlockTextRecursive(columnID: colID, valueElements: rootValueElements)
                    }
                }
               
//                let format = tableDataModel.getDateFormatFromFieldPosition(key: key, columnID: colID)
                let width = Utility.getCellWidth(type: column.type ?? .unknown, format: DateFormatType(rawValue: column.format ?? "") ?? .empty , text: longestTextForWidth)
                cellWidthMap[colID] = width
            }
        }
    }
    
    func updateCellWidthMap(tableColumns: [FieldTableColumn], columnID: String) {
        if let column = tableColumns.first(where: { $0.id == columnID }) {
            var longestTextForWidth = ""
            if let rootValueElements = tableDataModel.valueToValueElements {
                longestTextForWidth = getLongestBlockTextRecursive(columnID: columnID, valueElements: rootValueElements)
            }
            let width = Utility.getCellWidth(type: column.type ?? .unknown, format: DateFormatType(rawValue: column.format ?? "") ?? .empty , text: longestTextForWidth)
            cellWidthMap[columnID] = width
        }
    }
    
    func selectUpperRow() {
        guard let currentRowID = tableDataModel.selectedRows.first,
              let currentIndex = tableDataModel.cellModels.firstIndex(where: { $0.rowID == currentRowID }) else {
            return
        }
        
        let currentRow = tableDataModel.cellModels[currentIndex]
        
        for i in stride(from: currentIndex - 1, through: 0, by: -1) {
            let priviousRow = tableDataModel.cellModels[i]
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
              let currentIndex = tableDataModel.cellModels.firstIndex(where: { $0.rowID == currentRowID }) else {
            return
        }
        
        let currentRow = tableDataModel.cellModels[currentIndex]
        
        for i in (currentIndex + 1)..<tableDataModel.cellModels.count {
            let nextRow = tableDataModel.cellModels[i]
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
        return Array(tableDataModel.cellModels.filter { $0.rowType.isRow }.prefix(3))
    }
    
    func getTableColumnsForSelectedRows() -> [FieldTableColumn] {
        guard let firstSelectedRow = tableDataModel.selectedRows.first else {
            Log("No row selected", type: .error)
            return []
        }
        
        let indexOfFirstSelectedRow = tableDataModel.cellModels.firstIndex(where: { $0.rowID == firstSelectedRow } ) ?? 0
        
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
    
    func isRowValid(for rowID: String, parentSchemaID: String) -> Bool {
        var childsvalidities: [Bool] = []
        let schema = tableDataModel.schema[parentSchemaID]
        //check the all required columns are filled
        if let valueElement = tableDataModel.documentEditor?.getValueElementByRowID(rowID, from: tableDataModel.valueToValueElements ?? []) {
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
            let children = getChildren(forRowId: rowID, in: valueElements) ?? [:]
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
        var longestBlockText = ""
        for column in tableColumns {
            if column.type == .block {
                if let rootValueElements = tableDataModel.valueToValueElements {
                    longestBlockText = getLongestBlockTextRecursive(columnID: column.id ?? "", valueElements: rootValueElements)
                }
            }
        }
        return Utility.getWidthForExpanderRow(columns: tableColumns, showSelector: showRowSelector, text: longestBlockText) + Utility.getTotalTableScrollWidth(level: level)
    }
    
    func updateCollectionWidth() {
        collectionWidth = tableDataModel.cellModels
            .map { $0.rowWidth }
            .max() ?? 0
    }
    
    func addNestedCellModel(rowID: String, index: Int, valueElement: ValueElement, columns: [FieldTableColumn], level: Int, childrens: [String : Children] = [:], rowType: RowType, schemaKey: String) {
        var rowCellModels = [TableCellModel]()
        let rowDataModels = tableDataModel.buildAllCellsForNestedRow(tableColumns: columns, valueElement, schemaKey: schemaKey)
            for rowDataModel in rowDataModels {
                if rowDataModel.type == .block {
                    updateCellWidthMap(tableColumns: columns, columnID: rowDataModel.id)
                }
                
                let cellModel = TableCellModel(rowID: rowID,
                                               data: rowDataModel,
                                               documentEditor: tableDataModel.documentEditor,
                                               fieldIdentifier: tableDataModel.fieldIdentifier,
                                               viewMode: .modalView,
                                               editMode: tableDataModel.mode) { cellDataModel in
                    let columnIndex = columns.firstIndex(where: { column in
                        column.id == cellDataModel.id
                    })
                    self.tableDataModel.valueToValueElements = self.cellDidChange(rowId: rowID, colIndex: columnIndex ?? 0, cellDataModel: cellDataModel, isNestedCell: true)
                }
                rowCellModels.append(cellModel)
            }
        if self.tableDataModel.cellModels.count > (index - 1) {
            let rowDataModel = RowDataModel(rowID: rowID,
                                            cells: rowCellModels,
                                            rowType: rowType,
                                            childrens: childrens, rowWidth: rowWidth(columns, level))
            
            self.tableDataModel.cellModels.insert(rowDataModel, at: index)
        } else {
            self.tableDataModel.cellModels.append(RowDataModel(rowID: rowID,
                                                               cells: rowCellModels,
                                                               rowType: rowType,
                                                               childrens: childrens,
                                                               rowWidth: rowWidth(columns, level)))
        }
        tableDataModel.documentEditor?.updateSchemaVisibilityOnNewRow(collectionFieldID: tableDataModel.fieldIdentifier.fieldID, rowID: rowID)
        updateCollectionWidth()
    }
    
    func getProgress(rowId: String) -> (Int, Int) {
        guard let rowCells = tableDataModel.cellModels
            .first(where: { $0.rowID == rowId })?.cells else {
            return (0,0)
        }
        
        let filledCount = rowCells.filter { cellModel in
            requiredColumnIds.contains(cellModel.data.id) && cellModel.data.isCellFilled
        }.count
        
        return (filledCount, requiredColumnIds.count)
    }
    
    func isColumnFilled(columnId: String) -> Bool {
        for rowDataModel in tableDataModel.cellModels {
            if let cellDataModel = rowDataModel.cells.first(where: { $0.data.id == columnId }) {
                if !cellDataModel.data.isCellFilled {
                    return false
                }
            }
        }
        return true
    }
    
    func setupCellModels() {
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
                                                   data: columnModel,
                                                   documentEditor: tableDataModel.documentEditor,
                                                   fieldIdentifier: tableDataModel.fieldIdentifier,
                                                   viewMode: .modalView,
                                                   editMode: tableDataModel.mode) { cellDataModel in
                        self.tableDataModel.valueToValueElements = self.cellDidChange(rowId: rowID, colIndex: colIndex, cellDataModel: cellDataModel, isNestedCell: false)
                    }
                    rowCellModels.append(cellModel)
                }
            }
            cellModels.append(RowDataModel(rowID: rowID, cells: rowCellModels, rowType: .row(index: cellModels.count + 1), childrens: childrens, rowWidth: rowWidth(tableDataModel.tableColumns, 0)))
        }
        tableDataModel.cellModels = cellModels
        tableDataModel.filteredcellModels = cellModels
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
    
    func getChildren(forRowId rowId: String, in elements: [ValueElement]) -> [String: Children]? {
        for element in elements {
            // If this element matches the rowId, return its children (if any)
            if element.id == rowId {
                return element.childrens
            }
            // Otherwise, if the element has nested children, search them recursively.
            if let childrenDict = element.childrens {
                for (_, child) in childrenDict {
                    if let nestedElements = child.valueToValueElements,
                       let found = getChildren(forRowId: rowId, in: nestedElements) {
                        return found
                    }
                }
            }
        }
        return nil
    }
        
    fileprivate func collapseATable(_ index: Int, _ rowDataModel: RowDataModel) {
        // Close all the nested rows for a particular row
        var indicesToRemoveArray: [Int] = tableDataModel.childrensForASpecificRow(index, rowDataModel)
        
        var rowIDsToRemove: Set<String> = []
        for i in indicesToRemoveArray {
            rowIDsToRemove.insert(tableDataModel.cellModels[i].rowID)
        }

        for i in indicesToRemoveArray.reversed() {
//            tableDataModel.filteredcellModels.remove(at: i)
            tableDataModel.cellModels.remove(at: i)
        }
        //Remove selections for the rows that are removed(Closed) from the table.
        tableDataModel.selectedRows.removeAll(where: { rowIDsToRemove.contains($0) })
    }
    
    func expendSpecificTable(rowDataModel: RowDataModel, parentID: (columnID: String, rowID: String), level: Int) {
        guard let index = tableDataModel.cellModels.firstIndex(of: rowDataModel) else { return }
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
                let childrens = getChildren(forRowId: parentID?.rowID ?? "", in: tableDataModel.valueToValueElements ?? []) ?? [:]
                
                let valueToValueElements = childrens[schemaValue?.0 ?? ""]?.valueToValueElements?.filter { valueElement in
                    !(valueElement.deleted ?? false)
                } ?? []
                
                for (nestedIndex,row) in valueToValueElements.enumerated() {
                    let cellDataModels = tableDataModel.buildAllCellsForNestedRow(tableColumns: filteredTableColumns, row, schemaKey: schemaValue?.0 ?? "")
                    var subCells: [TableCellModel] = []
                    for cellDataModel in cellDataModels {
                        let cellModel = TableCellModel(rowID: row.id ?? "",
                                                       data: cellDataModel,
                                                       documentEditor: tableDataModel.documentEditor,
                                                       fieldIdentifier: tableDataModel.fieldIdentifier,
                                                       viewMode: .modalView,
                                                       editMode: tableDataModel.mode) { cellDataModel in
                            let columnIndex = filteredTableColumns.firstIndex(where: { column in
                                column.id == cellDataModel.id
                            })
                            self.tableDataModel.valueToValueElements = self.cellDidChange(rowId: row.id ?? "", colIndex: columnIndex ?? 0, cellDataModel: cellDataModel, isNestedCell: true)
                            
                        }
                        subCells.append(cellModel)
                    }
                    
                    cellModels.append(RowDataModel(rowID: row.id ?? "",
                                                   cells: subCells,
                                                   rowType: .nestedRow(level: level + 1,
                                                                       index: nestedIndex+1,
                                                                       parentID: parentID,
                                                                       parentSchemaKey: schemaValue?.0 ?? ""),
                                                   childrens: row.childrens ?? [:],
                                                   rowWidth: rowWidth(filteredTableColumns, level + 1)
                                                  ))
                }
            default:
                break
            }
//            tableDataModel.filteredcellModels.insert(contentsOf: cellModels, at: index+1)
            tableDataModel.cellModels.insert(contentsOf: cellModels, at: index+1)
        }
        updateCollectionWidth()
    }
    
    fileprivate func collapseTables(_ index: Int, _ rowDataModel: RowDataModel, _ level: Int) {
        var indicesToRemove: [Int] = tableDataModel.childrensForRows(index, rowDataModel, level)
           
        var rowIDsToRemove: Set<String> = []
        for i in indicesToRemove {
            rowIDsToRemove.insert(tableDataModel.cellModels[i].rowID)
        }
        
        for i in indicesToRemove.reversed() {
//            tableDataModel.filteredcellModels.remove(at: i)
            tableDataModel.cellModels.remove(at: i)
        }
        //Remove selections for the rows that are removed from the table.
        tableDataModel.selectedRows.removeAll(where: { rowIDsToRemove.contains($0) })
    }
            
    func expandTables(rowDataModel: RowDataModel, level: Int) {
        guard let index = tableDataModel.cellModels.firstIndex(of: rowDataModel) else { return }
        if rowDataModel.isExpanded {
            collapseTables(index, rowDataModel, level)
            tableDataModel.cellModels[index].isExpanded.toggle()
        } else {
            var cellModels = [RowDataModel]()
            let parentSchemaKey = rowDataModel.rowType.isRow ? rootSchemaKey : rowDataModel.rowType.parentSchemaKey
            let parentRowID = rowDataModel.rowType.parentID?.rowID
            let parentCellModel = cellModels.first(where: { $0.rowID == parentRowID })
            let ids = tableDataModel.schema[parentSchemaKey]?.children ?? []
            
            
            for id in ids {
                let rowSchemaID = RowSchemaID(rowID: rowDataModel.rowID, schemaID: id)
                if let shouldShow = tableDataModel.documentEditor?.shouldShowSchema(for: tableDataModel.fieldIdentifier.fieldID, rowSchemaID: rowSchemaID), shouldShow {
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
                                                                                rowWidth: Utility.getWidthForExpanderRow(columns: filteredTableColumns, showSelector: showRowSelector, text: "")),
                                                        childrens: childrens,
                                                        rowWidth: rowWidth(filteredTableColumns, level)
                        )
                        rowDataModel.isExpanded = false
                        cellModels.append(rowDataModel)
                        
                    }
                }
            }
//            tableDataModel.filteredcellModels.insert(contentsOf: cellModels, at: index+1)
            tableDataModel.cellModels.insert(contentsOf: cellModels, at: index+1)
            for cellModel in cellModels {
                expendSpecificTable(rowDataModel: cellModel, parentID: (columnID: "", rowID: cellModel.rowID), level: level)
            }
            tableDataModel.cellModels[index].isExpanded.toggle()
        }
        tableDataModel.filterRowsIfNeeded()
        updateCollectionWidth()
    }
    
    func deleteSelectedRow() {
        guard let firstSelectedRowID = tableDataModel.selectedRows.first else {
            Log("No row selected", type: .error)
            return
        }
        
        guard let firstSelectedRow = tableDataModel.cellModels.first(where: { $0.rowID == firstSelectedRowID }) else {
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
    
    func deleteSelectedNestedRow(parentRowId: String, nestedKey: String) {
        let valueToValueElements = tableDataModel.documentEditor?.deleteNestedRows(rowIDs: tableDataModel.selectedRows,
                                                                                   fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                                   rootSchemaKey: rootSchemaKey,
                                                                                   nestedKey: nestedKey,
                                                                                   parentRowId: parentRowId)
        self.tableDataModel.valueToValueElements = valueToValueElements
        for rowID in tableDataModel.selectedRows {
            if let index = tableDataModel.cellModels.firstIndex(where: { $0.rowID == rowID }) {
                deleteRow(at: index, rowID: rowID, isNested: true)
            }
        }
    }
    
    fileprivate func getTableColumnsByIndex(_ indexOfFirstSelectedRow: Int) -> [FieldTableColumn] {
        for indexOfCurrentRow in stride(from: indexOfFirstSelectedRow, through: 0, by: -1) {
            switch tableDataModel.cellModels[indexOfCurrentRow].rowType {
            case .header(level: let level, tableColumns: let tableColumns):
                if level == tableDataModel.cellModels[indexOfFirstSelectedRow].rowType.level {
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
        guard let firstSelectedRow = tableDataModel.cellModels.first(where: { $0.rowID == firstSelectedRowID }) else {
            return
        }
        switch firstSelectedRow.rowType {
        case .row(index: let index):
            duplicateNestedRow(parentID: ("",""), level: 0, isNested: false, tableColumns: tableDataModel.tableColumns, parentSchemaKey: rootSchemaKey)
        case .nestedRow(level: let level, index: let index, parentID: let parentID, parentSchemaKey: let parentSchemaKey):
            let indexOfFirstSelectedRow = tableDataModel.cellModels.firstIndex(where: { $0.rowID == firstSelectedRowID } ) ?? 0
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
        
        let sortedChanges = result.0.sorted { $0.key < $1.key }
        
        let sortedSelectedRows = tableDataModel.selectedRows.sorted { (rowID1, rowID2) in
            guard let index1 = tableDataModel.cellModels.firstIndex(where: { $0.rowID == rowID1 }),
                  let index2 = tableDataModel.cellModels.firstIndex(where: { $0.rowID == rowID2 }) else {
                return false
            }
            return index1 < index2
        }
        
        for (offset, change) in sortedChanges.enumerated() {
            let startingIndex = tableDataModel.cellModels.firstIndex(where: { $0.rowID == sortedSelectedRows[offset] }) ?? 0
            let rowDataModel = tableDataModel.cellModels[startingIndex]
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
            tableDataModel.filterRowsIfNeeded()
        }
        
        guard let rowDataModel = tableDataModel.cellModels.first(where: { $0.rowID == sortedSelectedRows[0] }) else {
            Log("Could not find rowDataModel", type: .error)
            return
        }
        reIndexingRows(rowDataModel: rowDataModel)
        tableDataModel.emptySelection()
    }
            
    func reIndexingRows(rowDataModel: RowDataModel) {
        // find upperMost item of this level
        var startingIndex = 0
        guard let currentIndex = tableDataModel.cellModels.firstIndex(of: rowDataModel) else {
            return
        }
        for i in stride(from: currentIndex, through: 0, by: -1) {
            let model = tableDataModel.cellModels[i]
            
            if model.rowType.level < rowDataModel.rowType.level {
                break
            }
            if model.rowType.level > rowDataModel.rowType.level {
                continue
            }
            startingIndex = i
        }
        
        var currentRowIndex = 1
        for i in startingIndex..<tableDataModel.cellModels.count {
            var model = tableDataModel.cellModels[i]
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
            tableDataModel.cellModels[i] = model
        }
        tableDataModel.filterRowsIfNeeded()
    }
    
    func insertBelow() -> String? {
        guard let firstSelectedRowID = tableDataModel.selectedRows.first else {
            Log("No row selected", type: .error)
            return nil
        }
        
        guard let firstSelectedRow = tableDataModel.cellModels.first(where: { $0.rowID == firstSelectedRowID }) else {
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
        tableDataModel.filterRowsIfNeeded()
        tableDataModel.emptySelection()
    }
    
    func insertRowBelow() -> String? {
        let cellValues = getCellValues()
        guard let result = tableDataModel.documentEditor?.insertBelowNestedRow(selectedRowID: tableDataModel.selectedRows[0],
                                                                               cellValues: cellValues,
                                                                               fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                               childrenKeys: tableDataModel.schema[rootSchemaKey]?.children,
                                                                               rootSchemaKey: rootSchemaKey,
                                                                               nestedKey: rootSchemaKey,
                                                                               parentRowId: "") else { return nil }
        let valueElement = result.inserted
        self.tableDataModel.valueToValueElements = result.all
        //updateCellModels
        guard let selecteRowIndex = tableDataModel.cellModels.firstIndex(where: { $0.rowID == tableDataModel.selectedRows[0] }) else {
            return nil
        }
        let selectedRow = tableDataModel.cellModels[selecteRowIndex]
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
        
        reIndexingRows(rowDataModel: tableDataModel.cellModels[selecteRowIndex])
        return newRowID
    }
    
    func insertNestedBelow(parentRowID: String, nestedKey: String) -> String? {
        guard let selecteRowIndex = tableDataModel.cellModels.firstIndex(where: { $0.rowID == tableDataModel.selectedRows[0] }) else {
            return nil
        }
        
        let tableColumns: [FieldTableColumn] = tableDataModel.schema[nestedKey]?.tableColumns ?? []
        let cellValues = getCellValuesForNested(columns: tableColumns)
        let selectedRow = tableDataModel.cellModels[selecteRowIndex]
        
        guard let rowData = tableDataModel.documentEditor?.insertBelowNestedRow(selectedRowID: tableDataModel.selectedRows[0],
                                                                                cellValues: cellValues,
                                                                                fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                                childrenKeys: tableDataModel.schema[selectedRow.rowType.parentSchemaKey]?.children,
                                                                                rootSchemaKey: rootSchemaKey,
                                                                                nestedKey: nestedKey,
                                                                                parentRowId: parentRowID) else { return nil }
        self.tableDataModel.valueToValueElements = rowData.all
                
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
        
        reIndexingRows(rowDataModel: tableDataModel.cellModels[selecteRowIndex])
        return newRowID
    }

    func moveUP() {
        guard let firstSelectedRowID = tableDataModel.selectedRows.first else {
            Log("No row selected", type: .error)
            return
        }
        
        guard let firstSelectedRow = tableDataModel.cellModels.first(where: { $0.rowID == firstSelectedRowID }) else {
            return
        }
        switch firstSelectedRow.rowType {
        case .row(index: let index):
            moveNestedUP(parentRowId: "", nestedKey: rootSchemaKey, isNested: false)
        case .nestedRow(level: let level, index: let index, parentID: let parentID, parentSchemaKey: let parentSchemaKey):
            moveNestedUP(parentRowId: parentID?.rowID ?? "", nestedKey: parentSchemaKey, isNested: true)
        default:
            return
        }
        reIndexingRows(rowDataModel: firstSelectedRow)
    }
    
    func moveNestedUP(parentRowId: String, nestedKey: String, isNested: Bool) {
        guard let firstSelectedRowID = tableDataModel.selectedRows.first else {
            Log("No row selected", type: .error)
            return
        }
        self.tableDataModel.valueToValueElements = tableDataModel.documentEditor?.moveNestedRowUp(rowID: firstSelectedRowID,
                                                                                                  fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                                                  rootSchemaKey: rootSchemaKey,
                                                                                                  nestedKey: nestedKey,
                                                                                                  parentRowId: parentRowId)
        guard let lastRowIndex = tableDataModel.cellModels.firstIndex(where: { $0.rowID == firstSelectedRowID }) else {
            Log("Could not find the row", type: .error)
            return
        }
        moveNestedUP(at: lastRowIndex, rowID: firstSelectedRowID, isNested: isNested)
    }

    func moveDown() {
        guard let firstSelectedRowID = tableDataModel.selectedRows.first else {
            Log("No row selected", type: .error)
            return
        }
        
        guard let firstSelectedRow = tableDataModel.cellModels.first(where: { $0.rowID == firstSelectedRowID }) else {
            return
        }
        switch firstSelectedRow.rowType {
        case .row(index: let index):
            moveNestedDown(parentRowId: "", nestedKey: rootSchemaKey)
        case .nestedRow(level: let level, index: let index, parentID: let parentID, parentSchemaKey: let parentSchemaKey):
            moveNestedDown(parentRowId: parentID?.rowID ?? "", nestedKey: parentSchemaKey)
        default:
            return
        }
        reIndexingRows(rowDataModel: firstSelectedRow)
    }
    
    func moveNestedDown(parentRowId: String, nestedKey: String) {
        guard let firstSelectedRowID = tableDataModel.selectedRows.first else {
            Log("No row selected", type: .error)
            return
        }
        self.tableDataModel.valueToValueElements = tableDataModel.documentEditor?.moveNestedRowDown(rowID: firstSelectedRowID,
                                                                                                    fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                                                    rootSchemaKey: rootSchemaKey,
                                                                                                    nestedKey: nestedKey,
                                                                                                    parentRowId: parentRowId)
        guard let lastRowIndex = tableDataModel.cellModels.firstIndex(where: { $0.rowID == firstSelectedRowID }) else {
            Log("Unable to find row with ID: \(firstSelectedRowID)", type: .error)
            return
        }
        moveNestedDown(at: lastRowIndex, rowID: firstSelectedRowID)
    }
    
    fileprivate func deleteRow(at index: Int, rowID: String, isNested: Bool) {
        let currentRow = tableDataModel.cellModels[index]
        if currentRow.isExpanded {
            collapseTables(index, currentRow, currentRow.rowType.level)
        }
        self.tableDataModel.cellModels.remove(at: index)
        tableDataModel.filterRowsIfNeeded()
    }
    
    func getUpperRowIndex(startingIndex: Int) -> Int {
        var upperRowIndex = 0
        for i in stride(from: startingIndex, through: 0, by: -1) {
            switch tableDataModel.cellModels[i].rowType {
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
            switch tableDataModel.cellModels[i].rowType {
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
        let currentRow = tableDataModel.cellModels[index]
        var currentRowIndicesToMove: [Int] = []
        var upperRowIndicesToMove: [Int] = []
        //we need to count the upper row childrens if upper row is aslo expanded
        var upperRowIndex = 0
        
        if isNested {
            upperRowIndex = getUpperNestedRowIndex(startingIndex: index - 1, level: currentRow.rowType.level)
        } else {
            upperRowIndex = getUpperRowIndex(startingIndex: index - 1)
        }
        
        upperRowIndicesToMove = tableDataModel.childrensForRows(upperRowIndex, tableDataModel.cellModels[upperRowIndex], tableDataModel.cellModels[upperRowIndex].rowType.level)
        upperRowIndicesToMove.append(upperRowIndex)
        
        if currentRow.isExpanded {
            currentRowIndicesToMove = tableDataModel.childrensForRows(index, currentRow, currentRow.rowType.level)
            currentRowIndicesToMove.append(index)
            self.tableDataModel.cellModels.moveItems(from: currentRowIndicesToMove.sorted(), to: upperRowIndicesToMove.sorted())
        } else {
            self.tableDataModel.cellModels.moveItems(from: [index], to: upperRowIndicesToMove.sorted())
        }
        tableDataModel.filterRowsIfNeeded()
    }
    
    fileprivate func moveNestedDown(at index: Int, rowID: String) {
        let currentRow = tableDataModel.cellModels[index]
        var currentRowIndicesToMove: [Int] = []
        var lowerRowIndicesToMove: [Int] = []
        
        currentRowIndicesToMove = tableDataModel.childrensForRows(index, currentRow, currentRow.rowType.level)
        currentRowIndicesToMove.append(index)
        
        let lowerRow = tableDataModel.cellModels[index + currentRowIndicesToMove.count]
        lowerRowIndicesToMove = tableDataModel.childrensForRows(index + currentRowIndicesToMove.count, lowerRow, lowerRow.rowType.level)
        lowerRowIndicesToMove.append(index + currentRowIndicesToMove.count)
        
        if currentRow.isExpanded {
            self.tableDataModel.cellModels.moveItems(from: lowerRowIndicesToMove.sorted(), to: currentRowIndicesToMove.sorted())
        } else {
            self.tableDataModel.cellModels.moveItems(from: lowerRowIndicesToMove.sorted(), to: [index])
        }
        tableDataModel.filterRowsIfNeeded()
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
    
    func addRow() {
        let id = generateObjectId()
        let cellValues = getCellValues()
        
        if let rowData = tableDataModel.documentEditor?.insertRowWithFilter(id: id,
                                                                            cellValues: cellValues,
                                                                            fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                            schemaKey: rootSchemaKey,
                                                                            childrenKeys: tableDataModel.schema[rootSchemaKey]?.children,
                                                                            rootSchemaKey: rootSchemaKey) {
            let index = tableDataModel.cellModels.count
            tableDataModel.valueToValueElements = rowData.all
            let valueElement = rowData.inserted
            guard let newRowID = valueElement.id else {
                Log("Could not find id for new row", type: .error)
                return
            }
            let rowIndex = tableDataModel.cellModels.filter({$0.rowType.isRow}).count + 1
            addNestedCellModel(rowID: newRowID,
                               index: index,
                               valueElement: valueElement,
                               columns: tableDataModel.tableColumns,
                               level: 0,
                               childrens: getChildrensBy(rootSchemaKey),
                               rowType: .row(index: rowIndex),
                               schemaKey: rootSchemaKey)
            self.tableDataModel.filterRowsIfNeeded()
        }
    }
    
    func addNestedRow(schemaKey: String, level: Int, startingIndex: Int, parentID: (columnID: String, rowID: String)) {
        let id = generateObjectId()
        let schemaTableColumns = tableDataModel.schema[schemaKey]?.tableColumns ?? []
        let filteredTableColumns = tableDataModel.filterTableColumns(key: schemaKey)
        let cellValues = getCellValuesForNested(columns: filteredTableColumns)
                
        if let rowData = tableDataModel.documentEditor?.insertRowWithFilter(id: id,
                                                                            cellValues: cellValues,
                                                                            fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                            parentRowId: parentID.rowID,
                                                                            schemaKey: schemaKey,
                                                                            childrenKeys: tableDataModel.schema[schemaKey]?.children,
                                                                            rootSchemaKey: rootSchemaKey) {
            //Update valueToValueElements
            self.tableDataModel.valueToValueElements = rowData.all
            
            //Index where we append new row in tableDataModel.cellModels
            var atNestedIndex = 0
            let rowDataModel = tableDataModel.cellModels[startingIndex]
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
            
            let rowDataModelForIndexing = tableDataModel.cellModels[startingIndex + 2]
            reIndexingRows(rowDataModel: rowDataModelForIndexing)
            self.tableDataModel.filterRowsIfNeeded()
        }
    }
    
    func getCellValuesForNested(columns: [FieldTableColumn]) -> [String: ValueUnion] {
        var cellValues: [String: ValueUnion] = [:]
        for column in columns {
            if let defaultValue = column.value {
                guard let id = column.id else {
                    Log("Missing column id", type: .error)
                    continue
                }
                cellValues[id] = defaultValue
            }
        }
        return cellValues
    }
    
    func getCellValues() -> [String: ValueUnion] {
        var cellValues: [String: ValueUnion] = [:]
        
        for filterModel in tableDataModel.filterModels {
            let change = filterModel.filterText
            let columnId = filterModel.colID ?? ""
            
            if change.isEmpty {
                // No filter Applied, Extract default value if present
                if let defaultValue = tableDataModel.tableColumns.first(where: { $0.id == columnId })?.value {
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

    func cellDidChange(rowId: String, colIndex: Int, cellDataModel: CellDataModel, isNestedCell: Bool) -> [ValueElement] {
        tableDataModel.updateCellModelForNested(rowId: rowId, colIndex: colIndex, cellDataModel: cellDataModel, isBulkEdit: false)
        
        let currentRowModel = tableDataModel.cellModels.first(where: { $0.rowID == rowId })
                
        let valueElememts = tableDataModel.documentEditor?.nestedCellDidChange(rowId: rowId,
                                                                  cellDataModel: cellDataModel,
                                                                  fieldIdentifier: tableDataModel.fieldIdentifier,
                                                                  rootSchemaKey: rootSchemaKey,
                                                                  nestedKey: currentRowModel?.rowType.parentSchemaKey ?? "",
                                                                  parentRowId: currentRowModel?.rowType.parentID?.rowID ?? "") ?? []
        tableDataModel.documentEditor?.updateSchemaVisibilityOnCellChange(collectionFieldID: tableDataModel.fieldIdentifier.fieldID, columnID: cellDataModel.id, rowID: rowId)
        if let shouldRefreshSchema = tableDataModel.documentEditor?.shouldRefreshSchema(for: tableDataModel.fieldIdentifier.fieldID, columnID: cellDataModel.id), shouldRefreshSchema {
            refreshCollectionSchema(rowID: rowId)
        }
        
        return valueElememts
    }
    
    func refreshCollectionSchema(rowID: String) {
        //Close and open the nested table to refresh
        guard let index = tableDataModel.cellModels.firstIndex(where: { $0.rowID == rowID }) else {
            return
        }
        
        var rowDataModel = tableDataModel.cellModels[index]
        
        if rowDataModel.isExpanded {
            expandTables(rowDataModel: rowDataModel, level: rowDataModel.rowType.level ?? 0)
            rowDataModel.isExpanded = false
            expandTables(rowDataModel: rowDataModel, level: rowDataModel.rowType.level ?? 0)
            rowDataModel.isExpanded = true
            
            tableDataModel.cellModels[index] = rowDataModel
        }
        tableDataModel.filterRowsIfNeeded()
    }

    func bulkEdit(changes: [Int: ValueUnion]) {
        let tableColumns = getTableColumnsForSelectedRows()
        var columnIDChanges = [String: ValueUnion]()
        changes.forEach { (colIndex: Int, value: ValueUnion) in
            guard let cellDataModelId = tableColumns[colIndex].id else { return }
            columnIDChanges[cellDataModelId] = value
        }
        tableDataModel.valueToValueElements =  tableDataModel.documentEditor?.bulkEditForNested(changes: columnIDChanges, selectedRows: tableDataModel.selectedRows, fieldIdentifier: tableDataModel.fieldIdentifier)
        
        for rowId in tableDataModel.selectedRows {
            let rowIndex = tableDataModel.cellModels.firstIndex(where: { $0.rowID == rowId }) ?? 0
            tableColumns.enumerated().forEach { colIndex, column in
                var cellDataModel = tableDataModel.cellModels[rowIndex].cells[colIndex].data
                guard let change = changes[colIndex] else { return }
                
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
                
                tableDataModel.updateCellModelForNested(rowId: rowId, colIndex: colIndex, cellDataModel: cellDataModel, isBulkEdit: true)
                
                tableDataModel.documentEditor?.updateSchemaVisibilityOnCellChange(collectionFieldID: tableDataModel.fieldIdentifier.fieldID, columnID: cellDataModel.id, rowID: rowId)
                if let shouldRefreshSchema = tableDataModel.documentEditor?.shouldRefreshSchema(for: tableDataModel.fieldIdentifier.fieldID, columnID: cellDataModel.id), shouldRefreshSchema {
                    refreshCollectionSchema(rowID: rowId)
                }
            }
        }
        tableDataModel.filterRowsIfNeeded()
    }
    
    func sendEventsIfNeeded() {
        tableDataModel.documentEditor?.onChange(fieldIdentifier: tableDataModel.fieldIdentifier)
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
