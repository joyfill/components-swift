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
    private var joyDocModel: JoyDocField?
    
    @Published var isTableModalViewPresented = false
    @Published var shouldShowAddRowButton: Bool = false
    @Published var shouldShowDeleteRowButton: Bool = false
    @Published var showRowSelector: Bool = false
    @Published var tableViewTitle: String = ""
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
    private var selectedRow: Int?
    private let fieldDependency: FieldDependency
    private var tableDataDidChange = false
    
    init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
        self.mode = fieldDependency.mode
        self.joyDocModel = fieldDependency.fieldData
        self.showRowSelector = mode == .fill
        self.shouldShowAddRowButton = mode == .fill
        
        setupColumns(joyDocModel: joyDocModel)
        setup()
    }
    
    private func setup() {
        setupRows(joyDocModel: joyDocModel)
        rowsSelection = Array.init(repeating: false, count: rows.count)
        
        quickViewRowCount = rows.count >= 3 ? 3 : rows.count
        setDeleteButtonVisibility()
        viewMoreText = rows.count > 1 ? "+\(rows.count)" : ""
        tableViewTitle = joyDocModel?.title ?? ""
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
    
    func toggleSelection(at index: Int? = nil) {
        if let lastSelectedRow = selectedRow {
            rowsSelection[lastSelectedRow].toggle()
            selectedRow = nil
        }
        
        guard let index = index else {
            return
        }
        
        rowsSelection[index].toggle()
        selectedRow = rowsSelection[index] ? index : nil
    }
    
    func resetLastSelection() {
        selectedRow = nil
    }
    
    func setDeleteButtonVisibility() {
        shouldShowDeleteRowButton = (mode == .fill && selectedRow != nil)
    }
    
    func deleteSelectedRow() {
        guard let selectedRow = selectedRow else {
            return
        }
        setTableDataDidChange(to: true)
        
        joyDocModel?.deleteRow(id: rows[selectedRow])
        rowToCellMap.removeValue(forKey: rows[selectedRow])
        resetLastSelection()
        setup()
    }
    
    func setTableDataDidChange(to: Bool) {
        tableDataDidChange = to
    }
    
    func addRow() {
        setTableDataDidChange(to: true)
        let id = generateObjectId()
        joyDocModel?.addRow(id: id)
        resetLastSelection()
        setup()
    }
    
    func cellDidChange(rowId: String, colIndex: Int, editedCell: FieldTableColumn) {
        setTableDataDidChange(to: true)
        joyDocModel?.cellDidChange(rowId: rowId, colIndex: colIndex, editedCell: editedCell)
        setup()
    }
    
    private func setupColumns(joyDocModel: JoyDocField?) {
        guard let joyDocModel = joyDocModel else { return }
        
        for column in joyDocModel.tableColumnOrder ?? [] {
            columnIdToColumnMap[column] = joyDocModel.tableColumns?.first { $0.id == column }
        }
        
        self.columns = joyDocModel.tableColumnOrder ?? []
        self.quickColumns = columns
        while quickColumns.count > 3 {
            quickColumns.removeLast()
        }
    }
    
    private func setupRows(joyDocModel: JoyDocField?) {
        guard let joyDocModel = joyDocModel else { return }
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
            cell?.images = valueUnion?.images
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
            quickRowToCellMap = [id : joyDocModel?.tableColumns ?? []]
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
            let change = FieldChange(changeData: ["value" : joyDocModel])
            fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldDependency.fieldData, changes: change))
        }
    }
    
    func uploadAction() {
        let uploadEvent = UploadEvent(field: joyDocModel!) { urls in
            for imageURL in urls {
//                let valueElement = valueElements.first { valueElement in
//                    if valueElement.url == imageURL {
//                        return true
//                    }
//                    return false
//                } ?? ValueElement(id: JoyfillModel.generateObjectId(), url: imageURL)
//                valueElements.append(valueElement)
            }
        }
         fieldDependency.eventHandler.onUpload(event: uploadEvent)
    }
    
}
