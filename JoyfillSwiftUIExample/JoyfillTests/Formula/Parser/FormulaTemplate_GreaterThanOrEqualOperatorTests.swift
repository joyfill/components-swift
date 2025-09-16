//
//  FormulaTemplate_GreaterThanOrEqualOperatorTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 27/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class FormulaTemplate_GreaterThanOrEqualOperatorTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_GreaterThanOrEqualOperator")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }

    // MARK: - Greater Than Or Equal Operator Tests

    func testTwoGreaterThanOrEqualOne() async throws {
        // 2 >= 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text1")
        print("🔢 2 >= 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "2 >= 1 should return Working")
    }

    func testOneGreaterThanOrEqualOne() async throws {
        // 1 >= 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text2")
        print("🔢 1 >= 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1 >= 1 should return Working")
    }

    func testOneGreaterThanOrEqualTwo() async throws {
        // 1 >= 2 (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text3")
        print("🔢 1 >= 2: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "1 >= 2 should return Working")
    }

    func testZeroGreaterThanOrEqualNegativeOne() async throws {
        // 0 >= -1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text4")
        print("🔢 0 >= -1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "0 >= -1 should return Working")
    }

    func testNegativeThreeGreaterThanOrEqualNegativeThree() async throws {
        // -3 >= -3 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text5")
        print("🔢 -3 >= -3: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "-3 >= -3 should return Working")
    }

    func testNegativeFiveGreaterThanOrEqualNegativeTwo() async throws {
        // -5 >= -2 (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text6")
        print("🔢 -5 >= -2: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "-5 >= -2 should return Working")
    }

    func testHundredGreaterThanOrEqualNinetyNine() async throws {
        // 100 >= 99 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text7")
        print("🔢 100 >= 99: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "100 >= 99 should return Working")
    }

    func testNinetyNinePointNineGreaterThanOrEqualHundred() async throws {
        // 99.9 >= 100 (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text8")
        print("🔢 99.9 >= 100: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "99.9 >= 100 should return Working")
    }

    func testNegativeOneGreaterThanOrEqualZero() async throws {
        // -1 >= 0 (Expect: Working - false condition)
        let result = documentEditor.value(ofFieldWithIdentifier: "text9")
        print("🔢 -1 >= 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "-1 >= 0 should return Working")
    }

    func testNegativeHundredGreaterThanOrEqualNegativeHundredOne() async throws {
        // -100 >= -101 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text10")
        print("🔢 -100 >= -101: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "-100 >= -101 should return Working")
    }

    func testStringTenGreaterThanOrEqualFive() async throws {
        // "10" >= 5 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text11")
        print("🔢 \"10\" >= 5: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"10\" >= 5 should return Working")
    }

    func testStringFiveGreaterThanOrEqualStringOne() async throws {
        // "5" >= "1" (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text12")
        print("🔢 \"5\" >= \"1\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"5\" >= \"1\" should return Working")
    }

    func testHelloGreaterThanOrEqualAbc() async throws {
        // "hello" >= "abc" (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text13")
        print("🔢 \"hello\" >= \"abc\": \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"hello\" >= \"abc\" should return Working")
    }

    func testTrueGreaterThanOrEqualFalse() async throws {
        // true >= false (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text14")
        print("🔢 true >= false: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "true >= false should return Working")
    }

    func testFalseGreaterThanOrEqualTrue() async throws {
        // false >= true (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text15")
        print("🔢 false >= true: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "false >= true should return Working")
    }

    func testTrueGreaterThanOrEqualOne() async throws {
        // true >= 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text16")
        print("🔢 true >= 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "true >= 1 should return Working")
    }

    func testNullGreaterThanOrEqualZero() async throws {
        // null >= 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text17")
        print("🔢 null >= 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null >= 0 should return Working")
    }

    func testNullGreaterThanOrEqualNull() async throws {
        // null >= null (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text18")
        print("🔢 null >= null: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "null >= null should return Working")
    }

    func testEmptyStringGreaterThanOrEqualZero() async throws {
        // "" >= 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text19")
        print("🔢 \"\" >= 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"\" >= 0 should return Working")
    }

    func testAbcGreaterThanOrEqualZero() async throws {
        // "abc" >= 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text20")
        print("🔢 \"abc\" >= 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "\"abc\" >= 0 should return Working")
    }

    func testEmptyArrayGreaterThanOrEqualOne() async throws {
        // [] >= 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text21")
        print("🔢 [] >= 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "[] >= 1 should return Working")
    }

    func testArrayOneGreaterThanOrEqualZero() async throws {
        // [1] >= 0 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text22")
        print("🔢 [1] >= 0: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "[1] >= 0 should return Working")
    }

    func testEmptyObjectGreaterThanOrEqualOne() async throws {
        // {} >= 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text23")
        print("🔢 {} >= 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "{} >= 1 should return Working")
    }

    func testObjectGreaterThanOrEqualOne() async throws {
        // { a: 1 } >= 1 (Expect: Working)
        let result = documentEditor.value(ofFieldWithIdentifier: "text24")
        print("🔢 { a: 1 } >= 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Working", "{ a: 1 } >= 1 should return Working")
    }
} 
