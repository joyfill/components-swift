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
    
    // MARK: - Additional Number Edge Case Tests
    
    func testDecimalStartingWithDot_Addition() {
        print("\n🔢 Test 11: Addition with decimal starting with dot")
        print("Formula: number1 + .25")
        print("Input: 10 + 0.25")
        print("Expected: 10.25")
        
        // Note: This test validates that .25 is parsed correctly as 0.25
        let result = documentEditor.value(ofFieldWithIdentifier: "number12")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 10.25, accuracy: 0.001, "Should add .25 correctly as 0.25")
    }
    
    func testDecimalStartingWithDot_Multiplication() {
        print("\n✖️ Test 12: Multiplication with decimal starting with dot")
        print("Formula: number1 * .5")
        print("Input: 10 * 0.5")
        print("Expected: 5")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number13")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 5, "Should multiply by .5 correctly as 0.5")
    }
    
    func testDecimalStartingWithDot_Division() {
        print("\n➗ Test 13: Division with decimal starting with dot")
        print("Formula: number1 / .2")
        print("Input: 10 / 0.2")
        print("Expected: 50")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number14")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 50, "Should divide by .2 correctly as 0.2")
    }
    
    func testMaxWithDotDecimal() {
        print("\n🔝 Test 14: Maximum with dot decimal")
        print("Formula: max([number1, .25])")
        print("Input: max([10, 0.25])")
        print("Expected: 10")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number15")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 10, "Should return 10 as it's greater than .25")
    }
    
    func testMinWithDotDecimal() {
        print("\n🔻 Test 15: Minimum with dot decimal")
        print("Formula: min([number1, .75])")
        print("Input: min([10, 0.75])")
        print("Expected: 0.75")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number16")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 0.75, accuracy: 0.001, "Should return .75 as it's less than 10")
    }
    
    func testNegativeDecimalStartingWithDot() {
        print("\n➖ Test 16: Negative decimal starting with dot")
        print("Formula: number1 + (-0.5)")
        print("Input: 10 + (-0.5)")
        print("Expected: 9.5")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number17")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 9.5, accuracy: 0.001, "Should handle negative decimal -0.5 correctly")
    }
    
    func testVerySmallDecimal_DotZeroOne() {
        print("\n🔬 Test 17: Very small decimal starting with dot")
        print("Formula: number1 * .01")
        print("Input: 10 * 0.01")
        print("Expected: 0.1")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number18")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 0.1, accuracy: 0.001, "Should handle .01 correctly")
    }
    
    func testVerySmallDecimal_DotZeroZeroOne() {
        print("\n🔬 Test 18: Very small decimal .001")
        print("Formula: number1 * .001")
        print("Input: 10 * 0.001")
        print("Expected: 0.01")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number19")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 0.01, accuracy: 0.0001, "Should handle .001 correctly")
    }
    
    func testPowWithDotDecimal() {
        print("\n² Test 19: Power with dot decimal")
        print("Formula: pow(number1, .5)")
        print("Input: pow(10, 0.5) - square root")
        print("Expected: ~3.162")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number20")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, sqrt(10), accuracy: 0.001, "Should calculate pow(10, .5) correctly")
    }
    
    func testRoundWithDotDecimal() {
        print("\n🔄 Test 20: Round with dot decimal precision")
        print("Formula: round(number1 * .123, 2)")
        print("Input: round(10 * 0.123, 2)")
        print("Expected: 1.23")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number21")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 1.23, "Should round result to 2 decimal places")
    }
    
//    func testAbsWithNegativeDotDecimal() {
//        print("\n🔢 Test 21: Absolute value with negative dot decimal")
//        print("Formula: abs(-0.99)")
//        print("Input: abs(-0.99)")
//        print("Expected: 0.99")
//        
//        let result = documentEditor.value(ofFieldWithIdentifier: "number22")
//        let resultNumber = result?.number ?? -1
//        print("🎯 Result: \(resultNumber)")
//        
//        XCTAssertEqual(resultNumber, 0.99, accuracy: 0.001, "Should return absolute value of -0.99")
//    }
    
    func testMaxWithMultipleDotDecimals() {
        print("\n🔝 Test 22: Maximum with multiple dot decimals")
        print("Formula: max([.25, .5, .75, .1])")
        print("Input: max([0.25, 0.5, 0.75, 0.1])")
        print("Expected: 0.75")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number23")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 0.75, accuracy: 0.001, "Should return .75 as maximum")
    }
    
    func testMinWithMultipleDotDecimals() {
        print("\n🔻 Test 23: Minimum with multiple dot decimals")
        print("Formula: min([.25, .5, .75, .1])")
        print("Input: min([0.25, 0.5, 0.75, 0.1])")
        print("Expected: 0.1")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number24")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 0.1, accuracy: 0.001, "Should return .1 as minimum")
    }
    
    func testChainedOperationsWithDotDecimals() {
        print("\n🔗 Test 24: Chained operations with dot decimals")
        print("Formula: (number1 * .5) + .25")
        print("Input: (10 * 0.5) + 0.25")
        print("Expected: 5.25")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number25")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 5.25, accuracy: 0.001, "Should calculate chained operations correctly")
    }
    
    func testDivisionByDotDecimal_SmallResult() {
        print("\n➗ Test 25: Division by dot decimal with small result")
        print("Formula: .5 / number1")
        print("Input: 0.5 / 10")
        print("Expected: 0.05")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number26")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 0.05, accuracy: 0.001, "Should calculate .5 / 10 correctly")
    }
    
    func testModWithDotDecimal() {
        print("\n% Test 26: Modulo with dot decimal")
        print("Formula: mod(number1, .3)")
        print("Input: mod(10, 0.3)")
        print("Expected: 0.1")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number27")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 0.1, accuracy: 0.001, "Should calculate mod(10, .3) correctly")
    }
    
    func testSqrtOfDotDecimal() {
        print("\n√ Test 27: Square root of dot decimal")
        print("Formula: sqrt(.25)")
        print("Input: sqrt(0.25)")
        print("Expected: 0.5")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number28")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 0.5, accuracy: 0.001, "Should calculate sqrt(.25) correctly")
    }
    
    func testCeilWithDotDecimal() {
        print("\n⬆️ Test 28: Ceiling of dot decimal")
        print("Formula: ceil(number1 * .123)")
        print("Input: ceil(10 * 0.123) = ceil(1.23)")
        print("Expected: 2")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number29")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 2, "Should round up 1.23 to 2")
    }
    
    func testFloorWithDotDecimal() {
        print("\n⬇️ Test 29: Floor of dot decimal")
        print("Formula: floor(number1 * .123)")
        print("Input: floor(10 * 0.123) = floor(1.23)")
        print("Expected: 1")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number30")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 1, "Should round down 1.23 to 1")
    }
    
    func testComplexExpressionWithDotDecimals() {
        print("\n🧮 Test 30: Complex expression with multiple dot decimals")
        print("Formula: (number1 * .5) + (.25 * 4) - .1")
        print("Input: (10 * 0.5) + (0.25 * 4) - 0.1")
        print("Expected: 5.9")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number31")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 5.9, accuracy: 0.001, "Should calculate complex expression correctly")
    }
    
    func testZeroPointNine() {
        print("\n🔢 Test 31: Decimal .9 close to 1")
        print("Formula: number1 * .9")
        print("Input: 10 * 0.9")
        print("Expected: 9")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number32")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 9, accuracy: 0.001, "Should multiply by .9 correctly")
    }
    
    func testZeroPointZeroFive() {
        print("\n🔢 Test 32: Small decimal .05")
        print("Formula: number1 * .05")
        print("Input: 10 * 0.05")
        print("Expected: 0.5")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number33")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 0.5, accuracy: 0.001, "Should multiply by .05 correctly")
    }
    
    func testMaxWithZeroAndDotDecimal() {
        print("\n🔝 Test 33: Maximum with zero and dot decimal")
        print("Formula: max([0, .5])")
        print("Input: max([0, 0.5])")
        print("Expected: 0.5")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number34")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 0.5, accuracy: 0.001, "Should return .5 as maximum")
    }
    
    func testMinWithZeroAndDotDecimal() {
        print("\n🔻 Test 34: Minimum with zero and dot decimal")
        print("Formula: min([0, .5])")
        print("Input: min([0, 0.5])")
        print("Expected: 0")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number35")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 0, "Should return 0 as minimum")
    }
    
    func testPrecisionWithTinyDecimals() {
        print("\n🔬 Test 35: Precision with tiny decimals")
        print("Formula: .0001 * 10000")
        print("Input: 0.0001 * 10000")
        print("Expected: 1")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number36")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 1, accuracy: 0.001, "Should handle tiny decimals with precision")
    }
    
    func testRepeatingDecimalApproximation() {
        print("\n🔁 Test 36: Repeating decimal approximation")
        print("Formula: 1 / 3")
        print("Input: 1 / 3")
        print("Expected: ~0.333")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number37")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 0.3333333333, accuracy: 0.001, "Should handle repeating decimal")
    }
    
    func testAdditionOfManyDotDecimals() {
        print("\n➕ Test 37: Addition of many dot decimals")
        print("Formula: .1 + .2 + .3 + .4")
        print("Input: 0.1 + 0.2 + 0.3 + 0.4")
        print("Expected: 1.0")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number38")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 1.0, accuracy: 0.001, "Should add multiple dot decimals correctly")
    }
    
    func testSubtractionWithDotDecimals() {
        print("\n➖ Test 38: Subtraction with dot decimals")
        print("Formula: number1 - .99")
        print("Input: 10 - 0.99")
        print("Expected: 9.01")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number39")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 9.01, accuracy: 0.001, "Should subtract .99 correctly")
    }
    
    func testComparisonWithDotDecimals() {
        print("\n⚖️ Test 39: Comparison with dot decimals")
        print("Formula: if(.5 > .25, 1, 0)")
        print("Input: if(0.5 > 0.25, 1, 0)")
        print("Expected: 1")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number40")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 1, "Should correctly compare dot decimals")
    }
    
    func testPercentageCalculationWithDotDecimal() {
        print("\n📊 Test 40: Percentage calculation with dot decimal")
        print("Formula: number1 * .15")
        print("Input: 10 * 0.15 (15% of 10)")
        print("Expected: 1.5")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "number41")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 1.5, accuracy: 0.001, "Should calculate 15% correctly")
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

