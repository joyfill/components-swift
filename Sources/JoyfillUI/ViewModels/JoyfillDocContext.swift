import Foundation
import JoyfillModel
import JoyfillFormulas

/// Protocol that provides access to JoyDoc data without direct dependency
public protocol JoyDocProvider {
    func field(for identifier: String) -> JoyDocField?
    func allFormulsFields() -> [JoyDocField]
    func formula(with id: String) -> Formula?
    func updateValue(for identifier: String, value: ValueUnion)
    func setFieldHidden(_ hidden: Bool, for identifier: String)
    func currentFieldIdentifier() -> String?
}

/// Application-level implementation of EvaluationContext that resolves references against a JoyDoc
/// This implementation handles the requirements outlined in the Reference Resolution PRD.
public class JoyfillDocContext: EvaluationContext {
    private let docProvider: JoyDocProvider
    private var temporaryVariables: [String: FormulaValue] = [:]
    
    // Add shared UTC date formatter
    private lazy var utcDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    // Properties for formula dependencies
    private var formulaCache: [String: FormulaValue] = [:]
    private var dependencyGraph: [String: Set<String>] = [:]  // field -> fields it depends on
    private var evaluationInProgress: Set<String> = []  // For circular dependency detection
    private let parser = Parser()
    private let evaluator = Evaluator()
    
    /// Initialize with a JoyDocProvider instance
    /// - Parameter docProvider: The provider to resolve references against
    public init(docProvider: JoyDocProvider) {
        self.docProvider = docProvider
        buildDependencyGraph()
        evaluateAllFormulas()
    }

    /// Resolve a reference string against the JoyDoc
    /// - Parameter name: Reference string (e.g., "{fieldIdentifier}" or "fieldIdentifier")
    /// - Returns: Result containing the resolved FormulaValue or an error
    public func resolveReference(_ name: String) -> Result<FormulaValue, FormulaError> {
        // First check temporary variables (for lambda parameters)
        if let tempValue = resolveTemporaryVariable(name) {
            return .success(tempValue)
        }
        
        // Handle braced references like {fieldName} or {fruits[{selectedIndex}]}
        if name.hasPrefix("{") && name.hasSuffix("}") {
            let content = String(name.dropFirst().dropLast())
            
            // Check if this is a simple field reference (no dots or brackets)
            if !content.contains(".") && !content.contains("[") {
                return resolveSimpleFieldReference(content)
            } else {
                // Complex reference - split by dots for processing
                let pathComponents = content.split(separator: ".").map(String.init)
                return resolveComplexFieldReference(pathComponents)
            }
        }
        
        // Handle bare references (like "self", "current", "this")
        return resolveSimpleFieldReference(name)
    }
    
    /// Provides access to cached formula values for introspection
    /// - Parameter identifier: Field identifier
    /// - Returns: Cached formula value if available
    public func getCachedFormulaValue(for identifier: String) -> FormulaValue? {
        return formulaCache[identifier]
    }
    
    /// Clears formula cache to force re-evaluation
    public func clearFormulaCache() {
        formulaCache.removeAll()
    }
    
    /// Clears cached value for specific field and its dependents
    /// - Parameter identifier: Field identifier whose cache should be cleared
    public func clearCacheForField(_ identifier: String) {
        // Clear the field's own cache
        formulaCache.removeValue(forKey: identifier)
        
        // Clear cache for all fields that depend on this field
        for (dependentField, dependencies) in dependencyGraph {
            if dependencies.contains(identifier) {
                formulaCache.removeValue(forKey: dependentField)
            }
        }
    }
    
    /// Updates the value of a field and clears related caches
    /// - Parameters:
    ///   - identifier: Field identifier
    ///   - value: New value for the field
    public func updateFieldValue(identifier: String, value: ValueUnion) {
        // Update the field value through the provider
        docProvider.updateValue(for: identifier, value: value)
        
        // Clear related caches
        clearCacheForField(identifier)
    }
    
    /// Gets all field identifiers that have dependencies
    /// - Returns: Array of field identifiers with formula dependencies
    public func getFieldsWithDependencies() -> [String] {
        return Array(dependencyGraph.keys)
    }
    
    /// Gets direct dependencies of a field
    /// - Parameter identifier: Field identifier
    /// - Returns: Set of field identifiers that this field depends on
    public func getDependencies(for identifier: String) -> Set<String> {
        return dependencyGraph[identifier] ?? Set()
    }
    
    /// Resolves self-reference (current field value)
    /// - Returns: Result containing the current field's value or an error
    public func resolveSelfReference() -> Result<FormulaValue, FormulaError> {
        // Get the current field identifier from the provider
        guard let currentIdentifier = docProvider.currentFieldIdentifier() else {
            return .failure(.invalidReference("Cannot resolve self reference: No current field context"))
        }
        
        // Resolve the reference to the current field
        guard let field = docProvider.field(for: currentIdentifier) else {
            return .failure(.invalidReference("Cannot resolve self reference: Current field not found"))
        }
        
        // Convert the field value to a formula value
        return convertFieldValueToFormulaValue(field.value)
    }
    
    /// Creates a new context with added temporary variable
    /// - Parameters:
    ///   - name: Variable name
    ///   - value: Variable value
    /// - Returns: A new context with the variable added
    public func contextByAdding(variable name: String, value: FormulaValue) -> EvaluationContext {
        // Create a lightweight wrapper instead of a new JoyfillDocContext to avoid infinite recursion
        return TemporaryVariableContext(
            baseContext: self,
            additionalVariables: [name: value]
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func resolveTemporaryVariable(_ name: String) -> FormulaValue? {
        // Check if name has braces
        let key = name.hasPrefix("{") && name.hasSuffix("}") 
                  ? String(name.dropFirst().dropLast()) 
                  : name
        
        return temporaryVariables[key]
    }
    
    /// Gets the applied formula for a field, if it exists
    private func getFormulaForField(_ field: JoyDocField) -> (formulaString: String, key: String)? {
        // Check if this field has any applied formulas
        guard let appliedFormulas = field.formulas, !appliedFormulas.isEmpty else {
            return nil
        }
        
        // Get the first applied formula (we assume one formula per field for now)
        let appliedFormula = appliedFormulas[0]
        
        // Get the formula ID and key
        guard let formulaId = appliedFormula.formula, let key = appliedFormula.key else {
            return nil
        }
        
        // Look up the actual formula by ID
        guard let formula = docProvider.formula(with: formulaId) else {
            return nil
        }
        
        // Return the formula string and the target key
        return (formulaString: formula.formula ?? "", key: key)
    }
    
    private func resolveSimpleFieldReference(_ identifier: String) -> Result<FormulaValue, FormulaError> {
        // Handle special self-reference keywords
        if identifier == "self" || identifier == "current" || identifier == "this" {
            // Map self-reference keywords to specific field patterns
            let fieldName = identifier + "Value"
            
            guard let field = docProvider.field(for: fieldName) else {
                return .failure(.invalidReference("Field with identifier '\(fieldName)' not found for '\(identifier)' reference"))
            }
            
            let result = convertFieldValueToFormulaValue(field.value)
            return result
        }
        
        // Search the fields for a matching identifier
        guard let field = docProvider.field(for: identifier) else {
            return .failure(.invalidReference("Field with identifier '\(identifier)' not found"))
        }
        
        // Check if it's a formula field
        if let formulaInfo = getFormulaForField(field) {
            // Check for cached value
            if let cachedValue = formulaCache[identifier] {
                return .success(cachedValue)
            }
            
            // Check for circular dependency
            if evaluationInProgress.contains(identifier) {
                return .failure(.circularReference("Circular dependency detected for field '\(identifier)'"))
            }
            
            // Mark this field as currently being evaluated
            evaluationInProgress.insert(identifier)
            
            // Evaluate the formula
            let parseResult = parser.parse(formula: formulaInfo.formulaString)
            
            switch parseResult {
            case .success(let ast):
                let result = evaluator.evaluate(node: ast, context: self)
                
                // Remove from in-progress set
                evaluationInProgress.remove(identifier)
                
                // Cache the result if successful
                if case .success(let value) = result {
                    formulaCache[identifier] = value
                }
                
                return result
                
            case .failure(let error):
                // Remove from in-progress set
                evaluationInProgress.remove(identifier)
                return .failure(error)
            }
        }
        
        // Not a formula field, return the stored value
        return convertFieldValueToFormulaValue(field.value)
    }
    
    private func resolveComplexFieldReference(_ pathComponents: [String]) -> Result<FormulaValue, FormulaError> {
        // Parsing logic for complex field references
        // Starting point is usually a field identifier
        let firstComponent = pathComponents[0]
        
        // Check if the first component contains array indexing syntax
        var fieldIdentifier = firstComponent
        var remainingPath = Array(pathComponents.dropFirst())
        
        // If the first component has array indexing like "fruits[0]" or "matrix[1][2]"
        if firstComponent.contains("[") && firstComponent.contains("]") {
            // Extract the base field name from something like "fruits[0]" or "matrix[1][2]"
            if let bracketIndex = firstComponent.firstIndex(of: "[") {
                fieldIdentifier = String(firstComponent[..<bracketIndex])
                
                // Extract and split multiple array index parts like [1][2]
                let indexPart = String(firstComponent[bracketIndex...])
                let indexComponents = splitArrayIndexes(indexPart)
                remainingPath = indexComponents + remainingPath
            }
        }
        
        guard let field = docProvider.field(for: fieldIdentifier) else {
            return .failure(.invalidReference("Field with identifier '\(fieldIdentifier)' not found"))
        }
        
        // Handle different reference patterns based on the field type
        if field.fieldType == JoyfillModel.FieldTypes.table {
            // Handle collection-specific reference patterns
            return resolveCollectionReference(field, pathComponents: remainingPath)
        } else if !remainingPath.isEmpty {
            // This could be a property access or array index reference
            
            // First, resolve the base field value
            let baseValueResult = convertFieldValueToFormulaValue(field.value)
            guard case .success(let baseValue) = baseValueResult else {
                return baseValueResult
            }
            
            // Process the remainder of the path
            return resolvePathOnValue(baseValue, path: remainingPath)
        }
        
        // For single component without indexing, fallback to simple resolution
        return resolveSimpleFieldReference(fieldIdentifier)
    }
    
    /// Splits array index notation like "[1][2]" into separate components ["[1]", "[2]"]
    private func splitArrayIndexes(_ indexString: String) -> [String] {
        var components: [String] = []
        var current = indexString
        
        while !current.isEmpty {
            if let startIndex = current.firstIndex(of: "["),
               let endIndex = current.firstIndex(of: "]") {
                // Extract one complete bracket pair
                let component = String(current[startIndex...endIndex])
                components.append(component)
                
                // Move past this bracket pair
                let nextIndex = current.index(after: endIndex)
                current = nextIndex < current.endIndex ? String(current[nextIndex...]) : ""
            } else {
                break // No more brackets
            }
        }
        
        return components
    }
    
    /// Resolves a path on a value (for property access and array indexing)
    private func resolvePathOnValue(_ value: FormulaValue, path: [String]) -> Result<FormulaValue, FormulaError> {
        var currentValue = value
        
        for component in path {
            // Check if this is a pure array index reference: [index] (without property name)
            if component.hasPrefix("[") && component.hasSuffix("]") {
                // Extract index from [index]
                var indexStr = String(component.dropFirst().dropLast()) // Remove [ and ]
                
                // Parse the index
                if let index = Int(indexStr) {
                    // Access array by index
                    guard case .array(let array) = currentValue else {
                        return .failure(.invalidReference("Cannot index a non-array value"))
                    }
                    
                    guard index >= 0 && index < array.count else {
                        return .failure(.invalidReference("Array index out of bounds: \(index)"))
                    }
                    
                    currentValue = array[index]
                } else {
                    // Try to resolve it as a dynamic index reference
                    // Check if indexStr already has braces
                    let referenceString = indexStr.hasPrefix("{") && indexStr.hasSuffix("}") 
                                         ? indexStr 
                                         : "{\(indexStr)}"
                    let dynamicIndexResult = resolveReference(referenceString)
                    
                    guard case .success(let indexValue) = dynamicIndexResult,
                          case .number(let indexNumber) = indexValue,
                          indexNumber.truncatingRemainder(dividingBy: 1) == 0 else {
                        return .failure(.invalidReference("Invalid array index: \(indexStr)"))
                    }
                    
                    let index = Int(indexNumber)
                    
                    guard case .array(let array) = currentValue else {
                        return .failure(.invalidReference("Cannot index a non-array value"))
                    }
                    
                    guard index >= 0 && index < array.count else {
                        return .failure(.invalidReference("Array index out of bounds: \(index)"))
                    }
                    
                    currentValue = array[index]
                }
            }
            // Check if this is an array index reference with property: component[index]
            else if component.contains("[") && component.hasSuffix("]") {
                let parts = component.split(separator: "[", maxSplits: 1)
                if parts.count == 2 {
                    let arrayName = String(parts[0])
                    var indexStr = String(parts[1])
                    indexStr.removeLast() // Remove the closing "]"
                    
                    // If we're accessing a property first
                    if !arrayName.isEmpty {
                        // Access the property
                        guard case .dictionary(let dict) = currentValue,
                              let propValue = dict[arrayName] else {
                            return .failure(.invalidReference("Property '\(arrayName)' not found"))
                        }
                        currentValue = propValue
                    }
                    
                    // Parse the index
                    if let index = Int(indexStr) {
                        // Access array by index
                        guard case .array(let array) = currentValue else {
                            return .failure(.invalidReference("Cannot index a non-array value"))
                        }
                        
                        guard index >= 0 && index < array.count else {
                            return .failure(.invalidReference("Array index out of bounds: \(index)"))
                        }
                        
                        currentValue = array[index]
                    } else {
                        // Try to resolve it as a dynamic index reference
                        let referenceString = indexStr.hasPrefix("{") && indexStr.hasSuffix("}") ? indexStr : "{\(indexStr)}"
                        let dynamicIndexResult = resolveReference(referenceString)
                        
                        guard case .success(let indexValue) = dynamicIndexResult,
                              case .number(let indexNumber) = indexValue,
                              indexNumber.truncatingRemainder(dividingBy: 1) == 0 else {
                            return .failure(.invalidReference("Invalid array index: \(indexStr)"))
                        }
                        
                        let index = Int(indexNumber)
                        
                        guard case .array(let array) = currentValue else {
                            return .failure(.invalidReference("Cannot index a non-array value"))
                        }
                        
                        guard index >= 0 && index < array.count else {
                            return .failure(.invalidReference("Array index out of bounds: \(index)"))
                        }
                        
                        currentValue = array[index]
                    }
                } else {
                    return .failure(.invalidReference("Invalid array index syntax: \(component)"))
                }
            } else {
                // Regular property access
                guard case .dictionary(let dict) = currentValue,
                      let propValue = dict[component] else {
                    return .failure(.invalidReference("Property '\(component)' not found"))
                }
                currentValue = propValue
            }
        }
        
        return .success(currentValue)
    }
    
    private func resolveCollectionReference(_ field: JoyDocField, pathComponents: [String]) -> Result<FormulaValue, FormulaError> {
        // Get the value elements array from the field
        guard let valueElements = field.value?.valueElements else {
            return .failure(.invalidReference("Field '\(field.identifier ?? "unknown")' is not a valid collection"))
        }
        
        // If no further path components, return the entire collection
        if pathComponents.isEmpty {
            // Convert to array of dictionaries
            let result = valueElements.map { element -> FormulaValue in
                // Convert each cell to a dictionary of FormulaValues
                var dict: [String: FormulaValue] = [:]
                if let cells = element.cells {
                    for (key, value) in cells {
                        dict[key] = convertValueUnionToFormulaValue(value)
                    }
                }
                return .dictionary(dict)
            }
            return .success(.array(result))
        }
        
        // The next component could be:
        // 1. A schemaId (for nested collections)
        // 2. A numeric index (for specific row)
        // 3. A column name (for all values in that column)
        
        let nextComponent = pathComponents[0]
        
        // Check if it's a numeric index
        if let index = Int(nextComponent), index >= 0, index < valueElements.count {
            // Handle {fieldName.index} or {fieldName.index.columnName}
            if pathComponents.count == 1 {
                // Return the entire row as a dictionary
                var dict: [String: FormulaValue] = [:]
                if let cells = valueElements[index].cells {
                    for (key, value) in cells {
                        dict[key] = convertValueUnionToFormulaValue(value)
                    }
                }
                return .success(.dictionary(dict))
            } else if pathComponents.count == 2 {
                // Return a specific cell value: {fieldName.index.columnName}
                let columnName = pathComponents[1]
                if let cells = valueElements[index].cells,
                   let cellValue = cells[columnName] {
                    return .success(convertValueUnionToFormulaValue(cellValue))
                } else {
                    return .failure(.invalidReference("Column '\(columnName)' not found in row at index \(index)"))
                }
            }
        } 
        
        // Check if it's a column name (for all values in that column)
        let possibleColumnName = nextComponent
        guard let possibleColumnID = field.tableColumns?.first(where: { column in
            column.title == possibleColumnName
        })?.id else {
            return .failure(.invalidReference("Field '\(field.identifier ?? "unknown")' is not a valid collection"))
        }

        if pathComponents.count == 1 {
            // Get all values from this column: {fieldName.columnName}
            var columnValues: [FormulaValue] = []
            
            for element in valueElements {
                if let cells = element.cells,
                   let cellValue = cells[possibleColumnID] {
                    columnValues.append(convertValueUnionToFormulaValue(cellValue))
                } else {
                    // If column doesn't exist in this row, use null
                    columnValues.append(.null)
                }
            }
            
            return .success(.array(columnValues))
        }
        
        // Check if it might be a schema ID (for nested collections)
        // This would require additional knowledge of the schema structure
        
        return .failure(.invalidReference("Unable to resolve complex collection reference path: \(pathComponents.joined(separator: "."))"))
    }
    
    // MARK: - Conversion Methods
    
    private func convertFieldValueToFormulaValue(_ value: ValueUnion?) -> Result<FormulaValue, FormulaError> {
        guard let value = value else {
            return .success(.null)
        }
        
        return .success(convertValueUnionToFormulaValue(value))
    }
    
    private func convertValueUnionToFormulaValue(_ value: ValueUnion) -> FormulaValue {
        switch value {
        case .double(let doubleVal):
            // Handle timestamp values - check if it's likely milliseconds or seconds
            if doubleVal > 1000000000000 { // Likely a millisecond timestamp (> year 2001 in milliseconds)
                let date = Date(timeIntervalSince1970: doubleVal / 1000.0)
                return .date(date)
            } else if doubleVal > 1000000000 { // Likely a second timestamp (> year 2001 in seconds)
                let date = Date(timeIntervalSince1970: doubleVal)
                return .date(date)
            }
            return .number(doubleVal)
        case .int(let intVal):
            // Handle timestamp values - check if it's likely milliseconds or seconds
            if intVal > 1000000000000 { // Likely a millisecond timestamp
                let date = Date(timeIntervalSince1970: Double(intVal) / 1000.0)
                return .date(date)
            } else if intVal > 1000000000 { // Likely a second timestamp
                let date = Date(timeIntervalSince1970: Double(intVal))
                return .date(date)
            }
            return .number(Double(intVal))
        case .string(let stringVal):
            // Try to parse as timestamp first - check if it's likely milliseconds or seconds
            if let timestamp = Double(stringVal) {
                if timestamp > 1000000000000 { // Likely milliseconds
                    let date = Date(timeIntervalSince1970: timestamp / 1000.0)
                    return .date(date)
                } else if timestamp > 1000000000 { // Likely seconds
                    let date = Date(timeIntervalSince1970: timestamp)
                    return .date(date)
                }
            }
            // Try to parse as date string using UTC formatter
            if let date = utcDateFormatter.date(from: stringVal) {
                return .date(date)
            }
            // Try to parse JSON strings if not a timestamp or date
            if let jsonData = stringVal.data(using: .utf8) {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    return convertJsonObjectToFormulaValue(jsonObject)
                } catch {
                    // If JSON parsing fails, return as regular string
                    return .string(stringVal)
                }
            }
            return .string(stringVal)
        case .bool(let boolVal):
            return .boolean(boolVal)
        case .array(let stringArray):
            return .array(stringArray.map { FormulaValue.string($0) })
        case .valueElementArray(let elements):
            // Convert value elements to dictionaries
            return .array(elements.map { element -> FormulaValue in
                var dict: [String: FormulaValue] = [:]
                if let cells = element.cells {
                    for (key, cellValue) in cells {
                        dict[key] = convertValueUnionToFormulaValue(cellValue)
                    }
                }
                return .dictionary(dict)
            })
        case .dictionary(let dictValues):
            // Convert each dictionary value
            var result: [String: FormulaValue] = [:]
            for (key, dictValue) in dictValues {
                result[key] = convertValueUnionToFormulaValue(dictValue)
            }
            return .dictionary(result)
        case .null:
            return .null
//        case .date(let date):
//            // Convert Date to timestamp in milliseconds
//            let timestamp = date.timeIntervalSince1970 * 1000.0
//            return .double(timestamp)
//        case .error:
//            // For error values, return null
//            return .null
//        case .lambda(_, _):
//            // For lambda values, return null (can't be represented in ValueUnion)
//            return .null
        }
    }
    
    /// Converts a JSON object to a FormulaValue
    private func convertJsonObjectToFormulaValue(_ jsonObject: Any) -> FormulaValue {
        if let dict = jsonObject as? [String: Any] {
            var result: [String: FormulaValue] = [:]
            for (key, value) in dict {
                result[key] = convertJsonObjectToFormulaValue(value)
            }
            return .dictionary(result)
        } else if let array = jsonObject as? [Any] {
            let result = array.map { convertJsonObjectToFormulaValue($0) }
            return .array(result)
        } else if let string = jsonObject as? String {
            return .string(string)
        } else if let number = jsonObject as? NSNumber {
            if CFBooleanGetTypeID() == CFGetTypeID(number) {
                // It's a boolean
                return .boolean(number.boolValue)
            } else {
                // It's a number
                return .number(number.doubleValue)
            }
        } else if jsonObject is NSNull {
            return .null
        } else {
            // Fallback to string representation
            return .string(String(describing: jsonObject))
        }
    }
    
    // MARK: - Formula Dependency Methods
    
    /// Builds a dependency graph for formula fields
    private func buildDependencyGraph() {
        // Get all formula fields
        let formulaFields = docProvider.allFormulsFields()
        
        for field in formulaFields {
            if let identifier = field.identifier, let formulaInfo = getFormulaForField(field) {
                // Extract references from the formula
                let dependencies = extractReferences(from: formulaInfo.formulaString)
                dependencyGraph[identifier] = Set(dependencies)
            }
        }
        
        // Check for circular dependencies
        detectCircularDependencies()
    }
    
    /// Extracts field references from a formula string
    /// - Parameter formula: The formula string
    /// - Returns: An array of field identifiers that the formula references
    private func extractReferences(from formula: String) -> [String] {
        var references: [String] = []
        
        // Parse the formula
        let parseResult = parser.parse(formula: formula)
        
        if case .success(let ast) = parseResult {
            // Extract reference nodes from the AST
            extractReferencesFromNode(ast, references: &references)
        }
        
        return references
    }
    
    /// Recursively extracts references from an AST node
    /// - Parameters:
    ///   - node: The AST node to examine
    ///   - references: Array to collect references
    private func extractReferencesFromNode(_ node: ASTNode, references: inout [String]) {
        switch node {
        case .reference(let name):
            // Handle both braced references {fieldName} and bare references like self
            if name.hasPrefix("{") && name.hasSuffix("}") {
                // Braced reference like {fieldName} or {fruits[{selectedIndex}]}
                let content = String(name.dropFirst().dropLast())
                
                // First, add the base field identifier (part before any '[' or '.')
                var baseIdentifier = content
                if let firstBracket = content.firstIndex(of: "[") {
                    baseIdentifier = String(content[..<firstBracket])
                } else if let firstDot = content.firstIndex(of: ".") {
                    baseIdentifier = String(content[..<firstDot])
                }
                
                if !baseIdentifier.isEmpty {
                    references.append(baseIdentifier)
                }
                
                // Now extract any nested references from array indexing: [...]
                extractNestedReferencesFromString(content, references: &references)
            } else {
                // Bare reference like self, current, this - map to corresponding field
                if name == "self" || name == "current" || name == "this" {
                    let fieldName = name + "Value"
                    references.append(fieldName)
                } else {
                    // Other bare references - add as is
                    references.append(name)
                }
            }
            
        case .infixOperation(operator: _, left: let left, right: let right):
            extractReferencesFromNode(left, references: &references)
            extractReferencesFromNode(right, references: &references)
            
        case .functionCall(name: _, arguments: let args):
            for arg in args {
                extractReferencesFromNode(arg, references: &references)
            }
            
        case .prefixOperation(operator: _, operand: let operand):
            extractReferencesFromNode(operand, references: &references)
            
        case .arrayLiteral(let elementNodes):
            for elementNode in elementNodes {
                extractReferencesFromNode(elementNode, references: &references)
            }
        case .lambda(_, let body):
            // Extract references from lambda body
            extractReferencesFromNode(body, references: &references)
        case .literal:
            // Literals don't contain references
            break
        case .arrayAccess(array: let arrayNode, index: let indexNode):
            // Extract references from both the array expression and the index expression
            extractReferencesFromNode(arrayNode, references: &references)
            extractReferencesFromNode(indexNode, references: &references)
        case .propertyAccess(object: let objectNode, property: _):
            // Extract references from the object expression
            // Property names are strings, not references
            extractReferencesFromNode(objectNode, references: &references)
        }
    }
    
    /// Extracts nested references from a string like "fruits[{selectedIndex}]" or "matrix[{row}][{col}]"
    private func extractNestedReferencesFromString(_ content: String, references: inout [String]) {
        var remaining = content
        
        while let startBracket = remaining.firstIndex(of: "[") {
            // Find the matching closing bracket
            let afterStart = remaining.index(after: startBracket)
            var braceCount = 0
            var bracketCount = 1
            var endBracket: String.Index? = nil
            var currentIndex = afterStart
            
            while currentIndex < remaining.endIndex && bracketCount > 0 {
                let char = remaining[currentIndex]
                switch char {
                case "[":
                    bracketCount += 1
                case "]":
                    bracketCount -= 1
                    if bracketCount == 0 {
                        endBracket = currentIndex
                    }
                case "{":
                    braceCount += 1
                case "}":
                    braceCount -= 1
                default:
                    break
                }
                currentIndex = remaining.index(after: currentIndex)
            }
            
            guard let closeBracket = endBracket else {
                break // Malformed bracket, stop processing
            }
            
            // Extract the content between brackets
            let bracketContent = String(remaining[afterStart..<closeBracket])
            
            // Look for references within the bracket content
            extractReferencesFromBracketContent(bracketContent, references: &references)
            
            // Move past this bracket pair
            remaining = String(remaining[remaining.index(after: closeBracket)...])
        }
    }
    
    /// Extracts references from bracket content like "{selectedIndex}" or "someField.property"
    private func extractReferencesFromBracketContent(_ content: String, references: inout [String]) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If it's a braced reference like {selectedIndex}
        if trimmed.hasPrefix("{") && trimmed.hasSuffix("}") {
            let innerContent = String(trimmed.dropFirst().dropLast())
            let baseField = innerContent.split(separator: ".").first.map(String.init) ?? ""
            if !baseField.isEmpty {
                references.append(baseField)
            }
            
            // Recursively check for more nested references
            extractNestedReferencesFromString(innerContent, references: &references)
        }
        // If it's a simple field reference without braces
        else if !trimmed.isEmpty && !trimmed.contains(where: { "0123456789".contains($0) }) {
            // Only add if it doesn't look like a numeric index
            let baseField = trimmed.split(separator: ".").first.map(String.init) ?? ""
            if !baseField.isEmpty {
                references.append(baseField)
            }
        }
    }
    
    /// Detects circular dependencies in the dependency graph
    private func detectCircularDependencies() {
        for field in dependencyGraph.keys {
            var visited: Set<String> = []
            var path: [String] = []
            
            if hasCycle(field, visited: &visited, path: &path) {
                print("Warning: Circular dependency detected for field '\(field)': \(path)")
            }
        }
    }
    
    /// Checks if a field has a circular dependency
    /// - Parameters:
    ///   - field: The field to check
    ///   - visited: Set of visited fields
    ///   - path: Current dependency path
    /// - Returns: True if a cycle is detected
    private func hasCycle(_ field: String, visited: inout Set<String>, path: inout [String]) -> Bool {
        // Mark the current field as visited and add to path
        visited.insert(field)
        path.append(field)
        
        // Check all dependencies of this field
        if let dependencies = dependencyGraph[field] {
            for dependency in dependencies {
                if !visited.contains(dependency) {
                    if hasCycle(dependency, visited: &visited, path: &path) {
                        return true
                    }
                } else if path.contains(dependency) {
                    // If the dependency is already in the path, we have a cycle
                    path.append(dependency)
                    return true
                }
            }
        }
        
        // Remove the field from path when backtracking
        path.removeLast()
        return false
    }
    
    /// Invalidates the cache for a specific field and all fields that directly or indirectly depend on it
    /// - Parameter identifier: The identifier of the field to invalidate
    /// - Returns: The number of cache entries that were invalidated
    @discardableResult
    public func invalidateCache(for identifier: String) -> Int {
        return invalidateCache(forFieldIdentifier: identifier)
    }
    
    /// Invalidates the cache for a specific field and all fields that directly or indirectly depend on it
    /// - Parameter identifier: The identifier of the field to invalidate
    /// - Returns: The number of cache entries that were invalidated
    @discardableResult
    public func invalidateCache(forFieldIdentifier identifier: String) -> Int {
        // Track how many cache entries we invalidate
        var invalidatedCount = 0
        
        // If this field has a cached value, remove it
        if formulaCache.removeValue(forKey: identifier) != nil {
            invalidatedCount += 1
        }
        
        // Find all fields that depend on this one (directly or indirectly)
        let dependentFields = findDependentFields(for: identifier)
        
        // Clear the cache entries for all dependent fields
        for field in dependentFields {
            if formulaCache.removeValue(forKey: field) != nil {
                invalidatedCount += 1
            }
        }
        
        return invalidatedCount
    }
    
    /// Invalidates the cache for multiple fields and all their dependents
    /// - Parameter identifiers: The identifiers of the fields to invalidate
    /// - Returns: The number of cache entries that were invalidated
    @discardableResult
    public func invalidateCache(forFieldIdentifiers identifiers: [String]) -> Int {
        // Use a set to avoid duplicate invalidation
        var fieldsToInvalidate = Set(identifiers)
        
        // Add all dependent fields
        for identifier in identifiers {
            fieldsToInvalidate.formUnion(findDependentFields(for: identifier))
        }
        
        // Track invalidation count
        var invalidatedCount = 0
        
        // Clear the cache entries
        for field in fieldsToInvalidate {
            if formulaCache.removeValue(forKey: field) != nil {
                invalidatedCount += 1
            }
        }
        
        return invalidatedCount
    }
    
    /// Finds all fields that directly or indirectly depend on the specified field
    /// - Parameter identifier: The field identifier to find dependents for
    /// - Returns: A set of field identifiers that depend on the specified field
    private func findDependentFields(for identifier: String) -> Set<String> {
        var result = Set<String>()
        
        // Helper function for DFS traversal
        func findDependents(of field: String, visited: inout Set<String>) {
            // Mark as visited
            visited.insert(field)
            
            // For each field in the dependency graph
            for (dependentField, dependencies) in dependencyGraph {
                // If this field depends on our target and we haven't visited it yet
                if dependencies.contains(field) && !visited.contains(dependentField) {
                    // Add to result
                    result.insert(dependentField)
                    // Recursively find fields that depend on this field
                    findDependents(of: dependentField, visited: &visited)
                }
            }
        }
        
        // Start DFS
        var visited = Set<String>()
        findDependents(of: identifier, visited: &visited)
        
        return result
    }
    
    /// Invalidates the cache for all fields that depend on fields with the specified identifiers
    /// - Parameter joyDocIdentifiers: The identifiers of the JoyDoc fields that were modified
    /// - Returns: The number of cache entries that were invalidated
    @discardableResult
    public func invalidateCacheForModifiedFields(_ joyDocIdentifiers: [String]) -> Int {
        return invalidateCache(forFieldIdentifiers: joyDocIdentifiers)
    }
    
    /// Updates all formula fields that depend on the specified field
    /// - Parameter identifier: The identifier of the field that was updated
    /// - Returns: The number of fields that were updated
    @discardableResult
    public func updateDependentFormulas(forFieldIdentifier identifier: String) -> Int {
        // First invalidate the cache for the changed field
        invalidateCache(for: identifier)
        
        // Find all fields that depend on this field
        let dependentFields = findDependentFields(for: identifier)
        
        // If no dependent fields, return early
        if dependentFields.isEmpty {
            return 0
        }
        
        // Sort dependent fields to ensure proper evaluation order
        let sortedDependentFields = topologicalSortFieldIdentifiers(Array(dependentFields))
        
        var updatedCount = 0
        
        // Evaluate each dependent field
        for fieldId in sortedDependentFields {
            if let field = docProvider.field(for: fieldId), let formulaInfo = getFormulaForField(field) {
                // Parse and evaluate the formula
                let parseResult = parser.parse(formula: formulaInfo.formulaString)
                
                switch parseResult {
                case .success(let ast):
                    let result = evaluator.evaluate(node: ast, context: self)
                    
                    if case .success(let value) = result {
                        // Cache the result
                        formulaCache[fieldId] = value
                        
                        // Update the field value in the document
                        updateFieldWithFormulaResult(identifier: fieldId, value: value, key: formulaInfo.key)
                        updatedCount += 1
                    }
                    
                case .failure(let error):
                    print("Error evaluating formula for field \(fieldId): \(error)")
                }
            }
        }
        
        return updatedCount
    }
    
    /// Updates all formula fields that depend on the specified fields
    /// - Parameter identifiers: The identifiers of the fields that were updated
    /// - Returns: The number of fields that were updated
    @discardableResult
    public func updateDependentFormulas(forFieldIdentifiers identifiers: [String]) -> Int {
        // Collect all dependent fields for all identifiers
        var allDependentFields = Set<String>()
        
        for identifier in identifiers {
            // Invalidate cache for the current field
            invalidateCache(for: identifier)
            
            // Add its dependents to the set
            allDependentFields.formUnion(findDependentFields(for: identifier))
        }
        
        // If no dependent fields, return early
        if allDependentFields.isEmpty {
            return 0
        }
        
        // Sort dependent fields to ensure proper evaluation order
        let sortedDependentFields = topologicalSortFieldIdentifiers(Array(allDependentFields))
        
        var updatedCount = 0
        
        // Evaluate each dependent field
        for fieldId in sortedDependentFields {
            if let field = docProvider.field(for: fieldId), let formulaInfo = getFormulaForField(field) {
                // Parse and evaluate the formula
                let parseResult = parser.parse(formula: formulaInfo.formulaString)
                
                switch parseResult {
                case .success(let ast):
                    let result = evaluator.evaluate(node: ast, context: self)
                    
                    if case .success(let value) = result {
                        // Cache the result
                        formulaCache[fieldId] = value
                        
                        // Update the field value in the document
                        updateFieldWithFormulaResult(identifier: fieldId, value: value, key: formulaInfo.key)
                        updatedCount += 1
                    }
                    
                case .failure(let error):
                    print("Error evaluating formula for field \(fieldId): \(error)")
                }
            }
        }
        
        return updatedCount
    }
    
    /// Performs a topological sort on field identifiers based on their dependencies
    /// - Parameter identifiers: Array of field identifiers to sort
    /// - Returns: Sorted array of identifiers
    private func topologicalSortFieldIdentifiers(_ identifiers: [String]) -> [String] {
        var result: [String] = []
        var visited: Set<String> = []
        var temporaryMarks: Set<String> = []
        
        // Helper function for depth-first search
        func visit(_ identifier: String) {
            // Skip if already visited
            if visited.contains(identifier) {
                return
            }
            
            // Check for circular dependency
            if temporaryMarks.contains(identifier) {
                // Handle circular dependency by skipping
                print("Warning: Circular dependency detected for field \(identifier)")
                return
            }
            
            // Mark node as temporary visited
            temporaryMarks.insert(identifier)
            
            // Visit all dependencies first
            if let dependencies = dependencyGraph[identifier] {
                for dependency in dependencies {
                    if identifiers.contains(dependency) {
                        visit(dependency)
                    }
                }
            }
            
            // Mark as visited and add to result
            temporaryMarks.remove(identifier)
            visited.insert(identifier)
            result.append(identifier)
        }
        
        // Perform topological sort
        for identifier in identifiers {
            if !visited.contains(identifier) {
                visit(identifier)
            }
        }
        
        return result
    }
    
    /// Evaluates all formula fields and updates their values
    public func evaluateAllFormulas() {
        print("🚀 evaluateAllFormulas started")
        
        // Get all formula fields
        let formulaFields = docProvider.allFormulsFields()
        print("🚀 Found \(formulaFields.count) formula fields")
        
        // Debug: List all formula fields
        for field in formulaFields {
            print("🚀 Formula field found: \(field.identifier ?? "no identifier") with formulas: \(field.formulas?.count ?? 0)")
        }
        
        // Create a topologically sorted list of fields based on dependencies
        let sortedFields = topologicalSortFormulaFields(formulaFields)
        
        // Evaluate each field in dependency order
        for field in sortedFields {
            if let identifier = field.identifier, let formulaInfo = getFormulaForField(field) {
                print("🚀 Evaluating formula for field \(identifier): \(formulaInfo.formulaString)")
                
                // Evaluate the formula
                let parseResult = parser.parse(formula: formulaInfo.formulaString)
                
                switch parseResult {
                case .success(let ast):
                    let result = evaluator.evaluate(node: ast, context: self)
                    
                    if case .success(let value) = result {
                        print("🚀 Formula evaluation successful for \(identifier): \(value)")
                        // Cache the result
                        formulaCache[identifier] = value
                        
                        // Update the field's value in the document
                        updateFieldWithFormulaResult(identifier: identifier, value: value, key: formulaInfo.key)
                    } else {
                        print("🚀 Formula evaluation failed for \(identifier): \(result)")
                    }
                    
                case .failure(let error):
                    print("Error evaluating formula for field \(identifier): \(error)")
                }
            }
        }
        
        print("🚀 evaluateAllFormulas completed")
    }
    
    /// Creates a topologically sorted list of formula fields based on their dependencies
    /// - Parameter fields: The list of formula fields to sort
    /// - Returns: A list of fields ordered so that dependencies are evaluated before dependent fields
    private func topologicalSortFormulaFields(_ fields: [JoyDocField]) -> [JoyDocField] {
        var result: [JoyDocField] = []
        var visited: Set<String> = []
        var temporaryMarks: Set<String> = []
        
        // Create a map of identifiers to fields for easy lookup
        var fieldMap: [String: JoyDocField] = [:]
        for field in fields {
            if let identifier = field.identifier {
                fieldMap[identifier] = field
            }
        }
        
        // Helper function for depth-first search
        func visit(_ identifier: String) {
            // Skip if already visited
            if visited.contains(identifier) {
                return
            }
            
            // Check for circular dependency
            if temporaryMarks.contains(identifier) {
                // Handle circular dependency by skipping
                print("Warning: Circular dependency detected for field \(identifier)")
                return
            }
            
            // Mark node as temporary visited
            temporaryMarks.insert(identifier)
            
            // Visit all dependencies first
            if let dependencies = dependencyGraph[identifier] {
                for dependency in dependencies {
                    visit(dependency)
                }
            }
            
            // Mark as visited and add to result
            temporaryMarks.remove(identifier)
            visited.insert(identifier)
            
            // Add the field to the result if it exists
            if let field = fieldMap[identifier] {
                result.append(field)
            }
        }
        
        // Perform topological sort
        for field in fields {
            if let identifier = field.identifier, !visited.contains(identifier) {
                visit(identifier)
            }
        }
        
        return result
    }
    
    /// Updates a field's value based on a formula evaluation result
    /// - Parameters:
    ///   - identifier: The field identifier
    ///   - value: The formula result value
    ///   - key: The field property to update (e.g., "value", "hidden", etc.)
    private func updateFieldWithFormulaResult(identifier: String, value: FormulaValue, key: String = "value") {
        print("🔧 updateFieldWithFormulaResult called for \(identifier) with value: \(value) and key: \(key)")
        
        // Convert FormulaValue to ValueUnion
        let valueUnion = convertFormulaValueToValueUnion(value)
        print("🔧 Converted to ValueUnion: \(valueUnion)")
        
        // Update the field value in the document
        // Note: Currently this only handles the "value" property
        // In the future, this would need to be extended to handle other properties like "hidden", "valid", etc.
        if key == "value" {
            print("🔧 Calling docProvider.updateValue for \(identifier)")
            docProvider.updateValue(for: identifier, value: valueUnion)
        } else if (key == "hidden") {
            docProvider.setFieldHidden(value.boolValue, for: identifier)
        } else {
            // TODO: Handle other field properties like hidden, valid, etc.
            print("Warning: Updating field property '\(key)' not implemented yet")
        }
    }
    
    /// Converts a FormulaValue to a ValueUnion
    /// - Parameter value: The FormulaValue to convert
    /// - Returns: A ValueUnion representation of the value
    private func convertFormulaValueToValueUnion(_ value: FormulaValue) -> ValueUnion {
        switch value {
        case .number(let number):
            // Check if it's an integer
            if number.truncatingRemainder(dividingBy: 1) == 0 && number <= Double(Int64.max) && number >= Double(Int64.min) {
                return .int(Int64(number))
            } else {
                return .double(number)
            }
        case .string(let string):
            return .string(string)
        case .boolean(let bool):
            return .bool(bool)
        case .array(let array):
            // For arrays, we want to create a string representation that tests can use
            let stringRepresentation = arrayToString(array)
            return .string(stringRepresentation)
        case .dictionary(let dict):
            var result: [String: ValueUnion] = [:]
            for (key, value) in dict {
                result[key] = convertFormulaValueToValueUnion(value)
            }
            return .dictionary(result)
        case .null:
            return .null
        case .date(let date):
            // Convert Date to timestamp in milliseconds
            let timestamp = date.timeIntervalSince1970 * 1000.0
            return .double(timestamp)
        case .error:
            // For error values, return null
            return .null
        case .lambda(_, _):
            // For lambda values, return null (can't be represented in ValueUnion)
            return .null
        }
    }
    
    /// Converts a FormulaValue array to a readable string representation
    /// - Parameter array: The array of FormulaValue to convert
    /// - Returns: A string representation of the array
    private func arrayToString(_ array: [FormulaValue]) -> String {
        let stringElements = array.map { value -> String in
            switch value {
            case .string(let str):
                return str
            case .number(let num):
                // Format numbers without unnecessary decimal places
                if num.truncatingRemainder(dividingBy: 1) == 0 {
                    return String(Int(num))
                } else {
                    return String(num)
                }
            case .boolean(let bool):
                return bool ? "true" : "false"
            case .array(let nestedArray):
                return "[\(arrayToString(nestedArray))]"
            case .dictionary(let dict):
                let dictString = dict.map { key, value in
                    return "\(key): \(formulaValueToString(value))"
                }.joined(separator: ", ")
                return "{\(dictString)}"
            case .null:
                return "null"
            case .date(let date):
                return String(date.timeIntervalSince1970 * 1000.0)
            case .error:
                return "error"
            case .lambda(_, _):
                return "lambda"
            }
        }
        return "[\(stringElements.joined(separator: ", "))]"
    }
    
    /// Converts a single FormulaValue to its string representation
    /// - Parameter value: The FormulaValue to convert
    /// - Returns: String representation of the value
    private func formulaValueToString(_ value: FormulaValue) -> String {
        switch value {
        case .string(let str):
            return str
        case .number(let num):
            if num.truncatingRemainder(dividingBy: 1) == 0 {
                return String(Int(num))
            } else {
                return String(num)
            }
        case .boolean(let bool):
            return bool ? "true" : "false"
        case .array(let array):
            return arrayToString(array)
        case .dictionary(let dict):
            let dictString = dict.map { key, value in
                return "\(key): \(formulaValueToString(value))"
            }.joined(separator: ", ")
            return "{\(dictString)}"
        case .null:
            return "null"
        case .date(let date):
            return String(date.timeIntervalSince1970 * 1000.0)
        case .error:
            return "error"
        case .lambda(_, _):
            return "lambda"
        }
    }
}

/// A lightweight context wrapper that adds temporary variables without triggering expensive initialization
/// This prevents infinite recursion when array functions like find() need to create new contexts
private class TemporaryVariableContext: EvaluationContext {
    private let baseContext: JoyfillDocContext
    private let additionalVariables: [String: FormulaValue]
    
    init(baseContext: JoyfillDocContext, additionalVariables: [String: FormulaValue]) {
        self.baseContext = baseContext
        self.additionalVariables = additionalVariables
    }
    
    func resolveReference(_ name: String) -> Result<FormulaValue, FormulaError> {
        // First check additional variables (temporary lambda parameters)
        let cleanName = name.hasPrefix("{") && name.hasSuffix("}") 
                       ? String(name.dropFirst().dropLast()) 
                       : name
        
        if let value = additionalVariables[cleanName] {
            return .success(value)
        }
        
        // Also check the original name in case it has braces
        if let value = additionalVariables[name] {
            return .success(value)
        }
        
        // Delegate to base context for all other references
        return baseContext.resolveReference(name)
    }
    
    func contextByAdding(variable name: String, value: FormulaValue) -> EvaluationContext {
        // Create a new lightweight context with the additional variable
        var newVariables = self.additionalVariables
        
        let cleanName = name.hasPrefix("{") && name.hasSuffix("}") 
                       ? String(name.dropFirst().dropLast()) 
                       : name
        
        newVariables[cleanName] = value
        
        return TemporaryVariableContext(
            baseContext: self.baseContext,
            additionalVariables: newVariables
        )
    }
} 
