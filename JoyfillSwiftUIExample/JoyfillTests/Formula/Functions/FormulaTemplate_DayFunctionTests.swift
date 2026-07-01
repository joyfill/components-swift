//
//  dayTests.swift
//  JoyfillTests
//
//  Unit tests for the day() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class dayTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "day")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    }
    
    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func getFieldValue(_ fieldId: String) -> String {
        return documentEditor.value(ofFieldWithIdentifier: fieldId)?.text ?? ""
    }
    
    private func updateStringValue(_ fieldId: String, _ value: String) {
        documentEditor.updateValue(for: fieldId, value: .string(value))
    }

    // MARK: - Engine-mirroring helpers
    // Per the date spec, ISO date strings now parse, so day() returns real values.
    private func utcCalendar() -> Calendar { var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(secondsFromGMT: 0)!; return c }
    private func parseISO(_ iso: String) -> Date {
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]; return f.date(from: iso)!
    }
    private func dayOf(_ iso: String) -> Int { utcCalendar().component(.day, from: parseISO(iso)) }
    private func monthOf(_ iso: String) -> Int { utcCalendar().component(.month, from: parseISO(iso)) }
    private func yearOf(_ iso: String) -> Int { utcCalendar().component(.year, from: parseISO(iso)) }
    private var todayUTC: DateComponents { utcCalendar().dateComponents([.day, .month, .year], from: Date()) }

    // MARK: - Static Tests: Basic day() Function
    
    /// Test: day(date(2023, 5, 15)) should return 15
    func testDayOfSpecificDate() {
        let result = getFieldValue("basic_example_specific")
        XCTAssertEqual(result, "15", "day(date(2023, 5, 15)) should return '15'")
    }
    
    /// Test: day(now()) should return current day (1-31)
    func testDayOfCurrentDate() {
        let result = getFieldValue("basic_example_current")
        // Should be a number between 1 and 31
        if let day = Int(result) {
            XCTAssertTrue(day >= 1 && day <= 31, "day(now()) should return 1-31, got '\(day)'")
        } else {
            XCTFail("day(now()) should return a number, got '\(result)'")
        }
    }
    
    /// Test: day(invoiceDate) parses the ISO string "2023-03-15..." -> 15
    func testDayFromFieldReference() {
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, String(dayOf("2023-03-15T00:00:00.000Z")), "day(invoiceDate) should parse the ISO string to 15")
    }

    /// Test: if(day(sampleDate) <= 15, ...) - sampleDate day is 20 -> "Second half of month"
    func testHalfMonthSecondHalf() {
        let result = getFieldValue("intermediate_example_half")
        XCTAssertEqual(result, "Second half of month", "sampleDate day 20 > 15 -> Second half of month")
    }

    /// Test: due today - dueDate is 2023-07-15; unless run on that exact day -> "Not due today"
    func testDueTodayCheck() {
        let result = getFieldValue("advanced_example_due")
        let iso = "2023-07-15T00:00:00.000Z"
        let t = todayUTC
        let expected = (dayOf(iso) == t.day && monthOf(iso) == t.month && yearOf(iso) == t.year) ? "Due today!" : "Not due today"
        XCTAssertEqual(result, expected, "dueDate 2023-07-15 compared against now()")
    }

    /// Test: position - sampleDate day is 20 (not 1, not > 25) -> "Middle of month"
    func testPositionInMonth() {
        let result = getFieldValue("advanced_example_position")
        XCTAssertEqual(result, "Middle of month", "sampleDate day 20 -> Middle of month")
    }

    /// Test: if(day(now()) % 7 == 0, ...). day(now()) parses fine, but the % modulo operator
    /// errors in the engine, so the whole if resolves to empty.
    func testRecurringTask() {
        let result = getFieldValue("advanced_example_recurring")
        XCTAssertEqual(result, "", "The % modulo operator errors, so the formula resolves to empty")
    }

    // MARK: - Dynamic Update Tests

    /// Test: Mutating sampleDate recomputes if(day(sampleDate) <= 15, ...).
    /// ISO date strings now parse, so the branch tracks the day of month.
    func testDynamicUpdateSampleDateRecomputes() {
        // Baseline: sampleDate 2023-02-20 -> day 20 -> Second half
        XCTAssertEqual(getFieldValue("intermediate_example_half"), "Second half of month", "Baseline: day 20 -> Second half")

        // First-half date
        updateStringValue("sampleDate", "2023-04-10T00:00:00.000Z")
        XCTAssertEqual(getFieldValue("intermediate_example_half"), "First half of month", "day 10 -> First half of month")

        // Second-half date
        updateStringValue("sampleDate", "2023-04-28T00:00:00.000Z")
        XCTAssertEqual(getFieldValue("intermediate_example_half"), "Second half of month", "day 28 -> Second half of month")
    }
}
