//import Foundation
//import JoyfillModel
//import JoyfillFormulas
//
///// Example showing how to use the JoyfillDocContext to resolve references in formulas
//class FormulaEvaluationExample {
//    
//    /// Evaluates a formula using a JoyDoc as the context
//    /// - Parameters:
//    ///   - formula: Formula string to evaluate
//    ///   - joyDoc: JoyDoc instance to use for reference resolution
//    /// - Returns: The result of formula evaluation as a FormulaValue
//    func evaluateFormula(formula: String, joyDoc: JoyDoc) -> Result<FormulaValue, FormulaError> {
//        // Create parser and evaluator
//        let parser = Parser()
//        let evaluator = Evaluator()
//        
//        // Create context with the JoyDoc
//        let context = JoyfillDocContext(joyDoc: joyDoc)
//        
//        // Parse formula into AST
//        let parseResult = parser.parse(formula: formula)
//        
//        switch parseResult {
//        case .success(let ast):
//            // Evaluate the AST using the JoyDoc context
//            return evaluator.evaluate(node: ast, context: context)
//            
//        case .failure(let error):
//            return .failure(error)
//        }
//    }
//    
//    /// Demonstrates formula evaluation with JoyDoc reference resolution
//    func runExamples() {
//        // Create a sample JoyDoc
//        let joyDoc = createSampleJoyDoc()
//        
//        // Example 1: Simple Field Reference
//        print("Example 1: Simple Field Reference")
//        let formula1 = "\"Hello, \" + {firstName}"
//        printResult(evaluateFormula(formula: formula1, joyDoc: joyDoc), formula: formula1)
//        
//        // Example 2: Arithmetic with Field References
//        print("\nExample 2: Arithmetic with Field References")
//        let formula2 = "{quantity} * {price}"
//        printResult(evaluateFormula(formula: formula2, joyDoc: joyDoc), formula: formula2)
//        
//        // Example 3: Using a collection reference in MAP function
//        print("\nExample 3: Using a collection reference in MAP function")
//        let formula3 = "MAP({employees}, \"emp\", {emp.salary} * 1.1)"
//        printResult(evaluateFormula(formula: formula3, joyDoc: joyDoc), formula: formula3)
//        
//        // Example 4: Using FILTER with collection
//        print("\nExample 4: Using FILTER with collection")
//        let formula4 = "FILTER({employees}, \"emp\", {emp.salary} > 80000)"
//        printResult(evaluateFormula(formula: formula4, joyDoc: joyDoc), formula: formula4)
//        
//        // Example 5: Using column reference
//        print("\nExample 5: Using column reference")
//        let formula5 = "SUM({employees.salary})"
//        printResult(evaluateFormula(formula: formula5, joyDoc: joyDoc), formula: formula5)
//    }
//    
//    /// Helper to print formula result
//    private func printResult(_ result: Result<FormulaValue, FormulaError>, formula: String) {
//        print("Formula: \(formula)")
//        switch result {
//        case .success(let value):
//            print("Result: \(value)")
//        case .failure(let error):
//            print("Error: \(error)")
//        }
//    }
//    
//    /// Creates a sample JoyDoc for testing
//    private func createSampleJoyDoc() -> JoyDoc {
//        let joyDoc = JoyDoc(dictionary: [:])
//        
//        // Add text fields
//        var firstNameField = JoyDocField(field: [:])
//        firstNameField.fieldType = .text
//        firstNameField.identifier = "firstName"
//        firstNameField.value = ValueUnion(value: "John")
//        
//        var lastNameField = JoyDocField(field: [:])
//        lastNameField.fieldType = .text
//        lastNameField.identifier = "lastName"
//        lastNameField.value = ValueUnion(value: "Doe")
//        
//        // Add number fields
//        var quantityField = JoyDocField(field: [:])
//        quantityField.fieldType = .number
//        quantityField.identifier = "quantity"
//        quantityField.value = ValueUnion(value: 5.0)
//        
//        var priceField = JoyDocField(field: [:])
//        priceField.fieldType = .number
//        priceField.identifier = "price"
//        priceField.value = ValueUnion(value: 19.99)
//        
//        // Create a collection field for employees
//        var employeesField = JoyDocField(field: [:])
//        employeesField.fieldType = .collection
//        employeesField.identifier = "employees"
//        
//        // Create employees
//        var employee1 = ValueElement()
//        employee1.cells = [
//            "name": ValueUnion(value: "Alice Smith"),
//            "department": ValueUnion(value: "Engineering"),
//            "salary": ValueUnion(value: 85000.0)
//        ]
//        
//        var employee2 = ValueElement()
//        employee2.cells = [
//            "name": ValueUnion(value: "Bob Johnson"),
//            "department": ValueUnion(value: "Marketing"),
//            "salary": ValueUnion(value: 75000.0)
//        ]
//        
//        var employee3 = ValueElement()
//        employee3.cells = [
//            "name": ValueUnion(value: "Carol Williams"),
//            "department": ValueUnion(value: "Engineering"),
//            "salary": ValueUnion(value: 90000.0)
//        ]
//        
//        employeesField.value = ValueUnion(value: [employee1, employee2, employee3])
//        
//        // Add fields to JoyDoc
//        joyDoc.fields = [firstNameField, lastNameField, quantityField, priceField, employeesField]
//        
//        return joyDoc
//    }
//}
//
//// Sample usage:
//// let example = FormulaEvaluationExample()
//// example.runExamples() 
