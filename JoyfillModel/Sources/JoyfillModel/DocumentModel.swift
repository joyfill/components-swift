//
//  DocumentModel.swift
//  JoyFill
//
//

import Foundation

public struct Document: Codable {
    public var _id: String
    public var type: String
    public var identifier: String
    public var name: String
    public var stage: String
    public var createdOn: Int
    public var files: [Files] = []
    public var deleted: Bool
    
    public struct Files: Codable {
        public let _id: String
        public let version: Int
        public let name: String
        public let pageOrder: [String]
        public let pages: [Pages]
    }
    
    public struct Pages: Codable {
        public let _id: String
        public let name: String
        public let width: Int
        public let height: Int
        public let cols: Int
        public let rowHeight: Int
        public let layout: String
        public let presentation: String
        public let margin: Double
        public let padding: Double
        public let borderWidth: Double
    }
}

extension Document: Identifiable {
    public var id: String { _id }
}

public struct DocumentListResponse: Codable {
    public let data: [Document]
}

// MARK: - GroupData
public struct GroupData: Codable {
    public let id, identifier, title: String

    public enum CodingKeys: String, CodingKey {
        case id = "_id"
        case identifier, title
    }
}

public struct GroupResponse: Codable {
    public let data: [GroupData]
}

// MARK: - RetrieveGroup
public struct RetrieveGroup: Codable {
    public let id, organization, identifier, title: String
    public let identifiers: [String]
    public let createdOn: Int
    public let deleted: Bool
    public let v: Int

    public enum CodingKeys: String, CodingKey {
        case id = "_id"
        case organization, identifier, title, identifiers, createdOn, deleted
        case v = "__v"
    }
}

public struct ListAllUsers: Codable {
    public let id, organization, type, identifier: String
    public let createdOn: Int
    public let firstName, lastName, email: String

    public enum CodingKeys: String, CodingKey {
        case id = "_id"
        case organization, type, identifier, createdOn, firstName, lastName, email
    }
}

public struct ListAllUsersResponse: Codable {
    public let data: [ListAllUsers]
}

public struct RetrieveUsers: Codable {
    public let id, organization, type, identifier: String
    public let createdOn: Int
    public let firstName, lastName, email: String

    public enum CodingKeys: String, CodingKey {
        case id = "_id"
        case organization, type, identifier, createdOn, firstName, lastName, email
    }
}

public enum FieldTypes: String, Codable {
    case text
    case multiSelect
    case dropdown
    case textarea
    case date
    case signature
    case block
    case number
    case chart
    case richText
    case table
    case image
}

public extension ValueUnion {
    var text: String? {
        switch self {
        case .string(let string):
            return string
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
    
    var number: Int? {
        switch self {
        case .integer(let int):
            return int
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
        case .integer(let integer):
            let date = timestampMillisecondsToDate(value: integer, format: format)
            return date
        default:
            return nil
        }
    }
}

public func getTimeFromISO8601Format(iso8601String: String) -> String {
    let dateFormatter = ISO8601DateFormatter()
    let instant = dateFormatter.date(from: iso8601String)
    
    let timeZone = TimeZone.current
    let zonedDateTime = instant ?? Date()
    
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a"
    formatter.timeZone = timeZone
    
    let timeString = formatter.string(from: zonedDateTime)
    return timeString
}

public func timestampMillisecondsToDate(value: Int, format: String) -> String {
    let timestampMilliseconds: TimeInterval = TimeInterval(value)
    let date = Date(timeIntervalSince1970: timestampMilliseconds / 1000.0)
    let dateFormatter = DateFormatter()
    
    if format == "MM/DD/YYYY" {
        dateFormatter.dateFormat = "MMMM d, yyyy"
    } else if format == "hh:mma" {
        dateFormatter.dateFormat = "hh:mm a"
    } else {
        dateFormatter.dateFormat = "MMMM d, yyyy h:mm a"
    }
    
    let formattedDate = dateFormatter.string(from: date)
    return formattedDate
}

public struct FieldEvent {
    public let field: JoyDocField?
    public var page: Page?
    public var file: File?
    
    public init(field: JoyDocField? = nil, page: Page? = nil, file: File? = nil) {
        self.field = field
        self.page = page
        self.file = file
    }
}

public struct Change {
    public let changeData: [String: Any]
    public init(changeData: [String : Any]) {
        self.changeData = changeData
    }
}

public struct ChangeEvent {
    public let changes: [Change]
    public var document: JoyDoc?
   
    public init(changes: [Change], document: JoyDoc? = nil) {
        self.changes = changes
        self.document = document
    }
}

public struct UploadEvent {
    public let field: JoyDocField
    public let page: Page?
    public let file: File?
    public var uploadHandler: ([String]) -> Void
    
    public init(field: JoyDocField, page: Page? = nil, file: File? = nil, uploadHandler: @escaping ([String]) -> Void) {
        self.field = field
        self.page = page
        self.file = file
        self.uploadHandler = uploadHandler
      }
}

public enum Mode {
    case fill
    case readonly
}

public protocol FormInterface {
    var document: JoyDoc { get }
    var mode: Mode { get }
    var events: Events? { get set}
}

public protocol Events {
    func onChange(event: ChangeEvent)
    func onFocus(event: FieldEvent)
    func onBlur(event: FieldEvent)
    func onUpload(event:UploadEvent)
}
