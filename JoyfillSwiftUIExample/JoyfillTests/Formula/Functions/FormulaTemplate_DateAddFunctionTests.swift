//
//  dateAddTests.swift
//  JoyfillTests
//
//  Unit tests for the dateAdd() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class dateAddTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "dateAdd")
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
    
    private func updateNumberValue(_ fieldId: String, _ value: Double) {
        documentEditor.updateValue(for: fieldId, value: .double(value))
    }

    private func updateStringValue(_ fieldId: String, _ value: String) {
        documentEditor.updateValue(for: fieldId, value: .string(value))
    }

    // MARK: - Engine-mirroring date helpers
    // These reproduce the engine's UTC Gregorian math and epoch-millis rendering so
    // assertions cross-check the result without hardcoding magic timestamps.

    private func utcCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func dateText(_ date: Date) -> String {
        return String(date.timeIntervalSince1970 * 1000.0)
    }

    private func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
        return utcCalendar().date(from: DateComponents(year: year, month: month, day: day))!
    }

    /// Mirrors extractDate(): numbers > 1e12 are epoch-milliseconds.
    private func dateFromMillis(_ millis: Double) -> Date {
        return Date(timeIntervalSince1970: millis / 1000.0)
    }

    private func adding(_ date: Date, _ value: Int, _ unit: Calendar.Component) -> Date {
        return utcCalendar().date(byAdding: unit, value: value, to: date)!
    }

    // The startDate field's fixed value in dateAdd.json.
    private let startDateMillis: Double = 478623784678234

    // MARK: - Static Tests
    
    /// Test: Document loads successfully
    func testDocumentLoads() {
        XCTAssertNotNil(documentEditor, "DocumentEditor should load successfully")
    }
    
    /// Test: Basic dateAdd with years - dateAdd(date(2023, 1, 1), 3, "years")
    func testBasicDateAddYears() {
        let result = getFieldValue("basic_example_years")
        let expected = dateText(adding(makeDate(2023, 1, 1), 3, .year))
        XCTAssertEqual(result, expected, "dateAdd(date(2023,1,1), 3, \"years\") should resolve to 2026-01-01 epoch-millis")
    }
    
    /// Test: Basic dateAdd with months - dateAdd(now(), 2, "months")
    /// now()-based: non-deterministic, so just verify it produces a parseable epoch-millis value.
    func testBasicDateAddMonths() {
        let result = getFieldValue("basic_example_months")
        XCTAssertNotNil(Double(result), "dateAdd(now(), 2, \"months\") should produce a numeric epoch-millis value, got '\(result)'")
    }
    
    /// Test: Intermediate dateAdd with field inputs - dateAdd(startDate, durationValue, durationUnit)
    /// Drivers: startDate=478623784678234 ms, durationValue=14, durationUnit="days".
    func testIntermediateDateAddField() {
        let result = getFieldValue("intermediate_example_field")
        let expected = dateText(adding(dateFromMillis(startDateMillis), 14, .day))
        XCTAssertEqual(result, expected, "dateAdd(startDate, 14, \"days\") should add 14 days to the start date")
    }

    /// Test: Intermediate dateAdd chain - dateAdd(dateAdd(date(2023, 1, 1), 6, "months"), 15, "days")
    func testIntermediateDateAddChain() {
        let result = getFieldValue("intermediate_example_chain")
        let expected = dateText(adding(adding(makeDate(2023, 1, 1), 6, .month), 15, .day))
        XCTAssertEqual(result, expected, "Chained dateAdd should resolve to 2023-07-16 epoch-millis")
    }
    
    /// Test: Advanced payment due check - if(dateAdd(now(), 30, "days") > dueDate, ...)
    /// now()-based, but dueDate is fixed in the past so the comparison is stable.
    func testAdvancedPaymentDueCheck() {
        let result = getFieldValue("advanced_example_payment")
        XCTAssertTrue(result == "Payment due soon!" || result == "Payment due in more than 30 days",
                      "Should return one of the payment status messages, got '\(result)'")
    }
    
    /// Test: Advanced planning check - if(month(dateAdd(now(), 3, "months")) == 12, ...)
    func testAdvancedPlanningCheck() {
        let result = getFieldValue("advanced_example_planning")
        XCTAssertTrue(result == "Q4 planning needed" || result == "Not time for Q4 planning yet",
                      "Should return one of the planning status messages, got '\(result)'")
    }

    /// Test: Advanced subscription - "Your subscription expires on " + dateAdd(subscriptionStartDate, 1, "years")
    /// subscriptionStartDate is the ISO string "2023-01-01T00:00:00.000Z". Per the date spec, a string
    /// input is parsed into a timestamp, so dateAdd adds one year and the date renders as epoch-millis.
    func testAdvancedSubscriptionAddsYear() {
        let result = getFieldValue("advanced_example_subscription")
        let expectedMillis = Int64(adding(makeDate(2023, 1, 1), 1, .year).timeIntervalSince1970 * 1000.0)
        XCTAssertEqual(result, "Your subscription expires on \(expectedMillis)",
                       "ISO-string subscriptionStartDate is parsed, +1 year -> 2024-01-01 epoch-millis")
    }

    // MARK: - Dynamic Update Tests

    /// Test: Updating durationValue/durationUnit recomputes dateAdd(startDate, durationValue, durationUnit)
    func testDynamicUpdateDurationRecomputes() {
        // Baseline: 14 days
        XCTAssertEqual(getFieldValue("intermediate_example_field"),
                       dateText(adding(dateFromMillis(startDateMillis), 14, .day)),
                       "Baseline should add 14 days")

        // Update to 3 months
        updateNumberValue("durationValue", 3)
        updateStringValue("durationUnit", "months")
        XCTAssertEqual(getFieldValue("intermediate_example_field"),
                       dateText(adding(dateFromMillis(startDateMillis), 3, .month)),
                       "Updated drivers should add 3 months")

        // Update to 5 years
        updateNumberValue("durationValue", 5)
        updateStringValue("durationUnit", "years")
        XCTAssertEqual(getFieldValue("intermediate_example_field"),
                       dateText(adding(dateFromMillis(startDateMillis), 5, .year)),
                       "Updated drivers should add 5 years")
    }

    /// Test: Updating startDate shifts the dateAdd(startDate, ...) result accordingly
    func testDynamicUpdateStartDateRecomputes() {
        let newStartMillis: Double = 1_700_000_000_000  // 2023-11-14T22:13:20Z
        updateNumberValue("startDate", newStartMillis)
        // durationValue/durationUnit keep their fixture defaults: 14 days
        XCTAssertEqual(getFieldValue("intermediate_example_field"),
                       dateText(adding(dateFromMillis(newStartMillis), 14, .day)),
                       "Updated startDate should add 14 days to the new start date")
    }
}
