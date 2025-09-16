import Foundation

/// String function implementations for common string operations
public struct StringFunctions {
    
    /// Implements the CONCAT function: CONCAT(string1, string2, ...) or CONCAT(array1, array2, ...)
    static func concat(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard !args.isEmpty else {
            return .failure(.invalidArguments(function: "CONCAT", reason: "Expected at least 1 argument, got 0"))
        }
        
        // Check if we're dealing with arrays or strings
        var hasArrays = false
        var hasNonArrays = false
        var evaluatedValues: [FormulaValue] = []
        
        // First pass: evaluate all arguments and check types
        for arg in args {
            let result = evaluator.evaluate(node: arg, context: context)
            guard case .success(let value) = result else { return result }
            evaluatedValues.append(value)
            
            if case .array(_) = value {
                hasArrays = true
            } else {
                hasNonArrays = true
            }
        }
        
        // If we have ONLY arrays (no strings/other types), check if we should concatenate as strings
        if hasArrays && !hasNonArrays {
            // Special case: if we have a single array of strings, concatenate them as strings
            if evaluatedValues.count == 1, case .array(let array) = evaluatedValues[0] {
                let allStrings = array.allSatisfy { 
                    if case .string(_) = $0 { return true }
                    return false
                }
                
                if allStrings {
                    // Concatenate array elements as strings without separator
                    var resultString = ""
                    for value in array {
                        if case .string(let str) = value {
                            resultString += str
                        }
                    }
                    return .success(.string(resultString))
                }
            }
            
            // Default array concatenation behavior for other cases
            var resultArray: [FormulaValue] = []
            
            for value in evaluatedValues {
                switch value {
                case .array(let array):
                    resultArray.append(contentsOf: array)
                default:
                    // This shouldn't happen in pure array mode
                    resultArray.append(value)
                }
            }
            
            return .success(.array(resultArray))
        } else {
            // Mixed mode or string mode: create a string result
            var resultString = ""
            
            for value in evaluatedValues {
                switch value {
                case .string(let str):
                    resultString += str
                case .number(let num):
                    // Format numbers without decimal places when they represent integers
                    if num.truncatingRemainder(dividingBy: 1) == 0 {
                        resultString += String(format: "%.0f", num)
                    } else {
                        resultString += String(num)
                    }
                case .boolean(let bool):
                    resultString += String(bool)
                case .null:
                    resultString += "null"
                case .undefined:
                    resultString += "undefined"
                case .date(let date):
                    // Format date as ISO string
                    let formatter = ISO8601DateFormatter()
                    resultString += formatter.string(from: date)
                case .array(let array):
                    // Join array elements with commas
                    let stringElements = array.map { item in
                        switch item {
                        case .string(let str): return str
                        case .number(let num):
                            if num.truncatingRemainder(dividingBy: 1) == 0 {
                                return String(format: "%.0f", num)
                            } else {
                                return String(num)
                            }
                        case .boolean(let bool): return String(bool)
                        case .null: return "null"
                        case .undefined: return "undefined"
                        case .date(let date):
                            let formatter = ISO8601DateFormatter()
                            return formatter.string(from: date)
                        default: return "\(item)"
                        }
                    }
                    resultString += stringElements.joined(separator: ", ")
                case .error(let error):
                    return .failure(error)
                case .dictionary(_):
                    return .failure(.typeMismatch(expected: "String, Number, Boolean, or Array", actual: "Dictionary"))
                case .lambda(_, _):
                    return .failure(.typeMismatch(expected: "String, Number, Boolean, or Array", actual: "Lambda"))
                }
            }
            
            return .success(.string(resultString))
        }
    }
    
    /// Implements the CONTAINS function: CONTAINS(text, substring)
    static func contains(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 2 else {
            return .failure(.invalidArguments(function: "CONTAINS", reason: "Expected exactly 2 arguments, got \(args.count)"))
        }
        
        // Evaluate first argument (text to search in)
        let textResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let textValue) = textResult else { return textResult }
        
        // Ensure it's a string
        guard case .string(let textToSearch) = textValue else {
            return .failure(.typeMismatch(expected: "String", actual: "Argument 1: \(typeDescription(textValue))"))
        }
        
        // Evaluate second argument (substring to find)
        let substringResult = evaluator.evaluate(node: args[1], context: context)
        guard case .success(let substringValue) = substringResult else { return substringResult }
        
        // Ensure it's a string
        guard case .string(let substringToFind) = substringValue else {
            return .failure(.typeMismatch(expected: "String", actual: "Argument 2: \(typeDescription(substringValue))"))
        }
        
        // Perform case-insensitive search
        let found = textToSearch.range(of: substringToFind, options: .caseInsensitive) != nil
        return .success(.boolean(found))
    }
    
    /// Implements the UPPER function: UPPER(text)
    static func upper(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 1 else {
            return .failure(.invalidArguments(function: "UPPER", reason: "Expected exactly 1 argument, got \(args.count)"))
        }
        
        // Evaluate the argument
        let textResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let textValue) = textResult else { return textResult }
        
        // Ensure it's a string
        guard case .string(let text) = textValue else {
            return .failure(.typeMismatch(expected: "String", actual: "Argument: \(typeDescription(textValue))"))
        }
        
        return .success(.string(text.uppercased()))
    }
    
    /// Implements the LOWER function: LOWER(text)
    static func lower(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 1 else {
            return .failure(.invalidArguments(function: "LOWER", reason: "Expected exactly 1 argument, got \(args.count)"))
        }
        
        // Evaluate the argument
        let textResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let textValue) = textResult else { return textResult }
        
        // Ensure it's a string
        guard case .string(let text) = textValue else {
            return .failure(.typeMismatch(expected: "String", actual: "Argument: \(typeDescription(textValue))"))
        }
        
        return .success(.string(text.lowercased()))
    }
    
    /// Implements the LENGTH function: LENGTH(text) or LENGTH(array)
    static func length(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 1 else {
            return .failure(.invalidArguments(function: "LENGTH", reason: "Expected exactly 1 argument, got \(args.count)"))
        }
        
        // Evaluate the argument
        let valueResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let value) = valueResult else { return valueResult }
        
        // Check type and calculate length
        switch value {
        case .string(let text):
            return .success(.number(Double(text.count)))
        case .array(let array):
            return .success(.number(Double(array.count)))
        default:
            return .failure(.typeMismatch(expected: "String or Array", actual: "Argument: \(typeDescription(value))"))
        }
    }
    
    /// Implements the TONUMBER function: TONUMBER(value)
    static func toNumber(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 1 else {
            return .failure(.invalidArguments(function: "TONUMBER", reason: "Expected exactly 1 argument, got \(args.count)"))
        }
        
        // Evaluate the argument
        let valueResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let value) = valueResult else { return valueResult }
        
        // Try to convert to number
        switch value {
        case .number(let num):
            return .success(.number(num)) // Already a number
        case .string(let str):
            // Trim whitespace before parsing
            let trimmedStr = str.trimmingCharacters(in: .whitespacesAndNewlines)
            if let num = Double(trimmedStr) {
                return .success(.number(num))
            } else {
                return .failure(.typeMismatch(expected: "String representing a number", actual: "String not convertible to number: '\(trimmedStr)'"))
            }
        case .boolean(let bool):
            return .success(.number(bool ? 1.0 : 0.0))
        default:
            return .failure(.typeMismatch(expected: "Value convertible to number", actual: "Argument: \(typeDescription(value))"))
        }
    }
    
    /// Implements the JOIN function: JOIN(array, separator)
    static func join(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 2 else {
            return .failure(.invalidArguments(function: "JOIN", reason: "Expected exactly 2 arguments, got \(args.count)"))
        }
        
        // Evaluate first argument (array)
        let arrayResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let arrayValue) = arrayResult else { return arrayResult }
        
        // Ensure it's an array
        guard case .array(let array) = arrayValue else {
            return .failure(.typeMismatch(expected: "Array", actual: "Argument 1: \(typeDescription(arrayValue))"))
        }
        
        // Evaluate second argument (separator)
        let separatorResult = evaluator.evaluate(node: args[1], context: context)
        guard case .success(let separatorValue) = separatorResult else { return separatorResult }
        
        // Ensure it's a string
        guard case .string(let separator) = separatorValue else {
            return .failure(.typeMismatch(expected: "String", actual: "Argument 2: \(typeDescription(separatorValue))"))
        }
        
        // Convert array elements to strings and join
        let stringElements = array.map { item in
            switch item {
            case .string(let str): return str
            case .number(let num):
                if num.truncatingRemainder(dividingBy: 1) == 0 {
                    return String(format: "%.0f", num)
                } else {
                    return String(num)
                }
            case .boolean(let bool): return String(bool)
            case .null: return "null"
            case .undefined: return "undefined"
            default: return "\(item)"
            }
        }
        
        return .success(.string(stringElements.joined(separator: separator)))
    }
    
    /// Implements the TOSTRING function: TOSTRING(value)
    static func toString(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 1 else {
            return .failure(.invalidArguments(function: "TOSTRING", reason: "Expected exactly 1 argument, got \(args.count)"))
        }
        
        // Evaluate the argument
        let valueResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let value) = valueResult else { return valueResult }
        
        // Convert to string based on type
        switch value {
        case .string(let str):
            return .success(.string(str)) // Already a string
        case .number(let num):
            // Format numbers appropriately
            if num.truncatingRemainder(dividingBy: 1) == 0 {
                return .success(.string(String(format: "%.0f", num)))
            } else {
                return .success(.string(String(num)))
            }
        case .boolean(let bool):
            return .success(.string(bool ? "true" : "false"))
        case .date(let date):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return .success(.string(formatter.string(from: date)))
        case .array(let array):
            // Convert array to string representation
            let stringElements = array.map { item in
                switch item {
                case .string(let str): return str
                case .number(let num):
                    if num.truncatingRemainder(dividingBy: 1) == 0 {
                        return String(format: "%.0f", num)
                    } else {
                        return String(num)
                    }
                case .boolean(let bool): return bool ? "true" : "false"
                case .null: return "null"
                case .undefined: return "undefined"
                default: return "\(item)"
                }
            }
            return .success(.string("[\(stringElements.joined(separator: ", "))]"))
        case .dictionary(let dict):
            // Convert dictionary to string representation
            let pairs = dict.map { key, value in
                let valueStr: String
                switch value {
                case .string(let str): valueStr = str
                case .number(let num):
                    if num.truncatingRemainder(dividingBy: 1) == 0 {
                        valueStr = String(format: "%.0f", num)
                    } else {
                        valueStr = String(num)
                    }
                case .boolean(let bool): valueStr = bool ? "true" : "false"
                case .null: valueStr = "null"
                case .undefined: valueStr = "undefined"
                default: valueStr = "\(value)"
                }
                return "\(key): \(valueStr)"
            }
            return .success(.string("{\(pairs.joined(separator: ", "))}"))
        case .null:
            return .success(.string("null"))
        case .undefined:
            return .success(.string("undefined"))
        case .error(let error):
            return .success(.string("Error: \(error)"))
        case .lambda:
            return .success(.string("Lambda function"))
        }
    }
    
    /// Implements the EQUALS function: EQUALS(value1, value2)
    static func equals(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 2 else {
            return .failure(.invalidArguments(function: "EQUALS", reason: "Expected exactly 2 arguments, got \(args.count)"))
        }
        
        // Evaluate first argument
        let leftResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let leftValue) = leftResult else { return leftResult }
        
        // Evaluate second argument
        let rightResult = evaluator.evaluate(node: args[1], context: context)
        guard case .success(let rightValue) = rightResult else { return rightResult }
        
        // Compare values based on their types
        switch (leftValue, rightValue) {
        case (.string(let left), .string(let right)):
            return .success(.boolean(left == right))
        case (.number(let left), .number(let right)):
            return .success(.boolean(left == right))
        case (.boolean(let left), .boolean(let right)):
            return .success(.boolean(left == right))
        case (.string(let str), .number(let num)):
            return .success(.boolean(str == String(num)))
        case (.number(let num), .string(let str)):
            return .success(.boolean(String(num) == str))
        case (.string(let str), .boolean(let bool)):
            return .success(.boolean(str == String(bool)))
        case (.boolean(let bool), .string(let str)):
            return .success(.boolean(String(bool) == str))
        case (.null, .null):
            return .success(.boolean(true))
        case (.null, _), (_, .null):
            return .success(.boolean(false))
        default:
            return .success(.boolean(false))
        }
    }
    
    /// Implements the TRIM function: TRIM(text)
    static func trim(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 1 else {
            return .failure(.invalidArguments(function: "TRIM", reason: "Expected exactly 1 argument, got \(args.count)"))
        }
        
        // Evaluate the argument
        let textResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let textValue) = textResult else { return textResult }
        
        // Ensure it's a string
        guard case .string(let text) = textValue else {
            return .failure(.typeMismatch(expected: "String", actual: "Argument: \(typeDescription(textValue))"))
        }
        
        // Trim whitespace and newlines from both ends
        return .success(.string(text.trimmingCharacters(in: .whitespacesAndNewlines)))
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
        case .lambda: return "Lambda"
        }
    }
} 