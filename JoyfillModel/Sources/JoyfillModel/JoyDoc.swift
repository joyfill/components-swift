import Foundation

// MARK: - JoyDoc
public struct JoyDoc: Codable {
    public var id, type, stage: String?
    public var metadata: Metadata?
    public var identifier, name: String?
    public var createdOn: Int?
    public var files: [File] = []
    public var fields: [JoyDocField]?
    let categories: [JSONAny]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type, stage, metadata, identifier, name, createdOn, files, fields, categories
    }
    
    public var fieldPosition: FieldPosition? {
        guard !self.files.isEmpty else {
            return nil
        }
        let fileIndex = 0
        let pageIndex = 0
        let fieldPositionIndex = 0
        let file = files[fileIndex]
        let page = file.pages?[pageIndex]
        let fieldPosition = page?.fieldPositions?[fieldPositionIndex]
        return fieldPosition
    }
}

// MARK: - JoyDocField
public struct JoyDocField: Codable, Identifiable, Equatable {
    public static func == (lhs: JoyDocField, rhs: JoyDocField) -> Bool {
        lhs.id == rhs.id
    }
    
    public var type, id, identifier, title: String?
    public var value: ValueUnion?
    public var fieldRequired: Bool?
    public var metadata: Metadata?
    public var file: String?
    public var options: [Option]?
    public var tipTitle, tipDescription: String?
    public var tipVisible: Bool?
    public var multi: Bool?
    public var yTitle: String?
    public var yMax, yMin: Int?
    public var xTitle: String?
    public var xMax, xMin: Int?
    public var rowOrder: [String]?
    public var tableColumns: [FieldTableColumn]?
    public var tableColumnOrder: [String]?
    
    enum CodingKeys: String, CodingKey {
        case type
        case id = "_id"
        case identifier, title, value
        case fieldRequired = "required"
        case metadata, file, options, multi, yTitle, yMax, yMin, xTitle, xMax, xMin, rowOrder, tableColumns, tableColumnOrder
        case tipTitle, tipDescription, tipVisible
    }
    
    public var valueToValueElements: [ValueElement]? {
        switch value {
        case .valueElementArray(let array):
            return array
        default:
            return nil
        }
    }
    
    public mutating func deleteRow(id: String) {
        guard var elements = valueToValueElements, let index = elements.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        var element = elements[index]
        element.setDeleted()
        elements[index] = element

        self.value = ValueUnion.valueElementArray(elements)
    }
    
    public mutating func addRow(id: String) {
        guard var elements = valueToValueElements else {
            return
        }
        
        elements.append(ValueElement(id: id))
        self.value = ValueUnion.valueElementArray(elements)
        rowOrder?.append(id)
    }
    
}

// MARK: - Metadata
public struct Metadata: Codable {
    public var deficiencies, blockImport, blockAutoPopulate, requireDeficiencyTitle: Bool?
    public var requireDeficiencyDescription, requireDeficiencyPhoto: Bool?
    public var list, listColumn: String?
}

// MARK: - Option
public struct Option: Codable,Identifiable{
    public var value: String?
    public var deleted: Bool?
    public var id: String?
    public var width: Int?
    
    enum CodingKeys: String, CodingKey {
        case value, deleted
        case id = "_id"
        case width
    }
}

// MARK: - FieldTableColumn
public struct FieldTableColumn: Codable {
    public let id, type: String?
    public var title: String?
    public let width: Int?
    public let identifier: String?
    public let options: [Option]?
    public let value: String?
    public var defaultDropdownSelectedId: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type, title, width, identifier, options, value
    }
}

public enum ValueUnion: Codable {
    case integer(Int)
    case string(String)
    case array([String])
    case valueElementArray([ValueElement])
    case null
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode([ValueElement].self) {
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
        if container.decodeNil() {
            self = .null
            return
        }
        throw DecodingError.typeMismatch(ValueUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ValueUnion"))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        case .valueElementArray(let x):
            try container.encode(x)
        case .array(let x):
            try container.encode(x)
        case .null:
            try container.encodeNil()
        }
    }
}

// MARK: - ValueElement
public struct ValueElement: Codable {
    public var id: String?
    public var url: String?
    public var fileName, filePath: String?
    public var deleted: Bool?
    public var title, description: String?
    public var points: [Point]?
    public var cells: [String: ValueUnion]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case url, fileName, filePath, deleted, title, description, points, cells
    }
    
    public mutating func setDeleted() {
        deleted = true
    }
}

// MARK: - Point
public struct Point: Codable {
    public var id, label: String?
    public var y, x: CGFloat?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case label, y, x
    }
}

// MARK: - File
public struct File: Codable {
    public var id: String?
    public var metadata: Metadata?
    public var name: String?
    public var version: Int?
    public var styles: Metadata?
    public var pages: [Page]?
    public var pageOrder: [String]?
    public var views: [ModelView]?
    
    public enum CodingKeys: String, CodingKey {
        case id = "_id"
        case metadata, name, version, styles, pages, views, pageOrder
    }
}

// MARK: - Page
public struct Page: Codable {
    public var name: String?
    public var fieldPositions: [FieldPosition]?
    public var metadata: Metadata?
    public var width, height, cols, rowHeight: Int?
    public var layout, presentation: String?
    public var margin, padding, borderWidth: Int?
    public var id: String?
    
    public enum CodingKeys: String, CodingKey {
        case name, fieldPositions, metadata, width, height, cols, rowHeight, layout, presentation, margin, padding, borderWidth
        case id = "_id"
    }
}

// MARK: - FieldPosition
public struct FieldPosition: Codable {
    public var field: String?
    public let displayType: String?
    public let width: Double?
    public let height: Double?
    public let x: Double?
    public var y: Double?
    public var id, targetValue: String?
    public var type: FieldTypes
    public let fontSize: Int?
    public let fontColor, fontStyle, fontWeight, textAlign: String?
    public let primaryDisplayOnly: Bool?
    public let format: String?
    public let column: String?
    public let backgroundColor: String?
    public let borderColor: String?
    public let textDecoration: String?
    public let borderWidth: Int?
    public let borderRadius: Int?
    
    enum CodingKeys: String, CodingKey {
        case field, displayType, width, height, x, y
        case id = "_id"
        case type, targetValue, fontSize, fontColor, fontStyle, fontWeight, textAlign, primaryDisplayOnly, format, column
        case backgroundColor, borderColor, textDecoration, borderWidth, borderRadius
    }
}

// MARK: - View
public struct ModelView: Codable {
    public var type: String?
    public var pageOrder: [String]?
    public var pages: [Page]?
    public var id: String?
    
    enum CodingKeys: String, CodingKey {
        case type, pageOrder, pages
        case id = "_id"
    }
}

// Function to generate ID
public func generateObjectId() -> String {
    let characters = "65111466f7a5f25393fd0ac7"
    let length = characters.count
    var objectId = "6"
    
    for _ in 1..<24 {
        let randomIndex = Int.random(in: 0..<length)
        let randomCharacter = characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
        objectId.append(randomCharacter)
    }
    
    return objectId
}
