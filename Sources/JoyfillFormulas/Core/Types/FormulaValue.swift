import Foundation

/// Represents the possible value types that can result from formula evaluation.
public enum FormulaValue: Equatable {
    case number(Double) // Use Double for flexibility with decimals
    case string(String)
    case boolean(Bool)
    case date(Date) // Represents a specific point in time
    case array([FormulaValue]) // Array containing other FormulaValue types
    case dictionary([String: FormulaValue]) // Represents nested objects
    case null // Explicit null type
    case undefined // Explicit undefined type
    case error(FormulaError) // Represents an evaluation error
    case lambda(parameters: [String], body: ASTNode) // Lambda expressions

    // Convenience Initializer from Any (Attempt conversion)
    // Keep this one as it deals with standard Swift types
    init?(anyValue: Any) {
        if let num = anyValue as? Double { self = .number(num) }
        else if let num = anyValue as? Int { self = .number(Double(num)) } 
        else if let str = anyValue as? String { self = .string(str) }
        else if let bool = anyValue as? Bool { self = .boolean(bool) }
        else if let date = anyValue as? Date { self = .date(date) }
        // Cannot handle Array<Any> or [String: Any] directly here
        else if anyValue is NSNull { self = .null } // Handle NSNull -> null
        else { return nil } 
    }

    public var boolValue: Bool {
        switch self {
        case .boolean(let bool): return bool
        default: return false
        }
    }

    /// Compares this value with another for sorting purposes.
    /// - Parameter other: The value to compare against.
    /// - Returns: `.orderedAscending`, `.orderedSame`, `.orderedDescending`, or `nil` if types are incompatible for comparison.
    func compare(to other: FormulaValue) -> ComparisonResult? {
        switch (self, other) {
        case (.number(let l), .number(let r)):
            if l < r { return .orderedAscending }
            if l > r { return .orderedDescending }
            return .orderedSame
        case (.string(let l), .string(let r)):
            // Standard string comparison
            return l.compare(r)
        case (.date(let l), .date(let r)):
            return l.compare(r)
        default:
            // Types are not comparable (e.g., number vs string, boolean vs array)
            return nil 
        }
    }
}

/// Represents errors that can occur during formula parsing or evaluation.
public enum FormulaError: Error, Equatable {
    case syntaxError(String)
    case invalidReference(String)
    case typeMismatch(expected: String, actual: String)
    case invalidArguments(function: String, reason: String)
    case divisionByZero
    case circularReference(String)
    case unknownError(String)
    // TODO: Add more specific error types as needed
}

// Initial placeholder - we might remove or refine this later.
// This file will be the central definition for types.
// We might move FormulaError to its own file if it grows complex. 
