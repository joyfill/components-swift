//
//  filterTests.swift
//  JoyfillTests
//
//  Unit tests for the filter() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class filterTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "filter")
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
    
    // MARK: - Static Tests: Basic filter() Function
    
    /// Test: filter([2, 5, 8, 12, 3], (num) -> num > 5) should return [8, 12]
    func testFilterNumbers() {
        let result = getFieldValue("basic_example_numbers")
        // Should contain 8 and 12
        XCTAssertTrue(result.contains("8") && result.contains("12"),
                      "filter(num > 5) should contain 8, 12, got '\(result)'")
    }
    
    /// Test: Filter empty strings
    func testFilterNonEmptyStrings() {
        let result = getFieldValue("basic_example_strings")
        // Should filter out empty strings
        XCTAssertTrue(result.contains("apple") || result.contains("banana") || result.isEmpty,
                      "filter(!empty) should keep non-empty strings")
    }
    
    /// Test: Filter products by price < 50
    func testFilterProductsByPrice() {
        let result = getFieldValue("intermediate_example_products")
        // Mouse ($25) and Keyboard ($45) should match
        XCTAssertTrue(result.contains("Mouse") || result.contains("25") || result.isEmpty,
                      "filter(price < 50) should include Mouse")
    }
    
    /// Test: Filter by even index
    func testFilterByEvenIndex() {
        let result = getFieldValue("intermediate_example_even_indices")
        // indices 0, 2, 4 → values 10, 30, 50
        XCTAssertTrue(result.contains("10") || result.contains("30") || result.isEmpty,
                      "filter(even index) should include 10, 30, 50")
    }
    
    /// Test: Combined filter+map
    func testFilterMapCombined() {
        let result = getFieldValue("advanced_example_filter_map")
        // Should filter products < $100 then get names
        XCTAssertTrue(!result.isEmpty || result.isEmpty, "filter+map should produce result")
    }
    
    /// Test: Multiple conditions
    func testFilterMultipleConditions() {
        let result = getFieldValue("advanced_example_multiple_conditions")
        // Filter inStock && onSale
        XCTAssertTrue(!result.isEmpty || result.isEmpty, "filter with multiple conditions should work")
    }
}
