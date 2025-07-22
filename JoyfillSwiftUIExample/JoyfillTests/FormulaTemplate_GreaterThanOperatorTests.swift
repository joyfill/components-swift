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
        documentEditor = DocumentEditor(document: document, shouldValidate: false)
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }

    // MARK: - Greater Than Operator Tests

    func testOneGreaterThanOne() async throws {
        // 1 > 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text1")
        print("🔢 1 > 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1 > 1 should return Working (test expects Broken)")
    }

    func testTwelveGreaterThanTen() async throws {
        // 12 > 10 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text2")
        print("🔢 12 > 10: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "12 > 10 should return Working")
    }

    func testDecimalGreaterThanInteger() async throws {
        // 1.2 > 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text3")
        print("🔢 1.2 > 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1.2 > 1 should return Working")
    }

    func testOneGreaterThanOne2() async throws {
        // 1 > 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text4")
        print("🔢 1 > 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1 > 1 should return Working (test expects Broken)")
    }

    func testNegativeGreaterThanMoreNegative() async throws {
        // -1 > -2 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text5")
        print("🔢 -1 > -2: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "-1 > -2 should return Working")
    }

    func testNegativeGreaterThanSameNegative() async throws {
        // -3 > -3 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text6")
        print("🔢 -3 > -3: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "-3 > -3 should return Working (test expects Broken)")
    }

    func testPositiveGreaterThanNegative() async throws {
        // 0 > -1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text7")
        print("🔢 0 > -1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "0 > -1 should return Working")
    }

    func testZeroGreaterThanZero() async throws {
        // 0 > 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text8")
        print("🔢 0 > 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "0 > 0 should return Working (test expects Broken)")
    }

    func testHundredGreaterThanNinetyNine() async throws {
        // 100 > 99 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text9")
        print("🔢 100 > 99: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "100 > 99 should return Working")
    }

    func testNegativeHundredGreaterThanNegativeHundredOne() async throws {
        // -100 > -101 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text10")
        print("🔢 -100 > -101: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "-100 > -101 should return Working")
    }

    func testTenGreaterThanDecimal() async throws {
        // 10 > 10.5 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text11")
        print("🔢 10 > 10.5: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "10 > 10.5 should return Working (test expects Broken)")
    }

    func testOneGreaterThanOne3() async throws {
        // 1 > 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text12")
        print("🔢 1 > 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1 > 1 should return Working (test expects Broken)")
    }

    func testThreeGreaterThanTwo() async throws {
        // 3 > 2 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text13")
        print("🔢 3 > 2: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "3 > 2 should return Working")
    }

    func testTwoGreaterThanThree() async throws {
        // 2 > 3 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text14")
        print("🔢 2 > 3: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "2 > 3 should return Working (test expects Broken)")
    }

    func testStringTenGreaterThanFive() async throws {
        // "10" > 5 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text15")
        print("🔢 \"10\" > 5: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"10\" > 5 should return Working")
    }

    func testStringFiveGreaterThanStringOne() async throws {
        // "5" > "1" (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text16")
        print("🔢 \"5\" > \"1\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"5\" > \"1\" should return Working")
    }

    func testHelloGreaterThanAbc() async throws {
        // "hello" > "abc" (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text17")
        print("🔢 \"hello\" > \"abc\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"hello\" > \"abc\" should return Working")
    }

    func testTrueGreaterThanFalse() async throws {
        // true > false (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text18")
        print("🔢 true > false: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "true > false should return Working")
    }

    func testFalseGreaterThanTrue() async throws {
        // false > true (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text19")
        print("🔢 false > true: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "false > true should return Working")
    }

    func testTrueGreaterThanOne() async throws {
        // true > 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text20")
        print("🔢 true > 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "true > 1 should return Working")
    }

    func testNullGreaterThanZero() async throws {
        // null > 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text21")
        print("🔢 null > 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null > 0 should return Working")
    }

    func testNullGreaterThanNull() async throws {
        // null > null (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text22")
        print("🔢 null > null: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null > null should return Working")
    }

    func testEmptyStringGreaterThanZero() async throws {
        // "" > 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text23")
        print("🔢 \"\" > 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"\" > 0 should return Working")
    }

    func testAbcGreaterThanZero() async throws {
        // "abc" > 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text24")
        print("🔢 \"abc\" > 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"abc\" > 0 should return Working")
    }

    func testEmptyArrayGreaterThanOne() async throws {
        // [] > 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text25")
        print("🔢 [] > 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "[] > 1 should return Working")
    }

    func testArrayOneGreaterThanZero() async throws {
        // [1] > 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text26")
        print("🔢 [1] > 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "[1] > 0 should return Working")
    }

    func testEmptyArrayGreaterThanOneAlternate() async throws {
        // [] > 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text27")
        print("🔢 [] > 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "[] > 1 should return Working")
    }

    func testObjectGreaterThanOne() async throws {
        // { a: 1 } > 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text28")
        print("🔢 { a: 1 } > 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "{ a: 1 } > 1 should return Working")
    }
} 
