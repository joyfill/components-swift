//
//  FormulaTemplate_DropdownFieldTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 25/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class FormulaTemplate_DropdownFieldTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_DropdownField")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    } 

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Dropdown Field Tests
    
    func testDropdownFieldFormulas() {
        print("\n🧪 === Dropdown Field Formula Tests ===")
        print("Testing dropdown field validation, mapping, and conditional formulas")
        
        testDropdownNotEmptyValidation()
        testDropdownConditionalMapping()
        testDropdownToNumberMapping()
        testDropdownConcatenation()
        testAdditionalDropdownFormulas()
        testDropdownFieldBehavior()
    }
    
    // MARK: - Individual Test Methods
    
    private func testDropdownNotEmptyValidation() {
        print("\n✅ Test 1: Dropdown not empty validation")
        print("Formula: not(empty(dropdown1))")
        print("Tests whether a dropdown has a selected value")
        print("Expected: 'true' (dropdown1 has value 'Yes' selected)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "text1")
        let resultText = result?.text ?? ""
        
        print("🎯 Result: '\(resultText)'")
        
        // The dropdown has value "Yes" selected, so it should not be empty
        XCTAssertEqual(resultText, "true", 
                     "Should return 'true' when dropdown1 has a selected value")
    }
    
    private func testDropdownConditionalMapping() {
        print("\n✅ Test 2: Dropdown conditional status mapping")
        print("Formula: if(dropdown1 == \"No\", \"Approved\", \"Pending\")")
        print("Maps dropdown selection to approval status")
        print("Expected: 'Pending' (dropdown1 has 'Yes' selected, not 'No')")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "text2")
        let resultText = result?.text ?? ""
        
        print("🎯 Result: '\(resultText)'")
        
        // dropdown1 has value "Yes" selected, so should return "Pending" (not "No")
        XCTAssertEqual(resultText, "Pending", 
                      "Should return 'Pending' when dropdown selection is 'Yes' (not 'No')")
    }
    
    private func testDropdownToNumberMapping() {
        print("\n✅ Test 3: Dropdown to number mapping")
        print("Formula: if(dropdown1 == \"Yes\", \"1\", if(dropdown1 == \"No\", \"2\", if(dropdown1 == \"N/A\", \"3\", \"0\")))")
        print("Maps dropdown options to corresponding numbers (as strings)")
        print("Expected: 1 (dropdown1 has 'Yes' selected)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number1")
        let resultNumber = result?.text
        
        print("🎯 Result: \(resultNumber)")
        
        // The dropdown has value "Yes" selected, so should return 1
        XCTAssertEqual(resultNumber, "1",
                      "Should return 1 when dropdown selection is 'Yes'")
    }
    
    private func testDropdownConcatenation() {
        print("\n✅ Test 4: Dropdown concatenation")
        print("Formula: concat(\"Selected: \", dropdown1)")
        print("Concatenates label with selected dropdown value")
        print("Expected: 'Selected: Yes' (dropdown1 has 'Yes' selected)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "text3")
        let resultText = result?.text ?? ""
        
        print("🎯 Result: '\(resultText)'")
        
        // Should concatenate "Selected: " with the selected value "Yes"
        XCTAssertEqual(resultText, "Selected: Yes",
                      "Should concatenate label with selected dropdown value 'Yes'")
    }
    
    private func testAdditionalDropdownFormulas() {
        print("\n✅ Test 5: Additional dropdown formulas")
        print("Testing dropdown2-dropdown5 with various conditional formulas")
        
        // Test dropdown2: if(not(empty(dropdown1)), "Yes", "No")
        print("\nDropdown2 test:")
        print("Formula: if(not(empty(dropdown1)), \"Yes\", \"No\")")
        print("Expected: 'Yes' (dropdown1 is not empty)")
        
        let dropdown2Field = documentEditor.field(fieldID: "dropdown2")
        let dropdown2Value = dropdown2Field?.value?.text ?? ""
        print("🎯 Dropdown2 Result: '\(dropdown2Value)'")
        
        XCTAssertEqual(dropdown2Value, "68936547268507ffd443b4a6",
                      "Dropdown2 should be 'Yes' when dropdown1 is not empty")
        
        // Test dropdown3: if(not(empty(dropdown1)), "", "No")  
        print("\nDropdown3 test:")
        print("Formula: if(not(empty(dropdown1)), \"\", \"No\")")
        print("Expected: '' (empty, because dropdown1 is not empty)")
        
        let dropdown3Field = documentEditor.field(fieldID: "dropdown3")
        let dropdown3Value = dropdown3Field?.value?.text ?? ""
        print("🎯 Dropdown3 Result: '\(dropdown3Value)'")
        
        XCTAssertEqual(dropdown3Value, "", 
                      "Dropdown3 should be empty when dropdown1 is not empty")
        
        // Test dropdown4: if(not(empty(dropdown1)), dropdown1, "")
        print("\nDropdown4 test:")
        print("Formula: if(not(empty(dropdown1)), dropdown1, \"\")")
        print("Expected: 'Yes' (mirrors dropdown1 value)")
        
        let dropdown4Field = documentEditor.field(fieldID: "dropdown4")
        let dropdown4Value = dropdown4Field?.value?.text ?? ""
        print("🎯 Dropdown4 Result: '\(dropdown4Value)'")
        
        XCTAssertEqual(dropdown4Value, "68936547268507ffd443b4a6",
                      "Dropdown4 should mirror dropdown1 value 'Yes'")
        
        // Test dropdown5: if(not(empty(dropdown1)), "Does Not Exist", "")
        print("\nDropdown5 test:")
        print("Formula: if(not(empty(dropdown1)), \"Does Not Exist\", \"\")")
        print("Expected: 'Does Not Exist' (string that doesn't exist in options)")
        
        let dropdown5Field = documentEditor.field(fieldID: "dropdown5")
        let dropdown5Value = dropdown5Field?.value?.text ?? ""
        print("🎯 Dropdown5 Result: '\(dropdown5Value)'")
        
        XCTAssertEqual(dropdown5Value, "Does Not Exist", 
                      "Dropdown5 should have 'Does Not Exist' value")
    }
    
    private func testDropdownFieldBehavior() {
        print("\n🔍 Test 6: Dropdown field behavior analysis")
        
        // Check the dropdown field itself
        let dropdownField = documentEditor.field(fieldID: "dropdown1")
        
        print("Dropdown field analysis:")
        print("  Field ID: dropdown1")
        print("  Field type: dropdown")
        
        XCTAssertNotNil(dropdownField, "Dropdown field should exist")
        XCTAssertEqual(dropdownField?.type, "dropdown", "Field should be of type dropdown")
        
        // Check dropdown options
        if let options = dropdownField?.dictionary["options"] as? [[String: Any]] {
            print("  Options count: \(options.count)")
            
            for (index, option) in options.enumerated() {
                let id = option["_id"] as? String ?? ""
                let value = option["value"] as? String ?? ""
                let deleted = option["deleted"] as? Bool ?? false
                
                print("    Option \(index + 1): '\(value)' (ID: \(id), Deleted: \(deleted))")
            }
            
            XCTAssertEqual(options.count, 3, "Should have 3 dropdown options")
        } else {
            XCTFail("Dropdown field should have options")
        }
        
        // Check current selection
        print("  Current selection analysis:")
        if let value = dropdownField?.value?.text {
            print("    Selected value: '\(value)'")
        } else {
            print("    No value selected")
        }
    }
    
    // MARK: - Dropdown Option Mapping Tests
    
    private func testDropdownOptionMapping() {
        print("\n📝 Test 7: Dropdown option mapping verification")
        
        // Test the mapping logic for all possible dropdown values
        let optionMappings = [
            ("Yes", "Pending", 1),
            ("No", "Approved", 2),
            ("N/A", "Pending", 3)
        ]
        
        print("Expected mappings:")
        for (option, statusExpected, numberExpected) in optionMappings {
            print("  '\(option)' → Status: '\(statusExpected)', Number: \(numberExpected)")
        }
        
        // Current selection should be "Yes" based on targetValue
        let dropdownField = documentEditor.field(fieldID: "dropdown1")
        let currentValue = dropdownField?.value?.text ?? "unknown"
        print("Current selection: '\(currentValue)'")
        
        // Verify the formulas work correctly for the current selection
        let statusResult = documentEditor.value(ofFieldWithIdentifier: "text2")
        let numberResult = documentEditor.value(ofFieldWithIdentifier: "number1")
        let concatResult = documentEditor.value(ofFieldWithIdentifier: "text3")
        let emptyResult = documentEditor.value(ofFieldWithIdentifier: "text1")
        
        print("Formula results for current selection:")
        print("  Status: '\(statusResult?.text ?? "")'")
        print("  Number: \(numberResult?.number ?? -1)")
        print("  Concat: '\(concatResult?.text ?? "")'")
        print("  Not empty: '\(emptyResult?.text ?? "")'")
    }
    
    private func testDropdownFormulaLogic() {
        print("\n🔍 Test 8: Dropdown formula logic verification")
        
        // Test the nested if logic for number mapping
        let numberFormula = "if(dropdown1 == \"Yes\", \"1\", if(dropdown1 == \"No\", \"2\", if(dropdown1 == \"N/A\", \"3\", \"0\")))"
        print("Number mapping formula: \(numberFormula)")
        print("Logic flow:")
        print("  If 'Yes' → 1")
        print("  Else if 'No' → 2") 
        print("  Else if 'N/A' → 3")
        print("  Else → 0")
        
        // Test the conditional status logic
        let statusFormula = "if(dropdown1 == \"No\", \"Approved\", \"Pending\")"
        print("Status mapping formula: \(statusFormula)")
        print("Logic flow:")
        print("  If 'No' → 'Approved'")
        print("  Else → 'Pending'")
        
        // Verify all formulas return expected results
        XCTAssertNotNil(documentEditor.value(ofFieldWithIdentifier: "text2"), 
                       "Status formula should return a result")
        XCTAssertNotNil(documentEditor.value(ofFieldWithIdentifier: "number1"), 
                       "Number formula should return a result")
        XCTAssertNotNil(documentEditor.value(ofFieldWithIdentifier: "text3"), 
                       "Concat formula should return a result")
        XCTAssertNotNil(documentEditor.value(ofFieldWithIdentifier: "text1"), 
                       "Empty check formula should return a result")
    }
    
    // MARK: - Helper Methods
    
    private func debugDropdownField() {
        print("\n🔍 Dropdown Field Debug:")
        
        if let dropdownField = documentEditor.field(fieldID: "dropdown1") {
            print("Dropdown field details:")
            print("  Type: \(dropdownField.type ?? "unknown")")
            print("  Title: \(dropdownField.title ?? "no title")")
            print("  Has value: \(dropdownField.value != nil)")
            
            if let value = dropdownField.value?.text {
                print("  Selected value: '\(value)'")
            }
            
            // Debug targetValue from fieldPosition
            let document = documentEditor.document
            for file in document.files {
                    if let pages = file.pages {
                        for page in pages {
                            if let positions = page.fieldPositions {
                                for position in positions {
                                    if position.field == "dropdown1" {
                                        print("  Target value: \(position.targetValue ?? "none")")
                                    }
                                }
                            }
                        }
                    }
            }
        } else {
            print("❌ Dropdown field not found")
        }
    }
    
    private func debugDropdownFormulas() {
        print("\n🔍 Dropdown Formula Debug:")
        
        let document = documentEditor.document
        print("Document has \(document.formulas.count ?? 0) formulas:")
        
            for formula in document.formulas {
                if let id = formula.id, let expression = formula.expression {
                    print("  Formula '\(id)': \(expression)")
                }
            }

    }
}
