//
//  FormulaTemplate_FlatFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the flat() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_FlatFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_FlatFunction")
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
    
    private func updateFieldValue(_ fieldId: String, _ value: String) {
        documentEditor.updateValue(for: fieldId, value: .string(value))
    }
    
    private func updateNumberValue(_ fieldId: String, _ value: Int) {
        documentEditor.updateValue(for: fieldId, value: .double(Double(value)))
    }
    
    // MARK: - Static Tests
    
    /// Test: Document loads successfully
    func testDocumentLoads() {
        XCTAssertNotNil(documentEditor, "DocumentEditor should load successfully")
    }
    
    /// Test: Basic flat simple nested array - flat([1, [2, 3]])
    func testBasicFlatSimple() {
        let result = getFieldValue("basic_example_simple")
        // flat([1, [2, 3]]) -> [1, 2, 3]
        XCTAssertFalse(result.isEmpty, "flat() should return a result")
        XCTAssertTrue(result.contains("1") && result.contains("2") && result.contains("3"), 
                      "flat([1, [2, 3]]) should contain 1, 2, 3")
    }
    
    /// Test: Basic flat already flat array - flat([1, 2, 3])
    func testBasicFlatUnchanged() {
        let result = getFieldValue("basic_example_unchanged")
        // flat([1, 2, 3]) -> [1, 2, 3] (unchanged)
        XCTAssertFalse(result.isEmpty, "flat() should return a result")
        XCTAssertTrue(result.contains("1") && result.contains("2") && result.contains("3"),
                      "flat([1, 2, 3]) should remain [1, 2, 3]")
    }
    
    /// Test: Intermediate flat with depth - flat([0, 1, [2, [3, [4, 5]]]], 2)
    func testIntermediateFlatWithDepth() {
        let result = getFieldValue("intermediate_example_depth")
        // flat([0, 1, [2, [3, [4, 5]]]], 2) -> [0, 1, 2, 3, [4, 5]]
        // Flattens 2 levels deep
        XCTAssertFalse(result.isEmpty, "flat() with depth should return a result")
        XCTAssertTrue(result.contains("0") && result.contains("1") && result.contains("2") && result.contains("3"),
                      "flat() with depth 2 should flatten first 2 levels")
    }
    
    /// Test: Intermediate flat with field reference - flat(nestedData, flattenDepth)
    func testIntermediateFlatDynamic() {
        let result = getFieldValue("intermediate_example_dynamic")
        // nestedData = [[1, 2], [3, [4, 5]], 6], flattenDepth = 2
        // Should flatten completely: [1, 2, 3, 4, 5, 6]
        XCTAssertFalse(result.isEmpty, "flat() with field reference should return a result")
    }
    
    /// Test: Advanced flat with condition - if(length(flat(responses, 1)) > 0, ...)
    func testAdvancedFlatResponses() {
        let result = getFieldValue("advanced_example_responses")
        // responses = [[], ["response1"], []]
        // flat(responses, 1) -> ["response1"], length > 0, so "At least one response received"
        XCTAssertEqual(result, "At least one response received", "Flat array with one response should indicate responses received")
    }
    
    /// Test: Advanced flat with concat - concat("All categories: ", flat(categories, 2))
    func testAdvancedFlatCategories() {
        let result = getFieldValue("advanced_example_categories")
        // categories = [["Electronics", ["Phones", "Computers"]], ["Clothing", ["Shirts", "Pants"]]]
        // flat(categories, 2) -> ["Electronics", "Phones", "Computers", "Clothing", "Shirts", "Pants"]
        XCTAssertFalse(result.isEmpty, "Concatenated flat categories should return a result")
        XCTAssertTrue(result.contains("All categories:"), "Result should start with 'All categories:'")
    }
    
    // MARK: - Dynamic Update Tests
    
    /// Test: Update nestedData to change flattened result
    func testDynamicUpdateNestedData() {
        // Update with simpler nested data
        updateFieldValue("nestedData", "[[10, 20], [30, 40]]")
        
        let result = getFieldValue("intermediate_example_dynamic")
        XCTAssertFalse(result.isEmpty, "Updated flat() should return a result")
        XCTAssertTrue(result.contains("10") && result.contains("20") && result.contains("30") && result.contains("40"),
                      "Flattened [[10, 20], [30, 40]] should contain all numbers")
    }
    
    /// Test: Update flattenDepth to change how much is flattened
    func testDynamicUpdateFlattenDepth() {
        // Initial depth is 2
        // Change to depth 1 - should leave some nesting
        updateNumberValue("flattenDepth", 1)
        
        let result = getFieldValue("intermediate_example_dynamic")
        XCTAssertFalse(result.isEmpty, "flat() with updated depth should return a result")
    }
    
    /// Test: Update responses to have no responses
    func testDynamicUpdateNoResponses() {
        // Initial: has one response
        let initialResult = getFieldValue("advanced_example_responses")
        XCTAssertEqual(initialResult, "At least one response received")
        
        // Update to have no responses
        updateFieldValue("responses", "[[], [], []]")
        
        let updatedResult = getFieldValue("advanced_example_responses")
        XCTAssertEqual(updatedResult, "No responses yet", "Empty responses should show 'No responses yet'")
    }
    
    /// Test: Update responses to have multiple responses
    func testDynamicUpdateMultipleResponses() {
        // Update to have multiple responses
        updateFieldValue("responses", "[[\"response1\", \"response2\"], [\"response3\"], [\"response4\"]]")
        
        let result = getFieldValue("advanced_example_responses")
        XCTAssertEqual(result, "At least one response received", "Multiple responses should still show 'At least one response received'")
    }
    
    /// Test: Update categories with different structure
    func testDynamicUpdateCategories() {
        // Update with different categories
        updateFieldValue("categories", "[[\"Books\", [\"Fiction\", \"Non-Fiction\"]], [\"Music\", [\"Rock\", \"Jazz\"]]]")
        
        let result = getFieldValue("advanced_example_categories")
        XCTAssertFalse(result.isEmpty, "Updated categories should return a result")
        XCTAssertTrue(result.contains("All categories:"), "Result should start with 'All categories:'")
    }
}
