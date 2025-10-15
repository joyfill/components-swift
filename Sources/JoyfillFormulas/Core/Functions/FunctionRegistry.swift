import Foundation

/// Closure signature used by the formula engine to evaluate registered functions.
public typealias FormulaFunction = (_ args: [ASTNode], _ context: EvaluationContext, _ evaluator: Evaluator) -> Result<FormulaValue, FormulaError>

/// Abstraction that supplies values to the formula evaluator.
public protocol EvaluationContext {
    /// Resolves a reference such as `fieldId` or `table.column` to a runtime value.
    func resolveReference(_ name: String) -> Result<FormulaValue, FormulaError>
    /// Creates a child context that temporarily overrides or supplies additional variables.
    func contextByAdding(variable name: String, value: FormulaValue) -> EvaluationContext
}

/// Minimal `EvaluationContext` that performs lookups against an in-memory dictionary.
public struct DictionaryContext: EvaluationContext {
    private var values: [String: FormulaValue]
    
    /// Creates a context using the supplied dictionary.
    /// - Parameter values: Initial field/value pairs available to the evaluator.
    public init(_ values: [String: FormulaValue] = [:]) {
        self.values = values
    }
    
    /// Looks up the provided reference and returns either the stored value or an `.invalidReference` error.
    public func resolveReference(_ name: String) -> Result<FormulaValue, FormulaError> {
        // Direct lookup - no brace stripping needed since we now parse field references directly
        if let value = values[name] {
            return .success(value)
        } else {
            return .failure(.invalidReference("Field '\(name)' not found in context."))
        }
    }
    
    /// Returns a new context containing the original values plus an override for `name`.
    public func contextByAdding(variable name: String, value: FormulaValue) -> EvaluationContext {
        var newValues = self.values
        // Store field names directly - no brace handling needed
        newValues[name] = value
        return DictionaryContext(newValues)
    }
}

/// Registry that stores built-in and user-defined formula functions.
public class FunctionRegistry {
    private var functions: [String: FormulaFunction] = [:]

    /// Creates a registry pre-populated with Joyfill's built-in functions.
    public init() {
        registerDefaultFunctions()
    }

    /// Registers a function with the given name (case-insensitive).
    /// - Parameters:
    ///   - name: Function identifier (e.g. `"SUM"`).
    ///   - function: Closure that will be invoked by the evaluator.
    public func register(name: String, function: @escaping FormulaFunction) {
        functions[name.uppercased()] = function // Store uppercase for case-insensitivity
    }

    /// Retrieves a function by name (case-insensitive).
    /// - Parameter name: Function identifier to look up.
    /// - Returns: The registered function, or `nil` when no match exists.
    public func lookup(name: String) -> FormulaFunction? {
        return functions[name.uppercased()]
    }

    private func registerDefaultFunctions() {
        // --- Register Default Functions Here ---
        
        // Logical Functions
        register(name: "IF", function: LogicalFunctions.if)
        register(name: "AND", function: LogicalFunctions.and)
        register(name: "OR", function: LogicalFunctions.or)
        register(name: "NOT", function: LogicalFunctions.not)
        register(name: "EMPTY", function: LogicalFunctions.empty)
        
        // String Functions
        register(name: "CONCAT", function: StringFunctions.concat)
        register(name: "CONTAINS", function: StringFunctions.contains)
        register(name: "UPPER", function: StringFunctions.upper)
        register(name: "LOWER", function: StringFunctions.lower)
        register(name: "LENGTH", function: StringFunctions.length)
        register(name: "TONUMBER", function: StringFunctions.toNumber)
        register(name: "TOSTRING", function: StringFunctions.toString)
        register(name: "JOIN", function: StringFunctions.join)
        register(name: "EQUALS", function: StringFunctions.equals)
        register(name: "TRIM", function: StringFunctions.trim)
        
        // Math Functions
        register(name: "SUM", function: MathFunctions.sum)
        register(name: "POW", function: MathFunctions.pow)
        register(name: "ROUND", function: MathFunctions.round)
        register(name: "CEIL", function: MathFunctions.ceil)
        register(name: "FLOOR", function: MathFunctions.floor)
        register(name: "MOD", function: MathFunctions.mod)
        register(name: "MAX", function: MathFunctions.max)
        register(name: "MIN", function: MathFunctions.min)
        register(name: "COUNT", function: MathFunctions.count)
        register(name: "AVG", function: MathFunctions.avg)
        register(name: "AVERAGE", function: MathFunctions.avg) // Alias for AVG
        register(name: "SQRT", function: MathFunctions.sqrt)
        
        // Date Functions
        register(name: "NOW", function: DateFunctions.now)
        register(name: "YEAR", function: DateFunctions.year)
        register(name: "MONTH", function: DateFunctions.month)
        register(name: "DAY", function: DateFunctions.day)
        register(name: "DATE", function: DateFunctions.date)
        register(name: "DATEADD", function: DateFunctions.dateAdd)
        register(name: "DATESUBTRACT", function: DateFunctions.dateSubtract)
        register(name: "TIMESTAMP", function: DateFunctions.timestamp)
        
        // Array Functions
        register(name: "FLAT", function: ArrayFunctions.flat)
        register(name: "MAP", function: ArrayFunctions.map)
        register(name: "FLATMAP", function: ArrayFunctions.flatMap)
        register(name: "FILTER", function: ArrayFunctions.filter)
        register(name: "REDUCE", function: ArrayFunctions.reduce)
        register(name: "FIND", function: ArrayFunctions.find)
        register(name: "EVERY", function: ArrayFunctions.every)
        register(name: "SOME", function: ArrayFunctions.some)
        register(name: "COUNTIF", function: ArrayFunctions.countIf)
        register(name: "UNIQUE", function: ArrayFunctions.unique)
        
        // Higher Order Functions
        register(name: "SORT", function: HigherOrderFunctions.sort)
        
        // TODO: Register other functions...
        
        // ... other functions from PRD (ROUND, DATEADD etc.)
    }
}

// Example placeholder for where function implementations might live
// struct SumFunction {
//     static func evaluate(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
//         // 1. Evaluate each argument ASTNode to get FormulaValue
//         // 2. Check types (expect numbers)
//         // 3. Perform summation
//         // 4. Return .success(.number(result)) or .failure(error)
//         return .failure(.unknownError("SUM not implemented"))
//     }
// } 
