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

    func addCellModel(rowID: String) {
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
        self.tableDataModel.cellModels.append(rowCellModels)
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
        for row in tableDataModel.selectedRows {
            tableDataModel.rowToCellMap.removeValue(forKey: row)
        }
        tableDataModel.documentEditor?.deleteRows(rowIDs: tableDataModel.selectedRows, fieldIdentifier: tableDataModel.fieldIdentifier)

        tableDataModel.emptySelection()
        tableDataModel.setup()
        uuid = UUID()
        setupCellModels()
    }
    
    func duplicateRow() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        guard let targetRows = tableDataModel.documentEditor?.duplicateRows(rowIDs: tableDataModel.selectedRows, fieldIdentifier: tableDataModel.fieldIdentifier) else { return }
        tableDataModel.setup()

        tableDataModel.emptySelection()
        setupCellModels()
    }

    func insertBelow() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        guard let targetRows = tableDataModel.documentEditor?.insertBelow(selectedRows: tableDataModel.selectedRows, fieldIdentifier: tableDataModel.fieldIdentifier) else { return }
        updateUI()
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

    fileprivate func updateRow(_ id: String, valueElement: ValueElement) {
        tableDataModel.rowToCellMap[id] = tableDataModel.buildAllCellsForRow(tableColumns: tableDataModel.tableColumns, valueElement)
        tableDataModel.rowOrder.append(id)
        addCellModel(rowID: id)
        tableDataModel.filterRowsIfNeeded()
    }
    
    func addRow() {
        let id = generateObjectId()

        if tableDataModel.filterModels.noFilterApplied {
            let rowData = tableDataModel.documentEditor!.insertRowAtTheEnd(id: id, fieldIdentifier: tableDataModel.fieldIdentifier)
            updateRow(id, valueElement: rowData)
        } else {
            if let rowData = tableDataModel.documentEditor?.insertRowWithFilter(id: id, filterModels: tableDataModel.filterModels, fieldIdentifier: tableDataModel.fieldIdentifier, tableDataModel: tableDataModel) {
                updateRow(id, valueElement: rowData)
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
    }
    
    
    func sendEventsIfNeeded() {
        tableDataModel.documentEditor?.onChange(fieldIdentifier: tableDataModel.fieldIdentifier)
    }
}
