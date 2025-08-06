//
//  FormulaTemplate_MultiSelectFieldTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 25/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class FormulaTemplate_MultiSelectFieldTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_MultiSelectField")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    } 

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - MultiSelect Formula Tests
    
    func testMultiSelectFormulas() {
        print("\n🧪 === MultiSelect Field Formula Tests ===")
        
        // Debug: Print multiSelect1 value
        if let multiSelectField = documentEditor.field(fieldID: "multiSelect1") {
            print("📝 MultiSelect1 value: \(multiSelectField.value?.text ?? "nil")")
            print("📝 MultiSelect1 options selected: Option 1 + Option 2")
        }
        
        testMultiSelectNotEmpty()
        testMultiSelectConcat()
        testMultiSelectToNumbers()
        testMultiSelectApprovedPending()
    }
    
    // MARK: - Individual Test Methods
    
    private func testMultiSelectNotEmpty() {
        print("\n✅ Test 1: Check if multiSelect has any value")
        print("Formula: not(empty(multiSelect1))")
        print("Selected: ['Option 2', 'Option 1'] (2 options selected)")
        print("Expected: true")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "text1")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "true", "Should return true when multiSelect has selected values")
    }
    
    private func testMultiSelectConcat() {
        print("\n🔗 Test 2: Concatenate selected options")
        print("Formula: concat(\"Selected: \", reduce(multiSelect1, (acc, item) -> if(empty(acc), item, concat(acc, \", \", item)), \"\"))")
        print("Selected: ['Option 2', 'Option 1']")
        print("Expected: 'Selected: Option 2, Option 1' (or similar order)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "text2")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        // The order might vary, so we check if it contains the expected parts
        XCTAssertTrue(resultText.contains("Selected:"), "Should start with 'Selected:'")
        XCTAssertTrue(resultText.contains("Option 1"), "Should contain 'Option 1'")
        XCTAssertTrue(resultText.contains("Option 2"), "Should contain 'Option 2'")
    }
    
    private func testMultiSelectToNumbers() {
        print("\n🔢 Test 3: Map selected options to numbers and sum")
        print("Formula: sum(map(multiSelect1, (item) -> if(item == \"Option 1\", 1, if(item == \"Option 2\", 2, if(item == \"Option 3\", 3, 0)))))")
        print("Selected: ['Option 2', 'Option 1'] → [2, 1] → sum = 3")
        print("Expected: 3")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number1")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "3", "Should sum to 3 (Option 1=1 + Option 2=2)")
    }
    
    private func testMultiSelectApprovedPending() {
        print("\n✅ Test 4: Approved if Option 2 selected, else Pending")
        print("Formula: if(some(multiSelect1, (item) -> item == \"Option 2\"), \"Approved\", \"Pending\")")
        print("Selected: ['Option 2', 'Option 1'] (includes Option 2)")
        print("Expected: 'Approved'")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "text3")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "Approved", "Should return 'Approved' when Option 2 is selected")
    }
    
    // MARK: - Helper Methods
    
    private func debugMultiSelectValue() {
        print("\n🔍 MultiSelect Debug Information:")
        if let multiSelectField = documentEditor.field(fieldID: "multiSelect1") {
            print("MultiSelect field found")
            
            if let value = multiSelectField.value {
                switch value {
                case .array(let selections):
                    print("📝 Selected IDs: \(selections)")
                    
                    // Try to map IDs to display values
                    if let fieldData = multiSelectField.dictionary["options"] as? [[String: Any]] {
                        for selection in selections {
//                            if case .string(let selectionID) = selection {
                                for option in fieldData {
                                    if let optionID = option["_id"] as? String,
                                       let optionValue = option["value"] as? String,
                                       optionID == selection {
                                        print("  - ID '\(selection)' = '\(optionValue)'")
                                    }
                                }
//                            }
                        }
                    }
                default:
                    print("📝 Value type: \(value)")
                }
            }
        } else {
            print("❌ MultiSelect field not found")
        }
    }
    
    private func debugFieldValue(_ fieldID: String, expectedValue: String? = nil) {
        if let field = documentEditor.field(fieldID: fieldID) {
            print("🔍 Field '\(fieldID)': '\(field.value?.text ?? "nil")'")
            if let expected = expectedValue {
                print("   Expected: '\(expected)'")
            }
        } else {
            print("❌ Field '\(fieldID)' not found")
        }
    }
}

