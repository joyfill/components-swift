import Foundation

/// `Document` is a struct that represents a document with its associated metadata and content.
///
/// It conforms to `Codable` and `Hashable` protocols.
public struct Document: Codable, Hashable {
    
    /// Compares two `Document` instances for equality.
    /// - Parameters:
    ///   - lhs: The left-hand side `Document` instance.
    ///   - rhs: The right-hand side `Document` instance.
    /// - Returns: `true` if the two instances have the same `id`, `false` otherwise.
    public static func == (lhs: Document, rhs: Document) -> Bool {
        lhs.id == rhs.id
    }
    
    /// The unique identifier of the document.
    public var _id: String
    
    /// The type of the document.
    public var type: String
    
    /// The identifier of the document.
    public var identifier: String
    
    /// The source of the document.
    public var source: String?
    
    /// The name of the document.
    public var name: String
    
    /// The stage of the document.
    public var stage: String
    
    /// The creation timestamp of the document.
    public var createdOn: Int
    
    /// The files associated with the document.
    public var files: [Files] = []
    
    /// Indicates whether the document is deleted or not.
    public var deleted: Bool
    
    /// `Files` is a struct that represents a file in the document.
    ///
    /// It contains the file's unique identifier, version, name, page order and pages.
    public struct Files: Codable, Hashable {
        public let _id: String
        public let version: Int
        public let name: String?
        public let pageOrder: [String]
        public let pages: [Pages]
    }
    
    /// `Pages` is a struct that represents a page in the document.
    ///
    /// It contains the page's unique identifier, name, dimensions, layout, presentation, margin, padding and border width.
    public struct Pages: Codable, Hashable {
        public let _id: String
        public let name: String
        public let width: Int
        public let height: Int
        public let cols: Int
        public let rowHeight: Int
        public let layout: String?
        public let presentation: String?
        public let margin: Double
        public let padding: Double
        public let borderWidth: Double
    }
}

/// An extension of `Document` that conforms to the `Identifiable` protocol.
///
/// This allows `Document` to be used in SwiftUI views that require identifiable data, such as `List` and `ForEach`.
extension Document: Identifiable {
    /// The unique identifier of the document. This is the same as `_id`.
    public var id: String { _id }
}

/// `DocumentListResponse` is a struct that represents a response containing a list of documents.
///
/// It conforms to the `Codable` protocol, allowing it to be encoded to and decoded from a serialized format (e.g., JSON).
public struct DocumentListResponse: Codable {
    /// The array of `Document` objects contained in the response.
    public let data: [Document]
}

// MARK: - GroupData
/// `GroupData` is a struct that represents the data of a group.
///
/// It contains the unique id, identifier, and title of the group.
public struct GroupData: Codable {
    public let id, identifier, title: String

    public enum CodingKeys: String, CodingKey {
        case id = "_id"
        case identifier, title
    }
}

/// `GroupResponse` is a struct that represents a response containing a list of group data.
///
/// It contains an array of `GroupData` objects.
public struct GroupResponse: Codable {
    public let data: [GroupData]
}

// MARK: - RetrieveGroup
/// `RetrieveGroup` is a struct that represents a group to be retrieved.
///
/// It contains the unique id, organization, identifier, title, identifiers, creation timestamp, deletion flag, and version of the group.
public struct RetrieveGroup: Codable {
    public let id, organization, identifier, title: String
    public let identifiers: [String]
    public let createdOn: Int
    public let deleted: Bool
    public let v: Int

    /// Coding keys to map the JSON keys to the properties.
    public enum CodingKeys: String, CodingKey {
        case id = "_id"
        case organization, identifier, title, identifiers, createdOn, deleted
        case v = "__v"
    }
}

/// `ListAllUsers` is a structure that represents a user.
///
/// It includes properties for the user's id, organization, type, identifier, creation date, first name, last name, and email.
public struct ListAllUsers: Codable {
    public let id, organization, type, identifier: String
    public let createdOn: Int
    public let firstName, lastName, email: String

    /// Coding keys for the `ListAllUsers` structure.
    public enum CodingKeys: String, CodingKey {
        case id = "_id"
        case organization, type, identifier, createdOn, firstName, lastName, email
    }
}

/// `ListAllUsersResponse` is a structure that represents a response containing a list of users.
///
/// It includes a property for the data which is an array of `ListAllUsers`.
public struct ListAllUsersResponse: Codable {
    /// The data of the response which is an array of `ListAllUsers`.
    public let data: [ListAllUsers]
}

/// `RetrieveUsers` is a structure that represents a user to be retrieved.
///
/// It includes properties for the user's id, organization, type, identifier, creation date, first name, last name, and email.
public struct RetrieveUsers: Codable {
    public let id, organization, type, identifier: String
    public let createdOn: Int
    public let firstName, lastName, email: String

    /// Coding keys for the `RetrieveUsers` structure.
    public enum CodingKeys: String, CodingKey {
        case id = "_id"
        case organization, type, identifier, createdOn, firstName, lastName, email
    }
}

/// `FieldTypes` is an enumeration that represents the types of fields.
///
/// It includes cases for text, multiSelect, dropdown, textarea, date, signature, block, number, chart, richText, table, and image.
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
    case collection
    case image
    case unknown

    public init(_ value: String?) {
        if let value = value {
            self = FieldTypes(rawValue: value) ?? .unknown
            return
        }
        self = .unknown
    }
}

public enum ColumnTypes: String {
    case text
    case dropdown
    case image
    case block
    case date
    case number
    case multiSelect
    case progress
    case barcode
    case table
    case signature
    case unknown
    
    public init(_ value: String?) {
        if let value = value {
            self = ColumnTypes(rawValue: value) ?? .unknown
            return
        }
        self = .unknown
    }
}

/// `DateFormatType` is an enumeration that represents the types of date formats.
///
/// Automatically converts JSON format patterns (YYYY, DD) to Swift DateFormatter patterns (yyyy, dd).
/// Provides convenience properties like `isDateOnly`, `isTimeOnly` to analyze the format.
public enum DateFormatType {
    case empty
    case custom(String)  // ✨ Handles ALL formats!
    
    // MARK: - Initialization
    
    /// Creates a DateFormatType from a format string
    /// Returns nil only if the string is nil (for optional chaining compatibility)
    public init?(rawValue: String?) {
        guard let rawValue = rawValue else {
            return nil
        }
        
        // Handle empty string
        if rawValue.isEmpty {
            self = .empty
            return
        }
        
        // Trim whitespace
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            self = .empty
            return
        }
        
        // Everything goes to .custom (no hardcoded formats!)
        self = .custom(trimmed)
    }
    
    public var rawValue: String {
        switch self {
        case .empty: return ""
        case .custom(let format): return format
        }
    }
    
    /// The date format corresponding to the `DateFormatType`.
    /// Converts from JSON format pattern (YYYY, DD) to Swift DateFormatter pattern (yyyy, dd).
    /// Returns a safe default for empty/invalid formats.
    public var dateFormat: String {
        if case .empty = self {
            return "MM/DD/YYYY hh:mma"  // Default format
        }
        
        let format = rawValue
        
        // Safety check: if format is empty or whitespace, use default
        if format.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "MM/DD/YYYY hh:mma"
        }
        
        // Convert JSON format to Swift DateFormatter pattern
        // Replace YYYY before YY to avoid conflicts
        return format
            .replacingOccurrences(of: "YYYY", with: "yyyy")  // 4-digit year (do first!)
            .replacingOccurrences(of: "DD", with: "dd")      // Day
            .replacingOccurrences(of: "YY", with: "yy")      // 2-digit year (do after YYYY)
            // Note: MM, HH, hh, mm, ss, SSS, a, Z are same in both JSON and Swift
    }
    
    // MARK: - Convenience Properties (analyze format string)
    
    /// Returns true if format contains time components (HH, hh, mm, a)
    public var hasTimeComponent: Bool {
        let upper = rawValue.uppercased()
        return upper.contains("HH")
    }
    
    /// Returns true if format contains date components (YYYY, MM, DD)
    public var hasDateComponent: Bool {
        let upper = rawValue.uppercased()
        return upper.contains("DD")
    }
    
    /// Returns true if format is date-only (no time components)
    /// Useful for: timezone conversions, picker type selection
    public var isDateOnly: Bool {
        return !hasTimeComponent
    }
    
    /// Returns true if format is time-only (no date components)
    public var isTimeOnly: Bool {
        return !hasDateComponent
    }
    
    /// Returns true if format has both date and time components
    public var isDateTime: Bool {
        return hasDateComponent && hasTimeComponent
    }
}

/// Converts an ISO8601 formatted string to a time string.
///
/// - Parameters:
///   - iso8601String: The ISO8601 formatted string representing a date and time.
///
/// - Returns: A formatted time string in the format "hh:mm a".
public func getTimeFromISO8601Format(iso8601String: String, tzId: String? = nil) -> String {
    let dateFormatter = ISO8601DateFormatter()
    let instant = dateFormatter.date(from: iso8601String)
    
    let timeZone = TimeZone(identifier: tzId ?? TimeZone.current.identifier)
    let zonedDateTime = instant ?? Date()
    
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a"
    formatter.timeZone = timeZone
    
    let timeString = formatter.string(from: zonedDateTime)
    return timeString
}

/// Converts a timestamp value in milliseconds to a formatted date string.
///
/// - Parameters:
///   - value: The timestamp value in milliseconds.
///   - format: The desired format for the date string. Supports US (MM/DD/YYYY) and European/Australian (DD/MM/YYYY) formats.
///
/// - Returns: A formatted date string based on the provided timestamp value and format.
public func timestampMillisecondsToDate(value: Int, format: DateFormatType, tzId: String? = nil) -> String {
    let timestampMilliseconds: TimeInterval = TimeInterval(value)
    let date = Date(timeIntervalSince1970: timestampMilliseconds / 1000.0)
    let dateFormatter = DateFormatter()
    let timeZone = TimeZone(identifier: tzId ?? TimeZone.current.identifier)
    dateFormatter.timeZone = timeZone
    dateFormatter.dateFormat = format.dateFormat
    
    let formattedDate = dateFormatter.string(from: date)
    return formattedDate
}

/// Converts a given `Date` object to a timestamp in milliseconds.
///
/// - Parameter date: The `Date` object to be converted.
/// - Returns: The timestamp in milliseconds.
public func dateToTimestampMilliseconds(date: Date) -> Double {
    let timestampSeconds = date.timeIntervalSince1970
    let timestampMilliseconds = Double(timestampSeconds * 1000)
    return timestampMilliseconds
}

public struct TargetRowModel {
    public let id: String
    public let index: Int

    public init(id: String, index: Int) {
        self.id = id
        self.index = index
    }
}
