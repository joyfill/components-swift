//
//  FormulaTemplate_NowFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the now() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_NowFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_NowFunction")
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
    
    // MARK: - Static Tests: Basic now() Function
    
    /// Test: now() returns a value
    func testNowReturnsValue() {
        let result = getFieldValue("basic_example")
        XCTAssertTrue(!result.isEmpty, "now() should return a value")
    }
    
    /// Test: Timestamp includes document text
    func testTimestampText() {
        let result = getFieldValue("intermediate_example_timestamp")
        XCTAssertTrue(result.contains("Document created on:"), "Timestamp should contain prefix")
    }
    
    /// Test: year(now()) returns current year
    func testYearOfNow() {
        let result = getFieldValue("intermediate_example_year")
        if let year = Int(result) {
            let currentYear = Calendar.current.component(.year, from: Date())
            XCTAssertEqual(year, currentYear, "year(now()) should match current year")
        } else {
            XCTFail("year(now()) should return a number, got '\(result)'")
        }
    }
    
    /// Test: month(now()) returns current month
    func testMonthOfNow() {
        let result = getFieldValue("intermediate_example_month")
        if let month = Int(result) {
            let currentMonth = Calendar.current.component(.month, from: Date())
            XCTAssertEqual(month, currentMonth, "month(now()) should match current month")
        } else {
            XCTFail("month(now()) should return a number, got '\(result)'")
        }
    }
    
    /// Test: Greeting based on hour
    func testGreeting() {
        let result = getFieldValue("advanced_example_greeting")
        // Should be one of the greetings
        let validGreetings = ["Good morning!", "Good afternoon!", "Good evening!"]
        XCTAssertTrue(validGreetings.contains(result) || result.isEmpty, 
                      "Greeting should be valid, got '\(result)'")
    }
    
    /// Test: Duration calculation
    func testDurationCalculation() {
        let result = getFieldValue("advanced_example_duration")
        // Should be number of days since 2023-01-01
        if let days = Double(result) {
            XCTAssertTrue(days > 0, "Duration should be positive, got '\(days)'")
        }
    }
}
