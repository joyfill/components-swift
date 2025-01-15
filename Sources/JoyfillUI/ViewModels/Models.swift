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
}

struct RowDataModel: Equatable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(rowID)
    }

    static func == (lhs: RowDataModel, rhs: RowDataModel) -> Bool {
        lhs.rowID == rhs.rowID
    }

    let rowID: String
    var cells: [TableCellModel]
    
    var filledCellCount: Int {
        cells.filter { $0.data.isCellFilled }.count
    }
}

let supportedColumnTypes: [ColumnTypes] = [.text, .image, .dropdown, .block, .date, .number, .multiSelect, .progress, .barcode]

extension FieldTableColumn {
    func getFormat(from tableColumns: [TableColumn]?) -> DateFormatType? {
        return tableColumns?.first(where: { $0.id == self.id })?.format
    }
}

struct TableDataModel {
    let fieldHeaderModel: FieldHeaderModel?
    let mode: Mode
    let documentEditor: DocumentEditor?
    let fieldIdentifier: FieldIdentifier
    let title: String?
    var rowOrder: [String]
    var valueToValueElements: [ValueElement]?
    var tableColumns = [FieldTableColumn]()
    let fieldPositionTableColumns: [TableColumn]?
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
        let fieldPosition = documentEditor.fieldPosition(fieldID: fieldIdentifier.fieldID)!
        self.fieldHeaderModel = fieldHeaderModel
        self.mode = mode
        self.documentEditor = documentEditor
        self.title = fieldData.title
        self.fieldIdentifier = fieldIdentifier
        self.rowOrder = fieldData.rowOrder ?? []
        self.valueToValueElements = fieldData.valueToValueElements
        self.fieldPositionTableColumns = fieldPosition.tableColumns

        fieldData.tableColumnOrder?.enumerated().forEach() { colIndex, colID in
            let column = fieldData.tableColumns?.first { $0.id == colID }
            if fieldPositionTableColumns?.first(where: { $0.id == colID })?.hidden == true { return }
            guard let column = column else { return }
            let filterModel = FilterModel(colIndex: colIndex, colID: colID, type: column.type ?? .unknown)
            self.filterModels.append(filterModel)
            if let columnType = column.type {
                if supportedColumnTypes.contains(columnType) {
                    tableColumns.append(column)
                }
            }
        }
        setupColumns()
        filterRowsIfNeeded()
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
                case .text:
                    return (column.title ?? "").localizedCaseInsensitiveContains(model.filterText)
                case .dropdown:
                    return (column.defaultDropdownSelectedId ?? "") == model.filterText
                case .number:
                    let columnNumberString = String(format: "%g", column.number ?? 0)
                    return columnNumberString.hasPrefix(model.filterText)
                case .multiSelect:
                    return column.multiSelectValues?.contains(model.filterText) ?? false
                default:
                    break
                }
                return false
            }
           filteredcellModels = filtred
        }
    }
    
    mutating private func setupColumns() {
        guard let fieldData = documentEditor?.field(fieldID: fieldIdentifier.fieldID) else { return }
        
        for fieldTableColumn in self.tableColumns {
                let optionsLocal = fieldTableColumn.options?.map { option in
                    OptionLocal(id: option.id, deleted: option.deleted, value: option.value, color: option.color)
                }
                
                let fieldTableColumnLocal = CellDataModel(
                    id: fieldTableColumn.id!,
                    defaultDropdownSelectedId: fieldTableColumn.defaultDropdownSelectedId,
                    options: optionsLocal,
                    valueElements: fieldTableColumn.images ?? [],
                    type: fieldTableColumn.type,
                    title: fieldTableColumn.title,
                    number: fieldTableColumn.number,
                    date: fieldTableColumn.date,
                    format: fieldTableColumn.getFormat(from: fieldPositionTableColumns),
                    multiSelectValues: fieldTableColumn.multiSelectValues,
                    multi: fieldTableColumn.multi)
                columnIdToColumnMap[fieldTableColumn.id!] = fieldTableColumnLocal
        }
    }
    
    

    func buildAllCellsForRow(tableColumns: [FieldTableColumn], _ row: ValueElement) -> [CellDataModel] {
        var cells: [CellDataModel] = []
        for columnData in tableColumns {
            let optionsLocal = columnData.options?.map { option in
                OptionLocal(id: option.id, deleted: option.deleted, value: option.value, color: option.color)
            }
            let valueUnion = row.cells?.first(where: { $0.key == columnData.id })?.value
            let defaultDropdownSelectedId = valueUnion?.dropdownValue
            
            let selectedOptionText = optionsLocal?.filter{ $0.id == defaultDropdownSelectedId }.first?.value ?? ""
            let columnDataLocal = CellDataModel(id: columnData.id!,
                                                defaultDropdownSelectedId: columnData.defaultDropdownSelectedId,
                                                options: optionsLocal,
                                                valueElements: columnData.images ?? [],
                                                type: columnData.type,
                                                title: columnData.title,
                                                number: columnData.number,
                                                selectedOptionText: selectedOptionText,
                                                date: columnData.date,
                                                format: columnData.getFormat(from: fieldPositionTableColumns),
                                                multiSelectValues: columnData.multiSelectValues,
                                                multi: columnData.multi)
            if let cell = buildCell(data: columnDataLocal, row: row, column: columnData.id!) {
                cells.append(cell)
            }
        }
        return cells
    }
    
    private func buildCell(data: CellDataModel?, row: ValueElement, column: String) -> CellDataModel? {
        var cell = data
        let valueUnion = row.cells?.first(where: { $0.key == column })?.value
        
        switch data?.type {
        case .text:
            cell?.title = valueUnion?.text ?? ""
        case .dropdown:
            cell?.defaultDropdownSelectedId = valueUnion?.dropdownValue
        case .image:
            cell?.valueElements = valueUnion?.valueElements ?? []
        case .block:
            cell?.title = valueUnion?.text ?? ""
        case .date:
            cell?.date = valueUnion?.number
        case .number:
            cell?.number = valueUnion?.number
        case .multiSelect:
            cell?.multiSelectValues = valueUnion?.stringArray
        case .progress:
            cell?.title = valueUnion?.text ?? ""
        case .barcode:
            cell?.title = valueUnion?.text ?? ""
        default:
            return nil
        }
        return cell
    }
    
    mutating func updateCellModel(rowIndex: Int, rowId: String, colIndex: Int, cellDataModel: CellDataModel, isBulkEdit: Bool) {
        var cellModel = cellModels[rowIndex].cells[colIndex]
        cellModel.data = cellDataModel
        cellModels[rowIndex].cells[colIndex] = cellModel
        if isBulkEdit {
            cellModels[rowIndex].cells[colIndex].id = UUID()
        }
    }

    var lastRowSelected: Bool {
        return !selectedRows.isEmpty && selectedRows.last! == rowOrder.last!
    }
    
    var firstRowSelected: Bool {
        return !selectedRows.isEmpty && selectedRows.first! == rowOrder.first!
    }
    
    var shouldDisableMoveUp: Bool {
        firstRowSelected || !filterModels.noFilterApplied || sortModel.order != .none
    }
    
    var shouldDisableMoveDown: Bool {
        lastRowSelected || !filterModels.noFilterApplied || sortModel.order != .none
    }
    
    mutating func updateCellModel(rowIndex: Int, colIndex: Int, value: String) {
        var cellModel = cellModels[rowIndex].cells[colIndex]
        cellModel.data.title  = value
        cellModels[rowIndex].cells[colIndex] = cellModel
    }

    func getFieldTableColumn(rowIndex: Int, col: Int) -> CellDataModel? {
        return cellModels[rowIndex].cells[col].data
    }
    
    func getDummyCell(col: Int, selectedOptionText: String = "") -> CellDataModel? {
        var dummyCell = cellModels.first?.cells[col].data
        dummyCell?.selectedOptionText = selectedOptionText
        return dummyCell
    }

    func getFieldTableColumn(row: String, col: Int) -> CellDataModel {
        let rowIndex = filteredcellModels.firstIndex(where: { rowDataModel in
            rowDataModel.rowID == row
        })!
        return filteredcellModels[rowIndex].cells[col].data
    }
    
    func getLongestBlockText() -> String {
        filteredcellModels.flatMap { $0.cells }
            .filter { $0.data.type == .block }
            .map { $0.data.title }
            .max(by: { $0.count < $1.count }) ?? ""
    }
    
    func getQuickFieldTableColumn(row: String, col: Int) -> CellDataModel? {
        if rowOrder.isEmpty {
            let id = generateObjectId()
            let columnData = tableColumns ?? []
            var columnDataLocal: [CellDataModel] = []
            let column = columnData[col]
            var optionsLocal: [OptionLocal] = []
            for option in column.options ?? []{
                optionsLocal.append(OptionLocal(id: option.id, deleted: option.deleted, value: option.value, color: option.color))
            }
            return CellDataModel(id: column.id!,
                                 defaultDropdownSelectedId: column.defaultDropdownSelectedId,
                                 options: optionsLocal,
                                 valueElements: column.images ?? [],
                                 type: column.type,
                                 title: column.title,
                                 number: column.number,
                                 selectedOptionText: optionsLocal.filter { $0.id == column.defaultDropdownSelectedId }.first?.value ?? "",
                                 date: column.date,
                                 format: column.getFormat(from: fieldPositionTableColumns),
                                 multiSelectValues: column.multiSelectValues,
                                 multi: column.multi)
        }
        let rowIndex = rowOrder.firstIndex(of: row)!
        return cellModels[rowIndex].cells[col].data
    }
    
    
    func getColumnTitle(columnId: String) -> String {
        return columnIdToColumnMap[columnId]?.title ?? ""
    }
    
    func getColumnTitleAtIndex(index: Int) -> String {
        guard index < tableColumns.count else { return "" }
        return columnIdToColumnMap[tableColumns[index].id!]?.title ?? ""
    }
    
    func getColumnType(columnId: String) -> ColumnTypes? {
        return columnIdToColumnMap[columnId]?.type
    }
    
    func getColumnFormat(columnId: String) -> DateFormatType? {
        return columnIdToColumnMap[columnId]?.format
    }
    
    func getColumnIDAtIndex(index: Int) -> String? {
        guard index < tableColumns.count else { return nil }
        return columnIdToColumnMap[tableColumns[index].id!]?.id
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
        lhs.uuid == rhs.uuid
    }
    let uuid = UUID()
    let id: String
    var defaultDropdownSelectedId: String?
    let options: [OptionLocal]?
    var valueElements: [ValueElement]
    let type: ColumnTypes?
    var title: String
    var number: Double?
    var selectedOptionText: String?
    var date: Double?
    var format: DateFormatType?
    var multiSelectValues: [String]?
    var multi: Bool?

    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    var isCellFilled: Bool {
        guard let type = type else { return false }
        switch type {
        case .text, .block, .barcode:
            return title.isEmpty || title != ""
        case .number:
            return number != nil
        case .dropdown:
            return !(selectedOptionText?.isEmpty ?? true)
        case .multiSelect:
            return !(multiSelectValues?.isEmpty ?? true)
        case .date:
            return date != nil
        case .image:
            return valueElements != nil || valueElements != []
        case .progress, .unknown:
            return false
        }
    }
}

struct OptionLocal: Identifiable {
    var id: String?
    var deleted: Bool?
    var value: String?
    var color: String?
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
    var format: DateFormatType?
    var fieldHeaderModel: FieldHeaderModel?
}

struct DisplayTextDataModel {
    var displayText: String?
    var fontSize: Double?
    var fontWeight: String?
    var fontColor: String?
    var fontStyle: String?
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
