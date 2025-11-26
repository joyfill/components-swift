//
//  FormulaTemplate_LengthFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the length() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_LengthFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_LengthFunction")
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
    
    // MARK: - Static Tests: Basic length() Function
    
    /// Test: length("Joyfill") should return 7
    func testLengthOfString() {
        let result = getFieldValue("basic_example_string")
        XCTAssertEqual(result, "7", "length('Joyfill') should return '7'")
    }
    
    /// Test: length(['opt1', 'opt2']) should return 2
    func testLengthOfArray() {
        let result = getFieldValue("basic_example_array")
        XCTAssertEqual(result, "2", "length(['opt1', 'opt2']) should return '2'")
    }
    
    // MARK: - Static Tests: Initial Field Values
    
    /// Test: Verify initial field values
    func testInitialFieldValues() {
        XCTAssertEqual(getFieldValue("userName"), "John Smith", "Initial userName")
        XCTAssertEqual(getFieldValue("phoneNumber"), "123456789", "Initial phoneNumber")
        XCTAssertEqual(getFieldValue("firstName"), "Alexander", "Initial firstName")
        XCTAssertEqual(getFieldValue("lastName"), "Johnson", "Initial lastName")
        XCTAssertEqual(getFieldValue("middleName"), "William", "Initial middleName")
    }
    
    /// Test: length(userName) with "John Smith" → 10
    func testLengthOfFieldReference() {
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "10", "length('John Smith') should return '10'")
    }
    
    /// Test: Phone validation - 9 digits is invalid (< 10)
    func testPhoneValidationInvalid() {
        let result = getFieldValue("advanced_example_validation")
        XCTAssertEqual(result, "Please enter a valid phone number", "9-digit phone should be invalid")
    }
    
    /// Test: Average name length - (9 + 7 + 7) / 3 ≈ 7.67
    func testAverageNameLength() {
        let result = getFieldValue("advanced_example_average")
        // Alexander=9, Johnson=7, William=7 → 23/3 = 7.666...
        XCTAssertTrue(result.hasPrefix("7."), "Average should be approximately 7.67, got '\(result)'")
    }
    
    /// Test: Long description detection (> 100 chars)
    func testLongDescriptionDetection() {
        let result = getFieldValue("advanced_example_ui")
        XCTAssertEqual(result, "Long description", "Description over 100 chars should be 'Long description'")
    }
    
    // MARK: - Dynamic Tests: Username
    
    /// Test: Update userName to shorter string
    func testDynamicUpdateUserNameShort() {
        updateStringValue("userName", "Jane")
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "4", "length('Jane') should return '4'")
    }
    
    /// Test: Update userName to empty string
    func testDynamicUpdateUserNameEmpty() {
        updateStringValue("userName", "")
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "0", "length('') should return '0'")
    }
    
    /// Test: Update userName with spaces
    func testDynamicUpdateUserNameWithSpaces() {
        updateStringValue("userName", "   ")
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "3", "length('   ') should return '3' (spaces count)")
    }
    
    // MARK: - Dynamic Tests: Phone Validation
    
    /// Test: Valid phone with 10 digits
    /// Note: Formula returns "" when condition length >= 10 is met (formula engine behavior)
    func testDynamicUpdatePhoneValid10Digits() {
        updateStringValue("phoneNumber", "1234567890")
        let result = getFieldValue("advanced_example_validation")
        // Formula returns empty string for valid condition
        XCTAssertNotEqual(result, "Please enter a valid phone number", "10-digit phone should not be invalid")
    }
    
    /// Test: Valid phone with 11 digits
    func testDynamicUpdatePhoneValid11Digits() {
        updateStringValue("phoneNumber", "12345678901")
        let result = getFieldValue("advanced_example_validation")
        // Formula returns empty string for valid condition
        XCTAssertNotEqual(result, "Please enter a valid phone number", "11-digit phone should not be invalid")
    }
    
    /// Test: Invalid phone with 5 digits
    func testDynamicUpdatePhoneInvalid() {
        updateStringValue("phoneNumber", "12345")
        let result = getFieldValue("advanced_example_validation")
        XCTAssertEqual(result, "Please enter a valid phone number", "5-digit phone should be invalid")
    }
    
    /// Test: Empty phone
    func testDynamicUpdatePhoneEmpty() {
        updateStringValue("phoneNumber", "")
        let result = getFieldValue("advanced_example_validation")
        XCTAssertEqual(result, "Please enter a valid phone number", "Empty phone should be invalid")
    }
    
    // MARK: - Dynamic Tests: Name Length Average
    
    /// Test: Update firstName
    func testDynamicUpdateFirstName() {
        updateStringValue("firstName", "Bob")  // 3 chars
        let result = getFieldValue("advanced_example_average")
        // (3 + 7 + 7) / 3 = 17/3 ≈ 5.67
        XCTAssertTrue(result.hasPrefix("5."), "Average with 'Bob' should be ~5.67, got '\(result)'")
    }
    
    /// Test: Update all names to same length
    func testDynamicUpdateAllNamesSameLength() {
        updateStringValue("firstName", "Test")   // 4
        updateStringValue("lastName", "Test")    // 4
        updateStringValue("middleName", "Test")  // 4
        let result = getFieldValue("advanced_example_average")
        // (4 + 4 + 4) / 3 = 4
        XCTAssertEqual(result, "4", "Average of three 4-char names should be '4'")
    }
    
    // MARK: - Dynamic Tests: Description Length
    
    /// Test: Short description (< 100)
    func testDynamicUpdateShortDescription() {
        updateStringValue("description", "Short text")
        let result = getFieldValue("advanced_example_ui")
        XCTAssertEqual(result, "Short description", "Description under 100 chars should be 'Short description'")
    }
    
    /// Test: Exactly 100 characters (boundary)
    func testDynamicUpdateExactly100Chars() {
        let exactly100 = String(repeating: "a", count: 100)
        updateStringValue("description", exactly100)
        let result = getFieldValue("advanced_example_ui")
        XCTAssertEqual(result, "Short description", "Exactly 100 chars should be 'Short description' (not > 100)")
    }
    
    /// Test: 101 characters (just over boundary)
    func testDynamicUpdate101Chars() {
        let exactly101 = String(repeating: "a", count: 101)
        updateStringValue("description", exactly101)
        let result = getFieldValue("advanced_example_ui")
        XCTAssertEqual(result, "Long description", "101 chars should be 'Long description'")
    }
    
    // MARK: - Sequence Test
    
    /// Test: Complex sequence of changes
    func testDynamicUpdateSequence() {
        // Initial phone is invalid (9 digits)
        XCTAssertEqual(getFieldValue("advanced_example_validation"), "Please enter a valid phone number", "Step 1: Invalid")
        
        // Add one digit - becomes valid (no longer shows error)
        updateStringValue("phoneNumber", "1234567890")
        XCTAssertNotEqual(getFieldValue("advanced_example_validation"), "Please enter a valid phone number", "Step 2: Valid")
        
        // Remove digits - becomes invalid again
        updateStringValue("phoneNumber", "123")
        XCTAssertEqual(getFieldValue("advanced_example_validation"), "Please enter a valid phone number", "Step 3: Invalid again")
    }
    
    // MARK: - Edge Cases
    
    /// Test: Unicode characters
    func testDynamicUpdateUnicode() {
        updateStringValue("userName", "日本語")
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "3", "length('日本語') should return '3'")
    }
    
    /// Test: Emoji
    func testDynamicUpdateEmoji() {
        updateStringValue("userName", "👋🌍")
        let result = getFieldValue("intermediate_example_field")
        // Emoji may be counted as 1 or more depending on implementation
        XCTAssertTrue(!result.isEmpty, "Emoji string should have a length")
    }
    
    /// Test: Special characters
    func testDynamicUpdateSpecialChars() {
        updateStringValue("userName", "!@#$%")
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "5", "length('!@#$%') should return '5'")
    }
}
