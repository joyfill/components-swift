import Foundation

/// Array function implementations for operations on arrays
public struct ArrayFunctions {
    
    /// Implements the COUNTIF function: COUNTIF(array, criterion)
    static func countIf(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 2 else {
            return .failure(.invalidArguments(function: "COUNTIF", reason: "Expected exactly 2 arguments (array, criterion), got \(args.count)"))
        }
        
        // Evaluate first argument (array)
        let arrayResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let arrayValue) = arrayResult else { return arrayResult }
        
        // Ensure it's an array
        guard case .array(let array) = arrayValue else {
            return .failure(.typeMismatch(expected: "Array", actual: "Argument 1: \(typeDescription(arrayValue))"))
        }
        
        // Evaluate second argument (criterion)
        let criterionResult = evaluator.evaluate(node: args[1], context: context)
        guard case .success(let criterionValue) = criterionResult else { return criterionResult }
        
        // Count items in array that match the criterion
        var count = 0
        
        for item in array {
            var matches = false
            
            // Handle different types of criteria and items
            switch (item, criterionValue) {
            case (.string(let itemStr), .string(let criterion)):
                // String to string: case-insensitive contains check
                matches = itemStr.range(of: criterion, options: .caseInsensitive) != nil
                
            case (.number(let itemNum), .number(let criterion)):
                // Number to number: exact match
                matches = itemNum == criterion
                
            case (.boolean(let itemBool), .boolean(let criterion)):
                // Boolean to boolean: exact match
                matches = itemBool == criterion
                
            case (.null, .null):
                // Null to null: match
                matches = true
                
            default:
                // For mixed types or other cases, convert both to strings and compare
                let itemStr = stringRepresentation(of: item)
                let criterionStr = stringRepresentation(of: criterionValue)
                matches = itemStr == criterionStr
            }
            
            if matches {
                count += 1
            }
        }
        
        return .success(.number(Double(count)))
    }
    
    /// Implements the MAP function: MAP(array, lambda)
    static func map(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 2 else {
            return .failure(.invalidArguments(function: "MAP", reason: "Expected exactly 2 arguments (array, lambda), got \(args.count)"))
        }
        
        // Evaluate first argument (array)
        let arrayResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let arrayValue) = arrayResult else { return arrayResult }
        
        guard case .array(let array) = arrayValue else {
            return .failure(.typeMismatch(expected: "Array", actual: "Argument 1: \(typeDescription(arrayValue))"))
        }
        
        // Second argument should be a lambda
        guard case .lambda(let parameters, let body) = args[1] else {
            return .failure(.typeMismatch(expected: "Lambda function", actual: "Argument 2: not a lambda"))
        }
        
        guard parameters.count >= 1 else {
            return .failure(.invalidArguments(function: "MAP", reason: "Lambda must have at least 1 parameter"))
        }
        
        var results: [FormulaValue] = []
        
        for (index, item) in array.enumerated() {
            // Create new context with lambda parameters
            var newContext = context
            newContext = newContext.contextByAdding(variable: parameters[0], value: item)
            
            // Add index parameter if lambda has 2 parameters
            if parameters.count >= 2 {
                newContext = newContext.contextByAdding(variable: parameters[1], value: .number(Double(index)))
            }
            
            // Evaluate lambda body
            let result = evaluator.evaluate(node: body, context: newContext)
            switch result {
            case .success(let value):
                results.append(value)
            case .failure(let error):
                continue
            }
        }
        
        return .success(.array(results))
    }
    
    /// Implements the FILTER function: FILTER(array, lambda)
    static func filter(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 2 else {
            return .failure(.invalidArguments(function: "FILTER", reason: "Expected exactly 2 arguments (array, lambda), got \(args.count)"))
        }
        
        // Evaluate first argument (array)
        let arrayResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let arrayValue) = arrayResult else { return arrayResult }
        
        guard case .array(let array) = arrayValue else {
            return .failure(.typeMismatch(expected: "Array", actual: "Argument 1: \(typeDescription(arrayValue))"))
        }
        
        // Second argument should be a lambda
        guard case .lambda(let parameters, let body) = args[1] else {
            return .failure(.typeMismatch(expected: "Lambda function", actual: "Argument 2: not a lambda"))
        }
        
        guard parameters.count >= 1 else {
            return .failure(.invalidArguments(function: "FILTER", reason: "Lambda must have at least 1 parameter"))
        }
        
        var results: [FormulaValue] = []
        
        for (index, item) in array.enumerated() {
            // Create new context with lambda parameters
            var newContext = context
            newContext = newContext.contextByAdding(variable: parameters[0], value: item)
            
            // Add index parameter if lambda has 2 parameters
            if parameters.count >= 2 {
                newContext = newContext.contextByAdding(variable: parameters[1], value: .number(Double(index)))
            }
            
            // Evaluate lambda body
            let result = evaluator.evaluate(node: body, context: newContext)
            switch result {
            case .success(.boolean(true)):
                results.append(item)
            case .success(.boolean(false)):
                // Skip this item
                continue
            case .success(let value):
                return .failure(.typeMismatch(expected: "Boolean from filter lambda", actual: typeDescription(value)))
            case .failure(let error):
                return .failure(error)
            }
        }
        
        return .success(.array(results))
    }
    
    /// Implements the FIND function: FIND(array, lambda)
    static func find(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 2 else {
            return .failure(.invalidArguments(function: "FIND", reason: "Expected exactly 2 arguments (array, lambda), got \(args.count)"))
        }
        
        // Evaluate first argument (array)
        let arrayResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let arrayValue) = arrayResult else { return arrayResult }
        
        guard case .array(let array) = arrayValue else {
            return .failure(.typeMismatch(expected: "Array", actual: "Argument 1: \(typeDescription(arrayValue))"))
        }
        
        // Second argument should be a lambda
        guard case .lambda(let parameters, let body) = args[1] else {
            return .failure(.typeMismatch(expected: "Lambda function", actual: "Argument 2: not a lambda"))
        }
        
        guard parameters.count >= 1 else {
            return .failure(.invalidArguments(function: "FIND", reason: "Lambda must have at least 1 parameter"))
        }
        
        for (index, item) in array.enumerated() {
            // Create new context with lambda parameters
            var newContext = context
            newContext = newContext.contextByAdding(variable: parameters[0], value: item)
            
            // Add index parameter if lambda has 2 parameters
            if parameters.count >= 2 {
                newContext = newContext.contextByAdding(variable: parameters[1], value: .number(Double(index)))
            }
            
            // Evaluate lambda body
            let result = evaluator.evaluate(node: body, context: newContext)
            switch result {
            case .success(.boolean(true)):
                return .success(item)
            case .success(.boolean(false)):
                // Continue searching
                continue
            case .success(let value):
                return .failure(.typeMismatch(expected: "Boolean from find lambda", actual: typeDescription(value)))
            case .failure(let error):
                return .failure(error)
            }
        }
        
        // No item found
        return .success(.null)
    }
    
    /// Implements the REDUCE function: REDUCE(array, lambda, initialValue)
    static func reduce(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 3 else {
            return .failure(.invalidArguments(function: "REDUCE", reason: "Expected exactly 3 arguments (array, lambda, initialValue), got \(args.count)"))
        }
        
        // Evaluate first argument (array)
        let arrayResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let arrayValue) = arrayResult else { return arrayResult }
        
        guard case .array(let array) = arrayValue else {
            return .failure(.typeMismatch(expected: "Array", actual: "Argument 1: \(typeDescription(arrayValue))"))
        }
        
        // Second argument should be a lambda
        guard case .lambda(let parameters, let body) = args[1] else {
            return .failure(.typeMismatch(expected: "Lambda function", actual: "Argument 2: not a lambda"))
        }
        
        guard parameters.count >= 2 else {
            return .failure(.invalidArguments(function: "REDUCE", reason: "Lambda must have at least 2 parameters (accumulator, currentItem)"))
        }
        
        // Evaluate initial value
        let initialResult = evaluator.evaluate(node: args[2], context: context)
        guard case .success(let initialValue) = initialResult else { return initialResult }
        
        var accumulator = initialValue
        
        for (index, item) in array.enumerated() {
            // Create new context with lambda parameters
            var newContext = context
            newContext = newContext.contextByAdding(variable: parameters[0], value: accumulator)
            newContext = newContext.contextByAdding(variable: parameters[1], value: item)
            
            // Add index parameter if lambda has 3 parameters
            if parameters.count >= 3 {
                newContext = newContext.contextByAdding(variable: parameters[2], value: .number(Double(index)))
            }
            
            // Evaluate lambda body
            let result = evaluator.evaluate(node: body, context: newContext)
            switch result {
            case .success(let value):
                accumulator = value
            case .failure(let error):
                return .failure(error)
            }
        }
        
        return .success(accumulator)
    }
    
    /// Implements the EVERY function: EVERY(array, lambda)
    static func every(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 2 else {
            return .failure(.invalidArguments(function: "EVERY", reason: "Expected exactly 2 arguments (array, lambda), got \(args.count)"))
        }
        
        // Evaluate first argument (array)
        let arrayResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let arrayValue) = arrayResult else { return arrayResult }
        
        guard case .array(let array) = arrayValue else {
            return .failure(.typeMismatch(expected: "Array", actual: "Argument 1: \(typeDescription(arrayValue))"))
        }
        
        // Second argument should be a lambda
        guard case .lambda(let parameters, let body) = args[1] else {
            return .failure(.typeMismatch(expected: "Lambda function", actual: "Argument 2: not a lambda"))
        }
        
        guard parameters.count >= 1 else {
            return .failure(.invalidArguments(function: "EVERY", reason: "Lambda must have at least 1 parameter"))
        }
        
        for (index, item) in array.enumerated() {
            // Create new context with lambda parameters
            var newContext = context
            newContext = newContext.contextByAdding(variable: parameters[0], value: item)
            
            // Add index parameter if lambda has 2 parameters
            if parameters.count >= 2 {
                newContext = newContext.contextByAdding(variable: parameters[1], value: .number(Double(index)))
            }
            
            // Evaluate lambda body
            let result = evaluator.evaluate(node: body, context: newContext)
            switch result {
            case .success(.boolean(true)):
                // Continue checking
                continue
            case .success(.boolean(false)):
                return .success(.boolean(false))
            case .success(let value):
                return .failure(.typeMismatch(expected: "Boolean from every lambda", actual: typeDescription(value)))
            case .failure(let error):
                return .failure(error)
            }
        }
        
        // All items passed the test
        return .success(.boolean(true))
    }
    
    /// Implements the SOME function: SOME(array, lambda)
    static func some(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 2 else {
            return .failure(.invalidArguments(function: "SOME", reason: "Expected exactly 2 arguments (array, lambda), got \(args.count)"))
        }
        
        // Evaluate first argument (array)
        let arrayResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let arrayValue) = arrayResult else { return arrayResult }
        
        guard case .array(let array) = arrayValue else {
            return .failure(.typeMismatch(expected: "Array", actual: "Argument 1: \(typeDescription(arrayValue))"))
        }
        
        // Second argument should be a lambda
        guard case .lambda(let parameters, let body) = args[1] else {
            return .failure(.typeMismatch(expected: "Lambda function", actual: "Argument 2: not a lambda"))
        }
        
        guard parameters.count >= 1 else {
            return .failure(.invalidArguments(function: "SOME", reason: "Lambda must have at least 1 parameter"))
        }
        
        for (index, item) in array.enumerated() {
            // Create new context with lambda parameters
            var newContext = context
            newContext = newContext.contextByAdding(variable: parameters[0], value: item)
            
            // Add index parameter if lambda has 2 parameters
            if parameters.count >= 2 {
                newContext = newContext.contextByAdding(variable: parameters[1], value: .number(Double(index)))
            }
            
            // Evaluate lambda body
            let result = evaluator.evaluate(node: body, context: newContext)
            switch result {
            case .success(.boolean(true)):
                return .success(.boolean(true))
            case .success(.boolean(false)):
                // Continue checking
                continue
            case .success(let value):
                return .failure(.typeMismatch(expected: "Boolean from some lambda", actual: typeDescription(value)))
            case .failure(let error):
                return .failure(error)
            }
        }
        
        // No item passed the test
        return .success(.boolean(false))
    }
    
    /// Implements the FLATMAP function: FLATMAP(array, lambda)
    static func flatMap(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 2 else {
            return .failure(.invalidArguments(function: "FLATMAP", reason: "Expected exactly 2 arguments (array, lambda), got \(args.count)"))
        }
        
        // Evaluate first argument (array)
        let arrayResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let arrayValue) = arrayResult else { return arrayResult }
        
        guard case .array(let array) = arrayValue else {
            return .failure(.typeMismatch(expected: "Array", actual: "Argument 1: \(typeDescription(arrayValue))"))
        }
        
        // Second argument should be a lambda
        guard case .lambda(let parameters, let body) = args[1] else {
            return .failure(.typeMismatch(expected: "Lambda function", actual: "Argument 2: not a lambda"))
        }
        
        guard parameters.count >= 1 else {
            return .failure(.invalidArguments(function: "FLATMAP", reason: "Lambda must have at least 1 parameter"))
        }
        
        var results: [FormulaValue] = []
        
        for (index, item) in array.enumerated() {
            // Create new context with lambda parameters
            var newContext = context
            newContext = newContext.contextByAdding(variable: parameters[0], value: item)
            
            // Add index parameter if lambda has 2 parameters
            if parameters.count >= 2 {
                newContext = newContext.contextByAdding(variable: parameters[1], value: .number(Double(index)))
            }
            
            // Evaluate lambda body
            let result = evaluator.evaluate(node: body, context: newContext)
            switch result {
            case .success(.array(let subArray)):
                results.append(contentsOf: subArray)
            case .success(let value):
                // If not an array, just add the value
                results.append(value)
            case .failure(let error):
                return .failure(error)
            }
        }
        
        return .success(.array(results))
    }
    
    /// Implements the FLAT function: FLAT(array, depth)
    static func flat(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count >= 1 && args.count <= 2 else {
            return .failure(.invalidArguments(function: "FLAT", reason: "Expected 1 or 2 arguments (array, optional depth), got \(args.count)"))
        }
        
        // Evaluate first argument (array)
        let arrayResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let arrayValue) = arrayResult else { return arrayResult }
        
        guard case .array(let array) = arrayValue else {
            return .failure(.typeMismatch(expected: "Array", actual: "Argument 1: \(typeDescription(arrayValue))"))
        }
        
        // Evaluate depth argument (default to 1)
        var depth = 1
        if args.count == 2 {
            let depthResult = evaluator.evaluate(node: args[1], context: context)
            guard case .success(let depthValue) = depthResult else { return depthResult }
            
            guard case .number(let depthNum) = depthValue else {
                return .failure(.typeMismatch(expected: "Number", actual: "Argument 2: \(typeDescription(depthValue))"))
            }
            
            depth = max(0, Int(depthNum))
        }
        
        return .success(.array(flattenArray(array, depth: depth)))
    }
    
    /// Helper function to flatten an array to a specific depth
    private static func flattenArray(_ array: [FormulaValue], depth: Int) -> [FormulaValue] {
        guard depth > 0 else { return array }
        
        var result: [FormulaValue] = []
        
        for item in array {
            if case .array(let subArray) = item {
                result.append(contentsOf: flattenArray(subArray, depth: depth - 1))
            } else {
                result.append(item)
            }
        }
        
        return result
    }
    
    /// Implements the UNIQUE function: UNIQUE(array)
    static func unique(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 1 else {
            return .failure(.invalidArguments(function: "UNIQUE", reason: "Expected exactly 1 argument, got \(args.count)"))
        }
        
        // Evaluate the argument (array)
        let arrayResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let arrayValue) = arrayResult else { return arrayResult }
        
        guard case .array(let array) = arrayValue else {
            return .failure(.typeMismatch(expected: "Array", actual: "Argument: \(typeDescription(arrayValue))"))
        }
        
        var uniqueValues: [FormulaValue] = []
        var seenValues: Set<String> = []
        
        for item in array {
            let stringRep = stringRepresentation(of: item)
            if !seenValues.contains(stringRep) {
                seenValues.insert(stringRep)
                uniqueValues.append(item)
            }
        }
        
        return .success(.array(uniqueValues))
    }
    
    // Helper function to get a string representation of any FormulaValue
    private static func stringRepresentation(of value: FormulaValue) -> String {
        switch value {
        case .string(let str):
            return str
        case .number(let num):
            if num.truncatingRemainder(dividingBy: 1) == 0 {
                return String(format: "%.0f", num)
            } else {
                return String(num)
            }
        case .boolean(let bool):
            return String(bool)
        case .date(let date):
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            return formatter.string(from: date)
        case .array:
            return "[Array]"
        case .dictionary:
            return "[Dictionary]"
        case .null:
            return "null"
        case .undefined:
            return "undefined"
        case .error:
            return "[Error]"
        case .lambda:
            return "[Lambda]"
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
        case .lambda: return "Lambda"
        }
    }
} 
