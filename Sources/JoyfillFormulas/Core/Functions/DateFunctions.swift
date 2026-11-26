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

    /// Interprets a numeric value as a UTC epoch timestamp in milliseconds.
    /// Wisdom date inputs are always epoch milliseconds — small numbers are no longer
    /// treated as seconds, so the whole engine reads numbers the same way.
    private static func dateFromTimestamp(_ timestamp: Double) -> Date {
        return Date(timeIntervalSince1970: timestamp / 1000.0)
    }

    private static let isoFractionalFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let dateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    /// Parses common date string formats (ISO 8601 with/without fractional
    /// seconds, and date-only "yyyy-MM-dd"). Returns nil if unparseable.
    private static func parseDateString(_ str: String) -> Date? {
        if let date = isoFractionalFormatter.date(from: str) { return date }
        if let date = isoFormatter.date(from: str) { return date }
        if let date = dateOnlyFormatter.date(from: str) { return date }
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
    
    /// Implements the DATE function: DATE(year, month, day, hour?, minute?, second?)
    /// Time parts default to 0 and are interpreted in UTC.
    static func date(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard (3...6).contains(args.count) else {
            return .failure(.invalidArguments(function: "DATE", reason: "Expected 3 to 6 arguments (year, month, day, hour?, minute?, second?), got \(args.count)"))
        }

        // Evaluate each argument to an integer; time parts default to 0.
        func intArg(_ index: Int, _ label: String) -> Result<Int, FormulaError> {
            guard index < args.count else {
                return .success(0)
            }
            let result = evaluator.evaluate(node: args[index], context: context)
            guard case .success(let value) = result else {
                if case .failure(let error) = result { return .failure(error) }
                return .failure(.unknownError("Invalid \(label)"))
            }
            guard case .number(let number) = value else {
                return .failure(.typeMismatch(expected: "Number for \(label)", actual: "Argument \(index + 1): \(typeDescription(value))"))
            }
            guard let intValue = number.safeInt else {
                return .failure(.unknownError("Invalid \(label): \(number)"))
            }
            return .success(intValue)
        }

        let parts = ["year", "month", "day", "hour", "minute", "second"]
        var values: [Int] = []
        for (index, label) in parts.enumerated() {
            switch intArg(index, label) {
            case .success(let value): values.append(value)
            case .failure(let error): return .failure(error)
            }
        }

        // Create date components using UTC calendar
        var components = DateComponents()
        components.year = values[0]
        components.month = values[1]
        components.day = values[2]
        components.hour = values[3]
        components.minute = values[4]
        components.second = values[5]

        let calendar = utcCalendar
        guard let newDate = calendar.date(from: components) else {
            return .failure(.unknownError("Invalid date: \(values)"))
        }

        return .success(.date(newDate))
    }

    /// Implements the TIME function: TIME(hour, minute, second)
    /// Returns a UTC date on the epoch day (1970-01-01) at the given time.
    static func time(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 3 else {
            return .failure(.invalidArguments(function: "TIME", reason: "Expected exactly 3 arguments (hour, minute, second), got \(args.count)"))
        }

        var values: [Int] = []
        for (index, label) in ["hour", "minute", "second"].enumerated() {
            let result = evaluator.evaluate(node: args[index], context: context)
            guard case .success(let value) = result else { return result }
            guard case .number(let number) = value else {
                return .failure(.typeMismatch(expected: "Number for \(label)", actual: "Argument \(index + 1): \(typeDescription(value))"))
            }
            guard let intValue = number.safeInt else {
                return .failure(.unknownError("Invalid \(label): \(number)"))
            }
            values.append(intValue)
        }

        var components = DateComponents()
        components.year = 1970
        components.month = 1
        components.day = 1
        components.hour = values[0]
        components.minute = values[1]
        components.second = values[2]

        let calendar = utcCalendar
        guard let newDate = calendar.date(from: components) else {
            return .failure(.unknownError("Invalid time: \(values)"))
        }

        return .success(.date(newDate))
    }

    /// Implements the FORMATDATE function: FORMATDATE(date, format, timezone?)
    /// `format` uses moment-style tokens (YYYY, MM, DD, HH, hh, mm, ss, a, …).
    /// `timezone` is "UTC", an IANA id (e.g. "America/New_York"), or omitted for
    /// the device timezone.
    static func formatDate(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 2 || args.count == 3 else {
            return .failure(.invalidArguments(function: "FORMATDATE", reason: "Expected 2 or 3 arguments (date, format, timezone?), got \(args.count)"))
        }

        // Date
        let dateResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let dateValue) = dateResult else { return dateResult }
        if case .null = dateValue { return .success(.string("")) }
        guard let date = extractDate(from: dateValue) else {
            return .success(.string(""))
        }

        // Format
        let formatResult = evaluator.evaluate(node: args[1], context: context)
        guard case .success(let formatValue) = formatResult else { return formatResult }
        guard case .string(let momentFormat) = formatValue else {
            return .failure(.typeMismatch(expected: "String for format", actual: "Argument 2: \(typeDescription(formatValue))"))
        }

        // Timezone (optional)
        var timeZone = TimeZone.current
        if args.count == 3 {
            let tzResult = evaluator.evaluate(node: args[2], context: context)
            guard case .success(let tzValue) = tzResult else { return tzResult }
            guard case .string(let tzString) = tzValue else {
                return .failure(.typeMismatch(expected: "String for timezone", actual: "Argument 3: \(typeDescription(tzValue))"))
            }
            if tzString.uppercased() == "UTC" {
                timeZone = TimeZone(secondsFromGMT: 0)!
            } else if let zone = TimeZone(identifier: tzString) {
                timeZone = zone
            } else {
                return .success(.string(""))
            }
        }

        // DayJS `d` is a 0-based day-of-week number (0=Sunday) that ICU patterns cannot
        // express, so compute it in the target timezone and inline it as a literal.
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let numericWeekday = calendar.component(.weekday, from: date) - 1

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = momentToICUFormat(momentFormat, numericWeekday: numericWeekday)

        return .success(.string(formatter.string(from: date)))
    }

    /// Converts a moment/dayjs-style format string to a Swift `DateFormatter` (Unicode)
    /// pattern. Scans maximal runs of the same token letter so `DD` and `D` map
    /// independently. DayJS escapes literal text with square brackets (`[...]`); those
    /// become ICU quoted literals. Any other non-token letter is also escaped so it
    /// prints verbatim instead of being read as an ICU pattern letter.
    /// `numericWeekday` is the date's 0-based day of week (0=Sunday), inlined for `d`.
    static func momentToICUFormat(_ format: String, numericWeekday: Int = 0) -> String {
        var result = ""
        let chars = Array(format)
        var index = 0
        // Letters that carry meaning as moment tokens; everything else passes through.
        let tokenLetters = Set("YMDdHhmsaASZ")

        while index < chars.count {
            let char = chars[index]

            // DayJS literal: everything between [ and ] is emitted verbatim.
            if char == "[" {
                index += 1
                var literal = ""
                while index < chars.count && chars[index] != "]" {
                    literal.append(chars[index])
                    index += 1
                }
                if index < chars.count { index += 1 } // consume the closing ]
                result += icuEscapedLiteral(literal)
                continue
            }

            guard tokenLetters.contains(char) else {
                // Escape stray ASCII letters so DateFormatter does not read them as tokens.
                if char.isLetter {
                    result += icuEscapedLiteral(String(char))
                } else {
                    result.append(char)
                }
                index += 1
                continue
            }

            // Measure the run length of this token letter.
            var length = 1
            while index + length < chars.count && chars[index + length] == char {
                length += 1
            }
            result += icuToken(for: char, length: length, numericWeekday: numericWeekday)
            index += length
        }

        return result
    }

    /// Wraps text as an ICU quoted literal, doubling any embedded single quote. Empty in → empty out.
    private static func icuEscapedLiteral(_ text: String) -> String {
        guard !text.isEmpty else { return "" }
        return "'" + text.replacingOccurrences(of: "'", with: "''") + "'"
    }

    private static func icuToken(for char: Character, length: Int, numericWeekday: Int) -> String {
        func run(_ token: Character) -> String { String(repeating: token, count: length) }
        switch char {
        case "Y": return length >= 3 ? "yyyy" : "yy"          // year
        case "M": return run("M")                              // month (M, MM, MMM, MMMM)
        case "D": return length >= 2 ? "dd" : "d"              // day of month
        case "d":                                              // day of week
            switch length {
            case 1: return String(numericWeekday)              // 0-based number (0=Sun), e.g. "0"
            case 2: return "EEEEEE"                             // short name, e.g. "Su"
            case 3: return "EEE"                                // abbreviated, e.g. "Sun"
            default: return "EEEE"                              // full, e.g. "Sunday"
            }
        case "H": return run("H")                              // hour 24
        case "h": return run("h")                              // hour 12
        case "m": return run("m")                              // minute
        case "s": return run("s")                              // second
        case "S": return run("S")                              // fractional second
        case "a", "A": return "a"                              // AM/PM (ICU renders uppercase)
        case "Z": return length >= 2 ? "xx" : "xxx"            // offset: ZZ=+0000, Z=+00:00
        default: return run(char)
        }
    }

    /// Implements the HOUR function: HOUR(date) — UTC
    static func hour(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        return component(.hour, name: "HOUR", args: args, context: context, evaluator: evaluator)
    }

    /// Implements the MINUTE function: MINUTE(date) — UTC
    static func minute(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        return component(.minute, name: "MINUTE", args: args, context: context, evaluator: evaluator)
    }

    /// Implements the SECOND function: SECOND(date) — UTC
    static func second(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        return component(.second, name: "SECOND", args: args, context: context, evaluator: evaluator)
    }

    /// Shared extractor for UTC date components, matching YEAR/MONTH/DAY behavior.
    private static func component(_ component: Calendar.Component, name: String, args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 1 else {
            return .failure(.invalidArguments(function: name, reason: "Expected exactly 1 argument, got \(args.count)"))
        }

        let dateResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let dateValue) = dateResult else { return dateResult }

        if case .null = dateValue {
            return .success(.null)
        }

        guard let date = extractDate(from: dateValue) else {
            return .failure(.typeMismatch(expected: "Date or timestamp", actual: "Argument: \(typeDescription(dateValue))"))
        }

        return .success(.number(Double(utcCalendar.component(component, from: date))))
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

        // Amount out of Int range -> invalid timestamp (0)
        guard let intAmount = amount.safeInt else {
            return .success(.number(0))
        }

        // Add to date using UTC calendar; a failed computation -> 0
        let calendar = utcCalendar
        guard let newDate = calendar.date(byAdding: component, value: intAmount, to: date) else {
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
        
        // Amount out of Int range -> invalid timestamp (0)
        guard let intAmount = amount.safeInt else {
            return .success(.number(0))
        }

        // Subtract from date (add negative amount) using UTC calendar
        let calendar = utcCalendar
        guard let newDate = calendar.date(byAdding: component, value: -intAmount, to: date) else {
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