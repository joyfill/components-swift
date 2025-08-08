import Foundation

/// Implementation of mathematical functions
public struct MathFunctions {
    
    /// Implements the SUM function: SUM(number1, number2, ...) or SUM(arrayOfNumbers)
    /// Adds up all numeric values provided as arguments, including flattening arrays of numbers
    static func sum(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard !args.isEmpty else {
            return .success(.number(0.0)) // Sum of empty set is 0
        }
        
        var sum: Double = 0.0
        
        for (index, arg) in args.enumerated() {
            let result = evaluator.evaluate(node: arg, context: context)
            guard case .success(let value) = result else { return result }
            
            switch value {
            case .number(let num):
                sum += num
            case .array(let arr):
                for (arrIndex, element) in arr.enumerated() {
                    switch element {
                    case .number(let num):
                        sum += num
                    case .string(let str):
                        if let num = Double(str) {
                            sum += num
                        }
                    case .null:
                        // Skip null values
                        continue
                    default:
                        return .failure(.typeMismatch(
                            expected: "Number",
                            actual: "Element at index \(arrIndex) in array argument \(index+1): \(typeDescription(element))"
                        ))
                    }
                }
            case .null:
                // Skip null values
                continue
            default:
                return .failure(.typeMismatch(
                    expected: "Number or Array of Numbers",
                    actual: "Argument \(index+1): \(typeDescription(value))"
                ))
            }
        }
        
        return .success(.number(sum))
    }
    
    /// Implements the POW function: POW(base, exponent)
    static func pow(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 2 else {
            return .failure(.invalidArguments(function: "POW", reason: "Expected exactly 2 arguments (base, exponent), got \(args.count)"))
        }
        
        // Evaluate base
        let baseResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let baseValue) = baseResult else { return baseResult }
        guard case .number(let base) = baseValue else {
            return .failure(.typeMismatch(expected: "Number for base", actual: "Argument 1: \(typeDescription(baseValue))"))
        }
        
        // Evaluate exponent
        let exponentResult = evaluator.evaluate(node: args[1], context: context)
        guard case .success(let exponentValue) = exponentResult else { return exponentResult }
        guard case .number(let exponent) = exponentValue else {
            return .failure(.typeMismatch(expected: "Number for exponent", actual: "Argument 2: \(typeDescription(exponentValue))"))
        }
        
        return .success(.number(Foundation.pow(base, exponent)))
    }
    
    /// Implements the ROUND function: ROUND(number, [digits])
    static func round(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count >= 1 && args.count <= 2 else {
            return .failure(.invalidArguments(function: "ROUND", reason: "Expected 1 or 2 arguments, got \(args.count)"))
        }
        
        // Evaluate number
        let numberResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let numberValue) = numberResult else { return numberResult }
        guard case .number(let number) = numberValue else {
            return .failure(.typeMismatch(expected: "Number", actual: "Argument 1: \(typeDescription(numberValue))"))
        }
        
        // Default digits to 0 (round to nearest integer)
        var digits = 0
        
        // If digits argument is provided, evaluate it
        if args.count == 2 {
            let digitsResult = evaluator.evaluate(node: args[1], context: context)
            guard case .success(let digitsValue) = digitsResult else { return digitsResult }
            guard case .number(let digitsDouble) = digitsValue else {
                return .failure(.typeMismatch(expected: "Number for digits", actual: "Argument 2: \(typeDescription(digitsValue))"))
            }
            
            digits = Int(digitsDouble)
        }
        
        // Perform rounding based on digits
        if digits <= 0 {
            // Round to integer
            return .success(.number(Foundation.round(number)))
        } else {
            // Round to specified decimal places
            let multiplier = Foundation.pow(10.0, Double(digits))
            return .success(.number(Foundation.round(number * multiplier) / multiplier))
        }
    }
    
    /// Implements the CEIL function: CEIL(number)
    static func ceil(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 1 else {
            return .failure(.invalidArguments(function: "CEIL", reason: "Expected exactly 1 argument, got \(args.count)"))
        }
        
        // Evaluate number
        let numberResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let numberValue) = numberResult else { return numberResult }
        guard case .number(let number) = numberValue else {
            return .failure(.typeMismatch(expected: "Number", actual: "Argument: \(typeDescription(numberValue))"))
        }
        
        return .success(.number(Foundation.ceil(number)))
    }
    
    /// Implements the FLOOR function: FLOOR(number)
    static func floor(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 1 else {
            return .failure(.invalidArguments(function: "FLOOR", reason: "Expected exactly 1 argument, got \(args.count)"))
        }
        
        // Evaluate number
        let numberResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let numberValue) = numberResult else { return numberResult }
        guard case .number(let number) = numberValue else {
            return .failure(.typeMismatch(expected: "Number", actual: "Argument: \(typeDescription(numberValue))"))
        }
        
        return .success(.number(Foundation.floor(number)))
    }
    
    /// Implements the MOD function: MOD(dividend, divisor)
    static func mod(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 2 else {
            return .failure(.invalidArguments(function: "MOD", reason: "Expected exactly 2 arguments (dividend, divisor), got \(args.count)"))
        }
        
        // Evaluate dividend
        let dividendResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let dividendValue) = dividendResult else { return dividendResult }
        guard case .number(let dividend) = dividendValue else {
            return .failure(.typeMismatch(expected: "Number for dividend", actual: "Argument 1: \(typeDescription(dividendValue))"))
        }
        
        // Evaluate divisor
        let divisorResult = evaluator.evaluate(node: args[1], context: context)
        guard case .success(let divisorValue) = divisorResult else { return divisorResult }
        guard case .number(let divisor) = divisorValue else {
            return .failure(.typeMismatch(expected: "Number for divisor", actual: "Argument 2: \(typeDescription(divisorValue))"))
        }
        
        // Check for division by zero
        if divisor == 0 {
            return .failure(.divisionByZero)
        }
        
        return .success(.number(dividend.truncatingRemainder(dividingBy: divisor)))
    }
    
    /// Implements the MAX function: MAX(number1, number2, ...) or MAX(arrayOfNumbers)
    static func max(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard !args.isEmpty else {
            return .failure(.invalidArguments(function: "MAX", reason: "Expected at least 1 argument, got 0"))
        }
        
        var values: [Double] = []
        
        for (index, arg) in args.enumerated() {
            let result = evaluator.evaluate(node: arg, context: context)
            guard case .success(let value) = result else { return result }
            
            switch value {
            case .number(let num):
                values.append(num)
            case .array(let arr):
                for (arrIndex, element) in arr.enumerated() {
                    switch element {
                    case .number(let num):
                        values.append(num)
                    case .null:
                        // Skip null values
                        continue
                    default:
                        return .failure(.typeMismatch(
                            expected: "Number",
                            actual: "Element at index \(arrIndex) in array argument \(index+1): \(typeDescription(element))"
                        ))
                    }
                }
            case .null:
                // Skip null values
                continue
            default:
                return .failure(.typeMismatch(
                    expected: "Number or Array of Numbers",
                    actual: "Argument \(index+1): \(typeDescription(value))"
                ))
            }
        }
        
        guard !values.isEmpty else {
            return .failure(.invalidArguments(function: "MAX", reason: "No numeric values found in arguments"))
        }
        
        return .success(.number(values.max()!))
    }
    
    /// Implements the SQRT function: SQRT(number)
    static func sqrt(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 1 else {
            return .failure(.invalidArguments(function: "SQRT", reason: "Expected exactly 1 argument, got \(args.count)"))
        }
        
        // Evaluate number
        let numberResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let numberValue) = numberResult else { return numberResult }
        guard case .number(let number) = numberValue else {
            return .failure(.typeMismatch(expected: "Number", actual: "Argument: \(typeDescription(numberValue))"))
        }
        
        // Check for negative number
        if number < 0 {
            return .failure(.invalidArguments(function: "SQRT", reason: "Cannot take square root of a negative number: \(number)"))
        }
        
        return .success(.number(Foundation.sqrt(number)))
    }
    
    /// Implements the MIN function: MIN(number1, number2, ...) or MIN(arrayOfNumbers)
    static func min(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard !args.isEmpty else {
            return .failure(.invalidArguments(function: "MIN", reason: "Expected at least 1 argument, got 0"))
        }
        
        var values: [Double] = []
        
        for (index, arg) in args.enumerated() {
            let result = evaluator.evaluate(node: arg, context: context)
            guard case .success(let value) = result else { return result }
            
            switch value {
            case .number(let num):
                values.append(num)
            case .array(let arr):
                for (arrIndex, element) in arr.enumerated() {
                    switch element {
                    case .number(let num):
                        values.append(num)
                    case .null:
                        // Skip null values
                        continue
                    default:
                        return .failure(.typeMismatch(
                            expected: "Number",
                            actual: "Element at index \(arrIndex) in array argument \(index+1): \(typeDescription(element))"
                        ))
                    }
                }
            case .null:
                // Skip null values
                continue
            default:
                return .failure(.typeMismatch(
                    expected: "Number or Array of Numbers",
                    actual: "Argument \(index+1): \(typeDescription(value))"
                ))
            }
        }
        
        guard !values.isEmpty else {
            return .failure(.invalidArguments(function: "MIN", reason: "No numeric values found in arguments"))
        }
        
        return .success(.number(values.min()!))
    }
    
    /// Implements the COUNT function: COUNT(value1, value2, ...) or COUNT(array)
    static func count(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard !args.isEmpty else {
            return .failure(.invalidArguments(function: "COUNT", reason: "Expected at least 1 argument, got 0"))
        }
        
        var count = 0
        
        for arg in args {
            let result = evaluator.evaluate(node: arg, context: context)
            guard case .success(let value) = result else { return result }
            
            switch value {
            case .array(let arr):
                count += arr.count
            case .null:
                // Skip null values
                continue
            default:
                count += 1
            }
        }
        
        return .success(.number(Double(count)))
    }
    
    /// Implements the AVG function: AVG(number1, number2, ...) or AVG(arrayOfNumbers)
    static func avg(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard !args.isEmpty else {
            return .failure(.invalidArguments(function: "AVG", reason: "Expected at least 1 argument, got 0"))
        }
        
        var values: [Double] = []
        
        for (index, arg) in args.enumerated() {
            let result = evaluator.evaluate(node: arg, context: context)
            guard case .success(let value) = result else { return result }
            
            switch value {
            case .number(let num):
                values.append(num)
            case .array(let arr):
                for (arrIndex, element) in arr.enumerated() {
                    switch element {
                    case .number(let num):
                        values.append(num)
                    case .null:
                        // Skip null values
                        continue
                    default:
                        return .failure(.typeMismatch(
                            expected: "Number",
                            actual: "Element at index \(arrIndex) in array argument \(index+1): \(typeDescription(element))"
                        ))
                    }
                }
            case .null:
                // Skip null values
                continue
            default:
                return .failure(.typeMismatch(
                    expected: "Number or Array of Numbers",
                    actual: "Argument \(index+1): \(typeDescription(value))"
                ))
            }
        }
        
        guard !values.isEmpty else {
            return .failure(.invalidArguments(function: "AVG", reason: "No numeric values found in arguments"))
        }
        
        let sum = values.reduce(0, +)
        return .success(.number(sum / Double(values.count)))
    }
    
    // Helper to get a user-friendly type name
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
        case .error(let error): return "Error: \(error)"
        case .lambda(_, _): return "Lambda function"
        }
    }
} 
