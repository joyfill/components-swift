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
    let supportedColumnTypes = ["text", "image", "dropdown"]
    private let mode: Mode
    var fieldDependency: FieldDependency
    
    @Published var shouldShowAddRowButton: Bool = false
    @Published var showRowSelector: Bool = false
    @Published var viewMoreText: String = ""
    @Published var rows: [String] = []
    @Published var quickRows: [String] = []
    @Published var columns: [String] = []
    @Published var quickColumns: [String] = []
    @Published var quickViewRowCount: Int = 0
    private var rowToCellMap: [String?: [FieldTableColumn?]] = [:]
    private var quickRowToCellMap: [String?: [FieldTableColumn?]] = [:]
    private var columnIdToColumnMap: [String: FieldTableColumn] = [:]
    @Published var selectedRows = [String]()

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

    var lastRowSelected: Bool {
        return !selectedRows.isEmpty && selectedRows.last! == rows.last!
    }

    var firstRowSelected: Bool {
        return !selectedRows.isEmpty && selectedRows.first! == rows.first!
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
        selectedRows = filteredcellModels.compactMap { $0.first?.rowID }
    }

    func emptySelection() {
        selectedRows = []
    }

    var allRowSelected: Bool {
        !selectedRows.isEmpty && selectedRows.count == filteredcellModels.count
    }

    var rowTitle: String {
        "\(selectedRows.count) " + (selectedRows.count > 1 ? "rows": "row")
    }
    
    func deleteSelectedRow() {
        guard !selectedRows.isEmpty else {
            return
        }

        for row in selectedRows {
            fieldDependency.fieldData?.deleteRow(id: row)
            rowToCellMap.removeValue(forKey: row)
        }
        fieldDependency.eventHandler.deleteRow(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldDependency.fieldData), targetRowIndexes: selectedRows.map { TargetRowModel.init(id: $0, index: 0)})

        emptySelection()
        setup()
        uuid = UUID()
        setTableDataDidChange(to: true)
        setupCellModels()
    }
    
    func setTableDataDidChange(to: Bool) {
        tableDataDidChange = to
    }
    
    func duplicateRow() {
        guard !selectedRows.isEmpty else { return }
        guard let targetRows = fieldDependency.fieldData?.duplicateRow(selectedRows: selectedRows) else { return }
        setTableDataDidChange(to: true)
        setup()
        fieldDependency.eventHandler.addRow(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldDependency.fieldData), targetRowIndexes: targetRows)
        emptySelection()
        setupCellModels()
    }

    func insertBelow() {
        guard !selectedRows.isEmpty else { return }
        guard let targetRows = fieldDependency.fieldData?.addRow(selectedRows: selectedRows) else { return }
        fieldDependency.eventHandler.addRow(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldDependency.fieldData), targetRowIndexes: targetRows)
        updateUI()
    }

    func moveUP() {
        guard !selectedRows.isEmpty else { return }
        guard let targetRows = fieldDependency.fieldData?.moveUP(rowID: selectedRows.first!) else { return }
        handleMove(targetRows: targetRows)
    }

    func moveDown() {
        guard !selectedRows.isEmpty else { return }
        guard let targetRows = fieldDependency.fieldData?.moveDown(rowID: selectedRows.first!) else { return }
        handleMove(targetRows: targetRows)
    }

    private func handleMove(targetRows: [TargetRowModel]) {
        guard !targetRows.isEmpty else { return }
        fieldDependency.eventHandler.moveRow(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldDependency.fieldData), targetRowIndexes: targetRows)
        updateUI()
    }

    private func updateUI() {
        setTableDataDidChange(to: true)
        setup()
        emptySelection()
        setupCellModels()
    }

    func addRow() {
        let id = generateObjectId()

        if filterModels.noFilterApplied {
            fieldDependency.fieldData?.insertLastRow(id: id)
        } else {
            fieldDependency.fieldData?.addRowWithFilter(id: id, filterModels: filterModels)
        }
        fieldDependency.eventHandler.addRow(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldDependency.fieldData), targetRowIndexes: [TargetRowModel(id: id, index: (fieldDependency.fieldData?.value?.valueElements?.count ?? 1) - 1)])
//        addCellModel(rowID: id)
        updateUI()
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

        emptySelection()
        setup()
        uuid = UUID()
        setTableDataDidChange(to: true)
        setupCellModels()
    }

    private func setupColumns() {
        guard let joyDocModel = fieldDependency.fieldData else { return }
        self.columns = (joyDocModel.tableColumnOrder ?? []).filter { columnID in
            if let columnType = joyDocModel.tableColumns?.first { $0.id == columnID }?.type {
                return supportedColumnTypes.contains(columnType)
            }
            return false
        }
        
        for column in self.columns {
            columnIdToColumnMap[column] = joyDocModel.tableColumns?.first { $0.id == column }
        }
        
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
            for column in self.columns {
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
