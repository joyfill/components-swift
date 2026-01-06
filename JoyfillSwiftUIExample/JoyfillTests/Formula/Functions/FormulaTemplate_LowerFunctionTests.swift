//
//  lowerTests.swift
//  JoyfillTests
//
//  Unit tests for the lower() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class lowerTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "lower")
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
    
    // MARK: - Static Tests: Basic lower() Function
    
    /// Test: lower("JOY") should return "joy"
    func testLowerAllUppercase() {
        let result = getFieldValue("basic_example_simple")
        XCTAssertEqual(result, "joy", "lower('JOY') should return 'joy'")
    }
    
    /// Test: lower("Joyfill") should return "joyfill"
    func testLowerMixedCase() {
        let result = getFieldValue("basic_example_mixed")
        XCTAssertEqual(result, "joyfill", "lower('Joyfill') should return 'joyfill'")
    }
    
    // MARK: - Static Tests: Initial Field Values
    
    /// Test: Verify initial field values
    func testInitialFieldValues() {
        XCTAssertEqual(getFieldValue("productName"), "Premium SUBSCRIPTION", "Initial productName")
        XCTAssertEqual(getFieldValue("firstName"), "John", "Initial firstName")
        XCTAssertEqual(getFieldValue("lastName"), "DOE", "Initial lastName")
        XCTAssertEqual(getFieldValue("userInput"), "Hello", "Initial userInput")
        XCTAssertEqual(getFieldValue("expectedValue"), "HELLO", "Initial expectedValue")
    }
    
    /// Test: lower(productName) with "Premium SUBSCRIPTION"
    func testLowerFieldReference() {
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "premium subscription", "lower(productName) should return 'premium subscription'")
    }
    
    /// Test: concat(firstName, " ", lower(lastName)) with "John" and "DOE"
    func testLowerWithConcat() {
        let result = getFieldValue("intermediate_example_concat")
        XCTAssertEqual(result, "John doe", "concat(firstName, ' ', lower(lastName)) should return 'John doe'")
    }
    
    /// Test: Advanced case-insensitive comparison - initial state
    /// lower("Hello") == lower("HELLO") → "hello" == "hello" → match
    func testAdvancedExampleInitialState() {
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "Input matches expected value (case-insensitive)", "Hello should match HELLO case-insensitively")
    }
    
    // MARK: - Dynamic Tests: Product Name
    
    /// Test: Update product name to all uppercase
    func testDynamicUpdateProductNameAllUpper() {
        updateStringValue("productName", "ENTERPRISE EDITION")
        
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "enterprise edition", "All uppercase should convert to lowercase")
    }
    
    /// Test: Update product name to all lowercase
    func testDynamicUpdateProductNameAllLower() {
        updateStringValue("productName", "basic plan")
        
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "basic plan", "Already lowercase should stay lowercase")
    }
    
    /// Test: Update product name with numbers
    func testDynamicUpdateProductNameWithNumbers() {
        updateStringValue("productName", "Plan 2024 PREMIUM")
        
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "plan 2024 premium", "Numbers should be preserved, letters lowercased")
    }
    
    // MARK: - Dynamic Tests: Last Name in Concat
    
    /// Test: Update lastName to mixed case
    func testDynamicUpdateLastNameMixedCase() {
        updateStringValue("lastName", "McArthur")
        
        let result = getFieldValue("intermediate_example_concat")
        XCTAssertEqual(result, "John mcarthur", "McArthur should become mcarthur")
    }
    
    /// Test: Update firstName (not lowered)
    func testDynamicUpdateFirstName() {
        updateStringValue("firstName", "JANE")
        
        let result = getFieldValue("intermediate_example_concat")
        // firstName is NOT lowered in the formula, only lastName
        XCTAssertEqual(result, "JANE doe", "firstName should stay as-is, lastName lowered")
    }
    
    /// Test: Update both names
    func testDynamicUpdateBothNames() {
        updateStringValue("firstName", "Alice")
        updateStringValue("lastName", "SMITH")
        
        let result = getFieldValue("intermediate_example_concat")
        XCTAssertEqual(result, "Alice smith", "Alice with lowered SMITH")
    }
    
    // MARK: - Dynamic Tests: Case-Insensitive Comparison
    
    /// Test: User input matches expected (different case)
    func testDynamicUpdateMatchingDifferentCase() {
        updateStringValue("userInput", "hElLo")
        
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "Input matches expected value (case-insensitive)", "hElLo should match HELLO")
    }
    
    /// Test: User input does not match
    func testDynamicUpdateNotMatching() {
        updateStringValue("userInput", "World")
        
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "Input does not match. Expected: HELLO", "World should not match HELLO")
    }
    
    /// Test: Change expected value
    func testDynamicUpdateExpectedValue() {
        updateStringValue("expectedValue", "WORLD")
        updateStringValue("userInput", "world")
        
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "Input matches expected value (case-insensitive)", "world should match WORLD")
    }
    
    /// Test: Both empty
    func testDynamicUpdateBothEmpty() {
        updateStringValue("userInput", "")
        updateStringValue("expectedValue", "")
        
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "Input matches expected value (case-insensitive)", "Empty strings should match")
    }
    
    // MARK: - Sequence Test
    
    /// Test: Complex sequence of changes
    func testDynamicUpdateSequence() {
        // Initial: Hello matches HELLO
        XCTAssertEqual(getFieldValue("advanced_example"), "Input matches expected value (case-insensitive)", "Step 1")
        
        // Change userInput to not match
        updateStringValue("userInput", "Hi")
        XCTAssertEqual(getFieldValue("advanced_example"), "Input does not match. Expected: HELLO", "Step 2")
        
        // Change expectedValue to match userInput
        updateStringValue("expectedValue", "HI")
        XCTAssertEqual(getFieldValue("advanced_example"), "Input matches expected value (case-insensitive)", "Step 3")
        
        // Test with special characters
        updateStringValue("userInput", "Test@123")
        updateStringValue("expectedValue", "TEST@123")
        XCTAssertEqual(getFieldValue("advanced_example"), "Input matches expected value (case-insensitive)", "Step 4")
    }
    
    // MARK: - Edge Cases
    
    /// Test: Empty string
    func testDynamicUpdateEmptyString() {
        updateStringValue("productName", "")
        
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "", "Empty string should return empty")
    }
    
    /// Test: Special characters (should be preserved)
    func testDynamicUpdateSpecialCharacters() {
        updateStringValue("productName", "Plan A+ (BETA)")
        
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "plan a+ (beta)", "Special characters preserved, letters lowered")
    }
    
    /// Test: Unicode characters
    func testDynamicUpdateUnicode() {
        updateStringValue("productName", "Ñoño CAFÉ")
        
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "ñoño café", "Unicode characters should be lowercased")
    }
    
    /// Test: Numbers only (no change)
    func testDynamicUpdateNumbersOnly() {
        updateStringValue("productName", "12345")
        
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "12345", "Numbers should remain unchanged")
    }
    
    /// Test: Whitespace handling
    func testDynamicUpdateWhitespace() {
        updateStringValue("productName", "  SPACED  OUT  ")
        
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "  spaced  out  ", "Whitespace should be preserved")
    }
}

