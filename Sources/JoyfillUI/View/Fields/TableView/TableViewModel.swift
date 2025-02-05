//
//  File.swift
//
//
//  Created by Nand Kishore on 04/03/24.
//

import Foundation
import SwiftUI
import JoyfillModel

class TableViewModel: ObservableObject {
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
        self.nestedTableCount = tableDataModel.tableColumns.filter { $0.type == .table }.count
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
                    self.cellDidChange(rowId: rowID, colIndex: colIndex, cellDataModel: cellDataModel)
                }
                rowCellModels.append(cellModel)
            }
        if self.tableDataModel.cellModels.count > (index - 1) {
            self.tableDataModel.cellModels.insert(RowDataModel(rowID: rowID, cells: rowCellModels, rowType: .row(index: index)), at: index)
        } else {
            self.tableDataModel.cellModels.append(RowDataModel(rowID: rowID, cells: rowCellModels, rowType: .row(index: self.tableDataModel.cellModels.count)))
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
        tableDataModel.rowOrder.enumerated().forEach { rowIndex, rowID in
            var rowCellModels = [TableCellModel]()
            tableDataModel.tableColumns.enumerated().forEach { colIndex, column in
                let columnModel = rowDataMap[rowID]?[colIndex]
                if let columnModel = columnModel {
                    let cellModel = TableCellModel(rowID: rowID,
                                                   data: columnModel,
                                                   documentEditor: tableDataModel.documentEditor,
                                                   fieldIdentifier: tableDataModel.fieldIdentifier,
                                                   viewMode: .modalView,
                                                   editMode: tableDataModel.mode) { cellDataModel in
                        self.cellDidChange(rowId: rowID, colIndex: colIndex, cellDataModel: cellDataModel)
                    }
                    rowCellModels.append(cellModel)
                }
            }
            cellModels.append(RowDataModel(rowID: rowID, cells: rowCellModels, rowType: .row(index: cellModels.count)))
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

    var rowTitle: String {
        "\(tableDataModel.selectedRows.count) " + (tableDataModel.selectedRows.count > 1 ? "rows": "row")
    }
    
    func findColumnById(_ columnId: String, in columns: [FieldTableColumn]) -> (column: FieldTableColumn, index: Int)? {
        for (index, column) in columns.enumerated() {
            // If the current column’s id matches, return it with its index.
            if column.id == columnId {
                return (column, index)
            }
            
            // If not -> recursively check its tableColumns.
            if column.type == .table,
               let subColumns = column.tableColumns,
               let found = findColumnById(columnId, in: subColumns) {
                return found
            }
        }
        return nil
    }
        
    func expendSpecificTable(rowDataModel: RowDataModel, columnID: String, level: Int, isOpenedFromTable: Bool) {
        guard let index = tableDataModel.cellModels.firstIndex(of: rowDataModel) else { return }
        if rowDataModel.isExpanded {
            // Close all the nested rows for a particular row
            var indicesToRemoveArray: [Int] = []
            
            for i in index + 1..<tableDataModel.filteredcellModels.count {
                let nextRow = tableDataModel.filteredcellModels[i]
                
                //Stop if find another table expander of same level
                if nextRow.rowType == .tableExpander(level: rowDataModel.rowType.level) {
                    break
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
                tableDataModel.cellModels.remove(at: i)
            }
        } else {
            var cellModels = [RowDataModel]()
            guard let result = findColumnById(columnID, in: tableDataModel.tableColumns) else { return }
            
            if isOpenedFromTable {
                //Add tableExpander if opened from direct table
                cellModels.append(RowDataModel(rowID: UUID().uuidString,
                                               cells: rowDataModel.cells,
                                               rowType: .tableExpander(tableColumn: result.column, level: level),
                                               isExpanded: true))
            }

            cellModels.append(RowDataModel(rowID: UUID().uuidString,
                                           cells: [],
                                           rowType: .header(level: level + 1, tableColumns: result.column.tableColumns ?? [])))

            let subRowIds = rowDataModel.cells.first { tableCellModel in
                tableCellModel.data.id == columnID
            }?.data.multiSelectValues ?? []

            
            for (index, id) in subRowIds.enumerated() {
                let newRowID = UUID().uuidString
                
                var subCells: [TableCellModel] = []
                
                guard let valueElement = tableDataModel.valueToValueElements?.first(where: { valueElement in
                    valueElement.id == id
                }) else {
                    return
                }
                
                let cellDataModels = tableDataModel.buildAllCellsForRow(tableColumns: result.column.tableColumns ?? [], valueElement)
                
                for cellDataModel in cellDataModels {
                    let cellModel = TableCellModel(rowID: id,
                                                   data: cellDataModel,
                                                   documentEditor: tableDataModel.documentEditor,
                                                   fieldIdentifier: tableDataModel.fieldIdentifier,
                                                   viewMode: .modalView,
                                                   editMode: tableDataModel.mode) { cellDataModel in
                        //TODO: Handle on Change for Nested tables
                        let result = self.findColumnById(cellDataModel.id, in: self.tableDataModel.tableColumns)
                        self.tableDataModel.valueToValueElements =  self.cellDidChange(rowId: id, colIndex: result?.index ?? 0, cellDataModel: cellDataModel)
                    }
                    subCells.append(cellModel)
                }
                
                cellModels.append(RowDataModel(rowID: id,
                                               cells: subCells,
                                               rowType: .nestedRow(level: level + 1, index: index+1)))
            }
            tableDataModel.filteredcellModels.insert(contentsOf: cellModels, at: index+1)
            tableDataModel.cellModels.insert(contentsOf: cellModels, at: index+1)
        }
    }
    
    func expandTables(rowDataModel: RowDataModel, level: Int) {
        guard let index = tableDataModel.cellModels.firstIndex(of: rowDataModel) else { return }
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
                tableDataModel.cellModels.remove(at: i)
            }
        } else {
            var cellModels = [RowDataModel]()

            let columns = columnsAtNestedLevel(level, from: tableDataModel.tableColumns)
            
            for column in columns {
                let newRowID = UUID().uuidString
                cellModels.append(RowDataModel(rowID: newRowID,
                                               cells: rowDataModel.cells,
                                               rowType: .tableExpander(tableColumn: column, level: level)))
            }
            tableDataModel.filteredcellModels.insert(contentsOf: cellModels, at: index+1)
            tableDataModel.cellModels.insert(contentsOf: cellModels, at: index+1)
        }
    }
    
    func columnsAtNestedLevel(_ level: Int, from columns: [FieldTableColumn]) -> [FieldTableColumn] {
        guard level >= 0 else { return [] }
        
        // level=0 just return the columns we have:
        if level == 0 {
            return columns.filter { column in
                column.type == .table
            }
        }
        
        // Otherwise, Recursive call to gather columns
        var immediateSubColumns: [FieldTableColumn] = []
        for col in columns {
            if col.type == .table, let subCols = col.tableColumns {
                immediateSubColumns.append(contentsOf: subCols)
            }
        }
        
        return columnsAtNestedLevel(level - 1, from: immediateSubColumns)
    }
    
    func deleteSelectedRow() {
        tableDataModel.documentEditor?.deleteRows(rowIDs: tableDataModel.selectedRows, fieldIdentifier: tableDataModel.fieldIdentifier)
        for rowID in tableDataModel.selectedRows {
            if let index = tableDataModel.rowOrder.firstIndex(of: rowID) {
                deleteRow(at: index, rowID: rowID)
            }
        }
        tableDataModel.emptySelection()
    }
    
    func duplicateRow() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        guard let changes = tableDataModel.documentEditor?.duplicateRows(rowIDs: tableDataModel.selectedRows, fieldIdentifier: tableDataModel.fieldIdentifier) else { return }
        
        let sortedChanges = changes.sorted { $0.key < $1.key }
        sortedChanges.forEach { (index, value) in
            updateRow(valueElement: value, at: index)
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
        tableDataModel.documentEditor?.moveRowUp(rowID: tableDataModel.selectedRows.first!, fieldIdentifier: tableDataModel.fieldIdentifier)
        let lastRowIndex = tableDataModel.rowOrder.firstIndex(of: tableDataModel.selectedRows.first!)!
        moveUP(at: lastRowIndex, rowID: tableDataModel.selectedRows.first!)
    }

    func moveDown() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        tableDataModel.documentEditor?.moveRowDown(rowID: tableDataModel.selectedRows.first!, fieldIdentifier: tableDataModel.fieldIdentifier)
        let lastRowIndex = tableDataModel.rowOrder.firstIndex(of: tableDataModel.selectedRows.first!)!
        moveDown(at: lastRowIndex, rowID: tableDataModel.selectedRows.first!)
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

    fileprivate func moveUP(at index: Int, rowID: String) {
        tableDataModel.rowOrder.swapAt(index, index-1)
        self.tableDataModel.cellModels.swapAt(index, index-1)
        tableDataModel.filterRowsIfNeeded()
        tableDataModel.emptySelection()
    }

    fileprivate func moveDown(at index: Int, rowID: String) {
        tableDataModel.rowOrder.swapAt(index, index+1)
        self.tableDataModel.cellModels.swapAt(index, index+1)
        tableDataModel.filterRowsIfNeeded()
        tableDataModel.emptySelection()
    }

    func addRow() {
        let id = generateObjectId()
        let cellValues = getCellValues()

        if let rowData = tableDataModel.documentEditor?.insertRowWithFilter(id: id, cellValues: cellValues, fieldIdentifier: tableDataModel.fieldIdentifier) {
            updateRow(valueElement: rowData, at: tableDataModel.rowOrder.count)
        }
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

    func cellDidChange(rowId: String, colIndex: Int, cellDataModel: CellDataModel) -> [ValueElement]{
        tableDataModel.updateCellModel(rowIndex: tableDataModel.rowOrder.firstIndex(of: rowId) ?? 0, rowId: rowId, colIndex: colIndex, cellDataModel: cellDataModel, isBulkEdit: false)
        
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
