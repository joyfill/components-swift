//
//  FormulaTemplate_LessThanOperatorTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 27/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class FormulaTemplate_LessThanOperatorTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_LessThanOperator")
        documentEditor = DocumentEditor(document: document, shouldValidate: false)
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }

    // MARK: - Less Than Operator Tests

    func testOneLessThanTwo() async throws {
        // 1 < 2 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text1")
        print("🔢 1 < 2: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1 < 2 should return Working")
    }

    func testOneLessThanOne() async throws {
        // 1 < 1 (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text2")
        print("🔢 1 < 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1 < 1 should return Working")
    }

    func testTenLessThanFive() async throws {
        // 10 < 5 (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text3")
        print("🔢 10 < 5: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "10 < 5 should return Working")
    }

    func testNegativeOneLessThanZero() async throws {
        // -1 < 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text4")
        print("🔢 -1 < 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "-1 < 0 should return Working")
    }

    func testNegativeThreeLessThanNegativeOne() async throws {
        // -3 < -1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text5")
        print("🔢 -3 < -1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "-3 < -1 should return Working")
    }

    func testNegativeFiveLessThanNegativeTen() async throws {
        // -5 < -10 (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text6")
        print("🔢 -5 < -10: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "-5 < -10 should return Working")
    }

    func testNinetyNineLessThanNinetyNinePointOne() async throws {
        // 99 < 99.1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text7")
        print("🔢 99 < 99.1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "99 < 99.1 should return Working")
    }

    func testHundredLessThanNinetyNine() async throws {
        // 100 < 99 (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text8")
        print("🔢 100 < 99: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "100 < 99 should return Working")
    }

    func testStringTenLessThanFive() async throws {
        // 10 < 5 (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text9")
        print("🔢 10 < 5: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "10 < 5 should return Working")
    }

    func testStringFiveLessThanStringOne() async throws {
        // "5" < "1" (Expect: Working - false condition in string comparison)
        let result = documentEditor.value(ofFieldWithIdentifier: "text10")
        print("🔢 \"5\" < \"1\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"5\" < \"1\" should return Working")
    }

    func testHelloLessThanAbc() async throws {
        // "hello" < "abc" (Expect: Working - false condition in string comparison)
        let result = documentEditor.value(ofFieldWithIdentifier: "text11")
        print("🔢 \"hello\" < \"abc\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"hello\" < \"abc\" should return Working")
    }

    func testTrueLessThanFalse() async throws {
        // true < false (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text12")
        print("🔢 true < false: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "true < false should return Working")
    }

    func testFalseLessThanTrue() async throws {
        // false < true (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text13")
        print("🔢 false < true: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "false < true should return Working")
    }

    func testTrueLessThanOne() async throws {
        // true < 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text14")
        print("🔢 true < 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "true < 1 should return Working")
    }

    func testNullLessThanZero() async throws {
        // null < 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text15")
        print("🔢 null < 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null < 0 should return Working")
    }

    func testNullLessThanNull() async throws {
        // null < null (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text16")
        print("🔢 null < null: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null < null should return Working")
    }

    func testEmptyStringLessThanZero() async throws {
        // "" < 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text17")
        print("🔢 \"\" < 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"\" < 0 should return Working")
    }

    func testAbcLessThanZero() async throws {
        // "abc" < 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text18")
        print("🔢 \"abc\" < 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"abc\" < 0 should return Working")
    }

    func testEmptyArrayLessThanOne() async throws {
        // [] < 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text19")
        print("🔢 [] < 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "[] < 1 should return Working")
    }

    func testArrayOneLessThanZero() async throws {
        // -1 < 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text20")
        print("🔢 -1 < 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "-1 < 0 should return Working")
    }

    func testEmptyObjectLessThanOne() async throws {
        // {} < 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text21")
        print("🔢 {} < 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "{} < 1 should return Working")
    }

    func testObjectLessThanOne() async throws {
        // { a: 1 } < 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text22")
        print("🔢 { a: 1 } < 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "{ a: 1 } < 1 should return Working")
    }

    func testStringFourLessThanFive() async throws {
        // "4" < 5 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text23")
        print("🔢 \"4\" < 5: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"4\" < 5 should return Working")
    }

    func testStringFiveLessThanFive() async throws {
        // "5" < 5 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text24")
        print("🔢 \"5\" < 5: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"5\" < 5 should return Working")
    }
} 
