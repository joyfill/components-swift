import Foundation

struct HigherOrderFunctions {
    
    /// Implements the MAP function: MAP(array, variableNameString, expressionAST)
    static func map(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 3 else {
            return .failure(.invalidArguments(function: "MAP", reason: "Expected 3 arguments (array, variableName, expression), got \(args.count)"))
        }

        // 1. Evaluate the first argument to get the array
        let arrayResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let arrayValue) = arrayResult else { return arrayResult }
        guard case .array(let items) = arrayValue else {
            return .failure(.typeMismatch(expected: "Array", actual: String(describing: arrayValue)))
        }

        // 2. Get the variable name
        guard case .literal(.string(let variableName)) = args[1] else {
            return .failure(.invalidArguments(function: "MAP", reason: "Second argument (variableName) must be a string literal."))
        }
        
        // 3. Get the expression to apply
        let expressionNode = args[2]
        
        // 4. Iterate, evaluate expression for each item, and collect results
        var results: [FormulaValue] = []
        results.reserveCapacity(items.count)

        for item in items {
            let itemContext = context.contextByAdding(variable: variableName, value: item)
            let result = evaluator.evaluate(node: expressionNode, context: itemContext)
            
            switch result {
            case .success(let value):
                results.append(value)
            case .failure(let error):
                return .failure(.unknownError("Error evaluating MAP expression for item \(item): \(error)"))
            }
        }
        return .success(.array(results))
    }

    /// Implements the FILTER function: FILTER(array, variableNameString, predicateExpressionAST)
    static func filter(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 3 else {
            return .failure(.invalidArguments(function: "FILTER", reason: "Expected 3 arguments (array, variableName, predicateExpression), got \(args.count)"))
        }

        // 1. Evaluate the first argument to get the array
        let arrayResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let arrayValue) = arrayResult else { return arrayResult }
        guard case .array(let items) = arrayValue else {
            return .failure(.typeMismatch(expected: "Array", actual: String(describing: arrayValue)))
        }

        // 2. Get the variable name
        guard case .literal(.string(let variableName)) = args[1] else {
            return .failure(.invalidArguments(function: "FILTER", reason: "Second argument (variableName) must be a string literal."))
        }
        
        // 3. Get the predicate expression to apply
        let predicateNode = args[2]
        
        // 4. Iterate, evaluate predicate for each item, and collect results if true
        var results: [FormulaValue] = []
        results.reserveCapacity(items.count)

        for item in items {
            let itemContext = context.contextByAdding(variable: variableName, value: item)
            let predicateResult = evaluator.evaluate(node: predicateNode, context: itemContext)
            
            switch predicateResult {
            case .success(let resultValue):
                guard case .boolean(let include) = resultValue else {
                    return .failure(.typeMismatch(expected: "Boolean for FILTER predicate", actual: String(describing: resultValue)))
                }
                if include {
                    results.append(item)
                }
            case .failure(let error):
                return .failure(.unknownError("Error evaluating FILTER predicate for item \(item): \(error)"))
            }
        }
        return .success(.array(results))
    }

    /// Implements the SORT function: 
    ///  - sort(array)
    ///  - sort(array, ascendingBoolean)
    static func sort(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 1 || args.count == 2 else {
            return .failure(.invalidArguments(function: "SORT", reason: "Expected 1 or 2 arguments (array, [ascending]), got \(args.count)"))
        }

        // 1. Evaluate the first argument to get the array
        let arrayResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let arrayValue) = arrayResult else { return arrayResult }
        guard case .array(let items) = arrayValue else {
            return .failure(.typeMismatch(expected: "Array", actual: String(describing: arrayValue)))
        }
        
        if items.isEmpty { return .success(.array([])) } // Handle empty array

        // 2. Determine sort direction
        var ascending = true // Default
        if args.count == 2 {
            let ascendingResult = evaluator.evaluate(node: args[1], context: context)
            guard case .success(let ascendingValue) = ascendingResult else { return ascendingResult }
            guard case .boolean(let ascBool) = ascendingValue else { 
                return .failure(.typeMismatch(expected: "Boolean for ascending flag", actual: String(describing: ascendingValue)))
            }
            ascending = ascBool
        }
        
        // Pre-check: Ensure all elements are comparable before sorting
        if items.count > 1 {
            var comparisonError: FormulaError? = nil
            for i in 1..<items.count {
                if items[i].compare(to: items[0]) == nil {
                     comparisonError = FormulaError.typeMismatch(expected: "Comparable types (Number, String)", actual: "Mixed types in array")
                     break
                }
            }
            if let error = comparisonError {
                return .failure(error)
            }
        }
        
        // Perform the sort (now safe to use non-throwing sort)
        var sortedItems = items
        sortedItems.sort { (lhs, rhs) -> Bool in
            let comparisonResult = lhs.compare(to: rhs) ?? .orderedSame 
            return ascending ? (comparisonResult == .orderedAscending) : (comparisonResult == .orderedDescending)
        }

        return .success(.array(sortedItems))
    }

    /// Implements the FLATMAP function: FLATMAP(array, variableNameString, expressionReturningArrayAST)
    static func flatMap(args: [ASTNode], context: EvaluationContext, evaluator: Evaluator) -> Result<FormulaValue, FormulaError> {
        guard args.count == 3 else {
            return .failure(.invalidArguments(function: "FLATMAP", reason: "Expected 3 arguments (array, variableName, expression), got \(args.count)"))
        }

        // 1. Evaluate the first argument to get the input array
        let arrayResult = evaluator.evaluate(node: args[0], context: context)
        guard case .success(let arrayValue) = arrayResult else { return arrayResult }
        guard case .array(let items) = arrayValue else {
            return .failure(.typeMismatch(expected: "Array", actual: String(describing: arrayValue)))
        }

        // 2. Get the variable name
        guard case .literal(.string(let variableName)) = args[1] else {
            return .failure(.invalidArguments(function: "FLATMAP", reason: "Second argument (variableName) must be a string literal."))
        }
        
        // 3. Get the expression to apply
        let expressionNode = args[2]
        
        // 4. Iterate, evaluate, check for array result, and flatten
        var results: [FormulaValue] = []
        for item in items {
            let itemContext = context.contextByAdding(variable: variableName, value: item)
            let result = evaluator.evaluate(node: expressionNode, context: itemContext)
            
            switch result {
            case .success(let value):
                guard case .array(let innerArray) = value else {
                    return .failure(.typeMismatch(expected: "Array from FLATMAP expression", actual: String(describing: value)))
                }
                results.append(contentsOf: innerArray)
            case .failure(let error):
                return .failure(.unknownError("Error evaluating FLATMAP expression for item \(item): \(error)"))
            }
        }
        return .success(.array(results))
    }
} 