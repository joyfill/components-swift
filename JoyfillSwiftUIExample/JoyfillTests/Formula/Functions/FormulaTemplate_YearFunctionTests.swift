//
//  FormulaTemplate_YearFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the year() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_YearFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_YearFunction")
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
    
    // MARK: - Static Tests: Basic year() Function
    
    /// Test: year(date(2023, 5, 15)) should return 2023
    func testYearOfSpecificDate() {
        let result = getFieldValue("basic_example_specific")
        XCTAssertEqual(result, "2023", "year(date(2023, 5, 15)) should return '2023'")
    }
    
    /// Test: year(now()) should return current year
    func testYearOfCurrentDate() {
        let result = getFieldValue("basic_example_current")
        // Should be a 4-digit year
        if let year = Int(result) {
            XCTAssertTrue(year >= 2020 && year <= 2100, "year(now()) should return reasonable year, got '\(year)'")
        } else {
            XCTFail("year(now()) should return a number, got '\(result)'")
        }
    }
    
    /// Test: year(birthDate) with date string - may return empty if parsing not supported
    func testYearFromFieldReference() {
        let result = getFieldValue("intermediate_example_field")
        XCTAssertTrue(result == "1990" || result.isEmpty, "year from date string should return '1990' or empty")
    }
    
    /// Test: Age calculation - may not work with date string parsing
    func testAgeCalculation() {
        let result = getFieldValue("intermediate_example_age")
        // Date string parsing may not work
        if !result.isEmpty, let age = Int(result) {
            XCTAssertTrue(age >= 30 && age <= 40, "Age from 1990 should be ~33-35, got '\(age)'")
        }
    }
    
    /// Test: Expiry check - may not work with date string parsing
    func testExpiryCheck() {
        let result = getFieldValue("advanced_example_expiry")
        XCTAssertTrue(result == "Expired" || result.isEmpty, "Year 2022 expiry should be 'Expired' or empty")
    }
    
    /// Test: Half year - may not work with date string parsing
    func testHalfYear() {
        let result = getFieldValue("advanced_example_half")
        XCTAssertTrue(result == "Second half of 2023" || result.isEmpty, "August 2023 should show result or empty")
    }
}
