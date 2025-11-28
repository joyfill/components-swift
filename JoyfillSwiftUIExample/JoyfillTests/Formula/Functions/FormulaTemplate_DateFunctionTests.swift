//
//  dateTests.swift
//  JoyfillTests
//
//  Unit tests for the date() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class dateTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "date")
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
    
    // MARK: - Static Tests: Basic date() Function
    
    /// Test: date(2023, 5, 15) creates a date
    func testDateCreation() {
        let result = getFieldValue("basic_example_specific")
        // Should produce some date representation
        XCTAssertTrue(!result.isEmpty, "date(2023, 5, 15) should produce a result")
    }
    
    /// Test: date with variables
    func testDateWithVariables() {
        let result = getFieldValue("basic_example_variables")
        // date(2023, 7, 4) from variables
        XCTAssertTrue(!result.isEmpty, "date(yearValue, monthValue, dayValue) should produce a result")
    }
    
    /// Test: year(date(2023, 5, 15)) = 2023
    func testYearExtraction() {
        let result = getFieldValue("intermediate_example_year")
        XCTAssertEqual(result, "2023", "year(date(2023, 5, 15)) should return '2023'")
    }
    
    /// Test: month(date(2023, 5, 15)) = 5
    func testMonthExtraction() {
        let result = getFieldValue("intermediate_example_month")
        XCTAssertEqual(result, "5", "month(date(2023, 5, 15)) should return '5'")
    }
    
    /// Test: day(date(2023, 5, 15)) = 15
    func testDayExtraction() {
        let result = getFieldValue("intermediate_example_day")
        XCTAssertEqual(result, "15", "day(date(2023, 5, 15)) should return '15'")
    }
    
    // MARK: - Dynamic Tests: Date Components
    
    /// Test: Update year value
    func testDynamicUpdateYear() {
        updateNumberValue("yearValue", 2024)
        let result = getFieldValue("basic_example_variables")
        // Should produce updated date
        XCTAssertTrue(!result.isEmpty, "Updated year should produce a result")
    }
    
    /// Test: Update month value
    func testDynamicUpdateMonth() {
        updateNumberValue("monthValue", 12)
        let result = getFieldValue("basic_example_variables")
        XCTAssertTrue(!result.isEmpty, "Updated month should produce a result")
    }
    
    /// Test: Update day value
    func testDynamicUpdateDay() {
        updateNumberValue("dayValue", 25)
        let result = getFieldValue("basic_example_variables")
        XCTAssertTrue(!result.isEmpty, "Updated day should produce a result")
    }
}
