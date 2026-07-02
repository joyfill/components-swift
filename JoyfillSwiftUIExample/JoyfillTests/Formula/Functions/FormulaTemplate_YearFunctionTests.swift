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

    // MARK: - Engine-mirroring helpers
    // Per the date spec, ISO date strings are parsed to a timestamp, so year() now
    // returns real values. These helpers reproduce the engine's UTC parse so the
    // assertions aren't hardcoded.
    private func utcCalendar() -> Calendar {
        var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(secondsFromGMT: 0)!; return c
    }
    private func parseISO(_ iso: String) -> Date {
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.date(from: iso)!
    }
    private func yearOf(_ iso: String) -> Int { utcCalendar().component(.year, from: parseISO(iso)) }
    private func currentYear() -> Int { utcCalendar().component(.year, from: Date()) }

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
    
    /// Test: year(birthDate) parses the ISO date string "1990-06-20T00:00:00.000Z" -> 1990
    func testYearFromFieldReference() {
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, String(yearOf("1990-06-20T00:00:00.000Z")), "year(birthDate) should parse the ISO string to 1990")
    }

    /// Test: Age calculation - year(now()) - year(birthDate)
    func testAgeCalculation() {
        let result = getFieldValue("intermediate_example_age")
        XCTAssertEqual(result, String(currentYear() - yearOf("1990-06-20T00:00:00.000Z")), "year(now()) - year(birthDate)")
    }

    /// Test: Expiry check - if(year(expiryDate) < year(now()), "Expired", "Valid")
    func testExpiryCheck() {
        let result = getFieldValue("advanced_example_expiry")
        let expected = yearOf("2022-12-31T00:00:00.000Z") < currentYear() ? "Expired" : "Valid"
        XCTAssertEqual(result, expected, "expiryDate year (2022) < current year -> Expired")
    }

    /// Test: Half year - if(year(sampleDate) == 2023 && month(sampleDate) > 6, ...)
    /// sampleDate is 2023-08-15, so year==2023 and month(8)>6 -> "Second half of 2023"
    func testHalfYear() {
        let result = getFieldValue("advanced_example_half")
        XCTAssertEqual(result, "Second half of 2023", "2023-08 -> Second half of 2023")
    }

    /// Test: Fiscal year uses the ternary operator (? :), which the engine does not support,
    /// so the expression errors and resolves to empty (regardless of date parsing).
    func testFiscalYear() {
        let result = getFieldValue("advanced_example_fiscal")
        XCTAssertEqual(result, "", "fiscal-year uses the unsupported ternary operator -> empty")
    }

    // MARK: - Dynamic Update Tests

    /// Test: Updating birthDate to another ISO date string recomputes year(birthDate)
    func testDynamicUpdateBirthDateRecomputes() {
        XCTAssertEqual(getFieldValue("intermediate_example_field"), String(yearOf("1990-06-20T00:00:00.000Z")), "Initial year(birthDate) is 1990")

        updateStringValue("birthDate", "2000-03-10T00:00:00.000Z")
        XCTAssertEqual(getFieldValue("intermediate_example_field"), String(yearOf("2000-03-10T00:00:00.000Z")), "year(birthDate) recomputes to 2000")
        XCTAssertEqual(getFieldValue("intermediate_example_age"), String(currentYear() - yearOf("2000-03-10T00:00:00.000Z")), "age recomputes after update")
    }
}
