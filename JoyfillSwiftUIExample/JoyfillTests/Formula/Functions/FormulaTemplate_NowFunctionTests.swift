//
//  nowTests.swift
//  JoyfillTests
//
//  Unit tests for the now() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class nowTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "now")
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

    /// now() is rendered as epoch milliseconds; allow a generous tolerance for clock drift / slow CI.
    private let toleranceMs: Double = 600_000  // 10 minutes
    private var nowMs: Double { Date().timeIntervalSince1970 * 1000 }

    // MARK: - Static Tests: Basic now() Function

    /// Test: now() returns the current time as epoch milliseconds
    func testNowReturnsValue() {
        let result = getFieldValue("basic_example")
        guard let ms = Double(result) else {
            return XCTFail("now() should return a numeric epoch-ms value, got '\(result)'")
        }
        XCTAssertEqual(ms, nowMs, accuracy: toleranceMs, "now() should be the current epoch ms")
    }

    /// Test: "Document created on: " + now() renders the prefix plus now() as an epoch-ms timestamp.
    func testTimestampText() {
        let result = getFieldValue("intermediate_example_timestamp")
        XCTAssertTrue(result.hasPrefix("Document created on: "), "Timestamp should have the prefix, got '\(result)'")
        let suffix = String(result.dropFirst("Document created on: ".count))
        XCTAssertNotNil(Double(suffix), "now() should render as an epoch-ms value in the concatenation, got '\(result)'")
    }

    /// Test: year(now()) returns the current year
    func testYearOfNow() {
        let result = getFieldValue("intermediate_example_year")
        let currentYear = Calendar.current.component(.year, from: Date())
        XCTAssertEqual(result, "\(currentYear)", "year(now()) should match the current year")
    }

    /// Test: month(now()) returns the current month
    func testMonthOfNow() {
        let result = getFieldValue("intermediate_example_month")
        let currentMonth = Calendar.current.component(.month, from: Date())
        XCTAssertEqual(result, "\(currentMonth)", "month(now()) should match the current month")
    }

    /// Test: dateSubtract(now(), 7, "days") returns epoch ms 7 days before now
    func testDateSubtract() {
        let result = getFieldValue("advanced_example_subtract")
        guard let ms = Double(result) else {
            return XCTFail("dateSubtract should return a numeric epoch-ms value, got '\(result)'")
        }
        let sevenDaysMs: Double = 7 * 24 * 60 * 60 * 1000
        XCTAssertEqual(ms, nowMs - sevenDaysMs, accuracy: toleranceMs, "dateSubtract(now(), 7, days) should be 7 days before now")
    }

    /// Test: Greeting uses hour(now()) which is unsupported, so the formula resolves to empty
    func testGreeting() {
        let result = getFieldValue("advanced_example_greeting")
        XCTAssertEqual(result, "", "greeting resolves to empty (hour() unsupported)")
    }

    /// Test: Duration subtracts a text-string startDate from now(), which is not supported, so empty
    func testDurationCalculation() {
        let result = getFieldValue("advanced_example_duration")
        XCTAssertEqual(result, "", "duration resolves to empty (text-string date cannot be subtracted)")
    }

    // MARK: - Dynamic Tests

    /// Test: Updating startDate does not change the duration output - it stays empty, because
    /// now() - <text-string date> is not a supported subtraction.
    func testDynamicUpdateStartDateDurationStaysEmpty() {
        XCTAssertEqual(getFieldValue("advanced_example_duration"), "", "Initial: empty")

        updateStringValue("startDate", "2020-01-01T00:00:00.000Z")
        XCTAssertEqual(getFieldValue("advanced_example_duration"), "", "After update: still empty (not supported)")
    }
}
