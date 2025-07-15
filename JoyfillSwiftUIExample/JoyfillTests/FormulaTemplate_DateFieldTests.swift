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
        let result = documentEditor.value(ofFieldWithIdentifier: "field_2")
        print("📅 Extract year from Date 1: \(result?.number ?? 0)")
        XCTAssertEqual(result?.number, 2025, "year(date1) should return 2025")
    }

    func testExtractMonthFromDate1() async throws {
        // month(date1) (Expect: 6)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_3")
        print("📅 Extract month from Date 1: \(result?.number ?? 0)")
        XCTAssertEqual(result?.number, 6, "month(date1) should return 6")
    }

    func testExtractDayFromDate1() async throws {
        // day(date1) (Expect: 1)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_4")
        print("📅 Extract day from Date 1: \(result?.number ?? 0)")
        XCTAssertEqual(result?.number, 1, "day(date1) should return 1")
    }

    func testAdd5DaysToDate1() async throws {
        // dateAdd(date1, 5, "days") (Expect: 1749229200000)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_date5")
        print("📅 Add 5 days to Date 1: \(result?.date ?? 0)")
        XCTAssertEqual(result?.date, 1749229200000, "dateAdd(date1, 5, \"days\") should return 1749229200000")
    }

    func testSubtract2WeeksFromDate1() async throws {
        // dateSubtract(date1, 2, "weeks") (Expect: 1747587600000)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_date6")
        print("📅 Subtract 2 weeks from Date 1: \(result?.date ?? 0)")
        XCTAssertEqual(result?.date, 1747587600000, "dateSubtract(date1, 2, \"weeks\") should return 1747587600000")
    }

    func testDaysBetweenNowAndDate1() async throws {
        // (now() - date1) / (1000 * 60 * 60 * 24) (Expect: approximately 25.38, but varies with current time)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_7")
        print("📅 Days between now and Date 1: \(result?.number ?? 0)")
        
        // Since this depends on current time, we'll verify it's a reasonable positive number
        // The spec suggests around 25.38 days, so we'll allow a range
        let daysDifference = result?.number ?? 0
        XCTAssertGreaterThan(daysDifference, 0, "Days between now and date1 should be positive (date1 is in the past)")
        XCTAssertLessThan(daysDifference, 100, "Days between now and date1 should be reasonable (less than 100 days)")
    }

    func testIsDate1InFuture() async throws {
        // date1 > now() (Expect: False)
        let result = documentEditor.value(ofFieldWithIdentifier: "field_8")
        print("📅 Is Date 1 in the future: \(result?.boolean ?? false)")
        XCTAssertEqual(result?.boolean, false, "date1 > now() should return false (date1 is in the past)")
    }

    func testPastOrUpcomingBasedOnDate1() async throws {
        // if(date1 < now(), "Past", "Upcoming") (Expect: "Past")
        let result = documentEditor.value(ofFieldWithIdentifier: "field_9")
        print("📅 Past or Upcoming based on Date 1: \(result?.text ?? "nil")")
        XCTAssertEqual(result?.text, "Past", "if(date1 < now(), \"Past\", \"Upcoming\") should return \"Past\"")
    }

    // MARK: - Additional Helper Tests

    func testBaseDateValue() async throws {
        // Verify the base date1 value
        let result = documentEditor.value(ofFieldWithIdentifier: "field_685dac8aeadaf7aabf92038e")
        print("📅 Base Date 1 value: \(result?.date ?? 0)")
        XCTAssertEqual(result?.date, 1748797200000, "date1 should have the expected timestamp value")
    }

    func testDateFormatConsistency() async throws {
        // Verify that date operations maintain proper formatting
        let originalDate = documentEditor.value(ofFieldWithIdentifier: "field_685dac8aeadaf7aabf92038e")
        let dateAddResult = documentEditor.value(ofFieldWithIdentifier: "field_date5")
        let dateSubtractResult = documentEditor.value(ofFieldWithIdentifier: "field_date6")
        
        print("📅 Original Date: \(originalDate?.date ?? 0)")
        print("📅 Date + 5 days: \(dateAddResult?.date ?? 0)")
        print("📅 Date - 2 weeks: \(dateSubtractResult?.date ?? 0)")
        
        // Verify the mathematical relationships
        let fiveDaysInMs: Double = 5 * 24 * 60 * 60 * 1000
        let twoWeeksInMs: Double = 14 * 24 * 60 * 60 * 1000
        
        let expectedDateAdd = (originalDate?.date ?? 0) + fiveDaysInMs
        let expectedDateSubtract = (originalDate?.date ?? 0) - twoWeeksInMs
        
        XCTAssertEqual(dateAddResult?.date, expectedDateAdd, "Date addition should be mathematically correct")
        XCTAssertEqual(dateSubtractResult?.date, expectedDateSubtract, "Date subtraction should be mathematically correct")
    }
} 