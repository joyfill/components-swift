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
    private let mode: Mode
    var fieldDependency: FieldDependency
    
    @Published var isTableModalViewPresented = false
    @Published var shouldShowAddRowButton: Bool = false
    @Published var shouldShowDeleteRowButton: Bool = false
    @Published var showRowSelector: Bool = false
    @Published var viewMoreText: String = ""
    @Published var rows: [String] = []
    @Published var quickRows: [String] = []
    @Published var rowsSelection: [Bool] = []
    @Published var columns: [String] = []
    @Published var quickColumns: [String] = []
    @Published var quickViewRowCount: Int = 0
    private var rowToCellMap: [String?: [FieldTableColumn?]] = [:]
    private var quickRowToCellMap: [String?: [FieldTableColumn?]] = [:]
    private var columnIdToColumnMap: [String: FieldTableColumn] = [:]
    var selectedRows = [Int]()

    private var tableDataDidChange = false
    @Published var uuid = UUID()
    
    init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
        self.mode = fieldDependency.mode
        self.showRowSelector = mode == .fill
        self.shouldShowAddRowButton = mode == .fill
        
        setupColumns()
        setup()
    }
    
    private func setup() {
        setupRows()
        rowsSelection = Array.init(repeating: false, count: rows.count)
        
        quickViewRowCount = rows.count >= 3 ? 3 : rows.count
        setDeleteButtonVisibility()
        viewMoreText = rows.count > 1 ? "+\(rows.count)" : ""
    }
    
    func getFieldTableColumn(row: String, col: Int) -> FieldTableColumn? {
        return rowToCellMap[row]?[col]
    }
    
    func getQuickFieldTableColumn(row: String, col: Int) -> FieldTableColumn? {
        return quickRowToCellMap[row]?[col]
    }
    
    
    func getColumnTitle(columnId: String) -> String {
        return columnIdToColumnMap[columnId]?.title ?? ""
    }
    
    func getColumnTitleAtIndex(index: Int) -> String {
        guard index < columns.count else { return "" }
        return columnIdToColumnMap[columns[index]]?.title ?? ""
    }

    func getColumnIDAtIndex(index: Int) -> String? {
        guard index < columns.count else { return nil }
        return columnIdToColumnMap[columns[index]]?.id
    }

    func toggleSelection(at index: Int? = nil) {
        guard let index = index else {
            return
        }
        
        if rowsSelection[index] {
            selectedRows.removeAll { $0 == index }
        } else {
            selectedRows.append(index)
        }
        rowsSelection[index].toggle()
    }
    
    func resetLastSelection() {
        selectedRows = []
    }
    
    func setDeleteButtonVisibility() {
        shouldShowDeleteRowButton = (mode == .fill && !selectedRows.isEmpty)
    }
    
    func deleteSelectedRow() {
        guard !selectedRows.isEmpty else {
            return
        }

        for row in selectedRows {
            fieldDependency.fieldData?.deleteRow(id: rows[row])
            rowToCellMap.removeValue(forKey: rows[row])
        }

        resetLastSelection()
        setup()
        uuid = UUID()
        setTableDataDidChange(to: true)
    }
    
    func setTableDataDidChange(to: Bool) {
        tableDataDidChange = to
    }
    
    func duplicateRow() {
        guard !selectedRows.isEmpty else {
            return
        }
        setTableDataDidChange(to: true)


        for row in selectedRows {
            let id = generateObjectId()
            fieldDependency.fieldData?.duplicateRow(id: rows[row])
            uuid = UUID()
            fieldDependency.eventHandler.addRow(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldDependency.fieldData), targetRowIndex: row+1)
        }
        resetLastSelection()
        setup()
    }

    func addRow() {
        let id = generateObjectId()
        fieldDependency.fieldData?.addRow(id: id)
        resetLastSelection()
        setup()
        uuid = UUID()
        fieldDependency.eventHandler.addRow(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldDependency.fieldData), targetRowIndex: (fieldDependency.fieldData?.value?.valueElements?.count ?? 1) - 1)
    }

    func cellDidChange(rowId: String, colIndex: Int, editedCell: FieldTableColumn) {
        setTableDataDidChange(to: true)
        fieldDependency.fieldData?.cellDidChange(rowId: rowId, colIndex: colIndex, editedCell: editedCell)
        setup()
        uuid = UUID()
    }

    func cellDidChange(rowId: String, colIndex: Int, editedCellId: String, value: String) {
        fieldDependency.fieldData?.cellDidChange(rowId: rowId, colIndex: colIndex, editedCellId: editedCellId, value: value)
        resetLastSelection()
        setup()
        uuid = UUID()
        setTableDataDidChange(to: true)
    }

    private func setupColumns() {
        guard let joyDocModel = fieldDependency.fieldData else { return }
        
        for column in joyDocModel.tableColumnOrder ?? [] {
            columnIdToColumnMap[column] = joyDocModel.tableColumns?.first { $0.id == column }
        }
        
        self.columns = joyDocModel.tableColumnOrder ?? []
        self.quickColumns = columns
        while quickColumns.count > 3 {
            quickColumns.removeLast()
        }
    }
    
    private func setupRows() {
        guard let joyDocModel = fieldDependency.fieldData else { return }
        guard let valueElements = joyDocModel.valueToValueElements, !valueElements.isEmpty else {
            setupQuickTableViewRows()
            return
        }
        
        let nonDeletedRows = valueElements.filter { !($0.deleted ?? false) }
        let sortedRows = sortElementsByRowOrder(elements: nonDeletedRows, rowOrder: joyDocModel.rowOrder)
        var rowToCellMap: [String?: [FieldTableColumn?]] = [:]
        
        for row in sortedRows {
            var cells: [FieldTableColumn?] = []
            for column in joyDocModel.tableColumnOrder ?? [] {
                let columnData = joyDocModel.tableColumns?.first { $0.id == column }
                let cell = buildCell(data: columnData, row: row, column: column)
                cells.append(cell)
            }
            rowToCellMap[row.id] = cells
        }
        
        self.rows = sortedRows.map { $0.id ?? "" }
        self.quickRows = self.rows
        self.rowToCellMap = rowToCellMap
        self.quickRowToCellMap = rowToCellMap
        setupQuickTableViewRows()
    }
    
    private func buildCell(data: FieldTableColumn?, row: ValueElement, column: String) -> FieldTableColumn? {
        var cell = data
        let valueUnion = row.cells?.first(where: { $0.key == column })?.value
        switch data?.type {
        case "text":
            cell?.title = valueUnion?.text ?? ""
        case "dropdown":
            cell?.defaultDropdownSelectedId = valueUnion?.dropdownValue
        case "image":
            cell?.images = valueUnion?.valueElements
        default:
            return nil
        }
        return cell
    }
    
    func setupQuickTableViewRows() {
        if quickRows.isEmpty {
            quickRowToCellMap = [:]
            let id = generateObjectId()
            quickRows = [id]
            quickRowToCellMap = [id : fieldDependency.fieldData?.tableColumns ?? []]
        }
        else {
            while quickRows.count > 3 {
                quickRows.removeLast()
            }
        }
    }
    
    func sortElementsByRowOrder(elements: [ValueElement], rowOrder: [String]?) -> [ValueElement] {
        guard let rowOrder = rowOrder else { return elements }
        let sortedRows = elements.sorted { (a, b) -> Bool in
            if let first = rowOrder.firstIndex(of: a.id ?? ""), let second = rowOrder.firstIndex(of: b.id ?? "") {
                return first < second
            }
            return false
        }
        return sortedRows
    }
    
    func sendEventsIfNeeded() {
        if tableDataDidChange {
            setTableDataDidChange(to: false)
            fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldDependency.fieldData))
        }
    }
}
