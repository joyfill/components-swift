//
//  DocumentModel.swift
//  JoyFill
//
//  Created by Vikash on 04/02/24.
//

import Foundation

public struct Document: Codable {
    public var _id: String
    public var type: String
    public var identifier: String
    public var name: String
    public var stage: String
    public var createdOn: Int
    public var files: [Files]
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


public struct FieldTypes {
    public static let text = "text"
    public static let multiSelect = "multiSelect"
    public static let dropdown = "dropdown"
    public static let textarea = "textarea"
    public static let date = "date"
    public static let signature = "signature"
    public static let block = "block"
    public static let number = "number"
    public static let chart = "chart"
    public static let richText = "richText"
    public static let table = "table"
    public static let image = "image"
}

public extension ValueUnion {
    var textabc: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }
    var imageURL: String? {
        switch self {
        case .valueElementArray(let valueElements):
            return valueElements[0].url
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
    var multiSelectValue: String? {
        switch self {
        case .string(let string):
            return string
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
    let field: JoyDocField
    let page: Page
    let file: File
}

public struct Change {
    
}

public struct ChangeEvent {
    let changes: [Change]
    let document: Document
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
    func onChange(event: FieldEvent)
    func onFocus(event: FieldEvent)
    func onBlur(event: FieldEvent)
    func onUpload(event:FieldEvent)
}
