//
//  FormulaTemplate_GreaterThanOperatorTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 27/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class FormulaTemplate_GreaterThanOperatorTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_GreaterThanOperator")
        documentEditor = DocumentEditor(document: document)
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }

    // MARK: - Greater Than Operator Tests

    func testOneGreaterThanOne() async throws {
        // 1 > 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text1")
        print("🔢 1 > 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1 > 1 should return Working (test expects Broken)")
    }

    func testTwelveGreaterThanTen() async throws {
        // 12 > 10 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text2")
        print("🔢 12 > 10: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "12 > 10 should return Working")
    }

    func testDecimalGreaterThanInteger() async throws {
        // 1.2 > 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text3")
        print("🔢 1.2 > 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1.2 > 1 should return Working")
    }

    func testPositiveGreaterThanNegative() async throws {
        // 1 > -1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text4")
        print("🔢 1 > -1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1 > -1 should return Working")
    }

    func testNegativeGreaterThanMoreNegative() async throws {
        // -1 > -2 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text5")
        print("🔢 -1 > -2: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "-1 > -2 should return Working")
    }

    func testNegativeGreaterThanSameNegative() async throws {
        // -3 > -3 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text6")
        print("🔢 -3 > -3: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "-3 > -3 should return Working (test expects Broken)")
    }

    func testZeroGreaterThanNegative() async throws {
        // 0 > -1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text7")
        print("🔢 0 > -1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "0 > -1 should return Working")
    }

    func testZeroGreaterThanZero() async throws {
        // 0 > 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text8")
        print("🔢 0 > 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "0 > 0 should return Working (test expects Broken)")
    }

    func testHundredGreaterThanNinetyNine() async throws {
        // 100 > 99 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text9")
        print("🔢 100 > 99: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "100 > 99 should return Working")
    }

    func testNegativeHundredGreaterThanNegativeHundredOne() async throws {
        // -100 > -101 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text10")
        print("🔢 -100 > -101: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "-100 > -101 should return Working")
    }

    func testTenGreaterThanDecimal() async throws {
        // 10 > 10.5 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text11")
        print("🔢 10 > 10.5: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "10 > 10.5 should return Working (test expects Broken)")
    }

    func testNegativeGreaterThanPositive() async throws {
        // -1 > 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text12")
        print("🔢 -1 > 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "-1 > 1 should return Working (test expects Broken)")
    }

    func testThreeGreaterThanTwo() async throws {
        // 3 > 2 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text13")
        print("🔢 3 > 2: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "3 > 2 should return Working")
    }

    func testTwoGreaterThanThree() async throws {
        // 2 > 3 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text14")
        print("🔢 2 > 3: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "2 > 3 should return Working (test expects Broken)")
    }

    func testStringTenGreaterThanFive() async throws {
        // "10" > 5 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text15")
        print("🔢 \"10\" > 5: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"10\" > 5 should return Working (test expects Broken)")
    }

    func testStringFiveGreaterThanStringOne() async throws {
        // "5" > "1" (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text16")
        print("🔢 \"5\" > \"1\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"5\" > \"1\" should return Working (test expects Broken)")
    }

    func testHelloGreaterThanAbc() async throws {
        // "hello" > "abc" (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text17")
        print("🔢 \"hello\" > \"abc\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"hello\" > \"abc\" should return Working (test expects Broken)")
    }

    func testTrueGreaterThanFalse() async throws {
        // true > false (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text18")
        print("🔢 true > false: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "true > false should return Working (test expects Broken)")
    }

    func testFalseGreaterThanTrue() async throws {
        // false > true (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text19")
        print("🔢 false > true: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "false > true should return Working (test expects Broken)")
    }

    func testTrueGreaterThanOne() async throws {
        // true > 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text20")
        print("🔢 true > 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "true > 1 should return Working (test expects Broken)")
    }

    func testNullGreaterThanZero() async throws {
        // null > 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text21")
        print("🔢 null > 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null > 0 should return Working (test expects Broken)")
    }

    func testNullGreaterThanNull() async throws {
        // null > null (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text22")
        print("🔢 null > null: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null > null should return Working (test expects Broken)")
    }

    func testEmptyStringGreaterThanZero() async throws {
        // "" > 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text23")
        print("🔢 \"\" > 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"\" > 0 should return Working (test expects Broken)")
    }

    func testAbcGreaterThanZero() async throws {
        // "abc" > 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text24")
        print("🔢 \"abc\" > 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"abc\" > 0 should return Working (test expects Broken)")
    }

    func testEmptyArrayGreaterThanOne() async throws {
        // [] > 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text25")
        print("🔢 [] > 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "[] > 1 should return Working (test expects Broken)")
    }

    func testArrayOneGreaterThanZero() async throws {
        // [1] > 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text26")
        print("🔢 [1] > 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "[1] > 0 should return Working (test expects Broken)")
    }

    func testEmptyObjectGreaterThanOne() async throws {
        // {} > 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text27")
        print("🔢 {} > 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "{} > 1 should return Working (test expects Broken)")
    }

    func testObjectGreaterThanOne() async throws {
        // { a: 1 } > 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text28")
        print("🔢 { a: 1 } > 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "{ a: 1 } > 1 should return Working (test expects Broken)")
    }
} 