import Foundation

/// Logical function implementations for standard boolean operations
public struct LogicalFunctions {
    
    /// Implements the IF function: IF(condition, trueResult, falseResult)
    static func `if`(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 3 else {
            return .failure(.invalidArguments(function: "IF", reason: "Expected 3 arguments (condition, trueResult, falseResult), got \(args.count)"))
        }
        
        // Evaluate the condition first
        let conditionResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let conditionValue) = conditionResult else { return conditionResult }
        guard case .boolean(let condition) = conditionValue else {
            return .failure(.typeMismatch(expected: "Boolean", actual: String(describing: conditionValue)))
        }
        
        // Evaluate only the branch we need based on the condition
        if condition {
            return evaluator.evaluate(node: args[1], context: context)
        } else {
            return evaluator.evaluate(node: args[2], context: context)
        }
    }
    
    /// Implements the AND function: AND(boolean1, boolean2, ...)
    static func and(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard !args.isEmpty else {
            return .failure(.invalidArguments(function: "AND", reason: "Expected at least 1 argument, got 0"))
        }
        
        // AND returns true if all conditions are true
        for (index, arg) in args.enumerated() {
            let result = evaluator.evaluate(node: arg, context: context)
            guard case .success(let value) = result else { return result }
            
            guard case .boolean(let boolValue) = value else {
                return .failure(.typeMismatch(expected: "Boolean", actual: "Argument \(index+1): \(String(describing: value))"))
            }
            
            // Short-circuit evaluation: if any argument is false, the result is false
            if !boolValue {
                return .success(.boolean(false))
            }
        }
        
        // All conditions were true
        return .success(.boolean(true))
    }
    
    /// Implements the OR function: OR(boolean1, boolean2, ...)
    static func or(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard !args.isEmpty else {
            return .failure(.invalidArguments(function: "OR", reason: "Expected at least 1 argument, got 0"))
        }
        
        // OR returns true if any condition is true
        for (index, arg) in args.enumerated() {
            let result = evaluator.evaluate(node: arg, context: context)
            guard case .success(let value) = result else { return result }
            
            guard case .boolean(let boolValue) = value else {
                return .failure(.typeMismatch(expected: "Boolean", actual: "Argument \(index+1): \(String(describing: value))"))
            }
            
            // Short-circuit evaluation: if any argument is true, the result is true
            if boolValue {
                return .success(.boolean(true))
            }
        }
        
        // No conditions were true
        return .success(.boolean(false))
    }
    
    /// Implements the NOT function: NOT(boolean)
    static func not(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 1 else {
            return .failure(.invalidArguments(function: "NOT", reason: "Expected exactly 1 argument, got \(args.count)"))
        }
        
        let result = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let value) = result else { return result }
        
        guard case .boolean(let boolValue) = value else {
            return .failure(.typeMismatch(expected: "Boolean", actual: String(describing: value)))
        }
        
        // Return the negation of the input boolean
        return .success(.boolean(!boolValue))
    }
    
    /// Implements the EMPTY function: EMPTY(value)
    static func empty(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 1 else {
            return .failure(.invalidArguments(function: "EMPTY", reason: "Expected exactly 1 argument, got \(args.count)"))
        }
        
        let result = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let value) = result else { return result }
        
        // Check if the value is considered empty
        let isEmpty: Bool
        switch value {
        case .string(let str):
            isEmpty = str.isEmpty
        case .number(let num):
            isEmpty = num == 0
        case .boolean(let bool):
            isEmpty = !bool
        case .array(let arr):
            isEmpty = arr.isEmpty
        case .dictionary(let dict):
            isEmpty = dict.isEmpty
        case .null:
            isEmpty = true
        case .date:
            isEmpty = false // Dates are not considered empty
        case .error:
            isEmpty = true // Errors are considered empty
        case .undefined:
            isEmpty = true // undefined is considered empty
        case .lambda(_, _):
            isEmpty = false // Lambda functions are not considered empty
        }
        
        return .success(.boolean(isEmpty))
    }
} 
