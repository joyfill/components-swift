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
    let fieldID: String
    let pageID: String
    let fileID: String
    var refreshID: UUID
}

struct TableDataModel {
    let supportedColumnTypes = ["text", "image", "dropdown"]
    var fieldHeaderModel: FieldHeaderModel?
    var mode: Mode
    var documentEditor: DocumentEditor?
    
    init(fieldHeaderModel: FieldHeaderModel?,
         mode: Mode,
         documentEditor: DocumentEditor,
         listModel: FieldListModel) {
        let fieldData = documentEditor.field(fieldID: listModel.fieldID)
        self.fieldHeaderModel = fieldHeaderModel
        self.mode = mode
        self.documentEditor = documentEditor
        self.pageId = listModel.pageID
        self.fileId = listModel.fileID
        self.tableColumnOrder = fieldData?.tableColumnOrder
        self.tableColumns = fieldData?.tableColumns
        self.valueToValueElements = fieldData?.valueToValueElements
        self.rowOrder = fieldData?.rowOrder
        self.title = fieldData?.title
        self.fieldId = listModel.fieldID
        
        setupColumns()
        setup()
        
        self.filterModels = columns.enumerated().map { colIndex, colID in
            FilterModel(colIndex: colIndex, colID: colID)
        }
    }
    
    var fieldId: String?
    var pageId: String?
    var fileId: String?
    var tableColumnOrder: [String]?
    var tableColumns: [FieldTableColumn]?
    var valueToValueElements: [ValueElement]?
    var rowOrder: [String]?
    var title: String?
    
    var rows: [String] = []
    var quickRows: [String] = []
    var columns: [String] = []
    var quickColumns: [String] = []
    var quickViewRowCount: Int = 0
    var rowToCellMap: [String?: [FieldTableColumn?]] = [:]
    var quickRowToCellMap: [String?: [FieldTableColumn?]] = [:]
    var columnIdToColumnMap: [String: FieldTableColumn] = [:]
    var selectedRows = [String]()
    
    var cellModels = [[TableCellModel]]()
    var filteredcellModels = [[TableCellModel]]()
    
    var filterModels = [FilterModel]()
    var sortModel = SortModel()
    var viewMoreText: String = ""
    
    var value: ValueUnion? {
        .valueElementArray(valueToValueElements ?? [])
    }
    
    mutating func setup() {
        setupRows()
        quickViewRowCount = rows.count >= 3 ? 3 : rows.count
        viewMoreText = rows.count > 1 ? "+\(rows.count)" : ""
    }
    
    mutating private func setupColumns() {
        //        guard let joyDocModel = fieldDependency.fieldData else { return }
        self.columns = (tableColumnOrder ?? []).filter { columnID in
            if let columnType = tableColumns?.first { $0.id == columnID }?.type {
                return supportedColumnTypes.contains(columnType)
            }
            return false
        }
        
        for column in self.columns {
            columnIdToColumnMap[column] = tableColumns?.first { $0.id == column }
        }
        
        self.quickColumns = columns
        while quickColumns.count > 3 {
            quickColumns.removeLast()
        }
    }
    
    mutating private func setupRows() {
        //        guard let joyDocModel = fieldDependency.fieldData else { return }
        guard let valueElements = valueToValueElements, !valueElements.isEmpty else {
            setupQuickTableViewRows()
            return
        }
        
        let nonDeletedRows = valueElements.filter { !($0.deleted ?? false) }
        let sortedRows = sortElementsByRowOrder(elements: nonDeletedRows, rowOrder: rowOrder)
        var rowToCellMap: [String?: [FieldTableColumn?]] = [:]
        
        for row in sortedRows {
            var cells: [FieldTableColumn?] = []
            for column in self.columns {
                let columnData = tableColumns?.first { $0.id == column }
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
    
    mutating func setupQuickTableViewRows() {
        if quickRows.isEmpty {
            quickRowToCellMap = [:]
            let id = generateObjectId()
            quickRows = [id]
            quickRowToCellMap = [id : tableColumns ?? []]
        }
        else {
            while quickRows.count > 3 {
                quickRows.removeLast()
            }
        }
    }
    
    mutating func updateCellModel(rowIndex: Int, colIndex: Int, editedCell: FieldTableColumn) {
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
    
    mutating func updateCellModel(rowIndex: Int, colIndex: Int, value: String) {
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
    
    mutating func toggleSelection(rowID: String) {
        if selectedRows.contains(rowID) {
            selectedRows = selectedRows.filter({ $0 != rowID})
        } else {
            selectedRows.append(rowID)
        }
    }
    
    mutating func selectAllRows() {
        selectedRows = filteredcellModels.compactMap { $0.first?.rowID }
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

struct ChartDataModel {
    var fieldId: String?
    var pageId: String?
    var fileId: String?
    var valueElements: [ValueElement]?
    var yTitle: String?
    var yMax: Double?
    var yMin: Double?
    var xTitle: String?
    var xMax: Double?
    var xMin: Double?
    var mode: Mode
    var documentEditor: DocumentEditor?
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct DateTimeDataModel {
    var fieldId: String?
    var value: ValueUnion?
    var format: String?
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct DisplayTextDataModel {
    var displayText: String?
    var fontWeight: String?
    var fieldHeaderModel: FieldHeaderModel?
}

struct DropdownDataModel {
    var fieldId: String?
    var dropdownValue: String?
    var options: [Option]?
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct ImageDataModel {
    var fieldId: String?
    var multi: Bool?
    var primaryDisplayOnly: Bool?
    var valueElements: [ValueElement]?
    var mode: Mode
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct MultiLineDataModel {
    var fieldId: String?
    var multilineText: String?
    var mode: Mode
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct MultiSelectionDataModel {
    var fieldId: String?
    var currentFocusedFieldsDataId: String?
    var multi: Bool?
    var options: [Option]?
    var multiSelector: [String]?
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct NumberDataModel {
    var fieldId: String?
    var number: Double?
    var mode: Mode
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct RichTextDataModel {
    var text: String?
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct SignatureDataModel {
    var fieldId: String?
    var signatureURL: String?
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct TextDataModel {
    var fieldId: String?
    var text: String?
    var mode: Mode
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}
