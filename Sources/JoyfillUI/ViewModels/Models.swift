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
        self.title = fieldData?.title
        self.fieldId = listModel.fieldID
        
        setupColumns()
        setup()
        
        self.filterModels = columns.enumerated().map { colIndex, colID in
            FilterModel(colIndex: colIndex, colID: colID)
        }
    }
    
    var fieldId: String
    var pageId: String?
    var fileId: String?
    var title: String?
    
    var rows: [String] = []
    var quickRows: [String] = []
    var columns: [String] = []
    var quickColumns: [String] = []
    var quickViewRowCount: Int = 0
    var rowToCellMap: [String?: [FieldTableColumnLocal?]] = [:]
    var quickRowToCellMap: [String?: [FieldTableColumnLocal?]] = [:]
    var columnIdToColumnMap: [String: FieldTableColumnLocal] = [:]
    var selectedRows = [String]()
    
    var cellModels = [[TableCellModel]]()
    var filteredcellModels = [[TableCellModel]]()
    
    var filterModels = [FilterModel]()
    var sortModel = SortModel()
    var viewMoreText: String = ""
    
    mutating func setup() {
        setupRows()
        quickViewRowCount = rows.count >= 3 ? 3 : rows.count
        viewMoreText = rows.count > 1 ? "+\(rows.count)" : ""
    }
    
    mutating private func setupColumns() {
        guard let fieldData = documentEditor?.field(fieldID: fieldId) else { return }
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
                let imagesLocal = fieldTableColumn.images?.map { valueElement in
                    ValueElementLocal(
                        id: valueElement.id ?? "",
                        url: valueElement.url,
                        fileName: valueElement.fileName,
                        filePath: valueElement.filePath,
                        deleted: valueElement.deleted,
                        title: valueElement.title,
                        description: valueElement.description,
                        points: valueElement.points,
                        cells: valueElement.cells?.mapValues { valueUnion in
                            convertToValueUnionLocal(valueUnion)
                        }
                    )
                }
                let fieldTableColumnLocal = FieldTableColumnLocal(
                    id: fieldTableColumn.id,
                    defaultDropdownSelectedId: fieldTableColumn.defaultDropdownSelectedId,
                    options: optionsLocal,
                    valueElements: imagesLocal,
                    type: fieldTableColumn.type,
                    title: fieldTableColumn.title
                )
                columnIdToColumnMap[column] = fieldTableColumnLocal
            }
        }
        
        self.quickColumns = columns
        while quickColumns.count > 3 {
            quickColumns.removeLast()
        }
    }
    
    func convertToValueUnionLocal(_ valueUnion: ValueUnion) -> ValueUnionLocal {
        switch valueUnion {
        case .double(let value):
            return .double(value)
        case .string(let value):
            return .string(value)
        case .array(let value):
            return .array(value)
        case .valueElementArray(let elements):
            return .valueElementArray(elements.map { $0.toLocal() })
        case .bool(let value):
            return .bool(value)
        case .null:
            return .null
        case .dictionary(_):
            return .null
        }
    }

    
    mutating private func setupRows() {
        guard let fieldData = documentEditor?.field(fieldID: fieldId) else { return }
        guard let valueElements = fieldData.valueToValueElements, !valueElements.isEmpty else {
            setupQuickTableViewRows()
            return
        }
        let valueElementsLocal = valueElements.map { $0.toLocal() }
        let nonDeletedRows = valueElementsLocal.filter { !($0.deleted ?? false) }
        let sortedRows = sortElementsByRowOrder(elements: nonDeletedRows, rowOrder: fieldData.rowOrder)
        var rowToCellMap: [String?: [FieldTableColumnLocal?]] = [:]
        
        for row in sortedRows {
            var cells: [FieldTableColumnLocal?] = []
            for column in self.columns {
                let columnData = fieldData.tableColumns?.first { $0.id == column }
                let optionsLocal = columnData?.options?.map { option in
                    OptionLocal(id: option.id, deleted: option.deleted, value: option.value)
                }
                
                let imagesLocal = columnData?.images?.map { valueElement in
                    ValueElementLocal(
                        id: valueElement.id ?? "",
                        url: valueElement.url,
                        fileName: valueElement.fileName,
                        filePath: valueElement.filePath,
                        deleted: valueElement.deleted,
                        title: valueElement.title,
                        description: valueElement.description,
                        points: valueElement.points,
                        cells: valueElement.cells?.mapValues { valueUnion in
                            convertToValueUnionLocal(valueUnion)
                        }
                    )
                }
                let valueUnion = row.cells?.first(where: { $0.key == column })?.value
                let defaultDropdownSelectedId = valueUnion?.dropdownValue
                
                let selectedOptionText = optionsLocal?.filter{ $0.id == defaultDropdownSelectedId }.first?.value ?? ""
                let columnDataLocal = FieldTableColumnLocal(id: columnData?.id,
                                                            defaultDropdownSelectedId: columnData?.defaultDropdownSelectedId,
                                                            options: optionsLocal,
                                                            valueElements: imagesLocal,
                                                            type: columnData?.type,
                                                            title: columnData?.title,
                                                            selectedOptionText: selectedOptionText)
                let cell = buildCell(data: columnDataLocal, row: row, column: column)
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
    
    private func buildCell(data: FieldTableColumnLocal?, row: ValueElementLocal, column: String) -> FieldTableColumnLocal? {
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
        guard let fieldData = documentEditor?.field(fieldID: fieldId) else { return }
        if quickRows.isEmpty {
            quickRowToCellMap = [:]
            let id = generateObjectId()
            quickRows = [id]
            let columnData = fieldData.tableColumns ?? []
            var columnDataLocal: [FieldTableColumnLocal] = []
            for column in columnData {
                var optionsLocal: [OptionLocal] = []
                for option in column.options ?? []{
                    optionsLocal.append(OptionLocal(id: option.id, deleted: option.deleted, value: option.value))
                }
                let imagesLocal = column.images?.map { valueElement in
                    ValueElementLocal(
                        id: valueElement.id ?? "",
                        url: valueElement.url,
                        fileName: valueElement.fileName,
                        filePath: valueElement.filePath,
                        deleted: valueElement.deleted,
                        title: valueElement.title,
                        description: valueElement.description,
                        points: valueElement.points,
                        cells: valueElement.cells?.mapValues { valueUnion in
                            convertToValueUnionLocal(valueUnion)
                        }
                    )
                }
                
                columnDataLocal.append(FieldTableColumnLocal(id: column.id,
                                                             defaultDropdownSelectedId: column.defaultDropdownSelectedId,
                                                             options: optionsLocal,
                                                             valueElements: imagesLocal,
                                                             type: column.type,
                                                             title: column.title,
                                                             selectedOptionText: optionsLocal.filter { $0.id == column.defaultDropdownSelectedId }.first?.value ?? ""))
            }
            quickRowToCellMap = [id : columnDataLocal ?? []]
        } else {
            while quickRows.count > 3 {
                quickRows.removeLast()
            }
        }
    }
    
    mutating func updateCellModel(rowIndex: Int, colIndex: Int, editedCell: FieldTableColumnLocal) {
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
    
    func getFieldTableColumn(row: String, col: Int) -> FieldTableColumnLocal? {
        return rowToCellMap[row]?[col]
    }
    
    func getQuickFieldTableColumn(row: String, col: Int) -> FieldTableColumnLocal? {
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
    
    func sortElementsByRowOrder(elements: [ValueElementLocal], rowOrder: [String]?) -> [ValueElementLocal] {
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

struct FieldTableColumnLocal {
    let id: String?
    var defaultDropdownSelectedId: String?
    let options: [OptionLocal]?
    var valueElements: [ValueElementLocal]?
    let type: String?
    var title: String?
    var selectedOptionText: String?
}

struct OptionLocal: Identifiable {
    var id: String?
    var deleted: Bool?
    var value: String?
}

struct ValueElementLocal: Codable,Hashable, Equatable, Identifiable {
    var id: String
    var url: String?
    var fileName: String?
    var filePath: String?
    var deleted: Bool?
    var title: String?
    var description: String?
    var points: [Point]?
    var cells: [String: ValueUnionLocal]?
    
    init(
        id: String,
        url: String? = nil,
        fileName: String? = nil,
        filePath: String? = nil,
        deleted: Bool? = false,
        title: String? = nil,
        description: String? = nil,
        points: [Point]? = nil,
        cells: [String: ValueUnionLocal]? = nil
    ) {
        self.id = id
        self.url = url
        self.fileName = fileName
        self.filePath = filePath
        self.deleted = deleted
        self.title = title
        self.description = description
        self.points = points
        self.cells = cells
    }
    
    mutating func setDeleted() {
        self.deleted = true
    }
}

enum ValueUnionLocal: Codable, Hashable, Equatable {
    case double(Double)
    case string(String)
    case array([String])
    case valueElementArray([ValueElementLocal])
    case bool(Bool)
    case null

    public static func == (lhs: ValueUnionLocal, rhs: ValueUnionLocal) -> Bool {
        switch (lhs, rhs) {
        case (.double(let a), .double(let b)):
            return a == b
        case (.string(let a), .string(let b)):
            return a == b
        case (.array(let a), .array(let b)):
            return a == b
        case (.valueElementArray(let a), .valueElementArray(let b)):
            return a == b
        case (.bool(let a), .bool(let b)):
            return a == b
        case (.null, .null):
            return true
        default:
            return false
        }
    }

    public init?(value: Any) {
        if let doubleValue = value as? Double {
            self = .double(doubleValue)
            return
        }
        if let boolValue = value as? Bool {
            self = .bool(boolValue)
            return
        }
        if let strValue = value as? String {
            self = .string(strValue)
            return
        }
        if let arrayValue = value as? [String] {
            self = .array(arrayValue)
            return
        }
        if let valueElementArray = value as? [ValueElementLocal] {
            self = .valueElementArray(valueElementArray)
            return
        }
        if value is NSNull {
            self = .null
            return
        }
#if DEBUG
        fatalError()
#else
        self = .null
#endif
    }

    public var isEmpty: Bool {
        switch self {
        case .double:
            return false
        case .string(let string):
            return string.isEmpty
        case .array(let stringArray):
            return stringArray.isEmpty
        case .valueElementArray(let valueElementArray):
            return valueElementArray.isEmpty
        case .bool(let bool):
            return bool
        case .null:
            return true
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        if let x = try? container.decode([ValueElementLocal].self) {
            self = .valueElementArray(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode([String].self) {
            self = .array(x)
            return
        }
        if let x = try? container.decode(Bool.self) {
            self = .bool(x)
            return
        }
        if container.decodeNil() {
            self = .null
            return
        }
        throw DecodingError.typeMismatch(ValueUnionLocal.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ValueUnionLocal"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .double(let x):
            if x.truncatingRemainder(dividingBy: 1) == 0 {
                try container.encode(Double(x))
            } else {
                try container.encode(x)
            }
        case .string(let x):
            try container.encode(x)
        case .valueElementArray(let x):
            try container.encode(x)
        case .array(let x):
            try container.encode(x)
        case .bool(let x):
            try container.encode(x)
        case .null:
            try container.encodeNil()
        }
    }
}

extension ValueUnionLocal {
    
    var text: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }

    var bool: Bool? {
        switch self {
        case .bool(let bool):
            return bool
        case .double(let double):
            return double != 0
        default:
            return nil
        }
    }

    var displayText: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }

    var stringArray: [String]? {
        switch self {
        case .array(let stringArray):
            return stringArray
        default:
            return nil
        }
    }

    var imageURLs: [String]? {
        switch self {
        case .valueElementArray(let valueElements):
            var imageURLArray: [String] = []
            for element in valueElements {
                imageURLArray.append(element.url ?? "")
            }
            return imageURLArray
        default:
            return nil
        }
    }
    
    var signatureURL: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }
    
    var multilineText: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }
    
    var number: Double? {
        switch self {
        case .double(let value):
            return value
        case .bool(let boolValue):
            return boolValue ? 1 : 0
        default:
            return nil
        }
    }

    var dropdownValue: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }
    
    var selector: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }
    
    var multiSelector: [String]? {
        switch self {
        case .array(let array):
            return array
        default:
            return nil
        }
    }
    
    func dateTime(format: String) -> String? {
        switch self {
        case .string(let string):
            let date = getTimeFromISO8601Format(iso8601String: string)
            return date
        case .double(let value):
            let date = timestampMillisecondsToDate(value: Int(value), format: format)
            return date
        default:
            return nil
        }
    }
    
    var valueElements: [ValueElementLocal]? {
        switch self {
        case .valueElementArray(let valueElements):
            return valueElements
        default:
            return nil
        }
    }
    
    func toValueUnion() -> ValueUnion {
        switch self {
        case .double(let value):
            return .double(value)
        case .string(let value):
            return .string(value)
        case .array(let value):
            return .array(value)
        case .valueElementArray(let elements):
            return .valueElementArray(elements.map { $0.toValueElement() })
        case .bool(let value):
            return .bool(value)
        case .null:
            return .null
        }
    }
}


extension ValueElement {
    func toLocal() -> ValueElementLocal {
        var valueElements = ValueElementLocal(
            id: self.id ?? "",
            deleted: self.deleted,
            title: self.title,
            description: self.description,
            points: self.points
        )
        valueElements.url = self.url
        valueElements.fileName = self.fileName
        valueElements.filePath = self.filePath
        valueElements.cells = self.cells?.mapValues { valueUnion in
            convertToValueUnionLocal(valueUnion)
        }
        
        return valueElements
    }
    
    func convertToValueUnionLocal(_ valueUnion: ValueUnion) -> ValueUnionLocal {
        switch valueUnion {
        case .double(let value):
            return .double(value)
        case .string(let value):
            return .string(value)
        case .array(let value):
            return .array(value)
        case .valueElementArray(let elements):
            return .valueElementArray(elements.map { $0.toLocal() })
        case .bool(let value):
            return .bool(value)
        case .null:
            return .null
        case .dictionary(_):
            return .null
        }
    }
}

extension ValueElementLocal {
    func toValueElement() -> ValueElement {
        var valueElement = ValueElement(
            id: self.id ?? "",
            deleted: self.deleted ?? false,
            description: self.description ?? "",
            title: self.title ?? "",
            points: self.points
        )
        valueElement.url = self.url
        valueElement.fileName = self.fileName
        valueElement.filePath = self.filePath
        valueElement.cells = self.cells?.mapValues { $0.toValueUnion() }
        
        return valueElement
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
    var fieldId: String
    var pageId: String?
    var fileId: String?
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
    var fieldId: String
    var pageId: String?
    var fileId: String?
    var dropdownValue: String?
    var options: [Option]?
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct ImageDataModel {
    var fieldId: String
    var pageId: String?
    var fileId: String?
    var multi: Bool?
    var primaryDisplayOnly: Bool?
    var valueElements: [ValueElementLocal]?
    var mode: Mode
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct MultiLineDataModel {
    var fieldId: String
    var pageId: String?
    var fileId: String?
    var multilineText: String?
    var mode: Mode
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct MultiSelectionDataModel {
    var fieldId: String
    var pageId: String?
    var fileId: String?
    var currentFocusedFieldsDataId: String?
    var multi: Bool?
    var options: [Option]?
    var multiSelector: [String]?
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct NumberDataModel {
    var fieldId: String
    var pageId: String?
    var fileId: String?
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
    var fieldId: String
    var pageId: String?
    var fileId: String?
    var signatureURL: String?
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct TextDataModel {
    var fieldId: String
    var pageId: String?
    var fileId: String?
    var text: String?
    var mode: Mode
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}
