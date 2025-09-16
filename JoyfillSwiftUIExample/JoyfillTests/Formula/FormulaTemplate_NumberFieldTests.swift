//
//  FormulaTemplate_NumberFieldTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 25/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class FormulaTemplate_NumberFieldTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_NumberField")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    } 

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Number Field Formula Tests
    
    func testNumberFieldFormulas() {
        print("\n🧪 === Number Field Formula Tests ===")
        
        // Debug: Print number1 base value
        if let numberField = documentEditor.field(fieldID: "number1") {
            print("🔢 Number1 base value: \(numberField.value?.number ?? -1)")
        }
        
        testAdd100()
        testDoubleValue()
        testDivideBy3Round2()
        testSqrtValue()
        testGreaterThan50Flag()
        testMod7()
        testSquareValue()
        testCeilDivBy4()
        testFloorDivBy4()
        testMaxWith25()
    }
    
    // MARK: - Individual Test Methods
    
    private func testAdd100() {
        print("\n➕ Test 1: Add 100 to number1")
        print("Formula: number1 + 100")
        print("Input: 10 + 100")
        print("Expected: 110")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number2")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 110, "Should add 100 to the base value")
    }
    
    private func testDoubleValue() {
        print("\n✖️ Test 2: Multiply number1 by 2")
        print("Formula: number1 * 2")
        print("Input: 10 * 2")
        print("Expected: 20")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number3")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 20, "Should double the base value")
    }
    
    private func testDivideBy3Round2() {
        print("\n➗ Test 3: Divide by 3 and round to 2 decimal places")
        print("Formula: round(number1 / 3, 2)")
        print("Input: round(10 / 3, 2)")
        print("Expected: 3.33")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number4")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 3.33, accuracy: 0.001, "Should divide by 3 and round to 2 decimal places")
    }
    
    private func testSqrtValue() {
        print("\n√ Test 4: Square root of number1")
        print("Formula: sqrt(number1)")
        print("Input: sqrt(10)")
        print("Expected: ~3.162")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number5")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, sqrt(10), accuracy: 0.001, "Should calculate square root")
    }
    
    private func testGreaterThan50Flag() {
        print("\n🚩 Test 5: Flag if greater than 50")
        print("Formula: if(number1 > 50, 1, 0)")
        print("Input: if(10 > 50, 1, 0)")
        print("Expected: 0")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number6")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 0, "Should return 0 when number1 (10) is not greater than 50")
    }
    
    private func testMod7() {
        print("\n% Test 6: Remainder when divided by 7")
        print("Formula: mod(number1, 7)")
        print("Input: mod(10, 7)")
        print("Expected: 3")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number7")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 3, "Should return remainder of 10 divided by 7")
    }
    
    private func testSquareValue() {
        print("\n² Test 7: Square of number1")
        print("Formula: pow(number1, 2)")
        print("Input: pow(10, 2)")
        print("Expected: 100")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number8")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 100, "Should calculate square of the number")
    }
    
    private func testCeilDivBy4() {
        print("\n⬆️ Test 8: Ceiling of number1 divided by 4")
        print("Formula: ceil(number1 / 4)")
        print("Input: ceil(10 / 4) = ceil(2.5)")
        print("Expected: 3")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number9")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 3, "Should round up 2.5 to 3")
    }
    
    private func testFloorDivBy4() {
        print("\n⬇️ Test 9: Floor of number1 divided by 4")
        print("Formula: floor(number1 / 4)")
        print("Input: floor(10 / 4) = floor(2.5)")
        print("Expected: 2")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number10")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 2, "Should round down 2.5 to 2")
    }
    
    private func testMaxWith25() {
        print("\n🔝 Test 10: Maximum of number1 and 25")
        print("Formula: max([number1, 25])")
        print("Input: max([10, 25])")
        print("Expected: 25")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number11")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 25, "Should return 25 as it's greater than 10")
    }
    
    // MARK: - Helper Methods
    
    private func debugFieldValue(_ fieldID: String, expectedValue: Double? = nil) {
        if let field = documentEditor.field(fieldID: fieldID) {
            print("🔍 Field '\(fieldID)': \(field.value?.number ?? -1)")
            if let expected = expectedValue {
                print("   Expected: \(expected)")
            }
        } else {
            print("❌ Field '\(fieldID)' not found")
        }
    }
}

