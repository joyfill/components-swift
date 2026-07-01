import Foundation

/// Date function implementations for date-related operations
public struct DateFunctions {
    
    /// Helper function to get a UTC calendar for consistent date operations
    private static var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }
    
    /// Helper function to convert a FormulaValue to a Date.
    /// Per spec: a string is parsed into a timestamp (numeric) or a date string
    /// (ISO 8601, with or without fractional seconds, or date-only). Returns nil
    /// only when the value cannot be interpreted as a date at all.
    private static func extractDate(from value: FormulaValue) -> Date? {
        switch value {
        case .date(let date):
            return date
        case .number(let timestamp):
            return dateFromTimestamp(timestamp)
        case .string(let raw):
            let str = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            // Numeric string -> treat as a timestamp
            if let timestamp = Double(str) {
                return dateFromTimestamp(timestamp)
            }
            // Otherwise try to parse it as a date string
            return parseDateString(str)
        default:
            return nil
        }
    }

    /// Interprets a numeric timestamp, using a milliseconds/seconds heuristic.
    private static func dateFromTimestamp(_ timestamp: Double) -> Date {
        if timestamp > 1000000000000 { // Milliseconds (> ~year 2001 in milliseconds)
            return Date(timeIntervalSince1970: timestamp / 1000.0)
        } else { // Seconds
            return Date(timeIntervalSince1970: timestamp)
        }
    }

    /// Parses common date string formats (ISO 8601 with/without fractional
    /// seconds, and date-only "yyyy-MM-dd"). Returns nil if unparseable.
    private static func parseDateString(_ str: String) -> Date? {
        let isoFractional = ISO8601DateFormatter()
        isoFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFractional.date(from: str) { return date }

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        if let date = iso.date(from: str) { return date }

        let dateOnly = DateFormatter()
        dateOnly.calendar = Calendar(identifier: .gregorian)
        dateOnly.timeZone = TimeZone(secondsFromGMT: 0)
        dateOnly.locale = Locale(identifier: "en_US_POSIX")
        dateOnly.dateFormat = "yyyy-MM-dd"
        if let date = dateOnly.date(from: str) { return date }

        return nil
    }
    
    /// Implements the NOW function: NOW()
    static func now(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.isEmpty else {
            return .failure(.invalidArguments(function: "NOW", reason: "Expected 0 arguments, got \(args.count)"))
        }
        
        return .success(.date(Date()))
    }
    
    /// Implements the YEAR function: YEAR(date)
    static func year(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 1 else {
            return .failure(.invalidArguments(function: "YEAR", reason: "Expected exactly 1 argument, got \(args.count)"))
        }
        
        // Evaluate the argument
        let dateResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let dateValue) = dateResult else { return dateResult }
        
        // Extract date from the value (handles both Date objects and timestamps)
        guard let date = extractDate(from: dateValue) else {
            return .failure(.typeMismatch(expected: "Date or timestamp", actual: "Argument: \(typeDescription(dateValue))"))
        }
        
        // Extract year component using UTC calendar
        let calendar = utcCalendar
        let year = calendar.component(.year, from: date)
        return .success(.number(Double(year)))
    }
    
    /// Implements the MONTH function: MONTH(date)
    static func month(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 1 else {
            return .failure(.invalidArguments(function: "MONTH", reason: "Expected exactly 1 argument, got \(args.count)"))
        }
        
        // Evaluate the argument
        let dateResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let dateValue) = dateResult else { return dateResult }
        
        // Extract date from the value (handles both Date objects and timestamps)
        guard let date = extractDate(from: dateValue) else {
            return .failure(.typeMismatch(expected: "Date or timestamp", actual: "Argument: \(typeDescription(dateValue))"))
        }
        
        // Extract month component (1-12) using UTC calendar
        let calendar = utcCalendar
        let month = calendar.component(.month, from: date)
        return .success(.number(Double(month)))
    }
    
    /// Implements the DAY function: DAY(date)
    static func day(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 1 else {
            return .failure(.invalidArguments(function: "DAY", reason: "Expected exactly 1 argument, got \(args.count)"))
        }
        
        // Evaluate the argument
        let dateResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let dateValue) = dateResult else { return dateResult }
        
        // Handle null values gracefully
        if case .null = dateValue {
            return .success(.null)
        }
        
        // Extract date from the value (handles both Date objects and timestamps)
        guard let date = extractDate(from: dateValue) else {
            return .failure(.typeMismatch(expected: "Date or timestamp", actual: "Argument: \(typeDescription(dateValue))"))
        }
        
        // Extract day component (1-31) using UTC calendar
        let calendar = utcCalendar
        let day = calendar.component(.day, from: date)
        return .success(.number(Double(day)))
    }
    
    /// Implements the DATE function: DATE(year, month, day)
    static func date(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 3 else {
            return .failure(.invalidArguments(function: "DATE", reason: "Expected exactly 3 arguments (year, month, day), got \(args.count)"))
        }
        
        // Evaluate year
        let yearResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let yearValue) = yearResult else { return yearResult }
        guard case .number(let year) = yearValue else {
            return .failure(.typeMismatch(expected: "Number for year", actual: "Argument 1: \(typeDescription(yearValue))"))
        }
        
        // Evaluate month
        let monthResult = evaluator.evaluate(node: args[1], context: context)
        guard case .success(let monthValue) = monthResult else { return monthResult }
        guard case .number(let month) = monthValue else {
            return .failure(.typeMismatch(expected: "Number for month", actual: "Argument 2: \(typeDescription(monthValue))"))
        }
        
        // Evaluate day
        let dayResult = evaluator.evaluate(node: args[2], context: context)
        guard case .success(let dayValue) = dayResult else { return dayResult }
        guard case .number(let day) = dayValue else {
            return .failure(.typeMismatch(expected: "Number for day", actual: "Argument 3: \(typeDescription(dayValue))"))
        }
        
        // Create date components using UTC calendar
        var components = DateComponents()
        components.year = Int(year)
        components.month = Int(month)
        components.day = Int(day)
        
        // Create date using UTC calendar
        let calendar = utcCalendar
        guard let newDate = calendar.date(from: components) else {
            return .failure(.unknownError("Invalid date: year=\(year), month=\(month), day=\(day)"))
        }
        
        return .success(.date(newDate))
    }
    
    /// Implements the DATEADD function: DATEADD(date, amount, unit)
    static func dateAdd(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 3 else {
            return .failure(.invalidArguments(function: "DATEADD", reason: "Expected exactly 3 arguments (date, amount, unit), got \(args.count)"))
        }
        
        // Evaluate date
        let dateResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let dateValue) = dateResult else { return dateResult }
        
        // Bad date argument -> invalid timestamp (0)
        guard let date = extractDate(from: dateValue) else {
            return .success(.number(0))
        }

        // Evaluate amount
        let amountResult = evaluator.evaluate(node: args[1], context: context)
        guard case .success(let amountValue) = amountResult else { return amountResult }
        guard case .number(let amount) = amountValue, amount.isFinite else {
            return .success(.number(0))
        }

        // Evaluate unit
        let unitResult = evaluator.evaluate(node: args[2], context: context)
        guard case .success(let unitValue) = unitResult else { return unitResult }
        guard case .string(let unitString) = unitValue else {
            return .success(.number(0))
        }

        // Bad/invalid unit -> invalid timestamp (0)
        guard let component = getCalendarComponent(from: unitString) else {
            return .success(.number(0))
        }

        // Add to date using UTC calendar; a failed computation -> 0
        let calendar = utcCalendar
        guard let newDate = calendar.date(byAdding: component, value: Int(amount), to: date) else {
            return .success(.number(0))
        }

        return .success(.date(newDate))
    }
    
    /// Implements the DATESUBTRACT function: DATESUBTRACT(date, amount, unit)
    static func dateSubtract(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 3 else {
            return .failure(.invalidArguments(function: "DATESUBTRACT", reason: "Expected exactly 3 arguments (date, amount, unit), got \(args.count)"))
        }
        
        // Evaluate date
        let dateResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let dateValue) = dateResult else { return dateResult }
        
        // Extract date from the value (handles both Date objects and timestamps)
        guard let date = extractDate(from: dateValue) else {
            return .failure(.typeMismatch(expected: "Date or timestamp", actual: "Argument 1: \(typeDescription(dateValue))"))
        }
        
        // Evaluate amount
        let amountResult = evaluator.evaluate(node: args[1], context: context)
        guard case .success(let amountValue) = amountResult else { return amountResult }
        guard case .number(let amount) = amountValue else {
            return .failure(.typeMismatch(expected: "Number for amount", actual: "Argument 2: \(typeDescription(amountValue))"))
        }
        
        // Evaluate unit
        let unitResult = evaluator.evaluate(node: args[2], context: context)
        guard case .success(let unitValue) = unitResult else { return unitResult }
        guard case .string(let unitString) = unitValue else {
            return .failure(.typeMismatch(expected: "String for unit", actual: "Argument 3: \(typeDescription(unitValue))"))
        }
        
        // Convert unit string to Calendar.Component
        guard let component = getCalendarComponent(from: unitString) else {
            return .failure(.invalidArguments(function: "DATESUBTRACT", reason: "Invalid unit: \(unitString). Valid units are: 'years', 'months', 'weeks', 'days', 'hours', 'minutes', 'seconds', 'milliseconds'"))
        }
        
        // Subtract from date (add negative amount) using UTC calendar
        let calendar = utcCalendar
        guard let newDate = calendar.date(byAdding: component, value: -Int(amount), to: date) else {
            return .failure(.unknownError("Failed to subtract \(amount) \(unitString) from date: \(date)"))
        }
        
        return .success(.date(newDate))
    }
    
    // Helper function to convert unit string to Calendar.Component
    private static func getCalendarComponent(from unit: String) -> Calendar.Component? {
        let normalizedUnit = unit.lowercased()
        
        switch normalizedUnit {
        case "years", "year", "y":
            return .year
        case "months", "month", "m":
            return .month
        case "weeks", "week", "w":
            return .weekOfYear
        case "days", "day", "d":
            return .day
        case "hours", "hour", "h":
            return .hour
        case "minutes", "minute", "min":
            return .minute
        case "seconds", "second", "sec", "s":
            return .second
        case "milliseconds", "millisecond", "ms":
            return .nanosecond // Will be adjusted by multiplying value by 1,000,000
        default:
            return nil
        }
    }
    
    // Helper function to get type description
    private static func typeDescription(_ value: FormulaValue) -> String {
        switch value {
        case .number: return "Number"
        case .string: return "String"
        case .boolean: return "Boolean"
        case .date: return "Date"
        case .array: return "Array"
        case .dictionary: return "Dictionary"
        case .null: return "Null"
        case .undefined: return "Undefined"
        case .error: return "Error"
        case .lambda(_, _): return "Lambda"
        }
    }
    
    /// Implements the TIMESTAMP function: TIMESTAMP(milliseconds)
    /// Converts a timestamp in milliseconds to a Date object
    static func timestamp(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 1 else {
            return .failure(.invalidArguments(function: "TIMESTAMP", reason: "Expected exactly 1 argument (milliseconds), got \(args.count)"))
        }
        
        // Evaluate the timestamp value
        let timeResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let timeValue) = timeResult else { return timeResult }
        
        // Ensure it's a number
        guard case .number(let milliseconds) = timeValue else {
            return .failure(.typeMismatch(expected: "Number", actual: "Argument: \(typeDescription(timeValue))"))
        }
        
        // Convert milliseconds to seconds for Date initializer
        let seconds = milliseconds / 1000.0
        let date = Date(timeIntervalSince1970: seconds)
        
        return .success(.date(date))
    }
} 