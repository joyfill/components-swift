////
////  FormulaTemplate_BlockFieldTests.swift
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
//class FormulaTemplate_BlockFieldTests: XCTestCase {
//
//    // MARK: - Setup & Teardown
//    
//    private var documentEditor: DocumentEditor!
//
//    override func setUp() {
//        super.setUp()
//        let document = sampleJSONDocument(fileName: "FormulaTemplate_BlockField")
//        documentEditor = DocumentEditor(document: document, validateSchema: false)
//    } 
//
//    override func tearDown() {
//        documentEditor = nil
//        super.tearDown()
//    }
//    
//    // MARK: - Block Field Tests
//    
//    func testBlockFieldFormulas() {
//        print("\n🧪 === Block Field Formula Tests ===")
//        print("Testing block field reference, transformation, and validation formulas")
//        
//        testBlockFieldReference()
//        testBlockConcatenationAndUppercase()
//        testConditionalBlockValidation()
//        testBlockFieldBehavior()
//    }
//    
//    // MARK: - Individual Test Methods
//    
//    private func testBlockFieldReference() {
//        print("\n✅ Test 1: Block field reference")
//        print("Formula: block1")
//        print("Input: 'test for formulas' (from block field)")
//        print("Expected: 'test for formulas' (direct copy)")
//        
//        let result = documentEditor.value(ofFieldWithIdentifier: "field_text2")
//        let resultText = result?.text ?? ""
//        
//        print("🎯 Result: '\(resultText)'")
//        
//        XCTAssertEqual(resultText, "test for formulas", 
//                      "Should copy block1 value exactly")
//    }
//    
//    private func testBlockConcatenationAndUppercase() {
//        print("\n✅ Test 2: Block concatenation with uppercase")
//        print("Formula: concat(\"Current entry: \", upper(block1))")
//        print("Input: 'test for formulas' (from block field)")
//        print("Expected: 'Current entry: TEST FOR FORMULAS'")
//        
//        let result = documentEditor.value(ofFieldWithIdentifier: "field_text3")
//        let resultText = result?.text ?? ""
//        
//        print("🎯 Result: '\(resultText)'")
//        
//        XCTAssertEqual(resultText, "Current entry: TEST FOR FORMULAS", 
//                      "Should concatenate prefix with uppercased block1")
//    }
//    
//    private func testConditionalBlockValidation() {
//        print("\n✅ Test 3: Conditional block validation")
//        print("Formula: if(lower(block1) == \"test for formulas\", \"Filled\", \"Empty\")")
//        print("Input: 'test for formulas' (from block field)")
//        print("Expected: 'Filled' (matches expected value)")
//        
//        let result = documentEditor.value(ofFieldWithIdentifier: "field_text4")
//        let resultText = result?.text ?? ""
//        
//        print("🎯 Result: '\(resultText)'")
//        
//        XCTAssertEqual(resultText, "Filled", 
//                      "Should return 'Filled' when block1 matches expected value")
//    }
//    
//    private func testBlockFieldBehavior() {
//        print("\n🔍 Test 4: Block field behavior analysis")
//        
//        // Check the source block field
//        let sourceField = documentEditor.field(fieldID: "block1")
//        let sourceValue = sourceField?.value?.text ?? ""
//        
//        print("Source block field analysis:")
//        print("  Field ID: block1")
//        print("  Field type: block")
//        print("  Value: '\(sourceValue)'")
//        print("  Length: \(sourceValue.count) characters")
//        
//        XCTAssertEqual(sourceValue, "test for formulas", "Source block field should have expected value")
//        
//        // Verify block field behaves like text field for formula purposes
//        let upperCaseExpected = sourceValue.uppercased()
//        let lowerCaseExpected = sourceValue.lowercased()
//        
//        print("  String transformations on block content:")
//        print("    Original: '\(sourceValue)'")
//        print("    Upper: '\(upperCaseExpected)'")
//        print("    Lower: '\(lowerCaseExpected)'")
//        
//        XCTAssertEqual(upperCaseExpected, "TEST FOR FORMULAS", "Uppercase transformation should work on block content")
//        XCTAssertEqual(lowerCaseExpected, "test for formulas", "Lowercase transformation should work on block content")
//    }
//    
//    // MARK: - Block vs Text Field Comparison
//    
//    private func testBlockFieldVsTextField() {
//        print("\n📝 Test 5: Block field vs text field behavior")
//        
//        // Block fields should behave similarly to text fields for formula evaluation
//        let testScenarios = [
//            ("Direct reference", "block1", "test for formulas"),
//            ("Concatenation + Upper", "concat(\"Current entry: \", upper(block1))", "Current entry: TEST FOR FORMULAS"),
//            ("Conditional validation", "if(lower(block1) == \"test for formulas\", \"Filled\", \"Empty\")", "Filled")
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
//        
//        print("\n📋 Note: Block fields should function identically to text fields for formula evaluation")
//    }
//    
//    private func testBlockFieldStringFunctions() {
//        print("\n🔍 Test 6: Block field with string functions")
//        
//        // Test that all string functions work correctly with block fields
//        let sourceValue = "test for formulas"
//        
//        // Test case sensitivity in conditional
//        let lowercaseMatch = sourceValue.lowercased() == "test for formulas"
//        print("Block field string function tests:")
//        print("  lowercase(block1) == 'test for formulas': \(lowercaseMatch)")
//        
//        XCTAssertTrue(lowercaseMatch, "Lowercase function should work correctly with block fields")
//        
//        // Test concatenation behavior
//        let concatResult = "Current entry: " + sourceValue.uppercased()
//        print("  concat + upper result: '\(concatResult)'")
//        
//        XCTAssertEqual(concatResult, "Current entry: TEST FOR FORMULAS", "Concatenation should work with block fields")
//        
//        // Test that block field type doesn't interfere with string operations
//        let blockField = documentEditor.field(fieldID: "block1")
//        XCTAssertEqual(blockField?.type, "block", "Field should be of type 'block'")
//        XCTAssertNotNil(blockField?.value, "Block field should have a value")
//    }
//    
//    // MARK: - Helper Methods
//    
//    private func debugBlockFields() {
//        print("\n🔍 Block Field Debug:")
//        
//        let fields = ["block1", "field_text2", "field_text3", "field_text4"]
//        
//        for fieldID in fields {
//            if let field = documentEditor.field(fieldID: fieldID) {
//                print("\nField '\(fieldID)':")
//                print("  Type: \(field.type ?? "unknown")")
//                print("  Title: \(field.title ?? "no title")")
//                print("  Value: '\(field.value?.text ?? "")'")
//                print("  Has formulas: \(field.dictionary["formulas"] != nil)")
//            } else {
//                print("❌ Field '\(fieldID)' not found")
//            }
//        }
//    }
//    
//    private func debugBlockFormulas() {
//        print("\n🔍 Block Formula Debug:")
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
