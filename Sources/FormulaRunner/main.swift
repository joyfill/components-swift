import Foundation
import JoyfillFormulas
import JoyfillModel
import Examples

print("Joyfill Formula Runner")
print("=====================")
print(Examples.getDescription())
print("\nSample Formula Examples:")

// Create evaluator components
let parser = Parser()
let evaluator = Evaluator()

// Create a simple evaluation context
class SimpleContext: EvaluationContext {
    func resolveReference(_ name: String) -> Result<FormulaValue, FormulaError> {
        // Just return null for all references in this simple example
        return .success(.null)
    }
    
    func contextByAdding(variable name: String, value: FormulaValue) -> EvaluationContext {
        // Return self as this is a simple example
        return self
    }
}

let context = SimpleContext()

// Loop through and evaluate each sample formula
for (name, formula) in Examples.sampleFormulas {
    print("\n\(name): \"\(formula)\"")
    
    // Parse the formula
    let parseResult = parser.parse(formula: formula)
    
    switch parseResult {
    case .success(let ast):
        // Evaluate the formula
        let result = evaluator.evaluate(node: ast, context: context)
        
        // Print the result
        switch result {
        case .success(let value):
            print("  Result: \(value)")
        case .failure(let error):
            print("  Evaluation Error: \(error)")
        }
        
    case .failure(let error):
        print("  Parse Error: \(error)")
    }
}

print("\nFormula evaluation complete!")

// If you want to add command-line formula evaluation later, 
// you can parse arguments here and use the Evaluator.
// For example:
// if CommandLine.arguments.count > 1 {
//     let formula = CommandLine.arguments[1]
//     // ... setup resolver, evaluator ...
//     // let result = try evaluator.evaluate(formula)
//     // print("Result: \(result)")
// } else {
//     print("Usage: FormulaRunner \"<formula_string>\"")
// } 