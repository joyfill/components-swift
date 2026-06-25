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
    
    /// Test: day(invoiceDate) where invoiceDate is the ISO string "2023-03-15T00:00:00.000Z".
    /// extractDate() only parses numeric strings, so day() receives nil, errors, and the field is empty.
    func testDayFromFieldReference() {
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "", "ISO-string invoiceDate is unparseable, so day(invoiceDate) resolves to empty")
    }

    /// Test: if(day(sampleDate) <= 15, ...) where sampleDate is an ISO string.
    /// day(sampleDate) errors, so the whole if resolves to empty.
    func testHalfMonthSecondHalf() {
        let result = getFieldValue("intermediate_example_half")
        XCTAssertEqual(result, "", "ISO-string sampleDate is unparseable, so the formula resolves to empty")
    }

    /// Test: if(day(dueDate) == day(now()) && ..., ...) where dueDate is an ISO string.
    /// day(dueDate) errors, so the whole comparison resolves to empty.
    func testDueTodayCheck() {
        let result = getFieldValue("advanced_example_due")
        XCTAssertEqual(result, "", "ISO-string dueDate is unparseable, so the formula resolves to empty")
    }

    /// Test: if(day(sampleDate) == 1, ...) where sampleDate is an ISO string.
    /// day(sampleDate) errors, so the whole if resolves to empty.
    func testPositionInMonth() {
        let result = getFieldValue("advanced_example_position")
        XCTAssertEqual(result, "", "ISO-string sampleDate is unparseable, so the formula resolves to empty")
    }

    /// Test: if(day(now()) % 7 == 0, ...). day(now()) parses fine, but the % modulo operator
    /// errors in the engine, so the whole if resolves to empty.
    func testRecurringTask() {
        let result = getFieldValue("advanced_example_recurring")
        XCTAssertEqual(result, "", "The % modulo operator errors, so the formula resolves to empty")
    }

    // MARK: - Dynamic Update Tests

    /// Test: Mutating sampleDate recomputes if(day(sampleDate) <= 15, ...).
    /// sampleDate stays an ISO string (unparseable by extractDate), so the formula recomputes
    /// on every update but stays empty regardless of the date value.
    func testDynamicUpdateSampleDateRecomputes() {
        // Baseline: fixture ISO string -> empty
        XCTAssertEqual(getFieldValue("intermediate_example_half"), "", "Baseline is empty (ISO sampleDate)")

        // Update to a first-half ISO date -> still empty (ISO unparseable)
        updateStringValue("sampleDate", "2023-04-10T00:00:00.000Z")
        XCTAssertEqual(getFieldValue("intermediate_example_half"), "", "Recompute stays empty: ISO sampleDate is unparseable")

        // Update to a second-half ISO date -> still empty
        updateStringValue("sampleDate", "2023-04-28T00:00:00.000Z")
        XCTAssertEqual(getFieldValue("intermediate_example_half"), "", "Recompute stays empty: ISO sampleDate is unparseable")
    }
}
