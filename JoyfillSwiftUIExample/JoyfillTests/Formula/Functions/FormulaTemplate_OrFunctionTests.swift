//
//  FormulaTemplate_OrFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the or() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_OrFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_OrFunction")
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
    
    private func getFieldNumber(_ fieldId: String) -> Double? {
        return documentEditor.value(ofFieldWithIdentifier: fieldId)?.number
    }
    
    private func updateStringValue(_ fieldId: String, _ value: String) {
        documentEditor.updateValue(for: fieldId, value: .string(value))
    }
    
    private func updateNumberValue(_ fieldId: String, _ value: Double) {
        documentEditor.updateValue(for: fieldId, value: .double(value))
    }
    
    // MARK: - Static Tests: Basic or() Function
    
    /// Test: or(true, false) should return "true"
    func testOrWithOneTrueOneFalse() {
        // or(true, false) → true
        let result = getFieldValue("basic_example_true")
        XCTAssertEqual(result, "true", "or(true, false) should return 'true'")
    }
    
    /// Test: or(false, false) should return "false"
    func testOrWithAllFalse() {
        // or(false, false) → false
        let result = getFieldValue("basic_example_false")
        XCTAssertEqual(result, "false", "or(false, false) should return 'false'")
    }
    
    // MARK: - Static Tests: Initial Field Values
    
    /// Test: Verify initial field values are set correctly
    func testInitialFieldValues() {
        // age = 25.0
        let age = getFieldNumber("age")
        XCTAssertEqual(age, 25.0, "Initial age should be 25.0")
    }
    
    /// Test: or(age < 18, status == 'Student') with age=25, status not set
    /// age < 18 is false, status == 'Student' is false → false
    func testIntermediateExampleInitialState() {
        let result = getFieldValue("intermediate_example")
        XCTAssertEqual(result, "false", "or(age < 18, status == 'Student') with age=25, no status should be 'false'")
    }
    
    /// Test: Advanced or with nested and() - initial state
    /// or(and(age >= 65, country == 'USA'), and(age >= 60, country == 'Canada'), and(status == 'Disabled', age >= 18))
    /// With age=25, no country, no status → all conditions false → false
    func testAdvancedOrWithNestedAndInitialState() {
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "false", "Advanced or() with no matching conditions should be 'false'")
    }
    
    // MARK: - Dynamic Tests: Intermediate Example
    
    /// Test: Set age to 15 (< 18) should make intermediate_example true
    func testDynamicUpdateAgeBelowEighteen() {
        // Set age = 15 (age < 18 is true)
        updateNumberValue("age", 15)
        
        let result = getFieldValue("intermediate_example")
        XCTAssertEqual(result, "true", "or(age < 18, status == 'Student') with age=15 should be 'true'")
    }
    
    /// Test: Set status to 'Student' should make intermediate_example true
    func testDynamicUpdateStatusToStudent() {
        // Age is 25 (> 18), but set status = Student
        updateStringValue("status", "Student")
        
        let result = getFieldValue("intermediate_example")
        XCTAssertEqual(result, "true", "or(age < 18, status == 'Student') with status='Student' should be 'true'")
    }
    
    /// Test: Age boundary - exactly 18
    func testDynamicUpdateAgeExactlyEighteen() {
        // age = 18 means age < 18 is false
        updateNumberValue("age", 18)
        
        let result = getFieldValue("intermediate_example")
        XCTAssertEqual(result, "false", "or(age < 18, status == 'Student') with age=18, no status should be 'false'")
    }
    
    /// Test: Age boundary - exactly 17
    func testDynamicUpdateAgeSeventeen() {
        // age = 17 means age < 18 is true
        updateNumberValue("age", 17)
        
        let result = getFieldValue("intermediate_example")
        XCTAssertEqual(result, "true", "or(age < 18, status == 'Student') with age=17 should be 'true'")
    }
    
    /// Test: Both conditions true
    func testDynamicUpdateBothConditionsTrue() {
        // age = 15 (age < 18 is true) AND status = Student
        updateNumberValue("age", 15)
        updateStringValue("status", "Student")
        
        let result = getFieldValue("intermediate_example")
        XCTAssertEqual(result, "true", "or() with both conditions true should be 'true'")
    }
    
    // MARK: - Dynamic Tests: Advanced Example
    
    /// Test: Senior in USA (age >= 65 && country == 'USA')
    func testDynamicUpdateSeniorInUSA() {
        updateNumberValue("age", 65)
        updateStringValue("country", "USA")
        
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "true", "Senior (65+) in USA should qualify")
    }
    
    /// Test: Senior in Canada (age >= 60 && country == 'Canada')
    func testDynamicUpdateSeniorInCanada() {
        updateNumberValue("age", 60)
        updateStringValue("country", "Canada")
        
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "true", "Senior (60+) in Canada should qualify")
    }
    
    /// Test: Disabled adult (status == 'Disabled' && age >= 18)
    func testDynamicUpdateDisabledAdult() {
        updateStringValue("status", "Disabled")
        // age is already 25 (>= 18)
        
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "true", "Disabled adult (18+) should qualify")
    }
    
    /// Test: Disabled minor should NOT qualify
    func testDynamicUpdateDisabledMinor() {
        updateStringValue("status", "Disabled")
        updateNumberValue("age", 16)
        
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "false", "Disabled minor (< 18) should NOT qualify")
    }
    
    /// Test: 64 year old in USA should NOT qualify (needs 65+)
    func testDynamicUpdateNotQuiteSeniorUSA() {
        updateNumberValue("age", 64)
        updateStringValue("country", "USA")
        
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "false", "64 year old in USA should NOT qualify (needs 65+)")
    }
    
    /// Test: 59 year old in Canada should NOT qualify (needs 60+)
    func testDynamicUpdateNotQuiteSeniorCanada() {
        updateNumberValue("age", 59)
        updateStringValue("country", "Canada")
        
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "false", "59 year old in Canada should NOT qualify (needs 60+)")
    }
    
    /// Test: Senior in Other country should NOT qualify
    func testDynamicUpdateSeniorInOtherCountry() {
        updateNumberValue("age", 70)
        updateStringValue("country", "Other")
        
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "false", "Senior in 'Other' country should NOT qualify")
    }
    
    /// Test: Multiple qualifying conditions
    func testDynamicUpdateMultipleQualifyingConditions() {
        // 65+ in USA AND Disabled AND adult → still true (or returns true if any is true)
        updateNumberValue("age", 65)
        updateStringValue("country", "USA")
        updateStringValue("status", "Disabled")
        
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "true", "Multiple qualifying conditions should still be 'true'")
    }
    
    // MARK: - Sequence Test
    
    /// Test: Changing conditions in sequence
    func testDynamicUpdateSequence() {
        // Initial: age=25, no status, no country → false
        XCTAssertEqual(getFieldValue("advanced_example"), "false", "Initial state should be false")
        
        // Add disabled status → true (disabled adult)
        updateStringValue("status", "Disabled")
        XCTAssertEqual(getFieldValue("advanced_example"), "true", "Disabled adult should be true")
        
        // Change status to Employed → false (no longer disabled)
        updateStringValue("status", "Employed")
        XCTAssertEqual(getFieldValue("advanced_example"), "false", "Employed adult should be false")
        
        // Set country to USA → still false (not 65+)
        updateStringValue("country", "USA")
        XCTAssertEqual(getFieldValue("advanced_example"), "false", "25yo in USA should be false")
        
        // Set age to 65 → true (senior in USA)
        updateNumberValue("age", 65)
        XCTAssertEqual(getFieldValue("advanced_example"), "true", "65yo in USA should be true")
        
        // Change country to Canada → false (needs 60+ for Canada, but 65 works, wait - should still be true!)
        updateStringValue("country", "Canada")
        XCTAssertEqual(getFieldValue("advanced_example"), "true", "65yo in Canada should be true (60+ requirement)")
        
        // Lower age to 55 → false
        updateNumberValue("age", 55)
        XCTAssertEqual(getFieldValue("advanced_example"), "false", "55yo in Canada should be false")
    }
}

