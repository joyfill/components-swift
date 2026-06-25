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
    
    private func updateStringValue(_ fieldId: String, _ value: String) {
        documentEditor.updateValue(for: fieldId, value: .string(value))
    }

    // MARK: - Static Tests: Basic filter() Function

    /// Test: filter([2, 5, 8, 12, 3], (num) -> num > 5) keeps exactly [8, 12].
    func testFilterNumbers() {
        let result = getFieldValue("basic_example_numbers")
        XCTAssertEqual(result, "8.0, 12.0", "filter(num > 5) should keep exactly 8 and 12")
    }

    /// Test: filter(["apple", "", "banana", "", "cherry"], !empty) drops the empty strings.
    func testFilterNonEmptyStrings() {
        let result = getFieldValue("basic_example_strings")
        XCTAssertEqual(result, "apple, banana, cherry", "filter(!empty) should keep only the non-empty strings")
    }

    /// Test: filter(products, price < 50) keeps Mouse(25) and Keyboard(45), drops Laptop/Phone.
    /// Result is an array of dictionaries whose key order is non-deterministic, so assert on
    /// the kept/dropped names and prices rather than an exact string.
    func testFilterProductsByPrice() {
        let result = getFieldValue("intermediate_example_products")
        XCTAssertTrue(result.contains("Mouse") && result.contains("25.0"), "Should keep Mouse(25), got '\(result)'")
        XCTAssertTrue(result.contains("Keyboard") && result.contains("45.0"), "Should keep Keyboard(45), got '\(result)'")
        XCTAssertFalse(result.contains("Laptop"), "Should drop Laptop(999), got '\(result)'")
        XCTAssertFalse(result.contains("Phone"), "Should drop Phone(699), got '\(result)'")
    }

    /// Test: filter(numbers, even index) keeps indices 0,2,4 → values 10, 30, 50.
    func testFilterByEvenIndex() {
        let result = getFieldValue("intermediate_example_even_indices")
        XCTAssertEqual(result, "10.0, 30.0, 50.0", "filter(even index) should keep 10, 30, 50")
    }

    /// Test: map(filter(products, price < 100), .name) → ["Mouse", "Keyboard"].
    func testFilterMapCombined() {
        let result = getFieldValue("advanced_example_filter_map")
        XCTAssertEqual(result, "Mouse, Keyboard", "filter(price < 100) + map(name) should be Mouse, Keyboard")
    }

    /// Test: filter(inventory, inStock && onSale) keeps Phone and Mouse, drops Laptop(onSale=false)
    /// and Keyboard(inStock=false). Dictionary key order is non-deterministic.
    func testFilterMultipleConditions() {
        let result = getFieldValue("advanced_example_multiple_conditions")
        XCTAssertTrue(result.contains("Phone"), "Should keep Phone (inStock && onSale), got '\(result)'")
        XCTAssertTrue(result.contains("Mouse"), "Should keep Mouse (inStock && onSale), got '\(result)'")
        XCTAssertFalse(result.contains("Laptop"), "Should drop Laptop (onSale=false), got '\(result)'")
        XCTAssertFalse(result.contains("Keyboard"), "Should drop Keyboard (inStock=false), got '\(result)'")
    }

    /// Test: filter(departments, any employee salary > 50000) keeps Engineering(Alice 75000) and
    /// Marketing(Diana 60000), drops Sales(max 35000). Dictionary key order is non-deterministic.
    func testFilterNestedDepartments() {
        let result = getFieldValue("advanced_example_nested")
        XCTAssertTrue(result.contains("Engineering"), "Should keep Engineering (Alice 75000), got '\(result)'")
        XCTAssertTrue(result.contains("Marketing"), "Should keep Marketing (Diana 60000), got '\(result)'")
        XCTAssertFalse(result.contains("Sales"), "Should drop Sales (max salary 35000), got '\(result)'")
    }

    // MARK: - Dynamic Update Tests

    /// Test: Mutating products recomputes filter(products, price < 50).
    func testDynamicUpdateProductsRecomputes() {
        // Baseline: Mouse(25) and Keyboard(45) kept
        XCTAssertTrue(getFieldValue("intermediate_example_products").contains("Mouse"), "Baseline keeps Mouse")

        // Make every product expensive -> nothing matches price < 50
        updateStringValue("products", "[{\"name\": \"Laptop\", \"price\": 999}, {\"name\": \"Phone\", \"price\": 699}]")
        XCTAssertEqual(getFieldValue("intermediate_example_products"), "", "No product under 50 -> empty result")

        // Make exactly one product cheap -> only it is kept
        updateStringValue("products", "[{\"name\": \"Cable\", \"price\": 10}, {\"name\": \"Phone\", \"price\": 699}]")
        let result = getFieldValue("intermediate_example_products")
        XCTAssertTrue(result.contains("Cable") && result.contains("10.0"), "Should keep Cable(10), got '\(result)'")
        XCTAssertFalse(result.contains("Phone"), "Should drop Phone(699), got '\(result)'")
    }

    /// Test: Mutating numbers recomputes filter(numbers, even index).
    func testDynamicUpdateNumbersRecomputes() {
        // Baseline: [10,20,30,40,50] -> even indices -> 10, 30, 50
        XCTAssertEqual(getFieldValue("intermediate_example_even_indices"), "10.0, 30.0, 50.0", "Baseline even indices")

        // New array [1,2,3,4] -> even indices 0,2 -> 1, 3
        updateStringValue("numbers", "[1, 2, 3, 4]")
        XCTAssertEqual(getFieldValue("intermediate_example_even_indices"), "1.0, 3.0", "Even indices of [1,2,3,4] are 1, 3")
    }
}
