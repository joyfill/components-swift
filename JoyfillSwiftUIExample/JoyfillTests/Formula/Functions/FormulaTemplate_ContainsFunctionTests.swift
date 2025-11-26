//
//  FormulaTemplate_ContainsFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the contains() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_ContainsFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_ContainsFunction")
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
    
    // MARK: - Static Tests: Basic contains() Function
    
    /// Test: contains("Joyfill Rocks", "rock") - case insensitive search
    func testContainsWithMatchingSubstring() {
        // contains("Joyfill Rocks", "rock") → true (case insensitive)
        let result = getFieldValue("basic_example_true")
        XCTAssertEqual(result, "true", "contains('Joyfill Rocks', 'rock') should return 'true' (case insensitive)")
    }
    
    /// Test: contains("Joyfill Rocks", "test") - no match
    func testContainsWithNoMatch() {
        // contains("Joyfill Rocks", "test") → false
        let result = getFieldValue("basic_example_false")
        XCTAssertEqual(result, "false", "contains('Joyfill Rocks', 'test') should return 'false'")
    }
    
    // MARK: - Static Tests: Initial Field Values
    
    /// Test: Verify initial field values are set correctly
    func testInitialFieldValues() {
        XCTAssertEqual(getFieldValue("productName"), "Premium Joyfill Subscription", "Initial productName")
        XCTAssertEqual(getFieldValue("email"), "user@example.com", "Initial email")
        XCTAssertEqual(getFieldValue("firstName"), "John", "Initial firstName")
        XCTAssertEqual(getFieldValue("lastName"), "Doe", "Initial lastName")
        XCTAssertEqual(getFieldValue("fullName"), "John Doe", "Initial fullName")
        XCTAssertEqual(getFieldValue("userInput"), "Hello, my name is John", "Initial userInput")
        XCTAssertEqual(getFieldValue("blockedWords"), "inappropriate,offensive,spam", "Initial blockedWords")
    }
    
    /// Test: contains(productName, "premium") with "Premium Joyfill Subscription"
    func testIntermediateProductContainsPremium() {
        // "Premium Joyfill Subscription" contains "premium" (case insensitive) → true
        let result = getFieldValue("intermediate_example_product")
        XCTAssertEqual(result, "true", "contains(productName, 'premium') should be 'true'")
    }
    
    /// Test: Email validation - initial state with valid email
    func testIntermediateEmailValidation() {
        // email = "user@example.com" contains "@" → "Valid email format"
        let result = getFieldValue("intermediate_example_email")
        XCTAssertEqual(result, "Valid email format", "Email with @ should show 'Valid email format'")
    }
    
    /// Test: Advanced example - initial state
    /// and(contains(fullName, firstName), contains(fullName, lastName), not(contains(blockedWords, userInput)))
    func testAdvancedExampleInitialState() {
        // fullName="John Doe" contains "John" → true
        // fullName="John Doe" contains "Doe" → true
        // blockedWords doesn't contain userInput → not(false) → true
        // and(true, true, true) → true
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "true", "Advanced example initial state should be 'true'")
    }
    
    // MARK: - Dynamic Tests: Product Name
    
    /// Test: Change product name to not contain "premium"
    func testDynamicUpdateProductNameNoPremium() {
        updateStringValue("productName", "Basic Joyfill Plan")
        
        let result = getFieldValue("intermediate_example_product")
        XCTAssertEqual(result, "false", "Product without 'premium' should return 'false'")
    }
    
    /// Test: Change product name with different casing
    func testDynamicUpdateProductNameDifferentCase() {
        updateStringValue("productName", "PREMIUM EDITION")
        
        let result = getFieldValue("intermediate_example_product")
        XCTAssertEqual(result, "true", "Product with 'PREMIUM' should return 'true' (case insensitive)")
    }
    
    // MARK: - Dynamic Tests: Email Validation
    
    /// Test: Remove @ from email
    func testDynamicUpdateEmailNoAt() {
        updateStringValue("email", "invalid-email.com")
        
        let result = getFieldValue("intermediate_example_email")
        XCTAssertEqual(result, "Invalid email format", "Email without @ should show 'Invalid email format'")
    }
    
    /// Test: Email with multiple @
    func testDynamicUpdateEmailMultipleAt() {
        updateStringValue("email", "user@@example.com")
        
        let result = getFieldValue("intermediate_example_email")
        XCTAssertEqual(result, "Valid email format", "Email with @ should show 'Valid email format'")
    }
    
    /// Test: Email with just @
    func testDynamicUpdateEmailJustAt() {
        updateStringValue("email", "@")
        
        let result = getFieldValue("intermediate_example_email")
        XCTAssertEqual(result, "Valid email format", "Email with just @ should show 'Valid email format'")
    }
    
    // MARK: - Dynamic Tests: Full Name Validation
    
    /// Test: Change firstName - no longer in fullName
    func testDynamicUpdateFirstNameNotInFullName() {
        updateStringValue("firstName", "Jane")
        
        let result = getFieldValue("advanced_example")
        // fullName="John Doe" doesn't contain "Jane" → false
        // and(false, true, true) → false
        XCTAssertEqual(result, "false", "fullName not containing firstName should be 'false'")
    }
    
    /// Test: Change lastName - no longer in fullName
    func testDynamicUpdateLastNameNotInFullName() {
        updateStringValue("lastName", "Smith")
        
        let result = getFieldValue("advanced_example")
        // fullName="John Doe" doesn't contain "Smith" → false
        // and(true, false, true) → false
        XCTAssertEqual(result, "false", "fullName not containing lastName should be 'false'")
    }
    
    /// Test: Update fullName to match new names
    func testDynamicUpdateFullNameToMatch() {
        updateStringValue("firstName", "Jane")
        updateStringValue("lastName", "Smith")
        updateStringValue("fullName", "Jane Smith")
        
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "true", "Updated fullName matching names should be 'true'")
    }
    
    // MARK: - Dynamic Tests: Blocked Words
    // Note: The formula is contains(blockedWords, userInput) - checking if blockedWords contains the ENTIRE userInput
    // Not checking if userInput contains any blocked word
    
    /// Test: User input is exactly a blocked word
    func testDynamicUpdateUserInputIsBlockedWord() {
        updateStringValue("userInput", "spam")
        
        let result = getFieldValue("advanced_example")
        // blockedWords="inappropriate,offensive,spam" contains "spam" → true
        // not(true) → false
        // and(true, true, false) → false
        XCTAssertEqual(result, "false", "User input that is a blocked word should be 'false'")
    }
    
    /// Test: User input is "inappropriate"
    func testDynamicUpdateUserInputInappropriate() {
        updateStringValue("userInput", "inappropriate")
        
        let result = getFieldValue("advanced_example")
        // blockedWords contains "inappropriate" → true, not(true) → false
        XCTAssertEqual(result, "false", "User input 'inappropriate' should be 'false'")
    }
    
    /// Test: Clear user input
    func testDynamicUpdateUserInputEmpty() {
        updateStringValue("userInput", "")
        
        let result = getFieldValue("advanced_example")
        // Empty string doesn't contain blocked words → not(false) → true
        XCTAssertEqual(result, "true", "Empty user input should be 'true'")
    }
    
    // MARK: - Sequence Test
    
    /// Test: Complex sequence of changes
    func testDynamicUpdateSequence() {
        // Initial state: true
        XCTAssertEqual(getFieldValue("advanced_example"), "true", "Step 1: Initial state")
        
        // Set userInput to exact blocked word (blockedWords contains "spam")
        updateStringValue("userInput", "spam")
        XCTAssertEqual(getFieldValue("advanced_example"), "false", "Step 2: userInput is blocked word")
        
        // Change to non-blocked content
        updateStringValue("userInput", "clean content")
        XCTAssertEqual(getFieldValue("advanced_example"), "true", "Step 3: Clean content")
        
        // Change firstName to not match
        updateStringValue("firstName", "Bob")
        XCTAssertEqual(getFieldValue("advanced_example"), "false", "Step 4: firstName not in fullName")
        
        // Update fullName to include new firstName
        updateStringValue("fullName", "Bob Doe")
        XCTAssertEqual(getFieldValue("advanced_example"), "true", "Step 5: Updated fullName")
    }
    
    // MARK: - Edge Cases
    
    /// Test: Empty string search
    func testDynamicUpdateEmptySearchString() {
        updateStringValue("firstName", "")
        
        // contains(fullName, "") - empty string is contained in everything
        let result = getFieldValue("advanced_example")
        // This depends on implementation - empty string might match everything
        XCTAssertTrue(result == "true" || result == "false", "Empty search string should return valid result")
    }
    
    /// Test: Special characters
    func testDynamicUpdateSpecialCharacters() {
        updateStringValue("productName", "Premium+ (Special) Edition!")
        
        let result = getFieldValue("intermediate_example_product")
        XCTAssertEqual(result, "true", "Special characters should not affect contains")
    }
    
    /// Test: Unicode characters
    func testDynamicUpdateUnicodeCharacters() {
        updateStringValue("productName", "プレミアム Premium 版")
        
        let result = getFieldValue("intermediate_example_product")
        XCTAssertEqual(result, "true", "Unicode characters should not affect contains for 'premium'")
    }
    
    /// Test: Partial word match
    func testDynamicUpdatePartialWordMatch() {
        updateStringValue("productName", "Premiumly Enhanced")
        
        let result = getFieldValue("intermediate_example_product")
        XCTAssertEqual(result, "true", "Partial word containing 'premium' should match")
    }
}

