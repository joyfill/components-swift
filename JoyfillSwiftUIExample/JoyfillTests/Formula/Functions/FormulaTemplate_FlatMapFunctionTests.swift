//
//  flatMapTests.swift
//  JoyfillTests
//
//  Unit tests for the flatMap() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class flatMapTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "flatMap")
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
    
    // MARK: - Static Tests
    
    /// Test: Document loads successfully
    func testDocumentLoads() {
        XCTAssertNotNil(documentEditor, "DocumentEditor should load successfully")
    }
    
    /// Test: Basic flatMap duplicating items - flatMap([1, 2, 3], (item) -> [item, item])
    func testBasicFlatMapDuplicate() {
        let result = getFieldValue("basic_example_duplicate")
        // flatMap([1, 2, 3], (item) -> [item, item]) -> [1, 1, 2, 2, 3, 3]
        XCTAssertFalse(result.isEmpty, "flatMap() should return a result")
        XCTAssertTrue(result.contains("1") && result.contains("2") && result.contains("3"),
                      "flatMap() should contain original values")
    }
    
    /// Test: Basic flatMap multiplying items - flatMap([1, 2, 3], (item) -> item * 2)
    func testBasicFlatMapMultiply() {
        let result = getFieldValue("basic_example_multiply")
        // flatMap([1, 2, 3], (item) -> item * 2) -> [2, 4, 6]
        XCTAssertFalse(result.isEmpty, "flatMap() should return a result")
        XCTAssertTrue(result.contains("2") && result.contains("4") && result.contains("6"),
                      "flatMap() with multiply should return [2, 4, 6]")
    }
    
    /// Test: Intermediate flatMap with filter - flatMap(products, (product) -> if(product.inStock, [product.name], []))
    func testIntermediateFlatMapFilter() {
        let result = getFieldValue("intermediate_example_filter")
        // products has Laptop, Phone in stock; Tablet out of stock
        // Should return ["Laptop", "Phone"]
        XCTAssertFalse(result.isEmpty, "flatMap() filter should return a result")
        XCTAssertTrue(result.contains("Laptop") && result.contains("Phone"),
                      "Should contain in-stock products")
        XCTAssertFalse(result.contains("Tablet"),
                      "Should not contain out-of-stock Tablet")
    }
    
    /// Test: Advanced flatMap with orders - extracting shipped order items
    func testAdvancedFlatMapOrders() {
        let result = getFieldValue("advanced_example_orders")
        // Extract items from shipped orders only
        XCTAssertFalse(result.isEmpty, "flatMap() orders should return a result")
        // Should contain items from shipped orders
        XCTAssertTrue(result.contains("Book") || result.contains("Pen") || result.contains("Pencil") || result.contains("A123") || result.contains("C789"),
                      "Should contain shipped order items")
    }
    
    // MARK: - Dynamic Update Tests
    
    /// Test: Update products to change in-stock items
    func testDynamicUpdateProductsInStock() {
        // Initial: Laptop, Phone in stock
        let initialResult = getFieldValue("intermediate_example_filter")
        XCTAssertTrue(initialResult.contains("Laptop") && initialResult.contains("Phone"))
        XCTAssertFalse(initialResult.contains("Tablet"))
        
        // Update to have different products in stock
        updateFieldValue("products", "[{\"name\": \"Laptop\", \"inStock\": false}, {\"name\": \"Phone\", \"inStock\": false}, {\"name\": \"Tablet\", \"inStock\": true}]")
        
        let updatedResult = getFieldValue("intermediate_example_filter")
        XCTAssertTrue(updatedResult.contains("Tablet"), "Only Tablet should be in stock now")
        XCTAssertFalse(updatedResult.contains("Laptop") || updatedResult.contains("Phone"),
                       "Laptop and Phone should no longer appear")
    }
    
    /// Test: Update orders to change shipped orders
    func testDynamicUpdateOrdersShipped() {
        // Initial: A123 and C789 are shipped
        let initialResult = getFieldValue("advanced_example_orders")
        XCTAssertFalse(initialResult.isEmpty)
        
        // Update to have only B456 shipped
        updateFieldValue("orders", "[{\"id\": \"A123\", \"status\": \"pending\", \"items\": [{\"name\": \"Book\", \"quantity\": 2}]}, {\"id\": \"B456\", \"status\": \"shipped\", \"items\": [{\"name\": \"Notebook\", \"quantity\": 1}]}, {\"id\": \"C789\", \"status\": \"pending\", \"items\": [{\"name\": \"Pencil\", \"quantity\": 3}]}]")
        
        let updatedResult = getFieldValue("advanced_example_orders")
        XCTAssertTrue(updatedResult.contains("Notebook") || updatedResult.contains("B456"),
                      "Should now contain B456 items")
    }
    
    /// Test: Update products to have all in stock
    func testDynamicUpdateAllProductsInStock() {
        updateFieldValue("products", "[{\"name\": \"Laptop\", \"inStock\": true}, {\"name\": \"Phone\", \"inStock\": true}, {\"name\": \"Tablet\", \"inStock\": true}]")
        
        let result = getFieldValue("intermediate_example_filter")
        XCTAssertTrue(result.contains("Laptop") && result.contains("Phone") && result.contains("Tablet"),
                      "All products should be in the result")
    }
    
    /// Test: Update products to have none in stock
    func testDynamicUpdateNoProductsInStock() {
        updateFieldValue("products", "[{\"name\": \"Laptop\", \"inStock\": false}, {\"name\": \"Phone\", \"inStock\": false}, {\"name\": \"Tablet\", \"inStock\": false}]")
        
        let result = getFieldValue("intermediate_example_filter")
        // Empty array or no product names
        XCTAssertFalse(result.contains("Laptop") || result.contains("Phone") || result.contains("Tablet"),
                      "No products should appear when all out of stock")
    }
}
