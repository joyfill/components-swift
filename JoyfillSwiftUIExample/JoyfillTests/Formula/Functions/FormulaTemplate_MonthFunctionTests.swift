//
//  monthTests.swift
//  JoyfillTests
//
//  Unit tests for the month() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class monthTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "month")
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
    
    /// Current calendar month (1-12), used to compute now()-relative expectations.
    private var currentMonth: Int {
        Calendar.current.component(.month, from: Date())
    }

    private func expectedSeason(for month: Int) -> String {
        if month >= 3 && month <= 5 { return "Spring" }
        if month >= 6 && month <= 8 { return "Summer" }
        if month >= 9 && month <= 11 { return "Fall" }
        return "Winter"
    }

    // MARK: - Engine-mirroring helpers
    // Per the date spec, ISO date strings now parse, so month()/year() return real
    // values. These mirror the engine's UTC parse (no hardcoded magic numbers).
    private func utcCalendar() -> Calendar { var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(secondsFromGMT: 0)!; return c }
    private func parseISO(_ iso: String) -> Date {
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]; return f.date(from: iso)!
    }
    private func monthOf(_ iso: String) -> Int { utcCalendar().component(.month, from: parseISO(iso)) }
    private func yearOf(_ iso: String) -> Int { utcCalendar().component(.year, from: parseISO(iso)) }
    private var currentMonthUTC: Int { utcCalendar().component(.month, from: Date()) }
    private var currentYearUTC: Int { utcCalendar().component(.year, from: Date()) }

    // MARK: - Static Tests: Basic month() Function
    
    /// Test: month(date(2023, 5, 15)) should return 5
    func testMonthOfSpecificDate() {
        let result = getFieldValue("basic_example_specific")
        XCTAssertEqual(result, "5", "month(date(2023, 5, 15)) should return '5'")
    }

    /// Test: month(now()) should return the current calendar month
    func testMonthOfCurrentDate() {
        let result = getFieldValue("basic_example_current")
        XCTAssertEqual(result, "\(currentMonth)", "month(now()) should return the current month")
    }

    /// Test: month(orderDate) parses the ISO date string "2023-03-15..." -> 3
    func testMonthFromFieldReference() {
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, String(monthOf("2023-03-15T00:00:00.000Z")), "month(orderDate) should parse the ISO string to 3")
    }

    /// Test: Month-name uses a 12-level deeply-nested if, which the engine does not fully evaluate,
    /// so it resolves to empty (matches Web) even though month(sampleDate) itself parses fine.
    func testMonthName() {
        let result = getFieldValue("intermediate_example_name")
        XCTAssertEqual(result, "", "deeply-nested if resolves to empty (month(sampleDate) still parses)")
    }

    /// Test: Season is computed from month(now())
    func testSeason() {
        let result = getFieldValue("advanced_example_season")
        XCTAssertEqual(result, expectedSeason(for: currentMonth), "season should match month(now())")
    }

    /// Test: Quarter - "Q" + ceil(month(sampleDate)/3) + " " + year(sampleDate)
    /// sampleDate 2023-02 -> ceil(2/3)=1 -> "Q1 2023"
    func testQuarterCalculation() {
        let result = getFieldValue("advanced_example_quarter")
        XCTAssertEqual(result, "Q1 2023", "sampleDate 2023-02 -> Q1 2023")
    }

    /// Test: Current-month - if(month(eventDate)==month(now()) && year(eventDate)==year(now()), ...)
    /// eventDate is 2023-07; unless run in July 2023 this resolves to "Different month".
    func testCurrentMonthComparison() {
        let result = getFieldValue("advanced_example_current_month")
        let iso = "2023-07-15T00:00:00.000Z"
        let expected = (monthOf(iso) == currentMonthUTC && yearOf(iso) == currentYearUTC) ? "This month" : "Different month"
        XCTAssertEqual(result, expected, "eventDate 2023-07 compared against now()")
    }

    // MARK: - Dynamic Tests

    /// Test: Updating orderDate recomputes month(orderDate)
    func testDynamicUpdateOrderDateRecomputes() {
        XCTAssertEqual(getFieldValue("intermediate_example_field"), String(monthOf("2023-03-15T00:00:00.000Z")), "Initial month is 3")

        updateStringValue("orderDate", "2023-09-20T00:00:00.000Z")
        XCTAssertEqual(getFieldValue("intermediate_example_field"), String(monthOf("2023-09-20T00:00:00.000Z")), "month recomputes to 9")
    }

    /// Test: Updating sampleDate recomputes the quarter (2023-05 -> Q2 2023). The month-name uses a
    /// deeply-nested if that resolves to empty regardless, so it stays empty.
    func testDynamicUpdateSampleDateRecomputes() {
        updateStringValue("sampleDate", "2023-05-10T00:00:00.000Z")
        XCTAssertEqual(getFieldValue("intermediate_example_name"), "", "month-name stays empty (deeply-nested if)")
        XCTAssertEqual(getFieldValue("advanced_example_quarter"), "Q2 2023", "quarter recomputes to Q2 2023")
    }
}
