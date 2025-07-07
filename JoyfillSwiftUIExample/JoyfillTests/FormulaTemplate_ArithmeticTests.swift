//
//  FormulaTemplate_ArithmeticTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 25/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class FormulaTemplate_ArithmeticTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_Arithmetic")
        documentEditor = DocumentEditor(document: document)
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }

    // MARK: - Addition Tests

    func testAddingTwoIntegers() async throws {
        // 5 + 3 = 8
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number1")
        print("🔢 Adding two integers: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, 8, "Adding two integers should equal 8")
    }

    func testAddingZero() async throws {
        // 0 + 10 = 10
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number2")
        print("🔢 Adding zero: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, 10, "Adding zero should equal 10")
    }

    func testNegativeAndPositive() async throws {
        // -4 + 6 = 2
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number3")
        print("🔢 Negative and positive: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, 2, "Negative and positive should equal 2")
    }

    func testDecimalAddition() async throws {
        // 2.5 + 4.1 = 6.6
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number4")
        print("🔢 Decimal addition: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number ?? 0, 6.6, accuracy: 0.001, "Decimal addition should equal 6.6")
    }

    func testNegativePlusPositive() async throws {
        // -5 + 3 = -2
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number5")
        print("🔢 Negative plus positive: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, -2, "Negative plus positive should equal -2")
    }

    func testPositivePlusNegativeExplicit() async throws {
        // 4 + (-6) = -2
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number6")
        print("🔢 Positive plus negative (explicit): \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, -2, "Positive plus negative should equal -2")
    }

    func testSumOfTwoNegativeNumbers() async throws {
        // -4 + (-3) = -7
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number7")
        print("🔢 Sum of two negative numbers: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, -7, "Sum of two negative numbers should equal -7")
    }

    func testZeroPlusNegative() async throws {
        // 0 + (-7) = -7
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number8")
        print("🔢 Zero plus negative: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, -7, "Zero plus negative should equal -7")
    }

    // MARK: - Subtraction Tests

    func testBasicSubtraction() async throws {
        // 9 - 4 = 5
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number9")
        print("🔢 Basic subtraction: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, 5, "Basic subtraction should equal 5")
    }

    func testSubtractingFromZero() async throws {
        // 0 - 7 = -7
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number10")
        print("🔢 Subtracting from zero: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, -7, "Subtracting from zero should equal -7")
    }

    func testSubtractingFromNegativeNumber() async throws {
        // -3 - 2 = -5
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number11")
        print("🔢 Subtracting from negative number: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, -5, "Subtracting from negative number should equal -5")
    }

    func testDecimalSubtraction() async throws {
        // 5.0 - 2.2 = 2.8
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number12")
        print("🔢 Decimal subtraction: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number ?? 0, 2.8, accuracy: 0.001, "Decimal subtraction should equal 2.8")
    }

    func testSubtractingNegativeBecomesAddition() async throws {
        // 5 - (-3) = 8
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number13")
        print("🔢 Subtracting negative becomes addition: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, 8, "Subtracting negative should equal 8")
    }

    func testNegativeMinusPositive() async throws {
        // -5 - 3 = -8
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number14")
        print("🔢 Negative minus positive: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, -8, "Negative minus positive should equal -8")
    }

    func testNegativeMinusNegative() async throws {
        // -7 - (-2) = -5
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number15")
        print("🔢 Negative minus negative: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, -5, "Negative minus negative should equal -5")
    }

    func testZeroMinusNegative() async throws {
        // 0 - (-4) = 4
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number16")
        print("🔢 Zero minus negative: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, 4, "Zero minus negative should equal 4")
    }

    // MARK: - Multiplication Tests

    func testBasicMultiplication() async throws {
        // 3 * 4 = 12
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number17")
        print("🔢 Basic multiplication: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, 12, "Basic multiplication should equal 12")
    }

    func testMultiplyingByZero() async throws {
        // 0 * 9 = 0
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number18")
        print("🔢 Multiplying by zero: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, 0, "Multiplying by zero should equal 0")
    }

    func testNegativeTimesPositive() async throws {
        // -2 * 5 = -10
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number19")
        print("🔢 Negative times positive: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, -10, "Negative times positive should equal -10")
    }

    func testDecimalMultiplication() async throws {
        // 1.5 * 2 = 3.0
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number20")
        print("🔢 Decimal multiplication: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number ?? 0, 3.0, accuracy: 0.001, "Decimal multiplication should equal 3.0")
    }

    func testNegativeTimesPositive1() async throws {
        // -4 * 2 = -8
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number21")
        print("🔢 Negative times positive: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, -8, "Negative times positive should equal -8")
    }

    func testPositiveTimesNegative() async throws {
        // 3 * (-5) = -15
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number22")
        print("🔢 Positive times negative: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, -15, "Positive times negative should equal -15")
    }

    func testNegativeTimesNegativeProducesPositive() async throws {
        // -3 * (-6) = 18
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number23")
        print("🔢 Negative times negative: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, 18, "Negative times negative should equal 18")
    }

    func testMultiplicationByZeroWithNegative() async throws {
        // -7 * 0 = 0
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number24")
        print("🔢 Multiplication by zero with negative: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, 0, "Multiplication by zero with negative should equal 0")
    }

    // MARK: - Division Tests

    func testEvenDivision() async throws {
        // 10 / 2 = 5.0
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number25")
        print("🔢 Even division: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number ?? 0, 5.0, accuracy: 0.001, "Even division should equal 5.0")
    }

    func testCleanIntegerResult() async throws {
        // 9 / 3 = 3.0
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number26")
        print("🔢 Clean integer result: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number ?? 0, 3.0, accuracy: 0.001, "Clean integer result should equal 3.0")
    }

    func testDivisionWithDecimalResult() async throws {
        // 7 / 2 = 3.5
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number27")
        print("🔢 Division with decimal result: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number ?? 0, 3.5, accuracy: 0.001, "Division with decimal result should equal 3.5")
    }

    func testDivisionByZero() async throws {
        // 5 / 0 = Error/Infinity
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number28")
        print("🔢 Division by zero: \(result?.number ?? -1)")
        // Division by zero should either be nil, infinity, or NaN
        XCTAssertTrue(result?.number?.isInfinite == true || result?.number?.isNaN == true || result?.number == nil, "Division by zero should be infinity, NaN, or nil")
    }

    func testNegativeDividendPositiveDivisor() async throws {
        // -10 / 2 = -5.0
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number29")
        print("🔢 Negative dividend, positive divisor: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number ?? 0, -5.0, accuracy: 0.001, "Negative dividend, positive divisor should equal -5.0")
    }

    func testPositiveDividendNegativeDivisor() async throws {
        // 10 / (-2) = -5.0
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number30")
        print("🔢 Positive dividend, negative divisor: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number ?? 0, -5.0, accuracy: 0.001, "Positive dividend, negative divisor should equal -5.0")
    }

    func testNegativeDividedByNegativePositiveResult() async throws {
        // -12 / (-3) = 4.0
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number31")
        print("🔢 Negative divided by negative: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number ?? 0, 4.0, accuracy: 0.001, "Negative divided by negative should equal 4.0")
    }

    func testZeroDividedByNegativeNumber() async throws {
        // 0 / (-4) = 0.0
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number32")
        print("🔢 Zero divided by negative number: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number ?? 0, 0.0, accuracy: 0.001, "Zero divided by negative number should equal 0.0")
    }

    // MARK: - Mixed Operations Tests

    func testMixOfNegativeAdditionAndMultiplication() async throws {
        // -3 + 5 * -2 = -13
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number33")
        print("🔢 Mix of negative addition and multiplication: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, -13, "Mix of negative addition and multiplication should equal -13")
    }

    func testNegativeGroupingAndMultiplication() async throws {
        // (-4 + 2) * (-3) = 6
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number34")
        print("🔢 Negative grouping and multiplication: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, 6, "Negative grouping and multiplication should equal 6")
    }

    func testSubtractionAndMultiplicationWithNegation() async throws {
        // -10 - (-5) * 2 = 0
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number35")
        print("🔢 Subtraction and multiplication with negation: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, 0, "Subtraction and multiplication with negation should equal 0")
    }

    func testDivisionOfNegativeSum() async throws {
        // (-12 + 4) / -2 = 4.0
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number36")
        print("🔢 Division of negative sum: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number ?? 0, 4.0, accuracy: 0.001, "Division of negative sum should equal 4.0")
    }

    // MARK: - Operator Precedence Tests

    func testMultiplicationBeforeAdditionOperatorPrecedence() async throws {
        // 2 + 3 * 4 = 14
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number37")
        print("🔢 Multiplication before addition: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, 14, "Multiplication before addition should equal 14")
    }

    func testParenthesesOverridePrecedence() async throws {
        // (2 + 3) * 4 = 20
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number38")
        print("🔢 Parentheses override precedence: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, 20, "Parentheses override precedence should equal 20")
    }

    func testDivisionBeforeSubtraction() async throws {
        // 10 - 6 / 2 = 7.0
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number39")
        print("🔢 Division before subtraction: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number ?? 0, 7.0, accuracy: 0.001, "Division before subtraction should equal 7.0")
    }

    func testParenthesesAffectOrder() async throws {
        // (10 - 6) / 2 = 2.0
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number40")
        print("🔢 Parentheses affect order: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number ?? 0, 2.0, accuracy: 0.001, "Parentheses affect order should equal 2.0")
    }

    // MARK: - Nested Operations Tests

    func testMultiplyResultsOfTwoGroupedExpressions() async throws {
        // (5 + 3) * (2 - 1) = 8
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number41")
        print("🔢 Multiply results of two grouped expressions: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, 8, "Multiply results of two grouped expressions should equal 8")
    }

    func testNestedOperationsWithMultipleSteps() async throws {
        // ((4 + 2) * 3) - 5 = 13
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number42")
        print("🔢 Nested operations with multiple steps: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number, 13, "Nested operations with multiple steps should equal 13")
    }

    func testDivisionWithInnerGrouping() async throws {
        // (12 / (2 + 4)) + 1 = 3.0
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number43")
        print("🔢 Division with inner grouping: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number ?? 0, 3.0, accuracy: 0.001, "Division with inner grouping should equal 3.0")
    }

    func testCombinesAllOperatorsWithProperGrouping() async throws {
        // ((8 + 2) * 3 - 4) / 2 = 13.0
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number44")
        print("🔢 Combines all operators with proper grouping: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number ?? 0, 13.0, accuracy: 0.001, "Combines all operators with proper grouping should equal 13.0")
    }

    func testDeeplyNestedExpressionTestingFullOrderOfOperations() async throws {
        // 7 + 3 * (10 / (12 / (3 + 1) - 1)) = 22.0
        let result = documentEditor.value(ofFieldWithIdentifier: "field_number45")
        print("🔢 Deeply nested expression: \(result?.number ?? -1)")
        XCTAssertEqual(result?.number ?? 0, 22.0, accuracy: 0.001, "Deeply nested expression should equal 22.0")
    }
} 