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
    private var requiredColumnIds: [String] = []

    @Published var uuid = UUID()
    
    init(tableDataModel: TableDataModel) {
        self.tableDataModel = tableDataModel
        self.showRowSelector = tableDataModel.mode == .fill
        self.shouldShowAddRowButton = tableDataModel.mode == .fill
        self.nestedTableCount = tableDataModel.childrens.count
        setupCellModels()
        self.tableDataModel.filterRowsIfNeeded()
        self.requiredColumnIds = tableDataModel.tableColumns
            .filter { $0.required == true }
            .map { $0.id! }
    }

    func addCellModel(rowID: String, index: Int, valueElement: ValueElement) {
        var rowCellModels = [TableCellModel]()
        let rowDataModels = tableDataModel.buildAllCellsForRow(tableColumns: tableDataModel.tableColumns, valueElement)
            for rowDataModel in rowDataModels {
                let cellModel = TableCellModel(rowID: rowID,
                                               data: rowDataModel,
                                               documentEditor: tableDataModel.documentEditor,
                                               fieldIdentifier: tableDataModel.fieldIdentifier,
                                               viewMode: .modalView,
                                               editMode: tableDataModel.mode) { cellDataModel in
                    let colIndex = self.tableDataModel.tableColumns.firstIndex( where: { fieldTableColumn in
                        fieldTableColumn.id == cellDataModel.id
                    })!
                    self.cellDidChange(rowId: rowID, colIndex: colIndex, cellDataModel: cellDataModel, isNestedCell: false)
                }
                rowCellModels.append(cellModel)
            }
        if self.tableDataModel.cellModels.count > (index - 1) {
            self.tableDataModel.cellModels.insert(RowDataModel(rowID: rowID, cells: rowCellModels, rowType: .row(index: index)), at: index)
        } else {
            self.tableDataModel.cellModels.append(RowDataModel(rowID: rowID, cells: rowCellModels, rowType: .row(index: self.tableDataModel.cellModels.count)))
        }
    }
    
    func addNestedCellModel(rowID: String, index: Int, valueElement: ValueElement, columns: [FieldTableColumn], level: Int, parentID: (columnID: String, rowID: String), nestedIndex: Int) {
        var rowCellModels = [TableCellModel]()
        let rowDataModels = tableDataModel.buildAllCellsForRow(tableColumns: columns, valueElement)
            for rowDataModel in rowDataModels {
                let cellModel = TableCellModel(rowID: rowID,
                                               data: rowDataModel,
                                               documentEditor: tableDataModel.documentEditor,
                                               fieldIdentifier: tableDataModel.fieldIdentifier,
                                               viewMode: .modalView,
                                               editMode: tableDataModel.mode) { cellDataModel in
//                    let result = self.findColumnById(cellDataModel.id, in: self.tableDataModel.tableColumns)
                    self.tableDataModel.valueToValueElements = self.cellDidChange(rowId: rowID, colIndex: 0, cellDataModel: cellDataModel, isNestedCell: true)
                }
                rowCellModels.append(cellModel)
            }
        if self.tableDataModel.filteredcellModels.count > (index - 1) {
            self.tableDataModel.filteredcellModels.insert(RowDataModel(rowID: rowID, cells: rowCellModels, rowType: .nestedRow(level: level, index: nestedIndex, parentID: parentID)), at: index)
        } else {
            self.tableDataModel.filteredcellModels.append(RowDataModel(rowID: rowID, cells: rowCellModels, rowType: .nestedRow(level: level, index: self.tableDataModel.filteredcellModels.count, parentID: parentID)))
        }
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
        tableDataModel.rowOrder.enumerated().forEach { rowIndex, rowID in
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
                        self.cellDidChange(rowId: rowID, colIndex: colIndex, cellDataModel: cellDataModel, isNestedCell: false)
                    }
                    rowCellModels.append(cellModel)
                }
            }
            cellModels.append(RowDataModel(rowID: rowID, cells: rowCellModels, rowType: .row(index: cellModels.count), childrens: childrens))
        }
        tableDataModel.cellModels = cellModels
        tableDataModel.filteredcellModels = cellModels
    }

    private func setupRows() -> [String: [CellDataModel]] {
        guard let valueElements = tableDataModel.valueToValueElements, !valueElements.isEmpty else {
            return [:]
        }

        let nonDeletedRows = valueElements.filter { !($0.deleted ?? false) }
        let sortedRows = tableDataModel.sortElementsByRowOrder(elements: nonDeletedRows, rowOrder: tableDataModel.rowOrder)
        let tableColumns = tableDataModel.tableColumns
        var rowToCellMap = [String: [CellDataModel]]()
        for row in sortedRows {
            let cellRowModel = tableDataModel.buildAllCellsForRow(tableColumns: tableColumns, row)
            rowToCellMap[row.id!] = cellRowModel
        }
        return rowToCellMap
    }
    
    private func setupRowsChildrens() -> [String: [String : Children]] {
        guard let valueElements = tableDataModel.valueToValueElements, !valueElements.isEmpty else {
            return [:]
        }

        let nonDeletedRows = valueElements.filter { !($0.deleted ?? false) }
        let sortedRows = tableDataModel.sortElementsByRowOrder(elements: nonDeletedRows, rowOrder: tableDataModel.rowOrder)
        var rowToChildrenMap = [String: [String : Children]]()
        for row in sortedRows {
            rowToChildrenMap[row.id!] = row.childrens
        }
        return rowToChildrenMap
    }

    var rowTitle: String {
        "\(tableDataModel.selectedRows.count) " + (tableDataModel.selectedRows.count > 1 ? "rows": "row")
    }
        
    func expendSpecificTable(rowDataModel: RowDataModel, parentID: (columnID: String, rowID: String), level: Int, isOpenedFromTable: Bool) {
        guard let index = tableDataModel.filteredcellModels.firstIndex(of: rowDataModel) else { return }
        if rowDataModel.isExpanded {
            // Close all the nested rows for a particular row
            var indicesToRemoveArray: [Int] = []
            
            for i in index + 1..<tableDataModel.filteredcellModels.count {
                let nextRow = tableDataModel.filteredcellModels[i]
                
                //Stop if find another table expander of same level
                if !isOpenedFromTable {
                    if nextRow.rowType == .tableExpander(level: rowDataModel.rowType.level) {
                        break
                    }
                }
                //Stop if find nested row of same level
                if nextRow.rowType == .nestedRow(level: rowDataModel.rowType.level, index: rowDataModel.rowType.index) {
                    break
                }
                switch nextRow.rowType {
                case .header, .nestedRow, .tableExpander:
                    indicesToRemoveArray.append(i)
                case .row:
                    break
                }
            }
            
            for i in indicesToRemoveArray.reversed() {
                tableDataModel.filteredcellModels.remove(at: i)
            }
        } else {
            var cellModels = [RowDataModel]()

            switch rowDataModel.rowType {
            case .tableExpander(schemaValue: let schemaValue, level: let level, parentID: let parentID, _):
                cellModels.append(RowDataModel(rowID: UUID().uuidString,
                                               cells: [],
                                               rowType: .header(level: level + 1, tableColumns: schemaValue?.1.tableColumns ?? [])))
                for row in rowDataModel.childrens[schemaValue?.0 ?? ""]?.valueToValueElements ?? [] {
                    let cellDataModels = tableDataModel.buildAllCellsForRow(tableColumns: schemaValue?.1.tableColumns ?? [], row)
                    var subCells: [TableCellModel] = []
                    for cellDataModel in cellDataModels {
                        let cellModel = TableCellModel(rowID: row.id ?? "",
                                                       data: cellDataModel,
                                                       documentEditor: tableDataModel.documentEditor,
                                                       fieldIdentifier: tableDataModel.fieldIdentifier,
                                                       viewMode: .modalView,
                                                       editMode: tableDataModel.mode) { cellDataModel in
    //                        let result = self.findColumnById(cellDataModel.id, in: self.tableDataModel.tableColumns)
//                            self.tableDataModel.valueToValueElements = self.cellDidChange(rowId: id, colIndex: 0, cellDataModel: cellDataModel, isNestedCell: true)
                        }
                        subCells.append(cellModel)
                    }
                    
                    cellModels.append(RowDataModel(rowID: row.id ?? "",
                                                   cells: subCells,
                                                   rowType: .nestedRow(level: level + 1, index: index+1,
                                                                       parentID: parentID)))
                }
            default:
                break
            }
            tableDataModel.filteredcellModels.insert(contentsOf: cellModels, at: index+1)
        }
    }
    
    func expandTables(rowDataModel: RowDataModel, level: Int) {
        guard let index = tableDataModel.filteredcellModels.firstIndex(of: rowDataModel) else { return }
        if rowDataModel.isExpanded {
            var indicesToRemove: [Int] = []

            for i in index + 1..<tableDataModel.filteredcellModels.count {
                let nextRow = tableDataModel.filteredcellModels[i]
                if rowDataModel.rowType == .nestedRow(level: level, index: rowDataModel.rowType.index) {
                    //Stop at same level but next index of current nested row
                    if nextRow.rowType == .nestedRow(level: rowDataModel.rowType.level, index: rowDataModel.rowType.index + 1) {
                        break
                    }
                    //Stop if there is an tableExpander of low level
                    if nextRow.rowType == .tableExpander(level: rowDataModel.rowType.level - 1) {
                        break
                    }
                    switch nextRow.rowType {
                    case .header, .nestedRow, .tableExpander:
                        indicesToRemove.append(i)
                    case .row:
                        break
                    }
                } else {
                    if nextRow.rowType == .row(index: index + 1) {
                        break
                    }
                    switch nextRow.rowType {
                    case .header, .nestedRow, .tableExpander:
                        indicesToRemove.append(i)
                    case .row:
                        break
                    }
                }
            }

            for i in indicesToRemove.reversed() {
                tableDataModel.filteredcellModels.remove(at: i)
            }
        } else {
            var cellModels = [RowDataModel]()

            for (id, children) in rowDataModel.childrens {
                let newRowID = UUID().uuidString
                if let schemaValue = tableDataModel.schema[id] {
                    cellModels.append(RowDataModel(rowID: newRowID,
                                                   cells: rowDataModel.cells,
                                                   rowType: .tableExpander(schemaValue: (id, schemaValue),
                                                                           level: level,
                                                                           parentID: (columnID: "", rowID: rowDataModel.rowID),
                                                                           rowWidth: Utility.getWidthForExpanderRow(columns: schemaValue.tableColumns ?? [])),
                                                   childrens: [id : children]
                                                  ))
                }
            }
            tableDataModel.filteredcellModels.insert(contentsOf: cellModels, at: index+1)
        }
    }
    
    func deleteSelectedRow() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        guard let firstSelectedRow = tableDataModel.filteredcellModels.first(where: { $0.rowID == tableDataModel.selectedRows.first! }) else {
            return
        }
        switch firstSelectedRow.rowType {
        case .row(index: let index):
            tableDataModel.documentEditor?.deleteRows(rowIDs: tableDataModel.selectedRows, fieldIdentifier: tableDataModel.fieldIdentifier)
            for rowID in tableDataModel.selectedRows {
                if let index = tableDataModel.rowOrder.firstIndex(of: rowID) {
                    deleteRow(at: index, rowID: rowID)
                }
            }
        case .nestedRow(level: let level, index: let index, parentID: let parentID):
            deleteSelectedNestedRow()
        default:
            return
        }
        
        tableDataModel.emptySelection()
    }
    
    func deleteSelectedNestedRow() {
        //TODO: Handle on change for delete nested row
//        tableDataModel.documentEditor?.deleteRows(rowIDs: tableDataModel.selectedRows, fieldIdentifier: tableDataModel.fieldIdentifier)
        for rowID in tableDataModel.selectedRows {
            if let index = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == rowID }) {
                deleteNestedRow(at: index, rowID: rowID)
            }
        }
    }
    
    func duplicateRow() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        guard let firstSelectedRow = tableDataModel.filteredcellModels.first(where: { $0.rowID == tableDataModel.selectedRows.first! }) else {
            return
        }
        switch firstSelectedRow.rowType {
        case .row(index: let index):
            guard let changes = tableDataModel.documentEditor?.duplicateRows(rowIDs: tableDataModel.selectedRows, fieldIdentifier: tableDataModel.fieldIdentifier) else { return }
            
            let sortedChanges = changes.sorted { $0.key < $1.key }
            sortedChanges.forEach { (index, value) in
                updateRow(valueElement: value, at: index)
            }
        case .nestedRow(level: let level, index: let index, parentID: let parentID):
            duplicateNestedRow(firstSelectedRow: firstSelectedRow)
        default:
            return
        }
        
        tableDataModel.emptySelection()
    }
    
    func duplicateNestedRow(firstSelectedRow: RowDataModel) {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        
        guard let changes = tableDataModel.documentEditor?.duplicateNestedRows(rowIDs: tableDataModel.selectedRows, parentID: firstSelectedRow.rowType.parentID ?? ("", ""), fieldIdentifier: tableDataModel.fieldIdentifier) else { return }
        
//        let result = findColumnById(firstSelectedRow.rowType.parentID?.columnID ?? "", in: tableDataModel.tableColumns)
        
        let sortedChanges = changes.sorted { $0.key < $1.key }
        
        let sortedSelectedRows = tableDataModel.selectedRows.sorted { (rowID1, rowID2) in
            guard let index1 = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == rowID1 }),
                  let index2 = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == rowID2 }) else {
                return false
            }
            return index1 < index2
        }
        
        for (offset, change) in sortedChanges.enumerated() {
            let startingIndex = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == sortedSelectedRows[offset] }) ?? 0
            updateRowForNested(startingIndex + 1, firstSelectedRow.rowType.level ?? 0, change.value, [], parentID: firstSelectedRow.rowType.parentID ?? ("", ""), nestedIndex: startingIndex)
        }
        
        tableDataModel.emptySelection()
    }

    func insertBelow() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        let cellValues = getCellValues()
        guard let targetRows = tableDataModel.documentEditor?.insertBelow(selectedRowID: tableDataModel.selectedRows[0], cellValues: cellValues, fieldIdentifier: tableDataModel.fieldIdentifier) else { return }
        let lastRowIndex = tableDataModel.rowOrder.firstIndex(of: tableDataModel.selectedRows[0])!
        updateRow(valueElement: targetRows.0, at: lastRowIndex+1)
        tableDataModel.emptySelection()
    }

    func moveUP() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        
        guard let firstSelectedRow = tableDataModel.filteredcellModels.first(where: { $0.rowID == tableDataModel.selectedRows.first! }) else {
            return
        }
        switch firstSelectedRow.rowType {
        case .row(index: let index):
            tableDataModel.documentEditor?.moveRowUp(rowID: tableDataModel.selectedRows.first!, fieldIdentifier: tableDataModel.fieldIdentifier)
            let lastRowIndex = tableDataModel.rowOrder.firstIndex(of: tableDataModel.selectedRows.first!)!
            moveUP(at: lastRowIndex, rowID: tableDataModel.selectedRows.first!)
        case .nestedRow(level: let level, index: let index, parentID: let parentID):
            moveNestedUP()
        default:
            return
        }
    }
    
    func moveNestedUP() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        //TODO: Handle calling on change
//        tableDataModel.documentEditor?.moveRowUp(rowID: tableDataModel.selectedRows.first!, fieldIdentifier: tableDataModel.fieldIdentifier)
        let lastRowIndex = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == tableDataModel.selectedRows.first! })!
        moveNestedUP(at: lastRowIndex, rowID: tableDataModel.selectedRows.first!)
    }

    func moveDown() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        
        guard let firstSelectedRow = tableDataModel.filteredcellModels.first(where: { $0.rowID == tableDataModel.selectedRows.first! }) else {
            return
        }
        switch firstSelectedRow.rowType {
        case .row(index: let index):
            tableDataModel.documentEditor?.moveRowDown(rowID: tableDataModel.selectedRows.first!, fieldIdentifier: tableDataModel.fieldIdentifier)
            let lastRowIndex = tableDataModel.rowOrder.firstIndex(of: tableDataModel.selectedRows.first!)!
            moveDown(at: lastRowIndex, rowID: tableDataModel.selectedRows.first!)
        case .nestedRow(level: let level, index: let index, parentID: let parentID):
            moveNestedDown()
        default:
            return
        }
    }
    
    func moveNestedDown() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        //TODO: Handle calling on change
//        tableDataModel.documentEditor?.moveRowDown(rowID: tableDataModel.selectedRows.first!, fieldIdentifier: tableDataModel.fieldIdentifier)
        let lastRowIndex = tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == tableDataModel.selectedRows.first! })!
        moveNestedDown(at: lastRowIndex, rowID: tableDataModel.selectedRows.first!)
    }
    
    fileprivate func updateRow(valueElement: ValueElement, at index: Int) {
        if tableDataModel.rowOrder.count > (index - 1) {
            tableDataModel.rowOrder.insert(valueElement.id!, at: index)
        } else {
            tableDataModel.rowOrder.append(valueElement.id!)
        }
        addCellModel(rowID: valueElement.id!, index: index, valueElement: valueElement)
        tableDataModel.filterRowsIfNeeded()
    }
    
    fileprivate func deleteRow(at index: Int, rowID: String) {
        tableDataModel.rowOrder.remove(at: index)
        self.tableDataModel.cellModels.remove(at: index)
        tableDataModel.filterRowsIfNeeded()
    }
    
    fileprivate func deleteNestedRow(at index: Int, rowID: String) {
//        tableDataModel.rowOrder.remove(at: index)
        self.tableDataModel.filteredcellModels.remove(at: index)
//        tableDataModel.filterRowsIfNeeded()
    }

    fileprivate func moveUP(at index: Int, rowID: String) {
        tableDataModel.rowOrder.swapAt(index, index-1)
        self.tableDataModel.cellModels.swapAt(index, index-1)
        tableDataModel.filterRowsIfNeeded()
        tableDataModel.emptySelection()
    }
    
    fileprivate func moveNestedUP(at index: Int, rowID: String) {
//        tableDataModel.rowOrder.swapAt(index, index-1)
        self.tableDataModel.filteredcellModels.swapAt(index, index-1)
//        tableDataModel.filterRowsIfNeeded()
        tableDataModel.emptySelection()
    }

    fileprivate func moveDown(at index: Int, rowID: String) {
        tableDataModel.rowOrder.swapAt(index, index+1)
        self.tableDataModel.cellModels.swapAt(index, index+1)
        tableDataModel.filterRowsIfNeeded()
        tableDataModel.emptySelection()
    }
    
    fileprivate func moveNestedDown(at index: Int, rowID: String) {
//        tableDataModel.rowOrder.swapAt(index, index+1)
        self.tableDataModel.filteredcellModels.swapAt(index, index+1)
//        tableDataModel.filterRowsIfNeeded()
        tableDataModel.emptySelection()
    }

    func addRow() {
        let id = generateObjectId()
        let cellValues = getCellValues()

        if let rowData = tableDataModel.documentEditor?.insertRowWithFilter(id: id, cellValues: cellValues, fieldIdentifier: tableDataModel.fieldIdentifier) {
            updateRow(valueElement: rowData, at: tableDataModel.rowOrder.count)
        }
    }
    
    fileprivate func updateRowOrderForNested(_ startingIndex: Int, _ parentID: (columnID: String, rowID: String), _ id: String) {
        var cellDataModel = tableDataModel.filteredcellModels[startingIndex].cells.first { tableCellModel in
            tableCellModel.data.id == parentID.columnID
        }?.data
        
        var multiSelectValues = cellDataModel?.multiSelectValues ?? []
        multiSelectValues.append(id)
        cellDataModel?.multiSelectValues = multiSelectValues
        self.tableDataModel.valueToValueElements = self.cellDidChange(rowId: parentID.rowID, colIndex: 0, cellDataModel: cellDataModel!, isNestedCell: true)
    }
    
    fileprivate func updateRowForNested(_ atIndex: Int, _ level: Int, _ rowData: ValueElement, _ columns: [FieldTableColumn], parentID: (columnID: String, rowID: String), nestedIndex: Int) {
        //TODO: append or remove or move down or move up
        self.tableDataModel.valueToValueElements?.append(rowData)
        addNestedCellModel(rowID: rowData.id!, index: atIndex, valueElement: rowData, columns: columns, level: level, parentID: parentID, nestedIndex: nestedIndex)
    }
    
    func addNestedRow(columnID: String, level: Int, startingIndex: Int, parentID: (columnID: String, rowID: String)) {
        let id = generateObjectId()
//        let result = findColumnById(columnID, in: tableDataModel.tableColumns)
        let cellValues = getCellValuesForNested(columns: [])
        
        updateRowOrderForNested(startingIndex, parentID, id)
        
        if let rowData = tableDataModel.documentEditor?.insertRowWithFilter(id: id, cellValues: cellValues, fieldIdentifier: tableDataModel.fieldIdentifier, isNested: true) {
            //Index where we append new row in tableDataModel.filteredcellModels
            var atIndex: Int = tableDataModel.filteredcellModels.count
            var atNestedIndex = 0
            loop: for i in (startingIndex + 1)..<tableDataModel.filteredcellModels.count {
                let nextRow = tableDataModel.filteredcellModels[i]
                
                // Stop at .row or .tableExpander
                switch nextRow.rowType {
                case .row, .tableExpander:
                    atIndex = i
                    break loop
                case .nestedRow(level: let nestedLevel, index: let nestedIndex, _):
                    atNestedIndex = nestedIndex + 1
                    if nestedLevel == level + 1 {
                        continue
                    } else {
                        atIndex = i
                        break loop
                    }
                default:
                    break
                }
            }
            updateRowForNested(atIndex, level + 1, rowData, [], parentID: parentID, nestedIndex: atNestedIndex)
        }
    }
    
    func getCellValuesForNested(columns: [FieldTableColumn]) -> [String: ValueUnion] {
        var cellValues: [String: ValueUnion] = [:]
        for column in columns {
            if let defaultValue = column.value {
                cellValues[column.id!] = defaultValue
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
                default:
                    break
                }
            }
        }
        return cellValues
    }

    func cellDidChange(rowId: String, colIndex: Int, cellDataModel: CellDataModel, isNestedCell: Bool) -> [ValueElement] {
        if isNestedCell {
            tableDataModel.updateFilteredCellModel(rowId: rowId, colIndex: colIndex, cellDataModel: cellDataModel, isBulkEdit: false)
        } else {
            tableDataModel.updateCellModel(rowIndex: tableDataModel.rowOrder.firstIndex(of: rowId) ?? 0, rowId: rowId, colIndex: colIndex, cellDataModel: cellDataModel, isBulkEdit: false)
        }
        
        return tableDataModel.documentEditor?.cellDidChange(rowId: rowId, cellDataModel: cellDataModel, fieldId: tableDataModel.fieldIdentifier.fieldID) ?? []
    }

    func bulkEdit(changes: [Int: ValueUnion]) {
        var columnIDChanges = [String: ValueUnion]()
        changes.forEach { (colIndex: Int, value: ValueUnion) in
            guard let cellDataModelId = tableDataModel.getColumnIDAtIndex(index: colIndex) else { return }
            columnIDChanges[cellDataModelId] = value
        }
        tableDataModel.documentEditor?.bulkEdit(changes: columnIDChanges, selectedRows: tableDataModel.selectedRows, fieldIdentifier: tableDataModel.fieldIdentifier)
        for rowId in tableDataModel.selectedRows {
            let rowIndex = tableDataModel.rowOrder.firstIndex(of: rowId) ?? 0
            tableDataModel.tableColumns.enumerated().forEach { colIndex, column in
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
                default:
                    break
                }
                
                tableDataModel.updateCellModel(rowIndex: tableDataModel.rowOrder.firstIndex(of: rowId) ?? 0, rowId: rowId, colIndex: colIndex, cellDataModel: cellDataModel, isBulkEdit: true)
            }
        }
        tableDataModel.filterRowsIfNeeded()
        tableDataModel.emptySelection()
    }
    
    func sendEventsIfNeeded() {
        tableDataModel.documentEditor?.onChange(fieldIdentifier: tableDataModel.fieldIdentifier)
    }
}
