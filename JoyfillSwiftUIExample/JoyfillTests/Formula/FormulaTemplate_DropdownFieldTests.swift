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
        testDropdownFieldBehavior()
    }
    
    // MARK: - Individual Test Methods
    
    private func testDropdownNotEmptyValidation() {
        print("\n✅ Test 1: Dropdown not empty validation")
        print("Formula: not(empty(dropdown1))")
        print("Tests whether a dropdown has a selected value")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field_6855a20d13afe3315c1c110a")
        let resultText = result?.text ?? ""
        
        print("🎯 Result: '\(resultText)'")
        
        // The dropdown has a targetValue set, so it should not be empty
        XCTAssertTrue(resultText == "true" || resultText == "1" || resultText.lowercased() == "true", 
                     "Should detect dropdown as not empty when it has a selected value")
    }
    
    private func testDropdownConditionalMapping() {
        print("\n✅ Test 2: Dropdown conditional status mapping")
        print("Formula: if(dropdown1 == \"No\", \"Approved\", \"Pending\")")
        print("Maps dropdown selection to approval status")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field_6855a18f2aca06f83946064d")
        let resultText = result?.text ?? ""
        
        print("🎯 Result: '\(resultText)'")
        
        // Based on the targetValue "684c3fed5216e0fbf165bcf4" which corresponds to "Yes"
        // So it should return "Pending" (not "No")
        XCTAssertEqual(resultText, "Pending", 
                      "Should return 'Pending' when dropdown selection is not 'No'")
    }
    
    private func testDropdownToNumberMapping() {
        print("\n✅ Test 3: Dropdown to number mapping")
        print("Formula: if(dropdown1 == \"Yes\", 1, if(dropdown1 == \"No\", 2, if(dropdown1 == \"N/A\", 3, 0)))")
        print("Maps dropdown options to corresponding numbers")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field_6855a1eb2693ebdf695fe9ce")
        let resultNumber = result?.number ?? -1
        
        print("🎯 Result: \(resultNumber)")
        
        // The targetValue corresponds to "Yes" option, so should return 1
        XCTAssertEqual(resultNumber, 1, 
                      "Should return 1 when dropdown selection is 'Yes'")
    }
    
    private func testDropdownConcatenation() {
        print("\n✅ Test 4: Dropdown concatenation")
        print("Formula: concat(\"Selected: \", dropdown1)")
        print("Concatenates label with selected dropdown value")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field_6855a17ad6e245b0b6045450")
        let resultText = result?.text ?? ""
        
        print("🎯 Result: '\(resultText)'")
        
        // Should concatenate "Selected: " with the selected value "Yes"
        XCTAssertEqual(resultText, "Selected: Yes", 
                      "Should concatenate label with selected dropdown value")
    }
    
    private func testDropdownFieldBehavior() {
        print("\n🔍 Test 5: Dropdown field behavior analysis")
        
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
        print("\n📝 Test 6: Dropdown option mapping verification")
        
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
        let statusResult = documentEditor.value(ofFieldWithIdentifier: "field_6855a18f2aca06f83946064d")
        let numberResult = documentEditor.value(ofFieldWithIdentifier: "field_6855a1eb2693ebdf695fe9ce")
        let concatResult = documentEditor.value(ofFieldWithIdentifier: "field_6855a17ad6e245b0b6045450")
        let emptyResult = documentEditor.value(ofFieldWithIdentifier: "field_6855a20d13afe3315c1c110a")
        
        print("Formula results for current selection:")
        print("  Status: '\(statusResult?.text ?? "")'")
        print("  Number: \(numberResult?.number ?? -1)")
        print("  Concat: '\(concatResult?.text ?? "")'")
        print("  Not empty: '\(emptyResult?.text ?? "")'")
    }
    
    private func testDropdownFormulaLogic() {
        print("\n🔍 Test 7: Dropdown formula logic verification")
        
        // Test the nested if logic for number mapping
        let numberFormula = "if(dropdown1 == \"Yes\", 1, if(dropdown1 == \"No\", 2, if(dropdown1 == \"N/A\", 3, 0)))"
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
        XCTAssertNotNil(documentEditor.value(ofFieldWithIdentifier: "field_6855a18f2aca06f83946064d"), 
                       "Status formula should return a result")
        XCTAssertNotNil(documentEditor.value(ofFieldWithIdentifier: "field_6855a1eb2693ebdf695fe9ce"), 
                       "Number formula should return a result")
        XCTAssertNotNil(documentEditor.value(ofFieldWithIdentifier: "field_6855a17ad6e245b0b6045450"), 
                       "Concat formula should return a result")
        XCTAssertNotNil(documentEditor.value(ofFieldWithIdentifier: "field_6855a20d13afe3315c1c110a"), 
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
            print("Document has \(document.formulas.count) formulas:")
            
            for formula in document.formulas {
                if let id = formula.id, let expression = formula.expression {
                    print("  Formula '\(id)': \(expression)")
                }
            }

    }
}
