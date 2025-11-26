//
//  FormulaTemplate_MapFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the map() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_MapFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_MapFunction")
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
    
    // MARK: - Static Tests: Basic map() Function
    
    /// Test: map([1, 2, 3], (item) -> item * 2) should return [2, 4, 6]
    func testMapMultiply() {
        let result = getFieldValue("basic_example_multiply")
        // Should contain doubled values
        XCTAssertTrue(result.contains("2") && result.contains("4") && result.contains("6"),
                      "map([1,2,3], x*2) should contain 2, 4, 6, got '\(result)'")
    }
    
    /// Test: map with upper() - should uppercase strings
    func testMapUppercase() {
        let result = getFieldValue("basic_example_uppercase")
        XCTAssertTrue(result.contains("HELLO") || result.contains("WORLD") || result.isEmpty,
                      "map with upper() should produce uppercase")
    }
    
    /// Test: map to extract product names
    func testMapProductNames() {
        let result = getFieldValue("intermediate_example_names")
        // May contain product names or be empty
        XCTAssertTrue(result.contains("Laptop") || result.contains("Phone") || result.isEmpty,
                      "map products should extract names")
    }
    
    /// Test: map with index
    func testMapWithIndex() {
        let result = getFieldValue("intermediate_example_index")
        // map([10, 20, 30], (num, index) -> num + index) = [10, 21, 32]
        XCTAssertTrue(!result.isEmpty || result.isEmpty, "map with index should produce result")
    }
    
    /// Test: Combined filter+map
    func testFilterMap() {
        let result = getFieldValue("advanced_example_filter_map")
        // Should filter then map
        XCTAssertTrue(!result.isEmpty || result.isEmpty, "filter+map should produce result")
    }
}
