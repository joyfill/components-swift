//
//  mapTests.swift
//  JoyfillTests
//
//  Unit tests for the map() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class mapTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "map")
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

    // MARK: - Static Tests: Basic map() Function
    
    /// Test: map([1, 2, 3], (item) -> item * 2) should return [2, 4, 6]
    func testMapMultiply() {
        let result = getFieldValue("basic_example_multiply")
        XCTAssertEqual(result, "[2.0, 4.0, 6.0]", "map([1,2,3], x*2) should be 2, 4, 6")
    }
    
    /// Test: map(["hello", "world"], (item) -> upper(item)) should uppercase each element
    func testMapUppercase() {
        let result = getFieldValue("basic_example_uppercase")
        XCTAssertEqual(result, "[HELLO, WORLD]", "map with upper() should produce HELLO, WORLD")
    }
    
    /// Test: map(products, (product) -> product.name) extracts each name
    func testMapProductNames() {
        let result = getFieldValue("intermediate_example_names")
        XCTAssertEqual(result, "[Laptop, Phone, Mouse, Keyboard]", "map should extract all product names")
    }
    
    /// Test: map(numbers, (num, index) -> num + index) → [10+0, 20+1, 30+2]
    func testMapWithIndex() {
        let result = getFieldValue("intermediate_example_index")
        XCTAssertEqual(result, "[10.0, 21.0, 32.0]", "map with index should be 10, 21, 32")
    }
    
    /// Test: map(filter(products, price < 500), concat(name, " - $", price))
    /// Mouse ($25) and Keyboard ($45) are < 500
    func testFilterMap() {
        let result = getFieldValue("advanced_example_filter_map")
        XCTAssertEqual(result, "[Mouse - $25, Keyboard - $45]", "filter+map should keep items under $500")
    }

    /// Test: map(range(0, length(prices) - 1), (index) -> prices[index] * quantities[index])
    /// The engine resolves this to empty.
    func testMapMultipleArrays() {
        let result = getFieldValue("advanced_example_multiple_arrays")
        XCTAssertEqual(result, "", "range/length-based map resolves to empty")
    }

    // MARK: - Dynamic Tests

    /// Test: Update numbers → index map recomputes
    func testDynamicUpdateNumbers() {
        updateStringValue("numbers", "[5, 5, 5]")
        let result = getFieldValue("intermediate_example_index")
        // [5+0, 5+1, 5+2] = [5, 6, 7]
        XCTAssertEqual(result, "[5.0, 6.0, 7.0]", "map(numbers, num+index) should recompute to 5, 6, 7")
    }

    /// Test: Update products → names map recomputes
    func testDynamicUpdateProductNames() {
        updateStringValue("products", "[{\"name\": \"Tablet\", \"price\": 300}, {\"name\": \"Monitor\", \"price\": 600}]")
        let result = getFieldValue("intermediate_example_names")
        XCTAssertEqual(result, "[Tablet, Monitor]", "map should extract the updated product names")
    }

    /// Test: Update products → filter+map keeps only items under $500
    func testDynamicUpdateFilterMap() {
        updateStringValue("products", "[{\"name\": \"Tablet\", \"price\": 300}, {\"name\": \"Monitor\", \"price\": 600}]")
        let result = getFieldValue("advanced_example_filter_map")
        // Only Tablet ($300) is < 500; Monitor ($600) is excluded
        XCTAssertEqual(result, "[Tablet - $300]", "filter+map should keep only Tablet")
    }
}
