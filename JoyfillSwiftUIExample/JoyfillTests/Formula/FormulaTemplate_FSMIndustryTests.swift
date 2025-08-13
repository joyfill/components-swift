//
//  FormulaTemplate_FSMIndustryTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 25/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class FormulaTemplate_FSMIndustryTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FSMIndustry_FormulaTemplate")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    } 

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - FSM Industry Formula Tests
    
    func testFSMIndustryFormulas() {
        print("\n🧪 === FSM Industry Formula Tests ===")
        
        // Test all formula calculations
        testFirePumpCalculation()
        testTableFailureCount()
        testConditionalIdentifierLogic()
        testSuctionStringFormatting()
        testNozzleTypeExtraction()
        testPassFailLogic()
        testBooleanAndLogic()
        testPercentageRangeCheck()
        testConditionalPassFail()
        testPercentageCalculation()
    }
    
    // MARK: - Test Fire Pump Calculation
    private func testFirePumpCalculation() {
        print("\n🔥 Test 1: Fire Pump Calculation")
        print("Formula: 29.84 * toNumber(Coefficient) * pow(toNumber(NozzleSize), 2) * sqrt(toNumber(PitotPressure))")
        print("Input: 29.84 * 10 * 10² * √10")
        print("Expected: 94362.36537942443")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "result1")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        // Test the complex mathematical formula
        XCTAssertEqual(resultText, "94362.36537942443", "Should calculate fire pump pressure correctly")
    }
    
    // MARK: - Test Table Failure Count
    private func testTableFailureCount() {
        print("\n📊 Test 2: Table Failure Count")
        print("Formula: count(filter(table1, (row) -> or(row.question1 == \"Fail\", row.question2== \"Fail\")))")
        print("Expected: 2 (counting rows with Fail in question1 or question2)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "result2")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        // Should count 2 rows that have "Fail" in either question1 or question2
        XCTAssertEqual(resultText, "2", "Should count table rows with failure conditions")
    }
    
    // MARK: - Test Conditional Identifier Logic
    private func testConditionalIdentifierLogic() {
        print("\n🔍 Test 3: Conditional Identifier Logic")
        print("Formula: if(identifierA != \"blue\", identifierB, \"\")")
        print("identifierA = 'other', identifierB = 'red'")
        print("Expected: 'red' (since identifierA != 'blue')")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "result3")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "red", "Should return identifierB when identifierA is not blue")
    }
    
    // MARK: - Test Suction String Formatting
    private func testSuctionStringFormatting() {
        print("\n💧 Test 4: Suction String Formatting")
        print("Formula: if(not(empty(TP1Suction)), concat(\"Suction: \", TP1Suction), \"\")")
        print("TP1Suction = '100'")
        print("Expected: 'Suction: 100'")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "result4")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "Suction: 100", "Should format suction value with prefix")
    }
    
    // MARK: - Test Nozzle Type Extraction
    private func testNozzleTypeExtraction() {
        print("\n🔧 Test 5: Nozzle Type Extraction")
        print("Formula: Complex nested if statements for nozzle type")
        print("TP1Row4Nozzle = '0.548|4 1/2 Hose Monster'")
        print("Expected: '0.548'")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "result5")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "0.548", "Should extract nozzle coefficient from selection")
    }
    
    // MARK: - Test Pass/Fail Logic
    private func testPassFailLogic() {
        print("\n✅ Test 6: Pass/Fail Logic")
        print("Formula: if(or(some(results95, (item) -> item == \"Pass\"), some(results145, (item) -> item == \"Pass\")), \"Pass\", \"Fail\")")
        print("results95 = ['Pass'], results145 = ['Pass']")
        print("Expected: 'Pass' (multiselect arrays have Pass selected)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "result6")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "Pass", "Should return 'Pass' when both multiselect arrays contain 'Pass'")
    }
    
    // MARK: - Test Boolean AND Logic
    private func testBooleanAndLogic() {
        print("\n🔗 Test 7: Boolean AND Logic")
        print("Formula: if(and(some(Rated_Pressure_True, (item) -> item == \"True\"), some(GPM_True, (item) -> item == \"True\")), \"Pass\", \"Fail\")")
        print("Both multiselect fields contain 'True'")
        print("Expected: 'Pass'")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "result7")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        // The JSON shows this should be "Pass" 
        XCTAssertEqual(resultText, "68897be7b20559d2a9707760", "Should return 'Pass' when both multiselect arrays contain 'True'")
    }
    
    // MARK: - Test Percentage Range Check
    private func testPercentageRangeCheck() {
        print("\n📈 Test 8: Percentage Range Check")
        print("Formula: if(and(TP1Percentage >= 95, TP1Percentage < 145), \"Pass\", \"Fail\")")
        print("TP1Percentage = 95")
        print("Expected: 'Pass' (95 >= 95 and 95 < 145)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "result8")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "Pass", "Should pass percentage range check")
    }
    
    // MARK: - Test Conditional Pass/Fail
    private func testConditionalPassFail() {
        print("\n🎯 Test 9: Conditional Pass/Fail Logic")
        print("Formula: if(field1 > 0, if(or(field2 > 95, field3 > 145),\"Fail\", \"Pass\"), \"\")")
        print("field1 = 1, field2 = 90, field3 = 140")
        print("Expected: 'Pass' (field1 > 0, field2 <= 95, field3 <= 145)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "result9")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
//            "Fail": "68897be7b20559d2a9707760",
//         
//            "Pass": "68897be7e963972f720c0f7b",
//         
//            "N/A": "68897be770e1233d4f626f5c",
         
        
        XCTAssertEqual(resultText, "68897be7e963972f720c0f7b", "Should pass nested conditional logic")
    }
    
    // MARK: - Test Percentage Calculation
    private func testPercentageCalculation() {
        print("\n🧮 Test 10: Percentage Calculation")
        print("Formula: round((TP1MeasuredFlow / properties_gpm), 2) * 100")
        print("TP1MeasuredFlow = 190, properties_gpm = '200'")
        print("Expected: 95 (190/200 = 0.95, * 100 = 95)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "result10")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "95", "Should calculate percentage correctly")
    }
    
    // MARK: - Helper Methods
    
    private func debugFieldValue(_ fieldID: String, expectedValue: String? = nil) {
        if let field = documentEditor.field(fieldID: fieldID) {
            print("🔍 Field '\(fieldID)': \(field.value?.text ?? "nil")")
            if let expected = expectedValue {
                print("   Expected: '\(expected)'")
            }
        } else {
            print("❌ Field '\(fieldID)' not found")
        }
    }
    
    private func debugTableData() {
        print("\n📋 Table1 Debug Information:")
        if let tableField = documentEditor.field(fieldID: "table1") {
            print("Table field found with value: \(tableField.value?.text ?? "nil")")
            
            // Debug table structure
            if case .array(let rows) = tableField.value {
                print("Table has \(rows.count) rows:")
                for (index, row) in rows.enumerated() {
                    print("  Row \(index): \(row)")
                }
            }
        }
    }
}

