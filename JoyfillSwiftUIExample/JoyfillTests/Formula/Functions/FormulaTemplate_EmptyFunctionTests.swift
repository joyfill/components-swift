//
//  FormulaTemplate_EmptyFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the empty() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_EmptyFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_EmptyFunction")
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
    
    // MARK: - Static Tests: Basic empty() Function
    
    /// Test: empty("") should return "true"
    func testEmptyWithEmptyString() {
        // empty("") → true
        let result = getFieldValue("basic_example_string")
        XCTAssertEqual(result, "true", "empty(\"\") should return 'true'")
    }
    
    /// Test: empty(0) - zero IS considered empty in Joyfill
    func testEmptyWithZero() {
        // empty(0) → true (Joyfill treats 0 as empty/falsy)
        let result = getFieldValue("basic_example_number")
        XCTAssertEqual(result, "true", "empty(0) should return 'true' - Joyfill treats 0 as empty")
    }
    
    /// Test: empty([]) should return "true"
    func testEmptyWithEmptyArray() {
        // empty([]) → true
        let result = getFieldValue("basic_example_array")
        XCTAssertEqual(result, "true", "empty([]) should return 'true'")
    }
    
    // MARK: - Static Tests: Field References
    
    /// Test: empty(name) with name = "" should return "true"
    func testEmptyWithEmptyFieldValue() {
        // name is "", so empty(name) → true
        let result = getFieldValue("intermediate_example_name")
        XCTAssertEqual(result, "true", "empty(name) with name='' should return 'true'")
    }
    
    /// Test: empty(selectedOptions) with no selections should return "true"
    func testEmptyWithNoSelections() {
        // selectedOptions has no selections, so empty(selectedOptions) → true
        let result = getFieldValue("intermediate_example_options")
        XCTAssertEqual(result, "true", "empty(selectedOptions) with no selections should return 'true'")
    }
    
    // MARK: - Static Tests: Advanced Example
    
    /// Test: Advanced email validation - initial state (empty email)
    func testAdvancedExampleInitialState() {
        // email is "", so if(empty(email), ...) → "Please enter your email"
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "Please enter your email", "Empty email should show 'Please enter your email'")
    }
    
    // MARK: - Dynamic Tests: Name Field
    
    /// Test: Set name to non-empty value
    func testDynamicUpdateNameToNonEmpty() {
        updateStringValue("name", "John Doe")
        
        let result = getFieldValue("intermediate_example_name")
        XCTAssertEqual(result, "false", "empty(name) with name='John Doe' should return 'false'")
    }
    
    /// Test: Set name to whitespace only
    func testDynamicUpdateNameToWhitespace() {
        updateStringValue("name", "   ")
        
        let result = getFieldValue("intermediate_example_name")
        // Whitespace-only string is technically not empty (depends on implementation)
        // Most implementations treat "   " as NOT empty since length > 0
        XCTAssertEqual(result, "false", "empty(name) with whitespace should return 'false'")
    }
    
    /// Test: Set name then clear it
    func testDynamicUpdateNameThenClear() {
        // Set name
        updateStringValue("name", "Test")
        XCTAssertEqual(getFieldValue("intermediate_example_name"), "false", "Non-empty name should be false")
        
        // Clear name
        updateStringValue("name", "")
        XCTAssertEqual(getFieldValue("intermediate_example_name"), "true", "Empty name should be true")
    }
    
    // MARK: - Dynamic Tests: Email Validation
    
    /// Test: Set email without @ symbol
    func testDynamicUpdateEmailWithoutAt() {
        updateStringValue("email", "invalidemail")
        
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "Invalid email format", "Email without @ should show 'Invalid email format'")
    }
    
    /// Test: Set email with @ symbol
    func testDynamicUpdateEmailWithAt() {
        updateStringValue("email", "test@example.com")
        
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "Valid email format", "Email with @ should show 'Valid email format'")
    }
    
    /// Test: Set email to just @
    func testDynamicUpdateEmailJustAt() {
        updateStringValue("email", "@")
        
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "Valid email format", "Email with just @ should show 'Valid email format' (contains @)")
    }
    
    /// Test: Clear email after setting
    func testDynamicUpdateEmailThenClear() {
        // Set valid email
        updateStringValue("email", "user@domain.com")
        XCTAssertEqual(getFieldValue("advanced_example"), "Valid email format", "Valid email should show valid")
        
        // Clear email
        updateStringValue("email", "")
        XCTAssertEqual(getFieldValue("advanced_example"), "Please enter your email", "Empty email should prompt for email")
    }
    
    // MARK: - Sequence Test
    
    /// Test: Email validation sequence
    func testDynamicUpdateEmailSequence() {
        // Initial: empty
        XCTAssertEqual(getFieldValue("advanced_example"), "Please enter your email", "Step 1: Empty email")
        
        // Enter invalid email
        updateStringValue("email", "notanemail")
        XCTAssertEqual(getFieldValue("advanced_example"), "Invalid email format", "Step 2: Invalid email")
        
        // Fix email
        updateStringValue("email", "user@example.com")
        XCTAssertEqual(getFieldValue("advanced_example"), "Valid email format", "Step 3: Valid email")
        
        // Remove @ symbol
        updateStringValue("email", "userexample.com")
        XCTAssertEqual(getFieldValue("advanced_example"), "Invalid email format", "Step 4: Removed @")
        
        // Clear everything
        updateStringValue("email", "")
        XCTAssertEqual(getFieldValue("advanced_example"), "Please enter your email", "Step 5: Cleared email")
    }
    
    // MARK: - Edge Cases
    
    /// Test: Single character name
    func testDynamicUpdateSingleCharacterName() {
        updateStringValue("name", "A")
        
        let result = getFieldValue("intermediate_example_name")
        XCTAssertEqual(result, "false", "Single character should not be empty")
    }
    
    /// Test: Special characters in name
    func testDynamicUpdateSpecialCharactersName() {
        updateStringValue("name", "!@#$%")
        
        let result = getFieldValue("intermediate_example_name")
        XCTAssertEqual(result, "false", "Special characters should not be empty")
    }
    
    /// Test: Unicode characters in email
    func testDynamicUpdateUnicodeEmail() {
        updateStringValue("email", "用户@例子.com")
        
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "Valid email format", "Unicode email with @ should be valid format")
    }
}

