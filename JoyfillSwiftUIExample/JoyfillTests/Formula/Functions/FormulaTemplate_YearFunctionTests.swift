//
//  yearTests.swift
//  JoyfillTests
//
//  Unit tests for the year() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class yearTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "year")
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
    
    /// Test: year(birthDate) with ISO date string - field-ref date strings are not parsed, resolves to empty
    func testYearFromFieldReference() {
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "", "year(birthDate) on an ISO date string resolves to empty")
    }

    /// Test: Age calculation - depends on year(birthDate), which is empty, so resolves to empty
    func testAgeCalculation() {
        let result = getFieldValue("intermediate_example_age")
        XCTAssertEqual(result, "", "year(now()) - year(birthDate) resolves to empty")
    }

    /// Test: Expiry check - depends on year(expiryDate), which is empty, so resolves to empty
    func testExpiryCheck() {
        let result = getFieldValue("advanced_example_expiry")
        XCTAssertEqual(result, "", "expiry check on an ISO date string resolves to empty")
    }

    /// Test: Half year - depends on year(sampleDate), which is empty, so resolves to empty
    func testHalfYear() {
        let result = getFieldValue("advanced_example_half")
        XCTAssertEqual(result, "", "half-year check on an ISO date string resolves to empty")
    }

    /// Test: Fiscal year - depends on year(sampleDate), which is empty, so resolves to empty
    func testFiscalYear() {
        let result = getFieldValue("advanced_example_fiscal")
        XCTAssertEqual(result, "", "fiscal-year expression on an ISO date string resolves to empty")
    }

    // MARK: - Dynamic Update Tests

    /// Test: Updating birthDate to another ISO date string keeps year(birthDate) empty
    func testDynamicUpdateBirthDateStaysEmpty() {
        XCTAssertEqual(getFieldValue("intermediate_example_field"), "", "Initial year(birthDate) is empty")

        updateStringValue("birthDate", "2000-03-10T00:00:00.000Z")
        XCTAssertEqual(getFieldValue("intermediate_example_field"), "", "year(birthDate) stays empty after update")
        XCTAssertEqual(getFieldValue("intermediate_example_age"), "", "age stays empty after update")
    }
}
