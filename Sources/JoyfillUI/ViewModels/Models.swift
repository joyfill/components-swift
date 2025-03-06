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
    var rowType: RowType
    var isExpanded: Bool = false
    var childrens: [String : Children]
    var filledCellCount: Int {
        cells.filter { $0.data.isCellFilled }.count
    }
    var rowWidth: CGFloat
    
    var hasMoreNestedRows: Bool {
        childrens.count > 0
    }
    
    init(rowID: String, cells: [TableCellModel], rowType: RowType, isExpanded: Bool = false, childrens: [String : Children] = [:], rowWidth: CGFloat = 0 ) {
        self.rowID = rowID
        self.cells = cells
        self.rowType = rowType
        self.isExpanded = isExpanded
        self.childrens = childrens
        self.rowWidth = rowWidth
    }
}

enum RowType: Equatable {
    case row(index: Int)
    case header(level: Int, tableColumns: [FieldTableColumn])
    case nestedRow(level: Int, index: Int, parentID: (columnID: String, rowID: String)? = nil, parentSchemaKey: String = "")
    case tableExpander(schemaValue: (String, Schema)? = nil, level: Int, parentID: (columnID: String, rowID: String)? = nil, rowWidth: CGFloat = 0)
    
    var level: Int {
        switch self {
        case let .row:
            return 0
        case let .header(level, _):
            return level
        case let .nestedRow(level, _, _,_):
            return level
        case let .tableExpander(_, level, _, _):
            return level
        }
    }
    
    var parentSchemaKey: String {
        switch self {
        case .nestedRow(_, _, _, let parentSchemaKey):
            return parentSchemaKey
        default:
            return ""
        }
    }
    
    var width: CGFloat? {
        switch self {
        case .tableExpander(let _, _, _, let rowWidth):
            return rowWidth
        default:
            return nil
        }
    }
    
    var parentID: (columnID: String, rowID: String)? {
        switch self {
        case let .nestedRow(_, _, parentID, _):                return parentID
        case let .tableExpander(_, _, parentID, _):            return parentID
        default:
            return nil
        }
    }
    
    var index: Int {
        switch self {
        case .nestedRow(_, index: let index, _, _): return index
        case .row(index: let index):
            return index
        case .header(level: let level, tableColumns: let tableColumns):
            return 0
        case .tableExpander(schemaValue: let schemaValue, level: let level, _, _):
            return 0
        }
    }
    
    var isRow: Bool {
        if case .row = self {
            return true
        }
        return false
    }
    
    static func == (lhs: RowType, rhs: RowType) -> Bool {
        switch (lhs, rhs) {
        case (.row, .row),
             (.header, .header),
             (.nestedRow, .nestedRow),
             (.tableExpander, .tableExpander):
            return lhs.level == rhs.level
        default:
            return false
        }
    }
}

let supportedColumnTypes: [ColumnTypes] = [.text, .image, .dropdown, .block, .date, .number, .multiSelect, .progress, .barcode, .table]

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
    var childrens = [String]()
    var schema: [String : Schema] = [:]
    let fieldPositionTableColumns: [TableColumn]?
    var columnIdToColumnMap: [String: CellDataModel] = [:]
    var selectedRows = [String]()
    var cellModels = [RowDataModel]()
    var filteredcellModels = [RowDataModel]()
    var filterModels = [FilterModel]()
    var sortModel = SortModel()
    var id = UUID()
    var showResetSelectionAlert: Bool = false
    private var pendingRowID: String?
    
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
                
        if fieldData.fieldType == .collection {
            self.schema = fieldData.schema ?? [:]
            fieldData.schema?.forEach { key, value in
                if value.root == true {
                    //Only top level columns
                    self.tableColumns = value.tableColumns ?? []
                    self.childrens = value.children ?? []
                }
            }
            
            for (colIndex, column) in self.tableColumns.enumerated() {
                let filterModel = FilterModel(colIndex: colIndex, colID: column.id ?? "", type: column.type ?? .unknown)
                self.filterModels.append(filterModel)
            }
        } else {
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
        }
        setupColumns()
        filterRowsIfNeeded()
    }
        
    mutating func filterRowsIfNeeded() {
        guard !filterModels.noFilterApplied else {
            filteredcellModels = cellModels
            return
        }
        
        var newFiltered = [RowDataModel]()
        var i = 0
        while i < filteredcellModels.count {
            let row = filteredcellModels[i]
            if row.rowType.isRow {
                let passesFilter = rowMatchesFilter(row, filters: filterModels)
                if passesFilter {
                    newFiltered.append(row)
                    i += 1
                    // Include all nested rows until the next top-level row.
                    while i < filteredcellModels.count, !filteredcellModels[i].rowType.isRow {
                        newFiltered.append(filteredcellModels[i])
                        i += 1
                    }
                } else {
                    // skip this row and all of its nested rows
                    i += 1
                    while i < filteredcellModels.count, !filteredcellModels[i].rowType.isRow {
                        i += 1
                    }
                }
            } else {
                i += 1
            }
        }
        
        filteredcellModels = newFiltered
    }

    func rowMatchesFilter(_ row: RowDataModel, filters: [FilterModel]) -> Bool {
        for filter in filters {
            if filter.filterText.isEmpty {
                continue
            }
            guard row.cells.indices.contains(filter.colIndex) else { continue }
            let column = row.cells[filter.colIndex].data
            let match: Bool
            switch column.type {
            case .text:
                match = (column.title ?? "").localizedCaseInsensitiveContains(filter.filterText)
            case .dropdown:
                match = (column.defaultDropdownSelectedId ?? "") == filter.filterText
            case .number:
                let columnNumberString = String(format: "%g", column.number ?? 0)
                match = columnNumberString.hasPrefix(filter.filterText)
            case .multiSelect:
                match = column.multiSelectValues?.contains(filter.filterText) ?? false
            case .barcode:
                match = (column.title ?? "").localizedCaseInsensitiveContains(filter.filterText)
            default:
                match = false
            }
            
            if !match {
                return false
            }
        }
        return true
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
        case .table:
            cell?.multiSelectValues = valueUnion?.stringArray
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
    
    mutating func updateCellModelForNested(rowId: String, colIndex: Int, cellDataModel: CellDataModel, isBulkEdit: Bool) {
        guard let index = cellModels.firstIndex(where: { $0.rowID == rowId }) else {
            return
        }
        var cellModel = cellModels[index].cells[colIndex]
        cellModel.data = cellDataModel
        cellModels[index].cells[colIndex] = cellModel
        if isBulkEdit {
            cellModels[index].cells[colIndex].id = UUID()
        }
    }
    
    func childrensForRows(_ index: Int, _ rowDataModel: RowDataModel, _ level: Int) -> [Int] {
        var indices: [Int] = []
        for i in index + 1..<cellModels.count {
            let nextRow = cellModels[i]
            
            if nextRow.rowType.level < rowDataModel.rowType.level {
                break
            }
            
            if rowDataModel.rowType == .nestedRow(level: level, index: rowDataModel.rowType.index) {
                //Stop at same level but next index of current nested row
                if nextRow.rowType == .nestedRow(level: rowDataModel.rowType.level, index: rowDataModel.rowType.index + 1) {
                    break
                }
                //Stop if there is an tableExpander of low level
                if nextRow.rowType == .tableExpander(level: rowDataModel.rowType.level - 1) {
                    break
                }
                switch nextRow.rowType {
                case .header, .tableExpander:
                    indices.append(i)
                case .nestedRow(level: let nestedLevel, index: _, _, _):
                    let level = rowDataModel.rowType.level
                    if nestedLevel < level {
                        break
                    } else {
                        indices.append(i)
                    }
                case .row:
                    break
                }
            } else {
                if nextRow.rowType == .row(index: index + 1) {
                    break
                }
                switch nextRow.rowType {
                case .header, .nestedRow, .tableExpander:
                    indices.append(i)
                case .row:
                    break
                }
            }
        }
        return indices
    }
    
    func childrensForASpecificRow(_ index: Int, _ rowDataModel: RowDataModel) -> [Int] {
        var indices: [Int] = []
        
        for i in index + 1..<cellModels.count {
            let nextRow = cellModels[i]
            
            //Stop if find another table expander of same level
            if nextRow.rowType == .tableExpander(level: rowDataModel.rowType.level) {
                break
            }
            //Stop if find nested row of same level
            if nextRow.rowType == .nestedRow(level: rowDataModel.rowType.level, index: rowDataModel.rowType.index) {
                break
            }
            
            if nextRow.rowType.level < rowDataModel.rowType.level {
                break
            }
            
            switch nextRow.rowType {
            case .header, .tableExpander:
                indices.append(i)
            case .nestedRow(level: let nestedLevel, index: _, _, _):
                let level = rowDataModel.rowType.level
                if nestedLevel < level {
                    break
                } else {
                    indices.append(i)
                }
            case .row:
                break
            }
        }
        
        return indices
    }

    var lastRowSelected: Bool {
        return !selectedRows.isEmpty && selectedRows.last! == rowOrder.last!
    }
    
    var firstRowSelected: Bool {
        return !selectedRows.isEmpty && selectedRows.first! == rowOrder.first!
    }
    
    var firstNestedRowSelected: Bool {
        return !selectedRows.isEmpty && isFirstNestedRow
    }
    
    var isFirstNestedRow: Bool {
        guard let selectedRowID = selectedRows.first, let index = cellModels.firstIndex(where: { $0.rowID == selectedRowID }), index > 0 else {
            return false
        }
        
        let previousRow = cellModels[index - 1]
        switch previousRow.rowType {
        case .header(level: _, tableColumns: _):
            return true
        default:
            return false
        }
    }
    
    var lastNestedRowSelected: Bool {
        return !selectedRows.isEmpty && isLastNestedRow
    }
    
    var isLastNestedRow: Bool {
        guard let selectedRowID = selectedRows.first,
              let index = cellModels.firstIndex(where: { $0.rowID == selectedRowID }) else {
            return false
        }
        
        let selectedRow = cellModels[index]
        switch selectedRow.rowType {
        case .row(index: let index):
            return false
        default:
            break
        }
        let childrenIndices = childrensForRows(index, selectedRow, selectedRow.rowType.level)
        
        // The next row after the current block is at:
        let nextIndex = index + childrenIndices.count + 1
        
        // If there's no next row, then this is the last row.
        guard nextIndex < cellModels.count else {
            return true
        }
        
        let nextRow = cellModels[nextIndex]
        
        switch nextRow.rowType {
        case .nestedRow(level: let nestedLevel, index: let index, parentID: _, _):
            return !(nestedLevel == selectedRow.rowType.level)
        default:
            return true
        }
    }
    
    var shouldDisableMoveUp: Bool {
        firstRowSelected || !filterModels.noFilterApplied || sortModel.order != .none || firstNestedRowSelected
    }
    
    var shouldDisableMoveDown: Bool {
        lastRowSelected || !filterModels.noFilterApplied || sortModel.order != .none || lastNestedRowSelected
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
    
    func getDummyNestedCell(col: Int, selectedOptionText: String = "", rowID: String) -> CellDataModel? {
        let selectedRow = cellModels.first(where: { $0.rowID == rowID })
        return selectedRow?.cells[col].data
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
        let topLevelCellModelsOnly = cellModels.filter { rowDataModel in
            rowDataModel.rowType.isRow
        }
        return topLevelCellModelsOnly[rowIndex].cells[col].data
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
        let currentSelectedRow = self.filteredcellModels.first { rowDataModel in
            rowDataModel.rowID == rowID
        }
        if selectedRows.count > 0 {
            if currentSelectedRow?.rowType.parentID?.rowID == getRowByID(rowID: selectedRows[0])?.rowType.parentID?.rowID {
                if selectedRows.contains(rowID) {
                    selectedRows = selectedRows.filter({ $0 != rowID})
                } else {
                    selectedRows.append(rowID)
                }
            } else {
                //show alert
                pendingRowID = rowID
                showResetSelectionAlert = true
            }
        } else {
            selectedRows.append(rowID)
        }
    }
    
    mutating func confirmResetSelection() {
        if let newRow = pendingRowID {
            selectedRows = [newRow]
        }
        pendingRowID = nil
        showResetSelectionAlert = false
    }
    
    mutating  func cancelResetSelection() {
        pendingRowID = nil
        showResetSelectionAlert = false
    }
    
    func getRowByID(rowID: String) -> RowDataModel? {
        return filteredcellModels.first { rowDataModel in
            rowDataModel.rowID == rowID
        }
    }
    
    mutating func selectAllRows() {
        selectedRows = filteredcellModels.filter { $0.rowType.isRow }.compactMap { $0.rowID }
    }
    
    mutating func emptySelection() {
        selectedRows = []
    }
    
    var allRowSelected: Bool {
        let validRows = filteredcellModels.filter { $0.rowType.isRow }.compactMap { $0.rowID }
        return !selectedRows.isEmpty && Set(selectedRows) == Set(validRows)
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
        case .progress, .unknown, .table:
            // TODO: Handle it for nested table
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
