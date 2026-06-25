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

    /// Test: month(orderDate) - date strings in text fields are not parsed, so result is empty
    func testMonthFromFieldReference() {
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "", "month() on a text-field date string is not parsed (empty)")
    }

    /// Test: Month-name nested if on sampleDate - month(sampleDate) is empty, so the nested
    /// comparisons never match and the formula resolves to empty.
    func testMonthName() {
        let result = getFieldValue("intermediate_example_name")
        XCTAssertEqual(result, "", "month-name formula resolves to empty (date string not parsed)")
    }

    /// Test: Season is computed from month(now())
    func testSeason() {
        let result = getFieldValue("advanced_example_season")
        XCTAssertEqual(result, expectedSeason(for: currentMonth), "season should match month(now())")
    }

    /// Test: Quarter uses month(sampleDate)/year(sampleDate) - date string not parsed, so empty
    func testQuarterCalculation() {
        let result = getFieldValue("advanced_example_quarter")
        XCTAssertEqual(result, "", "quarter formula resolves to empty (date string not parsed)")
    }

    /// Test: Current-month comparison uses month(eventDate) which is empty, so the && condition
    /// errors out and the formula resolves to empty.
    func testCurrentMonthComparison() {
        let result = getFieldValue("advanced_example_current_month")
        XCTAssertEqual(result, "", "current-month formula resolves to empty (date string not parsed)")
    }

    // MARK: - Dynamic Tests

    /// Test: Updating a date-string text field does not change month() output - it stays empty,
    /// because month() does not parse date strings held in text fields.
    func testDynamicUpdateOrderDateStaysEmpty() {
        XCTAssertEqual(getFieldValue("intermediate_example_field"), "", "Initial: empty")

        updateStringValue("orderDate", "2023-09-20T00:00:00.000Z")
        XCTAssertEqual(getFieldValue("intermediate_example_field"), "", "After update: still empty (not parsed)")
    }

    /// Test: Updating sampleDate does not change the month-name or quarter output - both stay empty.
    func testDynamicUpdateSampleDateStaysEmpty() {
        updateStringValue("sampleDate", "2023-05-10T00:00:00.000Z")
        XCTAssertEqual(getFieldValue("intermediate_example_name"), "", "month-name still empty after update")
        XCTAssertEqual(getFieldValue("advanced_example_quarter"), "", "quarter still empty after update")
    }
}
