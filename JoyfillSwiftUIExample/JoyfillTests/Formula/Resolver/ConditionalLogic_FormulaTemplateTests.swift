//
//  ConditionalLogic_FormulaTemplateTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 25/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class ConditionalLogic_FormulaTemplateTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "ConditionalLogic_FormulaTemplate")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    } 

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Conditional Logic Tests
    
    func testConditionalLogicFormulas() {
        print("\n🧪 === Conditional Logic Formula Tests ===")
        print("Testing formula calculations and conditional field visibility logic")
        
        debugBaseValues()
        testNumber3Calculation()
        testNumber4Calculation()
        testText2ConditionalLogic()
        testCalculationChain()
    }
    
    // MARK: - Individual Test Methods
    
    private func testNumber3Calculation() {
        print("\n🔢 Test 1: Number3 = number1 + number2")
        print("Formula: number1 + number2")
        print("Input: 10 + 5")
        print("Expected: 15")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number3")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 15, "Should calculate number3 as number1 + number2 = 10 + 5 = 15")
    }
    
    private func testNumber4Calculation() {
        print("\n🔢 Test 2: Number4 = number3 + 5")
        print("Formula: number3 + 5")
        print("Input: 15 + 5 (number3 from previous calculation)")
        print("Expected: 20")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number4")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 20, "Should calculate number4 as number3 + 5 = 15 + 5 = 20")
    }
    
    private func testText2ConditionalLogic() {
        print("\n📝 Test 3: Text2 conditional logic")
        print("Formula: if(not(empty(text1)), 'Show Field', 'Hide Field')")
        print("text1 = 'Populated' (not empty)")
        print("Expected: 'Show Field'")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "text2")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "Show Field", "Should return 'Show Field' when text1 is not empty")
    }
    
    private func testCalculationChain() {
        print("\n🔗 Test 4: Complete calculation chain")
        print("Chain: number1(10) + number2(5) → number3(15) → number4(20)")
        print("Conditional: text1('Populated') → text2('Show Field')")
        
        let number1 = documentEditor.value(ofFieldWithIdentifier: "number1")?.number ?? -1
        let number2 = documentEditor.value(ofFieldWithIdentifier: "number2")?.number ?? -1
        let number3 = documentEditor.value(ofFieldWithIdentifier: "number3")?.number ?? -1
        let number4 = documentEditor.value(ofFieldWithIdentifier: "number4")?.number ?? -1
        let text1 = documentEditor.value(ofFieldWithIdentifier: "text1")?.text ?? ""
        let text2 = documentEditor.value(ofFieldWithIdentifier: "text2")?.text ?? ""
        
        print("🎯 Complete Results:")
        print("  number1: \(number1) (base)")
        print("  number2: \(number2) (base)")
        print("  number3: \(number3) (calculated: \(number1) + \(number2))")
        print("  number4: \(number4) (calculated: \(number3) + 5)")
        print("  text1: '\(text1)' (base)")
        print("  text2: '\(text2)' (conditional)")
        
        // Verify all calculations in the chain
        XCTAssertEqual(number1, 10, "Number1 should be 10")
        XCTAssertEqual(number2, 5, "Number2 should be 5") 
        XCTAssertEqual(number3, 15, "Number3 should be calculated correctly")
        XCTAssertEqual(number4, 20, "Number4 should be calculated correctly")
        XCTAssertEqual(text1, "Populated", "Text1 should be 'Populated'")
        XCTAssertEqual(text2, "Show Field", "Text2 should show conditional result")
        
        // Additional logic check: number4 > 15 should trigger conditional visibility
        XCTAssertTrue(number4 > 15, "Number4 should be greater than 15 for conditional logic")
    }
    
    // MARK: - Conditional Visibility Tests
    
    private func testConditionalVisibility() {
        print("\n👁️ Test 5: Conditional field visibility")
        
        // Get number4 value to check conditional logic
        let number4 = documentEditor.value(ofFieldWithIdentifier: "number4")?.number ?? -1
        let text2 = documentEditor.value(ofFieldWithIdentifier: "text2")?.text ?? ""
        
        print("Visibility conditions:")
        print("  - text3: visible if text2 == 'Show Field' → \(text2 == "Show Field")")
        print("  - text4: visible if text2 == 'Show Field' → \(text2 == "Show Field")")
        print("  - text5: hidden if number4 > 15 → \(number4 > 15)")
        print("  - Page2: visible if number4 > 15 → \(number4 > 15)")
        
        // These tests focus on the logic conditions rather than actual UI visibility
        // since visibility is handled by the UI layer
        XCTAssertEqual(text2, "Show Field", "Text2 should be 'Show Field' for conditional visibility")
        XCTAssertTrue(number4 > 15, "Number4 should be > 15 for page/field conditional logic")
    }
    
    // MARK: - Helper Methods
    
    private func debugBaseValues() {
        print("\n🔍 Base Field Values:")
        print("  number1: \(documentEditor.field(fieldID: "number1")?.value?.number ?? -1)")
        print("  number2: \(documentEditor.field(fieldID: "number2")?.value?.number ?? -1)")
        print("  text1: '\(documentEditor.field(fieldID: "text1")?.value?.text ?? "")'")
    }
    
    private func debugAllFieldValues() {
        print("\n🔍 All Field Values:")
        let fieldIDs = ["number1", "number2", "number3", "number4", "text1", "text2"]
        
        for fieldID in fieldIDs {
            if let field = documentEditor.field(fieldID: fieldID) {
                let hasFormula = field.dictionary["formulas"] != nil
                let status = hasFormula ? "calculated" : "base"
                
                if let numberValue = field.value?.number {
                    print("  \(fieldID): \(numberValue) (\(status))")
                } else if let textValue = field.value?.text {
                    print("  \(fieldID): '\(textValue)' (\(status))")
                } else {
                    print("  \(fieldID): nil (\(status))")
                }
            } else {
                print("  \(fieldID): not found")
            }
        }
    }
    
    private func debugFieldValue(_ fieldID: String, expectedValue: String? = nil) {
        if let field = documentEditor.field(fieldID: fieldID) {
            if let numberValue = field.value?.number {
                print("🔍 Field '\(fieldID)': \(numberValue)")
            } else if let textValue = field.value?.text {
                print("🔍 Field '\(fieldID)': '\(textValue)'")
            } else {
                print("🔍 Field '\(fieldID)': nil")
            }
            
            if let expected = expectedValue {
                print("   Expected: '\(expected)'")
            }
        } else {
            print("❌ Field '\(fieldID)' not found")
        }
    }
}