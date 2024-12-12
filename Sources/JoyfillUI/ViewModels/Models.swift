//
//  File.swift
//  
//
//  Created by Vishnu Dutt on 25/11/24.
//

import Foundation
import JoyfillModel

struct PageModel {
    let id: String
    var fields: [FieldListModel]
}

struct FieldListModel {
    let fieldIdentifier: FieldIdentifier
    let fieldEditMode: Mode
    var model: FieldListModelType
    var refreshID: UUID
}

struct RowDataModel: Equatable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(cells)
    }

    static func == (lhs: RowDataModel, rhs: RowDataModel) -> Bool {
        lhs.cells == rhs.cells
    }

    var id = UUID()
    let rowID: String
    var cells: [TableCellModel]
}

struct TableDataModel {
    let supportedColumnTypes = ["text", "image", "dropdown"]
    let fieldHeaderModel: FieldHeaderModel?
    let mode: Mode
    let documentEditor: DocumentEditor?
    let fieldIdentifier: FieldIdentifier
    let title: String?
    var rowOrder: [String]
    var valueToValueElements: [ValueElement]?
    var tableColumns: [FieldTableColumn]
    var columns: [String] = []
    var rowToCellMap: [String: [CellDataModel]] = [:]
    var columnIdToColumnMap: [String: CellDataModel] = [:]
    var selectedRows = [String]()
    var cellModels = [RowDataModel]()
    var filteredcellModels = [RowDataModel]()
    var filterModels = [FilterModel]()
    var sortModel = SortModel()
    var id = UUID()
    
    var viewMoreText: String {
        rowOrder.count > 1 ? "+\(rowOrder.count)" : ""
    }

    init(fieldHeaderModel: FieldHeaderModel?,
         mode: Mode,
         documentEditor: DocumentEditor,
         fieldIdentifier: FieldIdentifier) {
        let fieldData = documentEditor.field(fieldID: fieldIdentifier.fieldID)!
        self.fieldHeaderModel = fieldHeaderModel
        self.mode = mode
        self.documentEditor = documentEditor
        self.title = fieldData.title
        self.fieldIdentifier = fieldIdentifier
        self.rowOrder = fieldData.rowOrder ?? []
        self.valueToValueElements = fieldData.valueToValueElements
        self.tableColumns = fieldData.tableColumns ?? []
        setupColumns()
        setup()
        filterRowsIfNeeded()

        self.filterModels = columns.enumerated().map { colIndex, colID in
            FilterModel(colIndex: colIndex, colID: colID)
        }
    }
    
    mutating func filterRowsIfNeeded() {
        filteredcellModels = cellModels
        guard !filterModels .noFilterApplied else {
            return
        }

        for model in filterModels  {
            if model.filterText.isEmpty {
                continue
            }

             let filtred = filteredcellModels.filter { rowArr in
                 let column = rowArr.cells[model.colIndex].data
                switch column.type {
                case "text":
                    return (column.title ?? "").localizedCaseInsensitiveContains(model.filterText)
                case "dropdown":
                    return (column.defaultDropdownSelectedId ?? "") == model.filterText
                default:
                    break
                }
                return false
            }
           filteredcellModels = filtred
        }
    }

    mutating func setup() {
        setupRows()
    }
    
    mutating private func setupColumns() {
        guard let fieldData = documentEditor?.field(fieldID: fieldIdentifier.fieldID) else { return }
        self.columns = (fieldData.tableColumnOrder ?? []).filter { columnID in
            if let columnType = fieldData.tableColumns?.first { $0.id == columnID }?.type {
                return supportedColumnTypes.contains(columnType)
            }
            return false
        }
        
        for column in self.columns {
            if let fieldTableColumn = fieldData.tableColumns?.first(where: { $0.id == column }) {
                let optionsLocal = fieldTableColumn.options?.map { option in
                    OptionLocal(id: option.id, deleted: option.deleted, value: option.value)
                }
                
                let fieldTableColumnLocal = CellDataModel(
                    id: fieldTableColumn.id,
                    defaultDropdownSelectedId: fieldTableColumn.defaultDropdownSelectedId,
                    options: optionsLocal,
                    valueElements: fieldTableColumn.images,
                    type: fieldTableColumn.type,
                    title: fieldTableColumn.title
                )
                columnIdToColumnMap[column] = fieldTableColumnLocal
            }
        }
    }

    func buildAllCellsForRow(tableColumns: [FieldTableColumn], _ row: ValueElement) -> [CellDataModel] {
        var cells: [CellDataModel] = []
        for columnData in tableColumns {
            let optionsLocal = columnData.options?.map { option in
                OptionLocal(id: option.id, deleted: option.deleted, value: option.value)
            }
            let valueUnion = row.cells?.first(where: { $0.key == columnData.id })?.value
            let defaultDropdownSelectedId = valueUnion?.dropdownValue
            
            let selectedOptionText = optionsLocal?.filter{ $0.id == defaultDropdownSelectedId }.first?.value ?? ""
            let columnDataLocal = CellDataModel(id: columnData.id,
                                                        defaultDropdownSelectedId: columnData.defaultDropdownSelectedId,
                                                        options: optionsLocal,
                                                        valueElements: columnData.images,
                                                        type: columnData.type,
                                                        title: columnData.title,
                                                        selectedOptionText: selectedOptionText)
            if let cell = buildCell(data: columnDataLocal, row: row, column: columnData.id!) {
                cells.append(cell)
            }
        }
        return cells
    }
    
    mutating private func setupRows() {
        guard let valueElements = valueToValueElements, !valueElements.isEmpty else {
            setupQuickTableViewRows()
            return
        }
        
        let nonDeletedRows = valueElements.filter { !($0.deleted ?? false) }
        let sortedRows = sortElementsByRowOrder(elements: nonDeletedRows, rowOrder: rowOrder)
        let tableColumns = tableColumns
        for row in sortedRows {
            let cellRowModel = buildAllCellsForRow(tableColumns: tableColumns, row)
            self.rowToCellMap[row.id!] = cellRowModel
        }
        setupQuickTableViewRows()
    }
    
    private func buildCell(data: CellDataModel?, row: ValueElement, column: String) -> CellDataModel? {
        var cell = data
        let valueUnion = row.cells?.first(where: { $0.key == column })?.value
        switch data?.type {
        case "text":
            cell?.title = valueUnion?.text ?? ""
        case "dropdown":
            cell?.defaultDropdownSelectedId = valueUnion?.dropdownValue
        case "image":
            cell?.valueElements = valueUnion?.valueElements
        default:
            return nil
        }
        return cell
    }

    mutating func setupQuickTableViewRows() {
        guard let fieldData = documentEditor?.field(fieldID: fieldIdentifier.fieldID) else { return }

    }
    
    mutating func updateCellModel(rowIndex: Int, rowId: String, colIndex: Int, cellDataModel: CellDataModel) {
        rowToCellMap[rowId]?[colIndex] = cellDataModel
        var cellModel = cellModels[rowIndex].cells[colIndex]
        cellModel.data  = cellDataModel
        cellModels[rowIndex].cells[colIndex] = cellModel
    }

    var lastRowSelected: Bool {
        return !selectedRows.isEmpty && selectedRows.last! == rowOrder.last!
    }
    
    var firstRowSelected: Bool {
        return !selectedRows.isEmpty && selectedRows.first! == rowOrder.first!
    }
    
    mutating func updateCellModel(rowIndex: Int, colIndex: Int, value: String) {
        var cellModel = cellModels[rowIndex].cells[colIndex]
        cellModel.data.title  = value
        cellModels[rowIndex].cells[colIndex] = cellModel
    }
    
    func getFieldTableColumn(row: String, col: Int) -> CellDataModel? {
        return rowToCellMap[row]?[col]
    }
    
    func getQuickFieldTableColumn(row: String, col: Int) -> CellDataModel? {
        if rowOrder.isEmpty {
            let id = generateObjectId()
            let columnData = tableColumns ?? []
            var columnDataLocal: [CellDataModel] = []
            let column = columnData[col]
            var optionsLocal: [OptionLocal] = []
            for option in column.options ?? []{
                optionsLocal.append(OptionLocal(id: option.id, deleted: option.deleted, value: option.value))
            }
            return CellDataModel(id: column.id,
                                         defaultDropdownSelectedId: column.defaultDropdownSelectedId,
                                         options: optionsLocal,
                                         valueElements: column.images,
                                         type: column.type,
                                         title: column.title,
                                         selectedOptionText: optionsLocal.filter { $0.id == column.defaultDropdownSelectedId }.first?.value ?? "")
        }
        return rowToCellMap[row]?[col]
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
    
    mutating func toggleSelection(rowID: String) {
        if selectedRows.contains(rowID) {
            selectedRows = selectedRows.filter({ $0 != rowID})
        } else {
            selectedRows.append(rowID)
        }
    }
    
    mutating func selectAllRows() {
        selectedRows = filteredcellModels.compactMap { $0.cells.first?.rowID }
    }
    
    mutating func emptySelection() {
        selectedRows = []
    }
    
    var allRowSelected: Bool {
        !selectedRows.isEmpty && selectedRows.count == filteredcellModels.count
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
    
}

struct CellDataModel: Hashable, Equatable {
    static func == (lhs: CellDataModel, rhs: CellDataModel) -> Bool {
        lhs.title == rhs.title && rhs.id == lhs.id && rhs.valueElements == lhs.valueElements
    }
    let id: String?
    var defaultDropdownSelectedId: String?
    let options: [OptionLocal]?
    var valueElements: [ValueElement]?
    let type: String?
    var title: String?
    var selectedOptionText: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(id)
        hasher.combine(defaultDropdownSelectedId)
        hasher.combine(valueElements)
    }
}

struct OptionLocal: Identifiable {
    var id: String?
    var deleted: Bool?
    var value: String?
}

struct ChartDataModel {
    var fieldIdentifier: FieldIdentifier
    var valueElements: [ValueElement]?
    var yTitle: String?
    var yMax: Double?
    var yMin: Double?
    var xTitle: String?
    var xMax: Double?
    var xMin: Double?
    var mode: Mode
    var documentEditor: DocumentEditor?
    var fieldHeaderModel: FieldHeaderModel?
}

struct DateTimeDataModel {
    var fieldIdentifier: FieldIdentifier
    var value: ValueUnion?
    var format: String?
    var fieldHeaderModel: FieldHeaderModel?
}

struct DisplayTextDataModel {
    var displayText: String?
    var fontWeight: String?
    var fieldHeaderModel: FieldHeaderModel?
}

struct DropdownDataModel {
    var fieldIdentifier: FieldIdentifier
    var dropdownValue: String?
    var options: [Option]?
    var fieldHeaderModel: FieldHeaderModel?
}

struct ImageDataModel {
    var fieldIdentifier: FieldIdentifier
    var multi: Bool?
    var primaryDisplayOnly: Bool?
    var valueElements: [ValueElement]?
    var mode: Mode
    var fieldHeaderModel: FieldHeaderModel?
}

struct MultiLineDataModel {
    var fieldIdentifier: FieldIdentifier
    var multilineText: String?
    var mode: Mode
    var fieldHeaderModel: FieldHeaderModel?
}

struct MultiSelectionDataModel {
    var fieldIdentifier: FieldIdentifier
    var multi: Bool?
    var options: [Option]?
    var multiSelector: [String]?
    var fieldHeaderModel: FieldHeaderModel?
}

struct NumberDataModel {
    var fieldIdentifier: FieldIdentifier
    var number: Double?
    var mode: Mode
    var fieldHeaderModel: FieldHeaderModel?
}

struct RichTextDataModel {
    var text: String?
    var fieldHeaderModel: FieldHeaderModel?
}

struct SignatureDataModel {
    var fieldIdentifier: FieldIdentifier
    var signatureURL: String?
    var fieldHeaderModel: FieldHeaderModel?
}

struct TextDataModel {
    var fieldIdentifier: FieldIdentifier
    var text: String?
    var mode: Mode
    var fieldHeaderModel: FieldHeaderModel?
}
