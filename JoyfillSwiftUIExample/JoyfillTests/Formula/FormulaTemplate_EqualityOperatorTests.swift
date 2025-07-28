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
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }

    // MARK: - Equality Operator Tests

    func testOneEqualsOne() async throws {
        // 1 == 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text1")
        print("🔢 1 == 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1 == 1 should return Working")
    }

    func testOneEqualsOneExplicit() async throws {
        // 1 == 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text2")
        print("🔢 1 == 1 (explicit): \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1 == 1 should return Working")
    }

    func testTenEqualsEleven() async throws {
        // 10 == 12 (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "text3")
        print("🔢 10 == 12: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "10 == 12 should return Working (since 10 != 12)")
    }

    func testStringTestEqualsTest() async throws {
        // "test" == "test" (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text4")
        print("🔤 \"test\" == \"test\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"test\" == \"test\" should return Working")
    }

    func testStringTESTEqualstest() async throws {
        // "TEST" == "test" (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "text5")
        print("🔤 \"TEST\" == \"test\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"TEST\" == \"test\" should return Working (since they're different)")
    }

    func testTrueEqualsTrue() async throws {
        // true == true (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text6")
        print("✅ true == true: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "true == true should return Working")
    }

    func testFalseEqualsTrue() async throws {
        // false == true (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "text7")
        print("❌ false == true: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "false == true should return Working (since they're different)")
    }

    func testNullEqualsNull() async throws {
        // null == null (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text8")
        print("⭕ null == null: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null == null should return Working")
    }

    func testToNumberOneEqualsOne() async throws {
        // toNumber("1") == 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text9")
        print("🔢 toNumber(\"1\") == 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "toNumber(\"1\") == 1 should return Working")
    }

    func testStringOneEqualsOne() async throws {
        // "1" == 1 (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "text10")
        print("🔤 \"1\" == 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"1\" == 1 should return Working (since string != number)")
    }

    func testStringTrueEqualsTrue() async throws {
        // "true" == true (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "text11")
        print("🔤 \"true\" == true: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"true\" == true should return Working (since string != boolean)")
    }

    func testZeroEqualsFalse() async throws {
        // 0 == false (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "text12")
        print("🔢 0 == false: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "0 == false should return Working (since number != boolean)")
    }

    func testFalseEqualsEmptyString() async throws {
        // false == "" (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "text13")
        print("❌ false == \"\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "false == \"\" should return Working (since boolean != string)")
    }

    func testEmptyArrayEqualsEmptyArray() async throws {
        // [] == [] (Expect: Broken - arrays are not equal by reference)
        let result = documentEditor.value(ofFieldWithIdentifier: "text14")
        print("📦 [] == []: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "[] == [] should return Working (arrays not equal by reference)")
    }

    func testArrayHiEqualsArrayHi() async throws {
        // ["hi"] == ["hi"] (Expect: Broken - arrays are not equal by reference)
        let result = documentEditor.value(ofFieldWithIdentifier: "text15")
        print("📦 [\"hi\"] == [\"hi\"]: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "[\"hi\"] == [\"hi\"] should return Working (arrays not equal by reference)")
    }

    func testEmptyObjectEqualsEmptyObject() async throws {
        // {} == {} (Expect: Broken - objects are not equal by reference)
        let result = documentEditor.value(ofFieldWithIdentifier: "text16")
        print("🏗️ {} == {}: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "{} == {} should return Working (objects not equal by reference)")
    }

    func testObjectNameJoyEqualsObjectNameJoy() async throws {
        // { name: "joy" } == { name: "joy" } (Expect: Broken - objects are not equal by reference)
        let result = documentEditor.value(ofFieldWithIdentifier: "text17")
        print("🏗️ { name: \"joy\" } == { name: \"joy\" }: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "{ name: \"joy\" } == { name: \"joy\" } should return Working (objects not equal by reference)")
    }

    func testEmptyStringEqualsEmptyString() async throws {
        // "" == "" (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text18")
        print("📝 \"\" == \"\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"\" == \"\" should return Working")
    }

    func testEmptyStringEqualsFalse() async throws {
        // "" == false (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "text19")
        print("📝 \"\" == false: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"\" == false should return Working (since string != boolean)")
    }

    func testEmptyStringEqualsNull() async throws {
        // "" == null (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "text20")
        print("📝 \"\" == null: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"\" == null should return Working (since string != null)")
    }

    func testOneEqualsTrue() async throws {
        // 1 == true (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "text21")
        print("🔢 1 == true: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1 == true should return Working (since number != boolean)")
    }

    func testZeroEqualsFalse2() async throws {
        // 0 == false (Expect: Broken) - second test
        let result = documentEditor.value(ofFieldWithIdentifier: "text22")
        print("🔢 0 == false (2): \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "0 == false should return Working (since number != boolean)")
    }

    func testArrayAEqualsStringA() async throws {
        // ["a"] == "a" (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "text23")
        print("📦 [\"a\"] == \"a\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "[\"a\"] == \"a\" should return Working (since array != string)")
    }

    func testEmptyObjectEqualsObjectString() async throws {
        // {} == "[object Object]" (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "text24")
        print("🏗️ {} == \"[object Object]\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "{} == \"[object Object]\" should return Working (since object != string)")
    }

    func testNullEqualsUndefined() async throws {
        // null == undefined (Expect: Broken - null != undefined)
        let result = documentEditor.value(ofFieldWithIdentifier: "text25")
        print("⭕ null == undefined: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null == undefined should return Working (null != undefined)")
    }

    func testNullEqualsFalse() async throws {
        // null == false (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "text26")
        print("⭕ null == false: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null == false should return Working (since null != boolean)")
    }

    func testNullEqualsZero() async throws {
        // null == 0 (Expect: Broken)
        let result = documentEditor.value(ofFieldWithIdentifier: "text27")
        print("⭕ null == 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null == 0 should return Working (since null != number)")
    }

    func testNestedArrayEqualsNestedArray() async throws {
        // [[1]] == [[1]] (Expect: Broken - arrays are not equal by reference)
        let result = documentEditor.value(ofFieldWithIdentifier: "text28")
        print("📦 [[1]] == [[1]]: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "[[1]] == [[1]] should return Working (arrays not equal by reference)")
    }

    func testNestedObjectEqualsNestedObject() async throws {
        // { a: { b: 1 } } == { a: { b: 1 } } (Expect: Broken - objects are not equal by reference)
        let result = documentEditor.value(ofFieldWithIdentifier: "text29")
        print("🏗️ { a: { b: 1 } } == { a: { b: 1 } }: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "{ a: { b: 1 } } == { a: { b: 1 } } should return Working (objects not equal by reference)")
    }
} 
