import Foundation

/// Evaluates an Abstract Syntax Tree (AST) to produce a FormulaValue.
public class Evaluator {

    private let functionRegistry: FunctionRegistry

    public init(functionRegistry: FunctionRegistry = FunctionRegistry()) {
        self.functionRegistry = functionRegistry
    }

    /// Evaluates the given AST node.
    public func evaluate(node: ASTNode, context: EvaluationContext) -> Result<FormulaValue, FormulaError> {
        print("Evaluator.evaluate called with node: \(node)") // Debug print

        switch node {
        case .literal(let value):
            return .success(value)

        case .reference(let name):
            print("Resolving reference: \(name)")
            return context.resolveReference(name)

        case .functionCall(let name, let arguments):
            print("Executing function: \(name) with args: \(arguments)")
            guard let function = functionRegistry.lookup(name: name) else {
                return .failure(.invalidReference("Function '\(name)' not found."))
            }
            return function(arguments, context, self)

        case .infixOperation(let op, let leftNode, let rightNode):
            print("Performing infix operation: \(op) on \(leftNode) and \(rightNode)")
            let leftResult = evaluate(node: leftNode, context: context)
            guard case .success(let leftValue) = leftResult else { return leftResult }

            let rightResult = evaluate(node: rightNode, context: context)
            guard case .success(let rightValue) = rightResult else { return rightResult }

            return performInfixOperation(op, leftValue, rightValue)

        case .prefixOperation(let op, let operandNode):
            print("Performing prefix operation: \(op) on \(operandNode)")
            let operandResult = evaluate(node: operandNode, context: context)
            guard case .success(let operandValue) = operandResult else {
                return operandResult // Propagate error from operand evaluation
            }
            
            switch op {
            case "-": // Unary Minus (Negation)
                guard case .number(let num) = operandValue else {
                    return .failure(.typeMismatch(expected: "Number for unary '-'", actual: typeDescription(operandValue)))
                }
                return .success(.number(-num))
                
            case "!": // Logical NOT
                guard case .boolean(let bool) = operandValue else {
                     return .failure(.typeMismatch(expected: "Boolean for unary '!'", actual: typeDescription(operandValue)))
                }
                return .success(.boolean(!bool))
                
            default:
                return .failure(.unknownError("Unsupported prefix operator: \(op)"))
            }

        case .arrayLiteral(let elementNodes):
            print("Evaluating array literal with elements: \(elementNodes)")
            var evaluatedElements: [FormulaValue] = []
            evaluatedElements.reserveCapacity(elementNodes.count)

            for elementNode in elementNodes {
                let elementResult = evaluate(node: elementNode, context: context)
                switch elementResult {
                case .success(let value):
                    evaluatedElements.append(value)
                case .failure(let error):
                    return .failure(.unknownError("Error evaluating element in array literal: \(error)"))
                }
            }
            return .success(.array(evaluatedElements))
            
        case .objectLiteral(let keyValuePairs):
            print("Evaluating object literal with \(keyValuePairs.count) key-value pairs")
            var evaluatedDict: [String: FormulaValue] = [:]
            evaluatedDict.reserveCapacity(keyValuePairs.count)
            
            for (key, valueNode) in keyValuePairs {
                let valueResult = evaluate(node: valueNode, context: context)
                switch valueResult {
                case .success(let value):
                    evaluatedDict[key] = value
                case .failure(let error):
                    return .failure(.unknownError("Error evaluating value for key '\(key)' in object literal: \(error)"))
                }
            }
            return .success(.dictionary(evaluatedDict))
            
        case .lambda(let parameters, let body):
            // Lambda expressions are stored as-is and evaluated when called by higher-order functions
            return .success(.lambda(parameters: parameters, body: body))
            
        case .arrayAccess(let arrayNode, let indexNode):
            print("Evaluating array access")
            // Evaluate the array expression
            let arrayResult = evaluate(node: arrayNode, context: context)
            guard case .success(let arrayValue) = arrayResult else {
                return arrayResult
            }
            
            // Evaluate the index expression
            let indexResult = evaluate(node: indexNode, context: context)
            guard case .success(let indexValue) = indexResult else {
                return indexResult
            }
            
            // Perform array indexing
            guard case .number(let indexNumber) = indexValue,
                  indexNumber.truncatingRemainder(dividingBy: 1) == 0 else {
                return .failure(.typeMismatch(expected: "Integer for array index", actual: typeDescription(indexValue)))
            }
            
            let index = Int(indexNumber)
            
            switch arrayValue {
            case .array(let array):
                guard index >= 0 && index < array.count else {
                    return .failure(.invalidArguments(function: "arrayAccess", reason: "Array index out of bounds: \(index)"))
                }
                return .success(array[index])
            default:
                return .failure(.typeMismatch(expected: "Array for array access", actual: typeDescription(arrayValue)))
            }
            
        case .propertyAccess(let objectNode, let propertyName):
            // If the object is a reference node, combine it with the property name
            if case .reference(let objectName) = objectNode {
                // Create a combined reference string (e.g., "products.price")
                let combinedReference = "\(objectName).\(propertyName)"
                return context.resolveReference(combinedReference)
            }
            
            // For non-reference objects (like dictionary literals or function results),
            // evaluate them and then access the property
            let objectResult = evaluate(node: objectNode, context: context)
            guard case .success(let objectValue) = objectResult else {
                return objectResult
            }
            
            // Perform property access
            switch objectValue {
            case .dictionary(let dict):
                // Single dictionary - extract the property
                if let value = dict[propertyName] {
                    return .success(value)
                } else {
                    return .failure(.invalidReference("Property '\(propertyName)' not found"))
                }
            case .array(let array):
                // Check if the property name is a numeric index (e.g., "0", "1", "2")
                if let index = Int(propertyName) {
                    // Array index access
                    guard index >= 0 && index < array.count else {
                        return .failure(.invalidReference("Array index out of bounds: \(index)"))
                    }
                    return .success(array[index])
                } else {
                    // Array of dictionaries (table rows) - extract property from each row
                    var extractedValues: [FormulaValue] = []
                    extractedValues.reserveCapacity(array.count)
                    
                    for item in array {
                        switch item {
                        case .dictionary(let dict):
                            if let value = dict[propertyName] {
                                extractedValues.append(value)
                            } else {
                                // If property doesn't exist in this row, include null
                                extractedValues.append(.null)
                            }
                        default:
                            // If item is not a dictionary, we can't extract properties from it
                            return .failure(.typeMismatch(expected: "Array of dictionaries for property access on array", actual: "Array containing \(typeDescription(item))"))
                        }
                    }
                    return .success(.array(extractedValues))
                }
            default:
                return .failure(.typeMismatch(expected: "Dictionary or Array for property access", actual: typeDescription(objectValue)))
            }
        }
    }

    // --- Private Helper Methods ---

    private func performInfixOperation(_ op: String, _ left: FormulaValue, _ right: FormulaValue) -> Result<FormulaValue, FormulaError> {
        switch op {
        case "+":
            switch (left, right) {
            case (.number(let l), .number(let r)): return .success(.number(l + r))
            case (.string(let l), .string(let r)): return .success(.string(l + r))
            case (.string(let l), let r): return .success(.string(l + stringify(r)))
            case (let l, .string(let r)): return .success(.string(stringify(l) + r))
            case (.date(let date), .number(let milliseconds)):
                // Add milliseconds to date
                let newDate = Date(timeIntervalSince1970: date.timeIntervalSince1970 + (milliseconds / 1000.0))
                return .success(.date(newDate))
            case (.number(let milliseconds), .date(let date)):
                // Add milliseconds to date (commutative)
                let newDate = Date(timeIntervalSince1970: date.timeIntervalSince1970 + (milliseconds / 1000.0))
                return .success(.date(newDate))
            default: return .failure(.typeMismatch(expected: "Numbers, Strings, or Date+Number for '+'", actual: "\(typeDescription(left)) and \(typeDescription(right))"))
            }

        case "-":
            switch (left, right) {
            case (.number(let l), .number(let r)):
                return .success(.number(l - r))
            case (.date(let l), .date(let r)):
                // Date subtraction returns difference in milliseconds
                let diffInSeconds = l.timeIntervalSince(r)
                let diffInMilliseconds = diffInSeconds * 1000.0
                return .success(.number(diffInMilliseconds))
            default:
                return .failure(.typeMismatch(expected: "Numbers or Dates for '-'", actual: "\(typeDescription(left)) and \(typeDescription(right))"))
            }

        case "*":
            guard case .number(let l) = left, case .number(let r) = right else {
                return .failure(.typeMismatch(expected: "Numbers for '*'", actual: "\(typeDescription(left)) and \(typeDescription(right))"))
            }
            return .success(.number(l * r))

        case "/":
            guard case .number(let l) = left, case .number(let r) = right else {
                return .failure(.typeMismatch(expected: "Numbers for '/'", actual: "\(typeDescription(left)) and \(typeDescription(right))"))
            }
            guard r != 0 else { return .failure(.divisionByZero) }
            return .success(.number(l / r))

        // --- Comparison Operators ---
        case "==": 
            switch (left, right) {
            case (.array, .array): return .success(.boolean(false)) // Arrays are not equal by reference
            case (.dictionary, .dictionary): return .success(.boolean(false)) // Objects are not equal by reference
            case (.null, .null): return .success(.boolean(true)) // null == null is true
            case (.undefined, .undefined): return .success(.boolean(true)) // undefined == undefined is true
            case (.null, .undefined): return .success(.boolean(false)) // null == undefined is false
            case (.undefined, .null): return .success(.boolean(false)) // undefined == null is false
            default: return .success(.boolean(left == right)) // Use default equality for other types
            }
        case "!=": 
            // != should be the logical negation of ==
            switch (left, right) {
            case (.array, .array): return .success(.boolean(true)) // Arrays are not equal by reference, so != is true
            case (.dictionary, .dictionary): return .success(.boolean(true)) // Objects are not equal by reference, so != is true
            case (.null, .null): return .success(.boolean(false)) // null == null is true, so null != null is false
            case (.undefined, .undefined): return .success(.boolean(false)) // undefined == undefined is true, so undefined != undefined is false
            case (.null, .undefined): return .success(.boolean(true)) // null == undefined is false, so null != undefined is true
            case (.undefined, .null): return .success(.boolean(true)) // undefined == null is false, so undefined != null is true
            default: return .success(.boolean(left != right)) // Use default inequality for other types
            }

        case ">":
            switch (left, right) {
            case (.number(let l), .number(let r)): return .success(.boolean(l > r))
            case (.date(let l), .date(let r)): return .success(.boolean(l > r))
            default: return .success(.boolean(false)) // For all other cases including string comparisons, return false
            }

        case "<":
             switch (left, right) {
             case (.number(let l), .number(let r)): return .success(.boolean(l < r))
             case (.date(let l), .date(let r)): return .success(.boolean(l < r))
             default: return .success(.boolean(false)) // For all other cases including string comparisons, return false
             }

        case ">=":
             switch (left, right) {
             case (.number(let l), .number(let r)): return .success(.boolean(l >= r))
             case (.date(let l), .date(let r)): return .success(.boolean(l >= r))
             default: return .success(.boolean(false)) // For all other cases including string comparisons, return false
             }

        case "<=":
             switch (left, right) {
             case (.number(let l), .number(let r)): return .success(.boolean(l <= r))
             case (.date(let l), .date(let r)): return .success(.boolean(l <= r))
             default: return .success(.boolean(false)) // For all other cases including string comparisons, return false
             }

        // --- Logical Operators ---
        case "&&":
            guard case .boolean(let l) = left, case .boolean(let r) = right else {
                return .failure(.typeMismatch(expected: "Booleans for '&&'", actual: "\(typeDescription(left)) and \(typeDescription(right))"))
            }
            return .success(.boolean(l && r))

        case "||":
             guard case .boolean(let l) = left, case .boolean(let r) = right else {
                 return .failure(.typeMismatch(expected: "Booleans for '||'", actual: "\(typeDescription(left)) and \(typeDescription(right))"))
             }
             return .success(.boolean(l || r))

        default:
             if op == "=" { return .failure(.unknownError("Assignment operator '=' is not supported. Use '==' for comparison.")) }
             return .failure(.unknownError("Unsupported infix operator: \(op)"))
        }
    }

    // Helper to get a user-friendly type name
     private func typeDescription(_ value: FormulaValue) -> String {
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

    // Helper to convert any FormulaValue to a string representation for concatenation
    private func stringify(_ value: FormulaValue) -> String {
        switch value {
        case .number(let n):
             // Use a simple format without thousands separators
             if n.truncatingRemainder(dividingBy: 1) == 0 {
                 return String(format: "%.0f", n)
             } else {
                 return String(n)
             }
        case .string(let s): return s
        case .boolean(let b): return String(b)
        case .date(let d):
             let formatter = ISO8601DateFormatter()
             formatter.formatOptions = [.withInternetDateTime] // Common format
             return formatter.string(from: d)
        case .array(let a): return "[" + a.map { stringify($0) }.joined(separator: ", ") + "]"
        case .dictionary(let d): 
             let pairs = d.map { key, value in "\"\(key)\": \(stringify(value))" }.sorted()
             return "{\(pairs.joined(separator: ", "))}"
        case .null:
             return "null"
        case .undefined:
             return "undefined"
        case .error(let e): return errorString(e)
        case .lambda(let parameters, _): 
             return "[Lambda: (\(parameters.joined(separator: ", "))) -> ...]"
        }
    }

    // Helper to get standard error string representation
    private func errorString(_ error: FormulaError) -> String {
         switch error {
         case .syntaxError(let msg): return "#SYNTAX!(\(msg))"
         case .invalidReference(let name): return "#REF!(\(name))"
         case .typeMismatch(let expected, let actual): return "#TYPE!(\(expected),\(actual))"
         case .invalidArguments(let function, let reason): return "#ARGS!(\(function):\(reason))"
         case .divisionByZero: return "#DIV/0!"
         case .circularReference(let path): return "#CIRC!(\(path))"
         case .unknownError(let msg): return "#ERROR!(\(msg))"
         }
    }
}