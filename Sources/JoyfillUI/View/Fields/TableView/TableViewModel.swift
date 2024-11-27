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

    private var tableDataDidChange = false
    @Published var uuid = UUID()
    
    init(tableDataModel: TableDataModel) {
        self.tableDataModel = tableDataModel
        self.showRowSelector = tableDataModel.mode == .fill
        self.shouldShowAddRowButton = tableDataModel.mode == .fill
    }

    func addCellModel(rowID: String) {
        let rowIndex: Int = tableDataModel.rows.isEmpty ? 0 : tableDataModel.rows.count - 1
        var rowCellModels = [TableCellModel]()
        tableDataModel.columns.enumerated().forEach { colIndex, colID in
            let columnModel = tableDataModel.getFieldTableColumn(row: rowID, col: colIndex)
            if let columnModel = columnModel {
                let cellModel = TableCellModel(rowID: rowID,
                                               data: columnModel,
                                               fieldId: tableDataModel.fieldId!,
                                               viewMode: .modalView,
                                               editMode: tableDataModel.mode) { editedCell  in
                    self.cellDidChange(rowId: rowID, colIndex: colIndex, editedCell: editedCell)
                }
                rowCellModels.append(cellModel)
            }
        }
        self.tableDataModel.cellModels.append(rowCellModels)
    }

    var rowTitle: String {
        "\(tableDataModel.selectedRows.count) " + (tableDataModel.selectedRows.count > 1 ? "rows": "row")
    }
    
    func deleteSelectedRow() {
        for row in tableDataModel.selectedRows {
            tableDataModel.rowToCellMap.removeValue(forKey: row)
        }
        tableDataModel.documentEditor?.deleteRows(rowIDs: tableDataModel.selectedRows, tableDataModel: tableDataModel)

        tableDataModel.emptySelection()
        tableDataModel.setup()
        uuid = UUID()
        setTableDataDidChange(to: true)
        tableDataModel.setupCellModels()
    }
    
    func setTableDataDidChange(to: Bool) {
        tableDataDidChange = to
    }
    
    func duplicateRow() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        guard let targetRows = tableDataModel.documentEditor?.duplicateRow(selectedRows: tableDataModel.selectedRows, tableDataModel: tableDataModel) else { return }
        setTableDataDidChange(to: true)
        tableDataModel.setup()

        tableDataModel.emptySelection()
        tableDataModel.setupCellModels()
    }

    func insertBelow() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        guard let targetRows = tableDataModel.documentEditor?.addRow(selectedRows: tableDataModel.selectedRows, tableDataModel: tableDataModel) else { return }
        updateUI()
    }

    func moveUP() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        tableDataModel.documentEditor?.moveUP(rowID: tableDataModel.selectedRows.first!, tableDataModel: tableDataModel)
        updateUI()
    }

    func moveDown() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        tableDataModel.documentEditor?.moveDown(rowID: tableDataModel.selectedRows.first!, tableDataModel: tableDataModel)
        updateUI()
    }

    private func updateUI() {
        setTableDataDidChange(to: true)
        tableDataModel.setup()
        tableDataModel.emptySelection()
        tableDataModel.setupCellModels()
    }

    func addRow() {
        let id = generateObjectId()

        if tableDataModel.filterModels.noFilterApplied {
            tableDataModel.documentEditor?.insertLastRow(id: id, tableDataModel: tableDataModel)
        } else {
            tableDataModel.documentEditor?.addRowWithFilter(id: id, filterModels: tableDataModel.filterModels, tableDataModel: tableDataModel)
        }
        
        updateUI()
    }

    func cellDidChange(rowId: String, colIndex: Int, editedCell: FieldTableColumn) {
        setTableDataDidChange(to: true)
        tableDataModel.documentEditor?.cellDidChange(rowId: rowId, colIndex: colIndex, editedCell: editedCell, fieldId: tableDataModel.fieldId!)
        tableDataModel.setup()
        uuid = UUID()
        tableDataModel.updateCellModel(rowIndex: tableDataModel.rows.firstIndex(of: rowId) ?? 0, colIndex: colIndex, editedCell: editedCell)
    }

    func bulkEdit(changes: [Int: String]) {
        for row in tableDataModel.selectedRows {
            for colIndex in changes.keys {
                if let editedCellId = tableDataModel.getColumnIDAtIndex(index: colIndex), let change = changes[colIndex] {
                    tableDataModel.documentEditor?.cellDidChange(rowId: row, colIndex: colIndex, editedCellId: editedCellId, value: change, fieldId: tableDataModel.fieldId!)
                }
            }
        }
        //Update local model with new bulk edit changes
        tableDataModel.valueToValueElements = tableDataModel.documentEditor?.field(fieldID: tableDataModel.fieldId!)?.valueToValueElements
        tableDataModel.emptySelection()
        tableDataModel.setup()
        uuid = UUID()
        setTableDataDidChange(to: true)
        tableDataModel.setupCellModels()
    }
    
    
    func sendEventsIfNeeded() {
        if tableDataDidChange {
            setTableDataDidChange(to: false)
            tableDataModel.documentEditor?.sendEventsIfNeeded(tableDataModel: tableDataModel)
        }
    }
}
