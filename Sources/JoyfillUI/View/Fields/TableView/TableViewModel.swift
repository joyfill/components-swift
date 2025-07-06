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

    @Published var uuid = UUID()
    
    init(tableDataModel: TableDataModel) {
        self.tableDataModel = tableDataModel
        self.showRowSelector = tableDataModel.mode == .fill
        self.shouldShowAddRowButton = tableDataModel.mode == .fill
        
        setupCellModels()
        self.tableDataModel.filterRowsIfNeeded()
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
                                               editMode: tableDataModel.mode) { [weak self] cellDataModel in
                    if let colIndex = self?.tableDataModel.columns.firstIndex(of: rowDataModel.id) {
                        self?.cellDidChange(rowId: rowID, colIndex: colIndex, cellDataModel: cellDataModel)
                    } else {
                        Log("Could not find column index for \(rowDataModel.id)", type: .error)
                    }
                }
                rowCellModels.append(cellModel)
            }
        if self.tableDataModel.cellModels.count > (index - 1) {
            self.tableDataModel.cellModels.insert(RowDataModel(rowID: rowID, cells: rowCellModels), at: index)
        } else {
            self.tableDataModel.cellModels.append(RowDataModel(rowID: rowID, cells: rowCellModels))
        }
    }
    
    func setupCellModels() {
        var cellModels = [RowDataModel]()
        let rowDataMap = setupRows()
        tableDataModel.rowOrder.enumerated().forEach { rowIndex, rowID in
            var rowCellModels = [TableCellModel]()
            tableDataModel.columns.enumerated().forEach { colIndex, colID in
                let columnModel = rowDataMap[rowID]?[colIndex]
                if let columnModel = columnModel {
                    let cellModel = TableCellModel(rowID: rowID,
                                                   data: columnModel,
                                                   documentEditor: tableDataModel.documentEditor,
                                                   fieldIdentifier: tableDataModel.fieldIdentifier,
                                                   viewMode: .modalView,
                                                   editMode: tableDataModel.mode) { [weak self] cellDataModel in
                        self?.cellDidChange(rowId: rowID, colIndex: colIndex, cellDataModel: cellDataModel)
                    }
                    rowCellModels.append(cellModel)
                }
            }
            cellModels.append(RowDataModel(rowID: rowID, cells: rowCellModels))
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
        guard let firstSelectedRowID = tableDataModel.selectedRows.first else {
            Log("No selected row", type: .error)
            return
        }
        guard let targetRows = tableDataModel.documentEditor?.insertBelow(selectedRowID: firstSelectedRowID, fieldIdentifier: tableDataModel.fieldIdentifier) else { return }
        guard let lastRowIndex = tableDataModel.rowOrder.firstIndex(of: firstSelectedRowID) else {
            Log("Could not find index of last selected row", type: .error)
            return
        }
        updateRow(valueElement: targetRows.0, at: lastRowIndex+1)
        tableDataModel.emptySelection()
    }

    func moveUP() {
        guard let firstSelectedRowID = tableDataModel.selectedRows.first else {
            Log("No selected row", type: .error)
            return
        }
        tableDataModel.documentEditor?.moveRowUp(rowID: firstSelectedRowID, fieldIdentifier: tableDataModel.fieldIdentifier)
        guard let lastRowIndex = tableDataModel.rowOrder.firstIndex(of: firstSelectedRowID) else {
            Log("RowID not found in rowOrder", type: .error)
            return
        }
        moveUP(at: lastRowIndex, rowID: firstSelectedRowID)
    }

    func moveDown() {
        guard let firstSelectedRowID = tableDataModel.selectedRows.first else {
            Log("No selected row", type: .error)
            return
        }
        tableDataModel.documentEditor?.moveRowDown(rowID: firstSelectedRowID, fieldIdentifier: tableDataModel.fieldIdentifier)
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

    func addRow() {
        let id = generateObjectId()
        if tableDataModel.filterModels.noFilterApplied {
            guard let rowData = tableDataModel.documentEditor?.insertRowAtTheEnd(id: id, fieldIdentifier: tableDataModel.fieldIdentifier) else {
                Log("Row data is nil", type: .error)
                return
            }
            updateRow(valueElement: rowData, at: tableDataModel.rowOrder.count)
        } else {
            if let rowData = tableDataModel.documentEditor?.insertRowWithFilter(id: id, filterModels: tableDataModel.filterModels, fieldIdentifier: tableDataModel.fieldIdentifier, tableDataModel: tableDataModel) {
                updateRow(valueElement: rowData, at: tableDataModel.rowOrder.count)
            }
        }
    }

    func cellDidChange(rowId: String, colIndex: Int, cellDataModel: CellDataModel) {
        tableDataModel.documentEditor?.cellDidChange(rowId: rowId, colIndex: colIndex, cellDataModel: cellDataModel, fieldId: tableDataModel.fieldIdentifier.fieldID)
        
        tableDataModel.updateCellModel(rowIndex: tableDataModel.rowOrder.firstIndex(of: rowId) ?? 0, rowId: rowId, colIndex: colIndex, cellDataModel: cellDataModel, isBulkEdit: false)
    }

    func bulkEdit(changes: [Int: String]) {
        var columnIDChanges = [String: String]()
        changes.forEach { (colIndex: Int, value: String) in
            guard let cellDataModelId = tableDataModel.getColumnIDAtIndex(index: colIndex) else { return }
            columnIDChanges[cellDataModelId] = value
        }
        tableDataModel.documentEditor?.bulkEdit(changes: columnIDChanges, selectedRows: tableDataModel.selectedRows, fieldIdentifier: tableDataModel.fieldIdentifier)
        for rowId in tableDataModel.selectedRows {
            let rowIndex = tableDataModel.rowOrder.firstIndex(of: rowId) ?? 0
            tableDataModel.columns.enumerated().forEach { colIndex, colID in
                var cellDataModel = tableDataModel.cellModels[rowIndex].cells[colIndex].data
                guard let change = changes[colIndex] else { return }
                if cellDataModel.type == "dropdown" {
                    cellDataModel.selectedOptionText =  cellDataModel.options?.filter { $0.id == change }.first?.value ?? ""
                    cellDataModel.defaultDropdownSelectedId = change
                } else {
                    cellDataModel.title = change
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
