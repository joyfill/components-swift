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
/// Supports various international date and time formats with automatic conversion from JSON format strings to Swift DateFormatter patterns.
public enum DateFormatType: String {
    // US Date Formats (MM/DD/YYYY)
    case dateOnly = "MM/DD/YYYY"
    case dateTime = "MM/DD/YYYY hh:mma"
    case dateTime24 = "MM/DD/YYYY HH:mm"
    case dateTimeWithSeconds = "MM/DD/YYYY hh:mm:ssa"
    case dateTime24WithSeconds = "MM/DD/YYYY HH:mm:ss"
    
    // European/Australian Date Formats (DD/MM/YYYY)
    case dateOnlyDDMMYYYY = "DD/MM/YYYY"
    case dateTimeDDMMYYYY = "DD/MM/YYYY HH:mm"
    case dateTimeDDMMYYYY12Hour = "DD/MM/YYYY hh:mma"
    case dateTimeDDMMYYYYWithSeconds = "DD/MM/YYYY HH:mm:ss"
    case dateTimeDDMMYYYY12HourWithSeconds = "DD/MM/YYYY hh:mm:ssa"
    
    // ISO and Asian Date Formats (YYYY-MM-DD / YYYY/MM/DD)
    case dateOnlyISO = "YYYY-MM-DD"
    case dateTimeISO = "YYYY-MM-DD HH:mm"
    case dateTimeISOWithSeconds = "YYYY-MM-DD HH:mm:ss"
    case dateOnlyYYYYMMDD = "YYYY/MM/DD"
    case dateTimeYYYYMMDD = "YYYY/MM/DD HH:mm"
    
    // Hyphen Separated Formats
    case dateOnlyDashUS = "MM-DD-YYYY"
    case dateOnlyDashEU = "DD-MM-YYYY"
    case dateTimeDashUS = "MM-DD-YYYY HH:mm"
    case dateTimeDashEU = "DD-MM-YYYY HH:mm"
    
    // Short Year Formats (YY)
    case dateOnlyShortYear = "MM/DD/YY"
    case dateOnlyShortYearEU = "DD/MM/YY"
    
    // Time Only Formats
    case timeOnly = "hh:mma"
    case timeOnly24 = "HH:mma"
    case timeOnly24Hour = "HH:mm"
    case timeOnlyWithSeconds = "hh:mm:ssa"
    case timeOnly24HourWithSeconds = "HH:mm:ss"
    
    case empty = ""
    
    /// The date format corresponding to the `DateFormatType`.
    /// Converts from JSON format pattern (YYYY, DD) to Swift DateFormatter pattern (yyyy, dd).
   public var dateFormat: String {
       if self == .empty {
           return "MM/dd/yyyy hh:mma"
       }
        // Convert JSON format to Swift DateFormatter pattern
        return self.rawValue
            .replacingOccurrences(of: "YYYY", with: "yyyy")  // Year: YYYY → yyyy
            .replacingOccurrences(of: "YY", with: "yy")      // Short year: YY → yy
            .replacingOccurrences(of: "DD", with: "dd")      // Day: DD → dd
            .replacingOccurrences(of: "MM", with: "MM")      // Month: stays MM (need to handle before mm)
            .replacingOccurrences(of: "HH", with: "HH")      // Hour 24: stays HH
            .replacingOccurrences(of: "hh", with: "hh")      // Hour 12: stays hh
            .replacingOccurrences(of: "mm", with: "mm")      // Minute: stays mm
            .replacingOccurrences(of: "ss", with: "ss")      // Second: stays ss
            .replacingOccurrences(of: "a", with: "a")        // AM/PM: stays a
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
    
    // Set locale based on format type
    if format.rawValue.contains("HH") {
        // Force 24-hour format
        dateFormatter.locale = Locale(identifier: "en_GB")
    } else if format == .empty || format.rawValue.contains("hh") {
        // For 12-hour format, use en_US_POSIX to ensure consistent 12-hour display
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    }
    
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
