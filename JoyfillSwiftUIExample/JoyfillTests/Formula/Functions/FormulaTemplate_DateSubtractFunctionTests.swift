//
//  dateSubtractTests.swift
//  JoyfillTests
//
//  Unit tests for the dateSubtract() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class dateSubtractTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "dateSubtract")
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

    /// Integer epoch-millis, matching how a date is rendered inside string concatenation ("+").
    private func dateTextInt(_ date: Date) -> String {
        return String(Int64(date.timeIntervalSince1970 * 1000.0))
    }

    private func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
        return utcCalendar().date(from: DateComponents(year: year, month: month, day: day))!
    }

    /// dateSubtract adds the negated amount, so this mirrors the engine's subtraction.
    private func subtracting(_ date: Date, _ value: Int, _ unit: Calendar.Component) -> Date {
        return utcCalendar().date(byAdding: unit, value: -value, to: date)!
    }

    // MARK: - Static Tests
    
    /// Test: Document loads successfully
    func testDocumentLoads() {
        XCTAssertNotNil(documentEditor, "DocumentEditor should load successfully")
    }
    
    /// Test: Basic dateSubtract with years - dateSubtract(date(2023, 1, 1), 3, "years")
    func testBasicDateSubtractYears() {
        let result = getFieldValue("basic_example_years")
        let expected = dateText(subtracting(makeDate(2023, 1, 1), 3, .year))
        XCTAssertEqual(result, expected, "dateSubtract(date(2023,1,1), 3, \"years\") should resolve to 2020-01-01 epoch-millis")
    }
    
    /// Test: Basic dateSubtract with months - dateSubtract(now(), 2, "months")
    /// now()-based: non-deterministic, so just verify it produces a parseable epoch-millis value.
    func testBasicDateSubtractMonths() {
        let result = getFieldValue("basic_example_months")
        XCTAssertNotNil(Double(result), "dateSubtract(now(), 2, \"months\") should produce a numeric epoch-millis value, got '\(result)'")
    }
    
    /// Test: Intermediate dateSubtract chain - dateSubtract(dateSubtract(date(2023, 12, 31), 6, "months"), 15, "days")
    func testIntermediateDateSubtractChain() {
        let result = getFieldValue("intermediate_example_chain")
        let expected = dateText(subtracting(subtracting(makeDate(2023, 12, 31), 6, .month), 15, .day))
        XCTAssertEqual(result, expected, "Chained dateSubtract should resolve to 2023-06-15 epoch-millis")
    }

    /// Test: Intermediate dateSubtract with field inputs - dateSubtract(startDate, durationValue, durationUnit)
    /// startDate "2023-05-15T00:00:00.000Z" now parses; subtract 14 days -> 2023-05-01 epoch-millis.
    func testIntermediateDateSubtractField() {
        let result = getFieldValue("intermediate_example_field")
        let expected = dateText(subtracting(makeDate(2023, 5, 15), 14, .day))
        XCTAssertEqual(result, expected, "dateSubtract(startDate, 14, \"days\") -> 2023-05-01 epoch-millis")
    }

    /// Test: Advanced invoice check - if(dateSubtract(dueDate, 30, "days") < now(), ...)
    /// dueDate 2023-08-15 minus 30 days = 2023-07-16, before now() -> "less than 30 days".
    func testAdvancedInvoiceCheck() {
        let result = getFieldValue("advanced_example_invoice")
        let dueMinus30 = subtracting(makeDate(2023, 8, 15), 30, .day)
        let expected = dueMinus30 < Date() ? "Invoice is due in less than 30 days" : "Invoice due date is more than 30 days away"
        XCTAssertEqual(result, expected, "dueDate minus 30 days compared against now()")
    }

    /// Test: Advanced planning check - if(month(dateSubtract(now(), 3, "months")) == 1, ...)
    /// now()-based, so just verify it returns one of the two valid messages.
    func testAdvancedPlanningCheck() {
        let result = getFieldValue("advanced_example_planning")
        XCTAssertTrue(result == "Q1 planning completed" || result == "Not from Q1 planning period",
                      "Should return one of the planning status messages, got '\(result)'")
    }

    /// Test: Advanced deadline - "Planning must start by " + dateSubtract(projectDeadline, 3, "months")
    /// projectDeadline 2023-12-31 now parses; minus 3 months, rendered as epoch-millis in the concat.
    func testAdvancedDeadline() {
        let result = getFieldValue("advanced_example_deadline")
        let expected = "Planning must start by " + dateTextInt(subtracting(makeDate(2023, 12, 31), 3, .month))
        XCTAssertEqual(result, expected, "deadline concat renders dateSubtract as epoch-millis")
    }

    // MARK: - Dynamic Update Tests

    /// Test: Mutating the duration drivers recomputes dateSubtract(startDate, durationValue, durationUnit).
    /// startDate "2023-05-15" now parses, so the result tracks the duration inputs.
    func testDynamicUpdateDurationRecomputes() {
        // Baseline: 14 days
        XCTAssertEqual(getFieldValue("intermediate_example_field"),
                       dateText(subtracting(makeDate(2023, 5, 15), 14, .day)),
                       "Baseline subtracts 14 days")

        // Update to 3 months
        updateNumberValue("durationValue", 3)
        updateStringValue("durationUnit", "months")
        XCTAssertEqual(getFieldValue("intermediate_example_field"),
                       dateText(subtracting(makeDate(2023, 5, 15), 3, .month)),
                       "Updated drivers subtract 3 months")

        // Update to 5 years
        updateNumberValue("durationValue", 5)
        updateStringValue("durationUnit", "years")
        XCTAssertEqual(getFieldValue("intermediate_example_field"),
                       dateText(subtracting(makeDate(2023, 5, 15), 5, .year)),
                       "Updated drivers subtract 5 years")
    }
}
