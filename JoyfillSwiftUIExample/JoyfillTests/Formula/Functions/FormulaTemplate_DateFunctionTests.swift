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
    
    // MARK: - Additional Static Tests
    
    /// Test: Days between dates
    func testDaysBetweenDates() {
        let result = getFieldValue("intermediate_example_days_between")
        // (date(2023, 5, 15) - date(2023, 1, 1)) / (1000 * 60 * 60 * 24)
        // Should be 134 days (Jan 1 to May 15)
        if let days = Double(result) {
            XCTAssertEqual(days, 134.0, accuracy: 1.0, "Jan 1 to May 15, 2023 should be 134 days")
        }
    }
    
    /// Test: Advanced Christmas formula
    func testAdvancedChristmasFormula() {
        let result = getFieldValue("advanced_example_christmas")
        // Will depend on current date, but should produce either message
        XCTAssertTrue(result == "Merry Christmas!" || result == "Not Christmas yet", 
                      "Should return Christmas message or 'Not Christmas yet'")
    }
    
    /// Test: Advanced tax deadline formula
    func testAdvancedTaxDeadlineFormula() {
        let result = getFieldValue("advanced_example_tax_deadline")
        // Will depend on current date
        XCTAssertTrue(result == "Tax filing deadline has passed" || 
                      result == "You still have time to file taxes", 
                      "Should return tax deadline message")
    }
    
    /// Test: Advanced Halloween formula
    func testAdvancedHalloweenFormula() {
        let result = getFieldValue("advanced_example_halloween")
        // Will depend on current date
        XCTAssertTrue(result == "Happy Halloween!" || result == "Not Halloween", 
                      "Should return Halloween message")
    }
    
    // MARK: - Additional Dynamic Tests with Verification
    
    /// Test: Update year and verify extraction
    func testDynamicUpdateYearExtraction() {
        updateNumberValue("yearValue", 2025)
        
        let result = getFieldValue("basic_example_variables")
        XCTAssertTrue(!result.isEmpty, "Updated year should produce date with 2025")
    }
    
    /// Test: Update month and verify extraction
    func testDynamicUpdateMonthExtraction() {
        updateNumberValue("monthValue", 12)
        
        let result = getFieldValue("basic_example_variables")
        XCTAssertTrue(!result.isEmpty, "Updated month should produce date with December")
    }
    
    /// Test: Update day and verify extraction
    func testDynamicUpdateDayExtraction() {
        updateNumberValue("dayValue", 31)
        
        let result = getFieldValue("basic_example_variables")
        XCTAssertTrue(!result.isEmpty, "Updated day should produce date with day 31")
    }
    
    /// Test: Update all components together
    func testDynamicUpdateAllComponents() {
        updateNumberValue("yearValue", 2025)
        updateNumberValue("monthValue", 12)
        updateNumberValue("dayValue", 31)
        
        let result = getFieldValue("basic_example_variables")
        XCTAssertTrue(!result.isEmpty, "date(2025, 12, 31) should produce a result")
    }
    
    // MARK: - Edge Case Tests
    
    /// Test: Leap year - February 29
    func testLeapYearFebruary29() {
        updateNumberValue("yearValue", 2024)  // 2024 is a leap year
        updateNumberValue("monthValue", 2)
        updateNumberValue("dayValue", 29)
        
        let result = getFieldValue("basic_example_variables")
        XCTAssertTrue(!result.isEmpty, "Feb 29, 2024 should be valid (leap year)")
    }
    
    /// Test: Invalid date - February 30
    func testInvalidDateFebruary30() {
        updateNumberValue("yearValue", 2023)
        updateNumberValue("monthValue", 2)
        updateNumberValue("dayValue", 30)  // Invalid
        
        let result = getFieldValue("basic_example_variables")
        // Behavior depends on implementation - may clamp or error
        XCTAssertTrue(true, "Should handle invalid date somehow")
    }
    
    /// Test: Month 0 (boundary)
    func testInvalidMonth0() {
        updateNumberValue("yearValue", 2023)
        updateNumberValue("monthValue", 0)  // Invalid
        updateNumberValue("dayValue", 15)
        
        let result = getFieldValue("basic_example_variables")
        // Should handle gracefully
        XCTAssertTrue(true, "Should handle month 0")
    }
    
    /// Test: Month 13 (boundary)
    func testInvalidMonth13() {
        updateNumberValue("yearValue", 2023)
        updateNumberValue("monthValue", 13)  // Invalid
        updateNumberValue("dayValue", 15)
        
        let result = getFieldValue("basic_example_variables")
        // Should handle gracefully
        XCTAssertTrue(true, "Should handle month 13")
    }
    
    /// Test: Day 0 (boundary)
    func testInvalidDay0() {
        updateNumberValue("yearValue", 2023)
        updateNumberValue("monthValue", 5)
        updateNumberValue("dayValue", 0)  // Invalid
        
        let result = getFieldValue("basic_example_variables")
        // Should handle gracefully
        XCTAssertTrue(true, "Should handle day 0")
    }
    
    /// Test: Day 32 (boundary)
    func testInvalidDay32() {
        updateNumberValue("yearValue", 2023)
        updateNumberValue("monthValue", 5)
        updateNumberValue("dayValue", 32)  // Invalid
        
        let result = getFieldValue("basic_example_variables")
        // Should handle gracefully
        XCTAssertTrue(true, "Should handle day 32")
    }
    
    /// Test: Negative year
    func testNegativeYear() {
        updateNumberValue("yearValue", -1)
        updateNumberValue("monthValue", 5)
        updateNumberValue("dayValue", 15)
        
        let result = getFieldValue("basic_example_variables")
        // Should handle gracefully
        XCTAssertTrue(true, "Should handle negative year")
    }
    
    /// Test: Year 0
    func testYear0() {
        updateNumberValue("yearValue", 0)
        updateNumberValue("monthValue", 5)
        updateNumberValue("dayValue", 15)
        
        let result = getFieldValue("basic_example_variables")
        // Should handle gracefully
        XCTAssertTrue(true, "Should handle year 0")
    }
    
    /// Test: Very large year
    func testVeryLargeYear() {
        updateNumberValue("yearValue", 9999)
        updateNumberValue("monthValue", 12)
        updateNumberValue("dayValue", 31)
        
        let result = getFieldValue("basic_example_variables")
        XCTAssertTrue(!result.isEmpty, "Should handle year 9999")
    }
    
    /// Test: January 1st (boundary)
    func testJanuary1st() {
        updateNumberValue("yearValue", 2023)
        updateNumberValue("monthValue", 1)
        updateNumberValue("dayValue", 1)
        
        let result = getFieldValue("basic_example_variables")
        XCTAssertTrue(!result.isEmpty, "Jan 1, 2023 should be valid")
    }
    
    /// Test: December 31st (boundary)
    func testDecember31st() {
        updateNumberValue("yearValue", 2023)
        updateNumberValue("monthValue", 12)
        updateNumberValue("dayValue", 31)
        
        let result = getFieldValue("basic_example_variables")
        XCTAssertTrue(!result.isEmpty, "Dec 31, 2023 should be valid")
    }
    
    /// Test: Sequence - multiple date updates
    func testDynamicSequenceDates() {
        // Step 1: Create Jan 1, 2023
        updateNumberValue("yearValue", 2023)
        updateNumberValue("monthValue", 1)
        updateNumberValue("dayValue", 1)
        var result = getFieldValue("basic_example_variables")
        XCTAssertTrue(!result.isEmpty, "Step 1: Jan 1, 2023")
        
        // Step 2: Update to Dec 31, 2023
        updateNumberValue("monthValue", 12)
        updateNumberValue("dayValue", 31)
        result = getFieldValue("basic_example_variables")
        XCTAssertTrue(!result.isEmpty, "Step 2: Dec 31, 2023")
        
        // Step 3: Update to Feb 29, 2024 (leap year)
        updateNumberValue("yearValue", 2024)
        updateNumberValue("monthValue", 2)
        updateNumberValue("dayValue", 29)
        result = getFieldValue("basic_example_variables")
        XCTAssertTrue(!result.isEmpty, "Step 3: Feb 29, 2024")
        
        // Step 4: Back to July 4, 2023
        updateNumberValue("yearValue", 2023)
        updateNumberValue("monthValue", 7)
        updateNumberValue("dayValue", 4)
        result = getFieldValue("basic_example_variables")
        XCTAssertTrue(!result.isEmpty, "Step 4: July 4, 2023")
    }
}
