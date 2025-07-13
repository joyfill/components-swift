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
    private var requiredColumnIds: [String] = []

    @Published var uuid = UUID()
    
    init(tableDataModel: TableDataModel) {
        self.tableDataModel = tableDataModel
        self.showRowSelector = tableDataModel.mode == .fill
        self.shouldShowAddRowButton = tableDataModel.mode == .fill
        
        setupCellModels()
        self.tableDataModel.filterRowsIfNeeded()
        self.requiredColumnIds = tableDataModel.tableColumns
            .filter { $0.required == true }
            .compactMap { $0.id }
        tableDataModel.documentEditor?.registerDelegate(self, forTableField: tableDataModel.fieldIdentifier.fieldID)
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
                    if let colIndex = self.tableDataModel.tableColumns.firstIndex( where: { fieldTableColumn in
                        fieldTableColumn.id == cellDataModel.id
                    }) {
                        self.cellDidChange(rowId: rowID, colIndex: colIndex, cellDataModel: cellDataModel, isNestedCell: false)
                    } else {
                        Log("Could not find column index for \(rowDataModel.id)", type: .error)
                    }
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
                        self.cellDidChange(rowId: rowID, colIndex: colIndex, cellDataModel: cellDataModel, isNestedCell: false)
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
            guard let rowID = row.id else {
                Log("Could not find row ID for row: \(row)", type: .error)
                continue
            }
            rowToCellMap[rowID] = cellRowModel
        }
        return rowToCellMap
    }

    var rowTitle: String {
        "\(tableDataModel.selectedRows.count) " + (tableDataModel.selectedRows.count > 1 ? "rows": "row")
    }
    
    func deleteSelectedRow(_ rows: [String]? = nil, shouldSendEvent: Bool = true) {
        let selectedRows: [String] =  rows ?? tableDataModel.selectedRows
        tableDataModel.documentEditor?.deleteRows(
            rowIDs: selectedRows,
            fieldIdentifier: tableDataModel.fieldIdentifier,
            shouldSendEvent: shouldSendEvent
        )
        for rowID in selectedRows {
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

    func insertBelow() -> String? {
        guard let firstSelectedRowID = tableDataModel.selectedRows.first else {
            Log("No selected row", type: .error)
            return nil
        }
        let cellValues = getCellValues()
        guard let targetRows = tableDataModel.documentEditor?.insertBelow(selectedRowID: firstSelectedRowID, cellValues: cellValues, fieldIdentifier: tableDataModel.fieldIdentifier) else { return nil }
        guard let lastRowIndex = tableDataModel.rowOrder.firstIndex(of: firstSelectedRowID) else {
            Log("Could not find index of last selected row", type: .error)
            return nil
        }
        updateRow(valueElement: targetRows.0, at: lastRowIndex+1)
        tableDataModel.emptySelection()
        return targetRows.0.id
    }
    
    func insertBelowFromBulkEdit() {
        if let newRowID = insertBelow() {
            tableDataModel.selectedRows = [newRowID]
        }
    }

    func selectBelowRow() {
        guard let currentRowID = tableDataModel.selectedRows.first,
              let currentIndex = tableDataModel.cellModels.firstIndex(where: { $0.rowID == currentRowID }) else {
            return
        }

        let nextIndex = currentIndex + 1
        guard nextIndex < tableDataModel.cellModels.count else {
            Log("No next row to select", type: .warning)
            return
        }

        let nextRowID = tableDataModel.cellModels[nextIndex].rowID
        tableDataModel.selectedRows = [nextRowID]
    }
    
    func selectUpperRow() {
        guard let currentRowID = tableDataModel.selectedRows.first,
              let currentIndex = tableDataModel.cellModels.firstIndex(where: { $0.rowID == currentRowID }) else {
            return
        }

        let prevIndex = currentIndex - 1
        guard prevIndex >= 0 else {
            Log("No previous row to select", type: .warning)
            return
        }

        let prevRowID = tableDataModel.cellModels[prevIndex].rowID
        tableDataModel.selectedRows = [prevRowID]
    }

    func moveUP(rowIDs: [String]? = nil, shouldSendEvent: Bool = true) {
        let selectedRows = rowIDs ?? tableDataModel.selectedRows
        guard let firstSelectedRowID = selectedRows.first else {
            Log("No selected row", type: .error)
            return
        }
        tableDataModel.documentEditor?.moveRowUp(
            rowID: firstSelectedRowID,
            fieldIdentifier: tableDataModel.fieldIdentifier,
            shouldSendEvent: shouldSendEvent)
        guard let lastRowIndex = tableDataModel.rowOrder.firstIndex(of: firstSelectedRowID) else {
            Log("RowID not found in rowOrder", type: .error)
            return
        }
        moveUP(at: lastRowIndex, rowID: firstSelectedRowID)
    }

    func moveDown(rowIDs: [String]? = nil, shouldSendEvent: Bool = true) {
        let selectedRows = rowIDs ?? tableDataModel.selectedRows
        guard let firstSelectedRowID = selectedRows.first else {
            Log("No selected row", type: .error)
            return
        }
        tableDataModel.documentEditor?.moveRowDown(
            rowID: firstSelectedRowID,
            fieldIdentifier: tableDataModel.fieldIdentifier,
            shouldSendEvent: shouldSendEvent)
        guard let lastRowIndex = tableDataModel.rowOrder.firstIndex(of: firstSelectedRowID) else {
            Log("RowID not found in rowOrder", type: .error)
            return
        }
        moveDown(at: lastRowIndex, rowID: firstSelectedRowID)
    }
    
    fileprivate func updateRow(valueElement: ValueElement, at index: Int) {
        guard let rowID = valueElement.id else {
            Log("Could not get ID for update row", type: .error)
            return
        }
        if tableDataModel.rowOrder.count > (index - 1) {
            tableDataModel.rowOrder.insert(rowID, at: index)
        } else {
            tableDataModel.rowOrder.append(rowID)
        }
        addCellModel(rowID: rowID, index: index, valueElement: valueElement)
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

    func addRow(with cellValues: [String: ValueUnion]? = nil, shouldSendEvent: Bool = true) {
        let id = generateObjectId()
        let cellValues = cellValues ?? getCellValues()
        
        if let rowData = tableDataModel.documentEditor?.insertRowWithFilter(
            id: id, cellValues: cellValues,
            fieldIdentifier: tableDataModel.fieldIdentifier,
            shouldSendEvent: shouldSendEvent
        ) {
            updateRow(valueElement: rowData, at: tableDataModel.rowOrder.count)
        } else {
            Log("Row data is nil", type: .error)
            return
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
        if isNestedCell {
            tableDataModel.updateCellModelForNested(rowId: rowId, colIndex: colIndex, cellDataModel: cellDataModel, isBulkEdit: false)
        } else {
            tableDataModel.updateCellModel(rowIndex: tableDataModel.rowOrder.firstIndex(of: rowId) ?? 0, rowId: rowId, colIndex: colIndex, cellDataModel: cellDataModel, isBulkEdit: false)
        }
        
        return tableDataModel.documentEditor?.cellDidChange(rowId: rowId, cellDataModel: cellDataModel, fieldIdentifier: tableDataModel.fieldIdentifier) ?? []
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
                case .image:
                    cellDataModel.valueElements = change.valueElements ?? []
                case .signature:
                    cellDataModel.title = change.text ?? ""
                default:
                    break
                }
                
                tableDataModel.updateCellModel(rowIndex: tableDataModel.rowOrder.firstIndex(of: rowId) ?? 0, rowId: rowId, colIndex: colIndex, cellDataModel: cellDataModel, isBulkEdit: true)
            }
        }
        tableDataModel.filterRowsIfNeeded()
    }
    
    func sendEventsIfNeeded() {
        tableDataModel.documentEditor?.onChange(fieldIdentifier: tableDataModel.fieldIdentifier)
    }
}

// MARK: - DocumentEditorDelegate methods
extension TableViewModel: DocumentEditorDelegate {
    func insertRow(for change: Change) {
        var cellValues: [String: ValueUnion] = [:]
        //TODO: add values
        addRow(with: cellValues, shouldSendEvent: false)
    }

    func deleteRow(for change: Change) {
        guard let rowID = change.change?["rowId"] as? String
        else {
            Log("RowID not found or no cached ValueElement", type: .error)
            return
        }
        deleteSelectedRow([rowID], shouldSendEvent: false)
    }
    
    func moveRow(for change: Change) {
        guard let rowID = change.change?["rowId"] as? String
        else {
            Log("RowID not found or no cached ValueElement", type: .error)
            return
        }
        
        guard var targetRowIndex = change.change?["targetRowIndex"] as? Int else { return }
        guard var rowIndex = tableDataModel.valueToValueElements?.firstIndex(where: { element in
            element.id == rowID
        }) else { return }
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
}
