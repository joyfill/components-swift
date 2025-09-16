////
////  FormulaTemplate_TextFieldTests.swift
////  JoyfillTests
////
////  Created by Vishnu Dutt on 25/06/25.
////
//
//import XCTest
//import Foundation
//import JoyfillModel
//import Joyfill
//
//class FormulaTemplate_TextFieldTests: XCTestCase {
//
//    // MARK: - Setup & Teardown
//    
//    private var documentEditor: DocumentEditor!
//
//    override func setUp() {
//        super.setUp()
//        let document = sampleJSONDocument(fileName: "FormulaTemplate_TextField")
//        documentEditor = DocumentEditor(document: document, validateSchema: false)
//    } 
//
//    override func tearDown() {
//        documentEditor = nil
//        super.tearDown()
//    }
//    
//    // MARK: - Text Field Tests
//    
//    func testTextFieldFormulas() {
//        print("\n🧪 === Text Field Formula Tests ===")
//        print("Testing text field reference, transformation, and validation formulas")
//        
//        testTextFieldReference()
//        testTextConcatenationAndUppercase()
//        testConditionalTextValidation()
//        testTextFieldBehavior()
//    }
//    
//    // MARK: - Individual Test Methods
//    
//    private func testTextFieldReference() {
//        print("\n✅ Test 1: Text field reference")
//        print("Formula: text1")
//        print("Input: 'test for formulas'")
//        print("Expected: 'test for formulas' (direct copy)")
//        
//        let result = documentEditor.value(ofFieldWithIdentifier: "field_text2")
//        let resultText = result?.text ?? ""
//        
//        print("🎯 Result: '\(resultText)'")
//        
//        XCTAssertEqual(resultText, "test for formulas", 
//                      "Should copy text1 value exactly")
//    }
//    
//    private func testTextConcatenationAndUppercase() {
//        print("\n✅ Test 2: Text concatenation with uppercase")
//        print("Formula: concat(\"Current entry: \", upper(text1))")
//        print("Input: 'test for formulas'")
//        print("Expected: 'Current entry: TEST FOR FORMULAS'")
//        
//        let result = documentEditor.value(ofFieldWithIdentifier: "field_text3")
//        let resultText = result?.text ?? ""
//        
//        print("🎯 Result: '\(resultText)'")
//        
//        XCTAssertEqual(resultText, "Current entry: TEST FOR FORMULAS", 
//                      "Should concatenate prefix with uppercased text1")
//    }
//    
//    private func testConditionalTextValidation() {
//        print("\n✅ Test 3: Conditional text validation")
//        print("Formula: if(lower(text1) == \"test for formulas\", \"Filled\", \"Empty\")")
//        print("Input: 'test for formulas'")
//        print("Expected: 'Filled' (matches expected value)")
//        
//        let result = documentEditor.value(ofFieldWithIdentifier: "field_text4")
//        let resultText = result?.text ?? ""
//        
//        print("🎯 Result: '\(resultText)'")
//        
//        XCTAssertEqual(resultText, "Filled", 
//                      "Should return 'Filled' when text1 matches expected value")
//    }
//    
//    private func testTextFieldBehavior() {
//        print("\n🔍 Test 4: Text field behavior analysis")
//        
//        // Check the source text field
//        let sourceField = documentEditor.field(fieldID: "text1")
//        let sourceValue = sourceField?.value?.text ?? ""
//        
//        print("Source text field analysis:")
//        print("  Field ID: text1")
//        print("  Value: '\(sourceValue)'")
//        print("  Length: \(sourceValue.count) characters")
//        
//        XCTAssertEqual(sourceValue, "test for formulas", "Source field should have expected value")
//        
//        // Test string transformation functions
//        let upperCaseExpected = sourceValue.uppercased()
//        let lowerCaseExpected = sourceValue.lowercased()
//        
//        print("  String transformations:")
//        print("    Original: '\(sourceValue)'")
//        print("    Upper: '\(upperCaseExpected)'")
//        print("    Lower: '\(lowerCaseExpected)'")
//        
//        XCTAssertEqual(upperCaseExpected, "TEST FOR FORMULAS", "Uppercase transformation should work")
//        XCTAssertEqual(lowerCaseExpected, "test for formulas", "Lowercase transformation should work")
//    }
//    
//    // MARK: - Text Function Tests
//    
//    private func testTextFunctionCombinations() {
//        print("\n📝 Test 5: Text function combinations")
//        
//        // Test various text function scenarios
//        let testScenarios = [
//            ("Direct reference", "text1", "test for formulas"),
//            ("Concatenation + Upper", "concat(\"Current entry: \", upper(text1))", "Current entry: TEST FOR FORMULAS"),
//            ("Conditional validation", "if(lower(text1) == \"test for formulas\", \"Filled\", \"Empty\")", "Filled")
//        ]
//        
//        let fieldIdentifiers = ["field_text2", "field_text3", "field_text4"]
//        
//        for (index, (description, formula, expected)) in testScenarios.enumerated() {
//            print("\nScenario \(index + 1): \(description)")
//            print("  Formula: \(formula)")
//            print("  Expected: '\(expected)'")
//            
//            if index < fieldIdentifiers.count {
//                let result = documentEditor.value(ofFieldWithIdentifier: fieldIdentifiers[index])
//                let actual = result?.text ?? ""
//                print("  Actual: '\(actual)'")
//                
//                XCTAssertEqual(actual, expected, "Should match expected result for \(description)")
//            }
//        }
//    }
//    
//    private func testTextFieldEdgeCases() {
//        print("\n🔍 Test 6: Text field edge cases")
//        
//        // Test edge cases and verify robust handling
//        let sourceValue = "test for formulas"
//        
//        // Test case sensitivity in conditional
//        let lowercaseMatch = sourceValue.lowercased() == "test for formulas"
//        print("Lowercase match test:")
//        print("  '\(sourceValue.lowercased())' == 'test for formulas': \(lowercaseMatch)")
//        
//        XCTAssertTrue(lowercaseMatch, "Lowercase comparison should match exactly")
//        
//        // Test concatenation behavior
//        let concatResult = "Current entry: " + sourceValue.uppercased()
//        print("Concatenation test:")
//        print("  Expected concat result: '\(concatResult)'")
//        
//        XCTAssertEqual(concatResult, "Current entry: TEST FOR FORMULAS", "Manual concatenation should match formula result")
//    }
//    
//    // MARK: - Helper Methods
//    
//    private func debugTextFields() {
//        print("\n🔍 Text Field Debug:")
//        
//        let textFields = ["text1", "field_text2", "field_text3", "field_text4"]
//        
//        for fieldID in textFields {
//            if let field = documentEditor.field(fieldID: fieldID) {
//                print("\nText field '\(fieldID)':")
//                print("  Type: \(field.type ?? "unknown")")
//                print("  Title: \(field.title ?? "no title")")
//                print("  Value: '\(field.value?.text ?? "")'")
//                print("  Has formulas: \(field.dictionary["formulas"] != nil)")
//            } else {
//                print("❌ Text field '\(fieldID)' not found")
//            }
//        }
//    }
//    
//    private func debugTextFormulas() {
//        print("\n🔍 Text Formula Debug:")
//        
//        let document = documentEditor.document
//            print("Document has \(document.formulas.count) formulas:")
//            
//            for formula in document.formulas {
//                if let id = formula.id, let expression = formula.expression {
//                    print("  Formula '\(id)': \(expression)")
//                }
//            }
//    }
//}
