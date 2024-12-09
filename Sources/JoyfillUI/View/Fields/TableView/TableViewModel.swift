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

    func addCellModel(rowID: String, index: Int) {
        var rowCellModels = [TableCellModel]()
        tableDataModel.columns.enumerated().forEach { colIndex, colID in
            let columnModel = tableDataModel.getFieldTableColumn(row: rowID, col: colIndex)
            if let columnModel = columnModel {
                let cellModel = TableCellModel(rowID: rowID,
                                               data: columnModel,
                                               documentEditor: tableDataModel.documentEditor,
                                               fieldIdentifier: tableDataModel.fieldIdentifier,
                                               viewMode: .modalView,
                                               editMode: tableDataModel.mode) { editedCell  in
                    self.cellDidChange(rowId: rowID, colIndex: colIndex, editedCell: editedCell)
                }
                rowCellModels.append(cellModel)
            }
        }
        if self.tableDataModel.cellModels.count > (index - 1) {
            self.tableDataModel.cellModels.insert(RowDataModel(index: index, rowID: rowID, cells: rowCellModels), at: index)
        } else {
            self.tableDataModel.cellModels.append(RowDataModel(index: self.tableDataModel.cellModels.count, rowID: rowID, cells: rowCellModels))
        }
    }
    
    func setupCellModels() {
        var cellModels = [RowDataModel]()
        tableDataModel.rowOrder.enumerated().forEach { rowIndex, rowID in
            var rowCellModels = [TableCellModel]()
            tableDataModel.columns.enumerated().forEach { colIndex, colID in
                let columnModel = tableDataModel.getFieldTableColumn(row: rowID, col: colIndex)
                if let columnModel = columnModel {
                    let cellModel = TableCellModel(rowID: rowID,
                                                   data: columnModel,
                                                   documentEditor: tableDataModel.documentEditor,
                                                   fieldIdentifier: tableDataModel.fieldIdentifier,
                                                   viewMode: .modalView,
                                                   editMode: tableDataModel.mode) { editedCell  in
                        self.cellDidChange(rowId: rowID, colIndex: colIndex, editedCell: editedCell)
                    }
                    rowCellModels.append(cellModel)
                }
            }
            cellModels.append(RowDataModel(index: cellModels.count, rowID: rowID, cells: rowCellModels))
        }
        tableDataModel.cellModels = cellModels
        tableDataModel.filteredcellModels = cellModels
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
        
        changes.forEach { (index: Int, value: ValueElement) in
            updateRow(valueElement: value, at: index)
        }
        tableDataModel.emptySelection()
    }

    func insertBelow() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        guard let targetRows = tableDataModel.documentEditor?.insertBelow(selectedRowID: tableDataModel.selectedRows[0], fieldIdentifier: tableDataModel.fieldIdentifier) else { return }
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

    private func updateUI() {
        tableDataModel.setup()
        tableDataModel.emptySelection()
        setupCellModels()
    }
    
    fileprivate func updateRow(valueElement: ValueElement, at index: Int) {
        tableDataModel.rowToCellMap[valueElement.id!] = tableDataModel.buildAllCellsForRow(tableColumns: tableDataModel.tableColumns, valueElement)
        if tableDataModel.rowOrder.count > (index - 1) {
            tableDataModel.rowOrder.insert(valueElement.id!, at: index)
        } else {
            tableDataModel.rowOrder.append(valueElement.id!)
        }
        addCellModel(rowID: valueElement.id!, index: index)
        tableDataModel.filterRowsIfNeeded()
    }
    
    fileprivate func deleteRow(at index: Int, rowID: String) {
        tableDataModel.rowToCellMap.removeValue(forKey: rowID)
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
            let rowData = tableDataModel.documentEditor!.insertRowAtTheEnd(id: id, fieldIdentifier: tableDataModel.fieldIdentifier)
            updateRow(valueElement: rowData, at: tableDataModel.rowOrder.count)
        } else {
            if let rowData = tableDataModel.documentEditor?.insertRowWithFilter(id: id, filterModels: tableDataModel.filterModels, fieldIdentifier: tableDataModel.fieldIdentifier, tableDataModel: tableDataModel) {
                updateRow(valueElement: rowData, at: tableDataModel.rowOrder.count)
            }
        }
    }

    func cellDidChange(rowId: String, colIndex: Int, editedCell: FieldTableColumnLocal) {
        tableDataModel.documentEditor?.cellDidChange(rowId: rowId, colIndex: colIndex, editedCell: editedCell, fieldId: tableDataModel.fieldIdentifier.fieldID)
        // TODO: USE AND SEE WHY WE NEED THIS AND WE DONT
        // If not required, simplify it by removing it to reduce complexity
//        tableDataModel.setup()
//        uuid = UUID()
        tableDataModel.updateCellModel(rowIndex: tableDataModel.rowOrder.firstIndex(of: rowId) ?? 0, colIndex: colIndex, editedCell: editedCell)
        //TODO: Need to check if ui model needs to be upsated
    }

    func bulkEdit(changes: [Int: String]) {
//        tableDataModel.filteredcellModels()
        
        var columnIDChanges = [String: String]()
        changes.forEach { (colIndex: Int, value: String) in
            guard let editedCellId = tableDataModel.getColumnIDAtIndex(index: colIndex) else { return }
            columnIDChanges[editedCellId] = value
        }
        tableDataModel.documentEditor?.bulkEdit(changes: columnIDChanges, selectedRows: tableDataModel.selectedRows, fieldIdentifier: tableDataModel.fieldIdentifier)
        
        for rowId in tableDataModel.selectedRows {
            let rowIndex = tableDataModel.rowOrder.firstIndex(of: rowId) ?? 0
            tableDataModel.columns.enumerated().forEach { colIndex, colID in
                tableDataModel.updateCellModel(rowIndex: rowIndex, colIndex: colIndex, value: changes[colIndex] ?? "")
            }
        }
        tableDataModel.filterRowsIfNeeded()
        
//        tableDataModel.emptySelection()
//        tableDataModel.setup()
//        uuid = UUID()
//        setupCellModels()
        //TODO: Need to check if ui model needs to be updated
    }
    
    
    func sendEventsIfNeeded() {
        tableDataModel.documentEditor?.onChange(fieldIdentifier: tableDataModel.fieldIdentifier)
    }
}
