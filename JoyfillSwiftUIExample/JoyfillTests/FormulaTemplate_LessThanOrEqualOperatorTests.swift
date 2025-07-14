//
//  FormulaTemplate_LessThanOrEqualOperatorTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 27/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class FormulaTemplate_LessThanOrEqualOperatorTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_LessThanOrEqualOperator")
        documentEditor = DocumentEditor(document: document)
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }

    // MARK: - Less Than Or Equal Operator Tests

    func testOneLessThanOrEqualTwo() async throws {
        // 1 <= 2 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text1")
        print("🔢 1 <= 2: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1 <= 2 should return Working")
    }

    func testOneLessThanOrEqualOne() async throws {
        // 1 <= 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text2")
        print("🔢 1 <= 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1 <= 1 should return Working")
    }

    func testTenLessThanOrEqualFive() async throws {
        // 10 <= 5 (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text3")
        print("🔢 10 <= 5: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "10 <= 5 should return Working")
    }

    func testNegativeOneLessThanOrEqualZero() async throws {
        // -1 <= 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text4")
        print("🔢 -1 <= 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "-1 <= 0 should return Working")
    }

    func testNegativeThreeLessThanOrEqualNegativeOne() async throws {
        // -3 <= -1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text5")
        print("🔢 -3 <= -1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "-3 <= -1 should return Working")
    }

    func testNegativeFiveLessThanOrEqualNegativeTen() async throws {
        // -5 <= -10 (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text6")
        print("🔢 -5 <= -10: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "-5 <= -10 should return Working")
    }

    func testNinetyNineLessThanOrEqualNinetyNinePointOne() async throws {
        // 99 <= 99.1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text7")
        print("🔢 99 <= 99.1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "99 <= 99.1 should return Working")
    }

    func testHundredLessThanOrEqualNinetyNine() async throws {
        // 100 <= 99 (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text8")
        print("🔢 100 <= 99: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "100 <= 99 should return Working")
    }

    func testStringFourLessThanOrEqualFive() async throws {
        // "4" <= 5 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text9")
        print("🔢 \"4\" <= 5: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"4\" <= 5 should return Working")
    }

    func testStringNineLessThanOrEqualTen() async throws {
        // "9" <= 10 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text10")
        print("🔢 \"9\" <= 10: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"9\" <= 10 should return Working")
    }

    func testStringZeroLessThanOrEqualOne() async throws {
        // "0" <= 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text11")
        print("🔢 \"0\" <= 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"0\" <= 1 should return Working")
    }

    func testStringHundredLessThanOrEqualTwoHundred() async throws {
        // "100" <= 200 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text12")
        print("🔢 \"100\" <= 200: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"100\" <= 200 should return Working")
    }

    func testStringFiveLessThanOrEqualFive() async throws {
        // "5" <= 5 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text13")
        print("🔢 \"5\" <= 5: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"5\" <= 5 should return Working")
    }

    func testStringFiveLessThanOrEqualStringOne() async throws {
        // "5" <= "1" (Expect: Working - false condition in string comparison)
        let result = documentEditor.value(ofFieldWithIdentifier: "text14")
        print("🔢 \"5\" <= \"1\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"5\" <= \"1\" should return Working")
    }

    func testHelloLessThanOrEqualAbc() async throws {
        // "hello" <= "abc" (Expect: Working - false condition in string comparison)
        let result = documentEditor.value(ofFieldWithIdentifier: "text15")
        print("🔢 \"hello\" <= \"abc\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"hello\" <= \"abc\" should return Working")
    }

    func testTrueLessThanOrEqualFalse() async throws {
        // true <= false (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text16")
        print("🔢 true <= false: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "true <= false should return Working")
    }

    func testFalseLessThanOrEqualTrue() async throws {
        // false <= true (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text17")
        print("🔢 false <= true: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "false <= true should return Working")
    }

    func testTrueLessThanOrEqualOne() async throws {
        // true <= 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text18")
        print("🔢 true <= 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "true <= 1 should return Working")
    }

    func testNullLessThanOrEqualZero() async throws {
        // null <= 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text19")
        print("🔢 null <= 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null <= 0 should return Working")
    }

    func testNullLessThanOrEqualNull() async throws {
        // null <= null (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text20")
        print("🔢 null <= null: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null <= null should return Working")
    }

    func testEmptyStringLessThanOrEqualZero() async throws {
        // "" <= 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text21")
        print("🔢 \"\" <= 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"\" <= 0 should return Working")
    }

    func testAbcLessThanOrEqualZero() async throws {
        // "abc" <= 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text22")
        print("🔢 \"abc\" <= 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"abc\" <= 0 should return Working")
    }

    func testEmptyArrayLessThanOrEqualOne() async throws {
        // [] <= 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text23")
        print("🔢 [] <= 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "[] <= 1 should return Working")
    }

    func testArrayOneLessThanOrEqualZero() async throws {
        // -1 <= 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text24")
        print("🔢 -1 <= 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "-1 <= 0 should return Working")
    }

    func testEmptyObjectLessThanOrEqualOne() async throws {
        // {} <= 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text25")
        print("🔢 {} <= 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "{} <= 1 should return Working")
    }

    func testObjectLessThanOrEqualOne() async throws {
        // { a: 1 } <= 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text26")
        print("🔢 { a: 1 } <= 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "{ a: 1 } <= 1 should return Working")
    }
} 