import Foundation
import JoyfillModel
import JoyfillFormulas

/// Protocol that provides access to JoyDoc data without direct dependency
public protocol JoyDocProvider {
    func field(for identifier: String) -> JoyDocField?
    func allFormulsFields() -> [JoyDocField]
    func updateValue(for identifier: String, value: ValueUnion)
}

/// Application-level implementation of EvaluationContext that resolves references against a JoyDoc
/// This implementation handles the requirements outlined in the Reference Resolution PRD.
public class JoyfillDocContext: EvaluationContext {
    private let docProvider: JoyDocProvider
    private var temporaryVariables: [String: FormulaValue] = [:]
    
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
    /// - Parameter name: Reference string (e.g., "{fieldIdentifier}" or "{fieldName.index.columnName}")
    /// - Returns: Result containing the resolved FormulaValue or an error
    public func resolveReference(_ name: String) -> Result<FormulaValue, FormulaError> {
        // First check for temporary/shadowing variables (for MAP, FILTER, etc.)
        if let tempVar = resolveTemporaryVariable(name) {
            return .success(tempVar)
        }
        
        // Check if name is in proper reference format with braces
        guard name.hasPrefix("{") && name.hasSuffix("}") else {
            return .failure(.invalidReference("Reference must be enclosed in curly braces: \(name)"))
        }
        
        // Strip braces for processing
        let reference = String(name.dropFirst().dropLast())
        
        // Split by dots to handle path components
        let pathComponents = reference.split(separator: ".")
        
        // Simple field reference: {fieldIdentifier}
        if pathComponents.count == 1 {
            return resolveSimpleFieldReference(String(pathComponents[0]))
        } else {
            // Complex reference with path: {fieldName.schemaId}, {fieldName.index.columnName}, etc.
            return resolveComplexFieldReference(pathComponents.map(String.init))
        }
    }
    
    /// Creates a new context with added temporary variable
    /// - Parameters:
    ///   - name: Variable name
    ///   - value: Variable value
    /// - Returns: A new context with the variable added
    public func contextByAdding(variable name: String, value: FormulaValue) -> EvaluationContext {
        let newContext = JoyfillDocContext(docProvider: self.docProvider)
        
        // Copy existing temp variables
        newContext.temporaryVariables = self.temporaryVariables
        
        // Add new variable (overriding if it exists)
        // Ensure variable name doesn't have braces
        let cleanName = name.hasPrefix("{") && name.hasSuffix("}") 
                        ? String(name.dropFirst().dropLast()) 
                        : name
                        
        newContext.temporaryVariables[cleanName] = value
        
        return newContext
    }
    
    // MARK: - Private Helper Methods
    
    private func resolveTemporaryVariable(_ name: String) -> FormulaValue? {
        // Check if name has braces
        let key = name.hasPrefix("{") && name.hasSuffix("}") 
                  ? String(name.dropFirst().dropLast()) 
                  : name
        
        return temporaryVariables[key]
    }
    
    private func resolveSimpleFieldReference(_ identifier: String) -> Result<FormulaValue, FormulaError> {
        // Search the fields for a matching identifier
        guard let field = docProvider.field(for: identifier) else {
            return .failure(.invalidReference("Field with identifier '\(identifier)' not found"))
        }
        
        // Check if it's a formula field
        if let formula = field.formula {
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
            let parseResult = parser.parse(formula: formula)
            
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
        let fieldIdentifier = pathComponents[0]
        
        guard let field = docProvider.field(for: fieldIdentifier) else {
            return .failure(.invalidReference("Field with identifier '\(fieldIdentifier)' not found"))
        }
        
        // If we're dealing with a collection/table field
        if field.fieldType == JoyfillModel.FieldTypes.table {
            // Handle collection-specific reference patterns
            return resolveCollectionReference(field, pathComponents: Array(pathComponents.dropFirst()))
        }
        
        // For other field types with complex paths (not detailed in the PRD)
        return .failure(.invalidReference("Complex path resolution not supported for field type \(field.fieldType)"))
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
        if pathComponents.count == 1 {
            // Get all values from this column: {fieldName.columnName}
            var columnValues: [FormulaValue] = []
            
            for element in valueElements {
                if let cells = element.cells,
                   let cellValue = cells[possibleColumnName] {
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
            return .number(doubleVal)
        case .int(let intVal):
            return .number(Double(intVal))
        case .string(let stringVal):
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
        }
    }
    
    // MARK: - Formula Dependency Methods
    
    /// Builds a dependency graph for formula fields
    private func buildDependencyGraph() {
        // Get all formula fields
        let formulaFields = docProvider.allFormulsFields()
        
        for field in formulaFields {
            if let identifier = field.identifier, let formula = field.formula {
                // Extract references from the formula
                let dependencies = extractReferences(from: formula)
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
            // Extract field identifier from the reference (remove braces)
            if name.hasPrefix("{") && name.hasSuffix("}") {
                let identifier = String(name.dropFirst().dropLast()).split(separator: ".").first.map(String.init) ?? ""
                if !identifier.isEmpty {
                    references.append(identifier)
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
            
        case .arrayLiteral(let elements):
            for element in elements {
                extractReferencesFromNode(element, references: &references)
            }
            
        case .literal:
            // Literals don't contain references
            break
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
    
    /// Clears the formula cache
    public func clearFormulaCache() {
        formulaCache.removeAll()
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
            if let field = docProvider.field(for: fieldId), let formula = field.formula {
                // Parse and evaluate the formula
                let parseResult = parser.parse(formula: formula)
                
                switch parseResult {
                case .success(let ast):
                    let result = evaluator.evaluate(node: ast, context: self)
                    
                    if case .success(let value) = result {
                        // Cache the result
                        formulaCache[fieldId] = value
                        
                        // Update the field value in the document
                        updateFieldWithFormulaResult(identifier: fieldId, value: value)
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
            if let field = docProvider.field(for: fieldId), let formula = field.formula {
                // Parse and evaluate the formula
                let parseResult = parser.parse(formula: formula)
                
                switch parseResult {
                case .success(let ast):
                    let result = evaluator.evaluate(node: ast, context: self)
                    
                    if case .success(let value) = result {
                        // Cache the result
                        formulaCache[fieldId] = value
                        
                        // Update the field value in the document
                        updateFieldWithFormulaResult(identifier: fieldId, value: value)
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
    private func evaluateAllFormulas() {
        // Get all formula fields
        let formulaFields = docProvider.allFormulsFields()
        
        // Create a topologically sorted list of fields based on dependencies
        let sortedFields = topologicalSortFormulaFields(formulaFields)
        
        // Evaluate each field in dependency order
        for field in sortedFields {
            if let identifier = field.identifier, let formula = field.formula {
                // Evaluate the formula
                let parseResult = parser.parse(formula: formula)
                
                switch parseResult {
                case .success(let ast):
                    let result = evaluator.evaluate(node: ast, context: self)
                    
                    if case .success(let value) = result {
                        // Cache the result
                        formulaCache[identifier] = value
                        
                        // Update the field's value in the document
                        updateFieldWithFormulaResult(identifier: identifier, value: value)
                    }
                    
                case .failure(let error):
                    print("Error evaluating formula for field \(identifier): \(error)")
                }
            }
        }
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
    private func updateFieldWithFormulaResult(identifier: String, value: FormulaValue) {
        // Convert FormulaValue to ValueUnion
        let valueUnion = convertFormulaValueToValueUnion(value)
        
        // Update the field value in the document
        docProvider.updateValue(for: identifier, value: valueUnion)
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
            // Handle array of different types
            if array.allSatisfy({ if case .string(_) = $0 { return true } else { return false } }) {
                let strings = array.compactMap { 
                    if case .string(let str) = $0 { return str } else { return nil }
                }
                return .array(strings)
            } else {
                // For mixed arrays, convert to value elements
                let elements = array.map { formulaValue -> ValueElement in
                    if case .dictionary(let dict) = formulaValue {
                        // Convert dictionary to cells
                        var cells: [String: ValueUnion] = [:]
                        for (key, value) in dict {
                            cells[key] = convertFormulaValueToValueUnion(value)
                        }
                        return ValueElement(dictionary: cells)
                    } else {
                        // For non-dictionary values, create a simple element
                        return ValueElement(dictionary: ["value": convertFormulaValueToValueUnion(formulaValue)])
                    }
                }
                return .valueElementArray(elements)
            }
        case .dictionary(let dict):
            var result: [String: ValueUnion] = [:]
            for (key, value) in dict {
                result[key] = convertFormulaValueToValueUnion(value)
            }
            return .dictionary(result)
        case .null:
            return .null
        case .date(let date):
            // Convert Date to string in ISO8601 format
            let formatter = ISO8601DateFormatter()
            return .string(formatter.string(from: date))
        case .error:
            // For error values, return null
            return .null
        }
    }
} 
