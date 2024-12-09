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
        self.tableDataModel.cellModels.insert(rowCellModels, at: index)
    }
    
    func setupCellModels() {
        var cellModels = [[TableCellModel]]()
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
            cellModels.append(rowCellModels)
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
    }

    func moveUP() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        tableDataModel.documentEditor?.moveRowUp(rowID: tableDataModel.selectedRows.first!, fieldIdentifier: tableDataModel.fieldIdentifier)
        updateUI()
    }

    func moveDown() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        tableDataModel.documentEditor?.moveRowDown(rowID: tableDataModel.selectedRows.first!, fieldIdentifier: tableDataModel.fieldIdentifier)
        updateUI()
    }

    private func updateUI() {
        tableDataModel.setup()
        tableDataModel.emptySelection()
        setupCellModels()
    }
    
    fileprivate func updateRow(valueElement: ValueElement, at index: Int) {
        tableDataModel.rowToCellMap[valueElement.id!] = tableDataModel.buildAllCellsForRow(tableColumns: tableDataModel.tableColumns, valueElement)
        tableDataModel.rowOrder.insert(valueElement.id!, at: index)
        addCellModel(rowID: valueElement.id!, index: index)
        tableDataModel.filterRowsIfNeeded()
    }
    
    fileprivate func deleteRow(at index: Int, rowID: String) {
        tableDataModel.rowToCellMap.removeValue(forKey: rowID)
        tableDataModel.rowOrder.remove(at: index)
        self.tableDataModel.cellModels.remove(at: index)
        tableDataModel.filterRowsIfNeeded()
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
        uuid = UUID()
        tableDataModel.updateCellModel(rowIndex: tableDataModel.rowOrder.firstIndex(of: rowId) ?? 0, colIndex: colIndex, editedCell: editedCell)
        //TODO: Need to check if ui model needs to be upsated
    }

    func bulkEdit(changes: [Int: String]) {
        var columnIDChanges = [String: String]()
        changes.forEach { (colIndex: Int, value: String) in
            guard let editedCellId = tableDataModel.getColumnIDAtIndex(index: colIndex) else { return }
            columnIDChanges[editedCellId] = value
        }
        tableDataModel.documentEditor?.bulkEdit(changes: columnIDChanges, selectedRows: tableDataModel.selectedRows, fieldIdentifier: tableDataModel.fieldIdentifier)
        //Update local model with new bulk edit changes
//        tableDataModel.valueToValueElements = tableDataModel.documentEditor?.field(fieldID: tableDataModel.fieldIdentifier.fieldID!)?.valueToValueElements
        tableDataModel.emptySelection()
        tableDataModel.setup()
        uuid = UUID()
        setupCellModels()
        //TODO: Need to check if ui model needs to be upsated
    }
    
    
    func sendEventsIfNeeded() {
        tableDataModel.documentEditor?.onChange(fieldIdentifier: tableDataModel.fieldIdentifier)
    }
}
