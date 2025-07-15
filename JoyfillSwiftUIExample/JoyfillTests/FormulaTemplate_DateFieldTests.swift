//
//  FormulaTemplate_DateFieldTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 27/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class FormulaTemplate_DateFieldTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_DateField")
        documentEditor = DocumentEditor(document: document)
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }

    // MARK: - Date Formula Tests

    func testExtractYearFromDate1() async throws {
        // year(date1) (Expect: 2025)
        let result = documentEditor.value(ofFieldWithIdentifier: "number2")
        print("📅 Extract year from Date 1: \(result?.number ?? 0)")
        XCTAssertEqual(result?.number, 2025, "year(date1) should return 2025")
    }

    func testExtractMonthFromDate1() async throws {
        // month(date1) (Expect: 6)
        let result = documentEditor.value(ofFieldWithIdentifier: "number3")
        print("📅 Extract month from Date 1: \(result?.number ?? 0)")
        XCTAssertEqual(result?.number, 6, "month(date1) should return 6")
    }

    func testExtractDayFromDate1() async throws {
        // day(date1) (Expect: 1)
        let result = documentEditor.value(ofFieldWithIdentifier: "number4")
        print("📅 Extract day from Date 1: \(result?.number ?? 0)")
        XCTAssertEqual(result?.number, 1, "day(date1) should return 1")
    }

    func testAdd5DaysToDate1() async throws {
        // dateAdd(date1, 5, "days") (Expect: 1749229200000)
        let result = documentEditor.value(ofFieldWithIdentifier: "date5")
        print("📅 Add 5 days to Date 1: \(result?.number ?? 0)")
        XCTAssertEqual(result?.number, 1749229200000, "dateAdd(date1, 5, \"days\") should return 1749229200000")
    }

    func testSubtract2WeeksFromDate1() async throws {
        // dateSubtract(date1, 2, "weeks") (Expect: 1747587600000)
        let result = documentEditor.value(ofFieldWithIdentifier: "date6")
        print("📅 Subtract 2 weeks from Date 1: \(result?.number ?? 0)")
        XCTAssertEqual(result?.number, 1747587600000, "dateSubtract(date1, 2, \"weeks\") should return 1747587600000")
    }

    func testDaysBetweenNowAndDate1() async throws {
        // (now() - date1) / (1000 * 60 * 60 * 24) (Expect: approximately 25.38, but varies with current time)
        // NOTE: This test is currently failing due to a formula engine issue with date arithmetic.
        // The formula engine throws: typeMismatch(expected: "Numbers for '-'", actual: "Date and Date")
        // This should be fixed in the formula engine to properly handle date subtraction.

        let result = documentEditor.value(ofFieldWithIdentifier: "number7")
        print("📅 Days between now and Date 1: \(result?.number ?? 0)")
        
        // Since this depends on current time, we'll verify it's a reasonable positive number
        // The spec suggests around 25.38 days, so we'll allow a range
        let daysDifference = result?.number ?? 0
        XCTAssertGreaterThan(daysDifference, 0, "Days between now and date1 should be positive (date1 is in the past)")
        XCTAssertLessThan(daysDifference, 100, "Days between now and date1 should be reasonable (less than 100 days)")

    }

    func testIsDate1InFuture() async throws {
        // date1 > now() (Expect: False)
        let result = documentEditor.value(ofFieldWithIdentifier: "text8")
        print("📅 Is Date 1 in the future: \(result?.bool ?? false)")
        XCTAssertEqual(result?.bool, false, "date1 > now() should return false (date1 is in the past)")
    }

    func testPastOrUpcomingBasedOnDate1() async throws {
        // if(date1 < now(), "Past", "Upcoming") (Expect: "Past")
        let result = documentEditor.value(ofFieldWithIdentifier: "text9")
        print("📅 Past or Upcoming based on Date 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Past", "if(date1 < now(), \"Past\", \"Upcoming\") should return \"Past\"")
    }

    // MARK: - Additional Helper Tests

    func testBaseDateValue() async throws {
        // Verify the base date1 value
        let result = documentEditor.value(ofFieldWithIdentifier: "date1")
        print("📅 Base Date 1 value: \(result?.number ?? 0)")
        XCTAssertEqual(result?.number, 1748797200000, "date1 should have the expected timestamp value")
    }

    func testDateFormatConsistency() async throws {
        // Verify that date operations maintain proper formatting
        let originalDate = documentEditor.value(ofFieldWithIdentifier: "date1")
        let dateAddResult = documentEditor.value(ofFieldWithIdentifier: "date5")
        let dateSubtractResult = documentEditor.value(ofFieldWithIdentifier: "date6")
        
        print("📅 Original Date: \(originalDate?.number ?? 0)")
        print("📅 Date + 5 days: \(dateAddResult?.number ?? 0)")
        print("📅 Date - 2 weeks: \(dateSubtractResult?.number ?? 0)")
        
        // Verify the mathematical relationships
        let fiveDaysInMs: Double = 5 * 24 * 60 * 60 * 1000
        let twoWeeksInMs: Double = 14 * 24 * 60 * 60 * 1000
        
        let expectedDateAdd = (originalDate?.number ?? 0) + fiveDaysInMs
        let expectedDateSubtract = (originalDate?.number ?? 0) - twoWeeksInMs
        
        XCTAssertEqual(dateAddResult?.number, expectedDateAdd, "Date addition should be mathematically correct")
        XCTAssertEqual(dateSubtractResult?.number, expectedDateSubtract, "Date subtraction should be mathematically correct")
    }
} 
