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
    @Published var allRowSelected: Bool = false
    @Published var viewMoreText: String = ""
    @Published var rows: [String] = []
    @Published var quickRows: [String] = []
    @Published var columns: [String] = []
    @Published var quickColumns: [String] = []
    @Published var quickViewRowCount: Int = 0
    private var rowToCellMap: [String?: [FieldTableColumn?]] = [:]
    private var quickRowToCellMap: [String?: [FieldTableColumn?]] = [:]
    private var columnIdToColumnMap: [String: FieldTableColumn] = [:]
    var selectedRows = [String]()

    @Published var cellModels = [[TableCellModel]]()
    @Published var filteredcellModels = [[TableCellModel]]()

    @Published var filterModels = [FilterModel]()
    @Published var sortModel = SortModel()

    private var tableDataDidChange = false
    @Published var uuid = UUID()
    
    init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
        self.mode = fieldDependency.mode
        self.showRowSelector = mode == .fill
        self.shouldShowAddRowButton = mode == .fill
        setupColumns()
        setup()
        setupCellModels()
        self.filterModels = columns.enumerated().map { colIndex, colID in
            FilterModel(colIndex: colIndex, colID: colID)
        }
    }
    
    private func setup() {
        setupRows()
        quickViewRowCount = rows.count >= 3 ? 3 : rows.count
        setDeleteButtonVisibility()
        viewMoreText = rows.count > 1 ? "+\(rows.count)" : ""
    }

    func setupCellModels() {
        var cellModels = [[TableCellModel]]()
        rows.enumerated().forEach { rowIndex, rowID in
            var rowCellModels = [TableCellModel]()
            columns.enumerated().forEach { colIndex, colID in
                let columnModel = getFieldTableColumn(row: rowID, col: colIndex)
                if let columnModel = columnModel {
                    let cellModel = TableCellModel(rowID: rowID, data: columnModel, eventHandler: fieldDependency.eventHandler, fieldData: fieldDependency.fieldData, viewMode: .modalView, editMode: fieldDependency.mode) { editedCell  in
                        self.cellDidChange(rowId: rowID, colIndex: colIndex, editedCell: editedCell)
                    }
                    rowCellModels.append(cellModel)
                }
            }
            cellModels.append(rowCellModels)
        }
        self.cellModels = cellModels
        self.filteredcellModels = cellModels
    }

    func addCellModel(rowID: String) {
        let rowIndex: Int = rows.isEmpty ? 0 : rows.count - 1
        var rowCellModels = [TableCellModel]()
        columns.enumerated().forEach { colIndex, colID in
            let columnModel = getFieldTableColumn(row: rowID, col: colIndex)
            if let columnModel = columnModel {
                let cellModel = TableCellModel(rowID: rowID, data: columnModel, eventHandler: fieldDependency.eventHandler, fieldData: fieldDependency.fieldData, viewMode: .modalView, editMode: fieldDependency.mode) { editedCell  in
                    self.cellDidChange(rowId: rowID, colIndex: colIndex, editedCell: editedCell)
                }
                rowCellModels.append(cellModel)
            }
        }
        self.cellModels.append(rowCellModels)
    }

    func updateCellModel(rowIndex: Int, colIndex: Int, editedCell: FieldTableColumn) {
        var cellModel = cellModels[rowIndex][colIndex]
        cellModel.data  = editedCell
        cellModels[rowIndex][colIndex] = cellModel
    }

    func updateCellModel(rowIndex: Int, colIndex: Int, value: String) {
        var cellModel = cellModels[rowIndex][colIndex]
        cellModel.data.title  = value
        self.cellModels[rowIndex][colIndex] = cellModel
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

    func getColumnType(columnId: String) -> String? {
        return columnIdToColumnMap[columnId]?.type
    }

    func getColumnIDAtIndex(index: Int) -> String? {
        guard index < columns.count else { return nil }
        return columnIdToColumnMap[columns[index]]?.id
    }

    func toggleSelection(rowID: String) {
        if selectedRows.contains(rowID) {
            selectedRows = selectedRows.filter({ $0 != rowID})
        } else {
            selectedRows.append(rowID)
        }
    }

    func selectAllRows() {
        selectedRows = rows
    }

    func resetLastSelection() {
        selectedRows = []
    }
    
    func setDeleteButtonVisibility() {
        shouldShowDeleteRowButton = (mode == .fill && !selectedRows.isEmpty && !filteredcellModels.isEmpty)
    }
    
    func deleteSelectedRow() {
        guard !selectedRows.isEmpty else {
            return
        }

        for row in selectedRows {
            fieldDependency.fieldData?.deleteRow(id: row)
            rowToCellMap.removeValue(forKey: row)
        }

        resetLastSelection()
        setup()
        uuid = UUID()
        setTableDataDidChange(to: true)
        setupCellModels()
    }
    
    func setTableDataDidChange(to: Bool) {
        tableDataDidChange = to
    }
    
    func duplicateRow() {
        guard !selectedRows.isEmpty else {
            return
        }

        var targetRows = [TargerRowModel]()
        for row in selectedRows {
            let newRowID = generateObjectId()
            let newIndex = fieldDependency.fieldData?.duplicateRow(id: row, newRowID: newRowID)
            targetRows.append(TargerRowModel(id: newRowID, index: newIndex!))
            uuid = UUID()
        }
        setTableDataDidChange(to: true)
        setup()
        fieldDependency.eventHandler.addRow(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldDependency.fieldData), targetRowIndexes: targetRows)
        resetLastSelection()
        setupCellModels()
    }

    func addRow() {
        let id = generateObjectId()

        if filterModels.noFilterApplied {
            fieldDependency.fieldData?.addRow(id: id)
        } else {
            fieldDependency.fieldData?.addRowWithFilter(id: id, filterModels: filterModels)
        }
        resetLastSelection()
        setup()
        uuid = UUID()
        fieldDependency.eventHandler.addRow(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldDependency.fieldData), targetRowIndexes: [TargerRowModel(id: id, index: (fieldDependency.fieldData?.value?.valueElements?.count ?? 1) - 1)])
//        addCellModel(rowID: id)
        setupCellModels()
    }

    func cellDidChange(rowId: String, colIndex: Int, editedCell: FieldTableColumn) {
        setTableDataDidChange(to: true)
        fieldDependency.fieldData?.cellDidChange(rowId: rowId, colIndex: colIndex, editedCell: editedCell)
        setup()
        uuid = UUID()
        updateCellModel(rowIndex: rows.firstIndex(of: rowId) ?? 0, colIndex: colIndex, editedCell: editedCell)
    }

    func bulkEdit(changes: [Int: String]) {
        for row in selectedRows {
            for colIndex in changes.keys {
                if let editedCellId = getColumnIDAtIndex(index: colIndex), let change = changes[colIndex] {
                    fieldDependency.fieldData?.cellDidChange(rowId: row, colIndex: colIndex, editedCellId: editedCellId, value: change)
                }
            }
        }

        resetLastSelection()
        setup()
        uuid = UUID()
        setTableDataDidChange(to: true)
        setupCellModels()
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
