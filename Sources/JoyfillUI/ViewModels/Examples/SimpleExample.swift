import Foundation
import JoyfillModel
import JoyfillFormulas

/// A simple example demonstrating JoyfillDocContext for basic field references
public class SimpleReferenceExample {
    
    /// Initialize a new instance
    public init() {
        // Nothing to initialize
    }
    
    /// Run the simple example
    public func run() {
        print("JoyfillDocContext - Simple Reference Example")
        print("===========================================")
        
        // Create a sample JoyDoc
        var joyDoc = JoyDoc(dictionary: [:])
        
        // Add some basic fields
        var nameField = JoyDocField(field: [:])
        nameField.fieldType = .text
        nameField.identifier = "name"
        nameField.value = ValueUnion(value: "John Smith")!
        
        var ageField = JoyDocField(field: [:])
        ageField.fieldType = .number
        ageField.identifier = "age"
        ageField.value = ValueUnion(value: 32.0)!
        
        var salaryField = JoyDocField(field: [:])
        salaryField.fieldType = .number
        salaryField.identifier = "salary"
        salaryField.value = ValueUnion(value: 75000.0)!
        
        // Add fields to JoyDoc
        joyDoc.fields = [nameField, ageField, salaryField]
        
        // Create evaluation context using our JoyfillDocContext
        let context = JoyfillDocContext(joyDoc: joyDoc)
        
        // Create parser and evaluator
        let parser = Parser()
        let evaluator = Evaluator()
        
        // Example 1: Simple field reference
        testFormula(parser: parser, evaluator: evaluator, context: context, 
                    formula: "{name}")
        
        // Example 2: Simple arithmetic with field references
        testFormula(parser: parser, evaluator: evaluator, context: context, 
                    formula: "{salary} / 12")
        
        // Example 3: Complex expression with multiple fields
        testFormula(parser: parser, evaluator: evaluator, context: context, 
                    formula: "{salary} * (1 + 0.1 * ({age} - 30) / 10)")
        
        // Example 4: Text concatenation
        testFormula(parser: parser, evaluator: evaluator, context: context, 
                    formula: "\"Hello, \" + {name}")
        
        // Example 5: Invalid reference
        testFormula(parser: parser, evaluator: evaluator, context: context, 
                    formula: "{nonexistent}")
    }
    
    /// Helper method to test and print formula results
    private func testFormula(parser: Parser, evaluator: Evaluator, context: EvaluationContext, formula: String) {
        print("\nFormula: \(formula)")
        
        // Parse formula
        let parseResult = parser.parse(formula: formula)
        
        switch parseResult {
        case .success(let ast):
            // Evaluate AST with our context
            let evalResult = evaluator.evaluate(node: ast, context: context)
            
            switch evalResult {
            case .success(let value):
                print("Result: \(value)")
                
                // Additional explanation for specific types
                switch value {
                case .number(let num):
                    print("Type: Number - Value: \(num)")
                case .string(let str):
                    print("Type: String - Value: \"\(str)\"")
                case .boolean(let bool):
                    print("Type: Boolean - Value: \(bool)")
                case .array(let arr):
                    print("Type: Array - Count: \(arr.count)")
                case .dictionary(let dict):
                    print("Type: Dictionary - Keys: \(dict.keys.joined(separator: ", "))")
                case .null:
                    print("Type: Null")
                case .date(let date):
                    print("Type: Date - Value: \(date)")
                case .error(let err):
                    print("Type: Error - Value: \(err)")
                }
                
            case .failure(let error):
                print("Evaluation Error: \(error)")
            }
            
        case .failure(let error):
            print("Parse Error: \(error)")
        }
    }
} 