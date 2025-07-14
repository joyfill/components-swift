//
//  FormulaTemplate_EqualityOperatorTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 27/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class FormulaTemplate_EqualityOperatorTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_EqualityOperator")
        documentEditor = DocumentEditor(document: document)
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }

    // MARK: - Equality Operator Tests

    func testOneEqualsOne() async throws {
        // 1 == 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text1")
        print("🔢 1 == 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1 == 1 should return Working")
    }

    func testOneEqualsOneExplicit() async throws {
        // 1 == 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text2")
        print("🔢 1 == 1 (explicit): \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1 == 1 should return Working")
    }

    func testTenEqualstwelve() async throws {
        // 10 == 12 (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text3")
        print("🔢 10 == 12: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "10 == 12 should return Working (test expects Broken)")
    }

    func testStringEqualsString() async throws {
        // "test" == "test" (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text4")
        print("🔢 \"test\" == \"test\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"test\" == \"test\" should return Working")
    }

    func testStringEqualsCaseSensitive() async throws {
        // "TEST" == "test" (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text5")
        print("🔢 \"TEST\" == \"test\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"TEST\" == \"test\" should return Working (test expects Broken)")
    }

    func testTrueEqualsTrue() async throws {
        // true == true (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text6")
        print("🔢 true == true: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "true == true should return Working")
    }

    func testFalseEqualsTrue() async throws {
        // false == true (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text7")
        print("🔢 false == true: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "false == true should return Working (test expects Broken)")
    }

    func testNullEqualsNull() async throws {
        // null == null (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text8")
        print("🔢 null == null: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null == null should return Working")
    }

    func testToNumberStringEqualsNumber() async throws {
        // toNumber("1") == 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text9")
        print("🔢 toNumber(\"1\") == 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "toNumber(\"1\") == 1 should return Working")
    }

    func testStringNumberEqualsNumber() async throws {
        // "1" == 1 (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text10")
        print("🔢 \"1\" == 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"1\" == 1 should return Working (test expects Broken)")
    }

    func testStringTrueEqualsTrue() async throws {
        // "true" == true (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text11")
        print("🔢 \"true\" == true: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"true\" == true should return Working (test expects Broken)")
    }

    func testZeroEqualsFalse() async throws {
        // 0 == false (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text12")
        print("🔢 0 == false: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "0 == false should return Working (test expects Broken)")
    }

    func testFalseEqualsEmptyString() async throws {
        // false == "" (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text13")
        print("🔢 false == \"\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "false == \"\" should return Working (test expects Broken)")
    }

    func testEmptyArrayEqualsEmptyArray() async throws {
        // [] == [] (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text14")
        print("🔢 [] == []: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "[] == [] should return Working (test expects Broken)")
    }

    func testArrayEqualsArray() async throws {
        // ["hi"] == ["hi"] (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text15")
        print("🔢 [\"hi\"] == [\"hi\"]: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "[\"hi\"] == [\"hi\"] should return Working (test expects Broken)")
    }

    func testEmptyObjectEqualsEmptyObject() async throws {
        // {} == {} (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text16")
        print("🔢 {} == {}: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "{} == {} should return Working (test expects Broken)")
    }

    func testObjectEqualsObject() async throws {
        // { name: 'joy' } == { name: 'joy' } (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text17")
        print("🔢 { name: 'joy' } == { name: 'joy' }: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "{ name: 'joy' } == { name: 'joy' } should return Working (test expects Broken)")
    }

    func testEmptyStringEqualsEmptyString() async throws {
        // "" == "" (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text18")
        print("🔢 \"\" == \"\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"\" == \"\" should return Working")
    }

    func testEmptyStringEqualsFalse() async throws {
        // "" == false (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text19")
        print("🔢 \"\" == false: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"\" == false should return Working (test expects Broken)")
    }

    func testEmptyStringEqualsNull() async throws {
        // "" == null (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text20")
        print("🔢 \"\" == null: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"\" == null should return Working (test expects Broken)")
    }

    func testOneEqualsTrue() async throws {
        // 1 == true (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text21")
        print("🔢 1 == true: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1 == true should return Working (test expects Broken)")
    }

    func testZeroEqualsFalseAgain() async throws {
        // 0 == false (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text22")
        print("🔢 0 == false (again): \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "0 == false should return Working (test expects Broken)")
    }

    func testArrayEqualsString() async throws {
        // ["a"] == "a" (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text23")
        print("🔢 [\"a\"] == \"a\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "[\"a\"] == \"a\" should return Working (test expects Broken)")
    }

    func testObjectEqualsString() async throws {
        // {} == "[object Object]" (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text24")
        print("🔢 {} == \"[object Object]\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "{} == \"[object Object]\" should return Working (test expects Broken)")
    }

    func testNullEqualsUndefined() async throws {
        // null == undefined (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text25")
        print("🔢 null == undefined: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null == undefined should return Working (test expects Broken)")
    }

    func testNullEqualsFalse() async throws {
        // null == false (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text26")
        print("🔢 null == false: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null == false should return Working (test expects Broken)")
    }

    func testNullEqualsZero() async throws {
        // null == 0 (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text27")
        print("🔢 null == 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null == 0 should return Working (test expects Broken)")
    }

    func testNestedArrayEqualsNestedArray() async throws {
        // [[1]] == [[1]] (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text28")
        print("🔢 [[1]] == [[1]]: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "[[1]] == [[1]] should return Working (test expects Broken)")
    }

    func testNestedObjectEqualsNestedObject() async throws {
        // { a: { b: 1 } } == { a: { b: 1 } } (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_text29")
        print("🔢 { a: { b: 1 } } == { a: { b: 1 } }: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "{ a: { b: 1 } } == { a: { b: 1 } } should return Working (test expects Broken)")
    }
} 