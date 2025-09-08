//
//  ValueUnion.swift
//  JoyfillModel
//
//  Created by Vishnu Dutt on 24/04/25.
//

import Foundation

/// `ValueUnion` is an enumeration that represents different types of values.
///
/// It can represent a `Double`, `String`, `Array<String>`, `Array<ValueElement>`, `Dictionary<String, ValueUnion>`, `Bool`, or `null`.
public enum ValueUnion: Codable, Hashable, Equatable {
    public static func == (lhs: ValueUnion, rhs: ValueUnion) -> Bool {
        switch (lhs, rhs) {
        case (.double(let a), .double(let b)):
            return a == b
        case (.string(let a), .string(let b)):
            return a == b
        case (.array(let a), .array(let b)):
            return a == b
        case (.valueElementArray(let a), .valueElementArray(let b)):
            return a == b
        case (.dictionary(let a), .dictionary(let b)):
            return a == b
        case (.bool(let a), .bool(let b)):
            return a == b
        case (.null, .null):
            return true
        default:
            return false
        }
    }
    /// Represents a `Double` value.
    case double(Double)
    case int(Int64)
    /// Represents a `String` value.
    case string(String)
    /// Represents a `Array<String>` value.
    case array([String])
    /// Represents a `Array<ValueElement>` value.
    case valueElementArray([ValueElement])
    /// Represents a `Dictionary<String, ValueUnion>` value.
    case dictionary([String: ValueUnion])
    /// Represents a `Bool` value.
    case bool(Bool)
    /// Represents a `null` value.
    case null

    /// Creates a new `ValueUnion` with the given dictionary.
    ///
    /// - Parameter dictionary: The dictionary that contains the initial properties of the column.
    public init(valueUnionDictionary: [String: ValueUnion]) {
        self = .dictionary(valueUnionDictionary)
    }

    public var nullOrEmpty: Bool {
        switch self {
        case .double(let double):
            return double == nil
        case .string(let string):
            return string.isEmpty
        case .array(let stringArray):
            return stringArray.isEmpty
        case .valueElementArray(let valueElementArray):
            return valueElementArray.map { $0.anyDictionary }.isEmpty
        case .bool(let bool):
            return bool
        case .null:
            return true
        case .dictionary(let dictionary):
            return dictionary.isEmpty
        case .int(let int):
            return int == nil
        }
    }

    /// Creates a new `ValueUnion` with the given dictionary.
    ///
    /// - Parameter dictionary: The dictionary that contains the initial properties of the column.
    public init(anyDictionary: [String: Any]) {
        var dictionary = [String : ValueUnion]()
        anyDictionary.forEach { dict in
            dictionary[dict.key] = ValueUnion(value: dict.value)
        }
        self = .dictionary(dictionary)
    }

    /// Creates a new `ValueUnion` with the given dictionary.
    ///
    /// - Parameter valueFromDictionary: The dictionary that contains the initial properties of the column.
    public init?(valueFromDictionary: [String: Any]) {
        guard let value = valueFromDictionary["value"] else { return nil }
        self.init(value: value)
    }

    /// Creates a new `ValueUnion` with the given value.
    ///
    /// - Parameter value: The value that the `ValueUnion` should represent.
    public init?(value: Any) {
        if let doubleValue = value as? Double {
            self = .double(doubleValue)
            return
        }
        
        if let int64Value = value as? Int64 {
            self = .int(int64Value)
            return
        }
        
        if let intValue = value as? Int {
            self = .int(Int64(intValue))
            return
        }

        if let boolValue = value as? Bool {
            self = .bool(boolValue)
            return
        }

        if let valueUnion = value as? ValueUnion {
            self = valueUnion
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

        if let valueElementArray = value as? [[String: Any]] {
            self = .valueElementArray(valueElementArray.map(ValueElement.init))
            return
        }

        if let valueElementArray = value as? [ValueElement] {
            self = .valueElementArray(valueElementArray)
            return
        }

        if let valueDictionary = value as? [String: Any] {
            self = ValueUnion.init(anyDictionary: valueDictionary)
            return
        }

        if value == nil || value is NSNull {
            self = .null
            return
        }
        
        guard let optionalValue = value as? Optional<Any>, let value = optionalValue else {
            self = .null
            return
        }
        
#if DEBUG
        fatalError("ValueUnion init: unsupported type \(type(of: value))")
#else
        self = .null
#endif
    }

    /// The dictionary representation of the `ValueUnion`.
    public var dictionary: Any? {
        switch self {
        case .double(let double):
            return double
        case .string(let string):
            return string
        case .array(let stringArray):
            return stringArray
        case .valueElementArray(let valueElementArray):
            return valueElementArray.map { $0.anyDictionary }
        case .bool(let bool):
            return bool
        case .null:
            return nil
        case .dictionary(let dictionary):
            var anyDict = [String: Any]()
            dictionary.forEach { (key: String, value: ValueUnion) in
                anyDict[key] = value.dictionary
            }
            return anyDict
        case .int(let int):
            return int
        }
    }

    /// The dictionary representation of the `ValueUnion` with `ValueUnion` types.
    var dictionaryWithValueUnionTypes: Any? {
        switch self {
        case .double(let double):
            return double
        case .string(let string):
            return string
        case .array(let stringArray):
            return stringArray
        case .valueElementArray(let valueElementArray):
            return valueElementArray
        case .bool(let bool):
            return bool
        case .null:
            return nil
        case .dictionary(let dictionary):
            return dictionary
        case .int(let int):
            return int
        }
    }

    /// Creates a new `ValueUnion` by decoding from the given decoder.
    ///
    /// - Parameter decoder: The decoder to decode data from.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Double.self) {
            self = .double(x)
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
        if let x = try? container.decode(Bool.self) {
            self = .bool(x)
            return
        }
        if container.decodeNil() {
            self = .null
            return
        }
        throw DecodingError.typeMismatch(ValueUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ValueUnion"))
    }
    
    /// Encodes this `ValueUnion` into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
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
        case .dictionary(let dictionary):
            try container.encode(dictionary)
        case .int(let x):
            try container.encode(x)
        }
    }

    public var isEmpty: Bool {
        switch self {
        case .double(let double):
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
        case .dictionary(let dictionary):
            return dictionary.isEmpty
        case .int(let int):
            return false
        }
    }
}

/// Extension on `ValueUnion` to provide computed properties and methods for different types of values.
public extension ValueUnion {

    /// Returns a text representation of the value for any ValueUnion type
    var text: String? {
        switch self {
        case .string(let string):
            return string
        case .double(let double):
            return String(double)
        case .int(let int):
            return String(int)
        case .bool(let bool):
            return bool ? "true" : "false"
        case .array(let array):
            return array.joined(separator: ", ")
        case .valueElementArray(let elements):
            let descriptions = elements.compactMap { element -> String? in
                if let id = element.id {
                    return "Element(\(id))"
                }
                return "Element"
            }
            return descriptions.joined(separator: ", ")
        case .dictionary(let dict):
            let keyValues = dict.map { key, value in
                if let valueText = value.text {
                    return "\(key): \(valueText)"
                } else {
                    return "\(key): null"
                }
            }
            return "{\(keyValues.joined(separator: ", "))}"
        case .null:
            return nil
        }
    }

    /// Returns the boolean value if the `ValueUnion` is a boolean, otherwise returns `nil`.
    /// If the `ValueUnion` is a double, it returns `true` if the double value is not equal to 0, otherwise returns `false`.
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

    /// Returns the display text value if the `ValueUnion` is a string, otherwise returns `nil`.
    var displayText: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }

    /// Returns the display text value if the `ValueUnion` is a array of string, otherwise returns `nil`.
    var stringArray: [String]? {
        switch self {
        case .array(let stringArray):
            return stringArray
        default:
            return nil
        }
    }

    /// Returns an array of image URLs if the `ValueUnion` is an array of `ValueElement`, otherwise returns `nil`.
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

    /// Returns the signature URL value if the `ValueUnion` is a string, otherwise returns `nil`.
    var signatureURL: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }

    /// Returns the multiline text value if the `ValueUnion` is a string, otherwise returns `nil`.
    var multilineText: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }

    /// Returns the number value if the `ValueUnion` is a double.
    /// If the `ValueUnion` is a boolean, it returns 1 if the boolean value is `true`, otherwise returns 0.
    var number: Double? {
        switch self {
        case .double(let int):
            return int
        case .bool(let value):
            if value {
                return 1
            }
            return 0
        case .int(let int)
            : return Double(int)
        default:
            return nil
        }
    }

    /// Returns the dropdown value if the `ValueUnion` is a string, otherwise returns `nil`.
    var dropdownValue: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }

    /// Returns the selector value if the `ValueUnion` is a string, otherwise returns `nil`.
    var selector: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }

    /// Returns an array of strings if the `ValueUnion` is an array, otherwise returns `nil`.
    var multiSelector: [String]? {
        switch self {
        case .array(let array):
            return array
        default:
            return nil
        }
    }

    /// Returns a formatted date and time string based on the `format` parameter.
    /// If the `ValueUnion` is a string, it assumes the string is in ISO8601 format and converts it to the specified format.
    /// If the `ValueUnion` is a double, it assumes the double value represents a timestamp in milliseconds and converts it to the specified format.
    /// Returns `nil` if the `ValueUnion` is neither a string nor a double.
    func dateTime(format: DateFormatType, tzId: String? = nil) -> String? {
        switch self {
        case .string(let string):
            let date = getTimeFromISO8601Format(iso8601String: string, tzId: tzId)
            return date
        case .double(let integer):
            let date = timestampMillisecondsToDate(value: Int(integer), format: format, tzId: tzId)
            return date
        case .int(let intValue):
            let date = timestampMillisecondsToDate(value: Int(intValue), format: format, tzId: tzId)
            return date

        default:
            return nil
        }
    }

    /// Returns an array of `ValueElement` if the `ValueUnion` is an array of `ValueElement`, otherwise returns `nil`.
    var valueElements: [ValueElement]? {
        switch self {
        case .valueElementArray(let valueElements):
            return valueElements
        default:
            return nil
        }
    }
}
