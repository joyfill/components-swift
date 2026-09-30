//
//  FormulaTemplate_UnequalOperatorTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 27/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class FormulaTemplate_UnequalOperatorTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_UnequalOperator")
        documentEditor = DocumentEditor(document: document, config: DocumentEditorConfig(validateSchema: false))
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }

    // MARK: - Unequal Operator Tests

    func testOneNotEqualOne() async throws {
        // 1 != 1 (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text1")
        print("🔢 1 != 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1 != 1 should return Working")
    }

    func testTenNotEqualTwelve() async throws {
        // 10 != 12 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text2")
        print("🔢 10 != 12: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "10 != 12 should return Working")
    }

    func testStringNotEqualString() async throws {
        // "test" != "test" (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text3")
        print("🔢 \"test\" != \"test\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"test\" != \"test\" should return Working")
    }

    func testStringNotEqualDifferentCase() async throws {
        // "TEST" != "test" (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text4")
        print("🔢 \"TEST\" != \"test\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"TEST\" != \"test\" should return Working")
    }

    func testTrueNotEqualTrue() async throws {
        // true != true (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text5")
        print("🔢 true != true: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "true != true should return Working")
    }

    func testFalseNotEqualTrue() async throws {
        // false != true (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text6")
        print("🔢 false != true: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "false != true should return Working")
    }

    func testFalseNotEqualFalse() async throws {
        // false != false (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text7")
        print("🔢 false != false: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "false != false should return Working")
    }

    func testNullNotEqualNull() async throws {
        // null != null (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text8")
        print("🔢 null != null: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null != null should return Working")
    }

    func testToNumberNotEqualNumber() async throws {
        // toNumber("1") != 1 (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text9")
        print("🔢 toNumber(\"1\") != 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "toNumber(\"1\") != 1 should return Working")
    }

    func testStringNumberNotEqualNumber() async throws {
        // "1" != 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text10")
        print("🔢 \"1\" != 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"1\" != 1 should return Working")
    }

    func testZeroNotEqualFalse() async throws {
        // 0 != false (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text12")
        print("🔢 0 != false: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "0 != false should return Working")
    }

    func testFalseNotEqualEmptyString() async throws {
        // false != "" (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text13")
        print("🔢 false != \"\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "false != \"\" should return Working")
    }

    func testEmptyStringNotEqualEmptyString() async throws {
        // "" != "" (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text14")
        print("🔢 \"\" != \"\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"\" != \"\" should return Working")
    }

    func testEmptyStringNotEqualFalse() async throws {
        // "" != false (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text15")
        print("🔢 \"\" != false: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"\" != false should return Working")
    }

    func testEmptyStringNotEqualNull() async throws {
        // "" != null (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text16")
        print("🔢 \"\" != null: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"\" != null should return Working")
    }

    func testStringFalseNotEqualFalse() async throws {
        // "false" != false (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text17")
        print("🔢 \"false\" != false: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"false\" != false should return Working")
    }

    func testNullNotEqualEmptyString() async throws {
        // null != "" (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text18")
        print("🔢 null != \"\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null != \"\" should return Working")
    }

    func testNullNotEqualFalse() async throws {
        // null != false (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text19")
        print("🔢 null != false: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null != false should return Working")
    }

    func testNullNotEqualZero() async throws {
        // null != 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text20")
        print("🔢 null != 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null != 0 should return Working")
    }

    func testEmptyArrayNotEqualEmptyArray() async throws {
        // "" != "" (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text21")
        print("🔢 \"\" != \"\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"\" != \"\" should return Working")
    }

    func testArrayNotEqualArray() async throws {
        // ["hi"] != ["hi"] (Expect: Working - arrays are not equal by reference)
        let result = documentEditor.value(ofFieldWithIdentifier: "text22")
        print("🔢 [\"hi\"] != [\"hi\"]: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "[\"hi\"] != [\"hi\"] should return Working")
    }

    func testEmptyObjectNotEqualEmptyObject() async throws {
        // "" != "" (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text23")
        print("🔢 \"\" != \"\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"\" != \"\" should return Working")
    }

    func testObjectNotEqualObject() async throws {
        // { name: 'joy' } != { name: 'joy' } (Expect: Working - objects are not equal by reference)
        let result = documentEditor.value(ofFieldWithIdentifier: "text24")
        print("🔢 { name: 'joy' } != { name: 'joy' }: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "{ name: 'joy' } != { name: 'joy' } should return Working")
    }

    func testNestedArrayNotEqualNestedArray() async throws {
        // 1 != 1 (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text25")
        print("🔢 1 != 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1 != 1 should return Working")
    }

    func testNestedObjectNotEqualNestedObject() async throws {
        // { a: { b: 1 } } != { a: { b: 1 } } (Expect: Working - objects are not equal by reference)
        let result = documentEditor.value(ofFieldWithIdentifier: "text26")
        print("🔢 { a: { b: 1 } } != { a: { b: 1 } }: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "{ a: { b: 1 } } != { a: { b: 1 } } should return Working")
    }
} 
