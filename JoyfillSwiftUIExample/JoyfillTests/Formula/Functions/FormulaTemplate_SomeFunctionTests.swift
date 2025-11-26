//
//  FormulaTemplate_SomeFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the some() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_SomeFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_SomeFunction")
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
    
    /// Test: Basic some with at least one true - some([2, 5, 12, 8], (num) -> num > 10)
    func testBasicSomeAtLeastOneTrue() {
        let result = getFieldValue("basic_example_true")
        // 12 is > 10, so should return true
        XCTAssertEqual(result, "true", "some([2, 5, 12, 8], (num) -> num > 10) should return true because 12 > 10")
    }
    
    /// Test: Basic some with none true - some([2, 5, 8, 9], (num) -> num > 10)
    func testBasicSomeNoneTrue() {
        let result = getFieldValue("basic_example_false")
        // No number > 10, so should return false
        XCTAssertEqual(result, "false", "some([2, 5, 8, 9], (num) -> num > 10) should return false because none > 10")
    }
    
    /// Test: Intermediate some with object property - some(products, (product) -> !product.inStock)
    /// products = [{inStock: true}, {inStock: true}, {inStock: false}, {inStock: true}]
    func testIntermediateSomeProductOutOfStock() {
        let result = getFieldValue("intermediate_example_products")
        // Mouse has inStock: false, so should return true
        XCTAssertEqual(result, "true", "At least one product is out of stock")
    }
    
    /// Test: Intermediate some with index - some(numbers_with_indices, (num, index) -> mod(index, 2) == 1 && num > 20)
    /// numbers_with_indices = [5, 25, 10, 30, 15, 35]
    func testIntermediateSomeWithIndex() {
        let result = getFieldValue("intermediate_example_indices")
        // index 1: 25 > 20 ✓, index 3: 30 > 20 ✓, index 5: 35 > 20 ✓
        XCTAssertEqual(result, "true", "At least one odd-indexed item > 20")
    }
    
    /// Test: Advanced nested some - some(departments, (dept) -> some(dept.employees, (emp) -> emp.salary > 70000))
    func testAdvancedNestedSome() {
        let result = getFieldValue("advanced_example_nested")
        // Engineering has Alice with salary 75000 > 70000, so should return true
        XCTAssertEqual(result, "true", "At least one employee in some department has salary > 70000")
    }
    
    /// Test: Advanced error detection - some(data_points, (point) -> point.hasError || point.value < 0 || empty(point.label))
    func testAdvancedErrorDetection() {
        let result = getFieldValue("advanced_example_error_detection")
        // Point B has value: -5 < 0, Point 3 has empty label, Point D has hasError: true
        XCTAssertEqual(result, "true", "At least one data point has an error condition")
    }
    
    /// Test: Advanced combined with filter - some(filter(electronics, (p) -> p.category == "Electronics"), (p) -> p.price < 50)
    func testAdvancedSomeCombined() {
        let result = getFieldValue("advanced_example_combined")
        // Headphones is Electronics with price 45 < 50, so should return true
        XCTAssertEqual(result, "true", "At least one Electronics item has price < 50")
    }
    
    // MARK: - Dynamic Update Tests
    
    /// Test: Update products to have all in stock
    func testDynamicUpdateAllProductsInStock() {
        // Initial: should be true (Mouse is out of stock)
        let initialResult = getFieldValue("intermediate_example_products")
        XCTAssertEqual(initialResult, "true")
        
        // Update all products to be in stock
        updateFieldValue("products", "[{\"name\": \"Laptop\", \"price\": 999, \"inStock\": true}, {\"name\": \"Phone\", \"price\": 699, \"inStock\": true}, {\"name\": \"Mouse\", \"price\": 25, \"inStock\": true}, {\"name\": \"Keyboard\", \"price\": 45, \"inStock\": true}]")
        
        let updatedResult = getFieldValue("intermediate_example_products")
        XCTAssertEqual(updatedResult, "false", "All products in stock means none out of stock, should return false")
    }
    
    /// Test: Update numbers to have no odd-indexed items > 20
    func testDynamicUpdateNumbersNoMatch() {
        // Initial: should be true
        let initialResult = getFieldValue("intermediate_example_indices")
        XCTAssertEqual(initialResult, "true")
        
        // Update to have low values at odd indices
        updateFieldValue("numbers_with_indices", "[5, 10, 10, 15, 15, 18]")
        
        let updatedResult = getFieldValue("intermediate_example_indices")
        XCTAssertEqual(updatedResult, "false", "No odd-indexed item > 20 should return false")
    }
    
    /// Test: Update departments so no employee has high salary
    func testDynamicUpdateNoHighSalary() {
        // Initial: should be true (Alice has 75000)
        let initialResult = getFieldValue("advanced_example_nested")
        XCTAssertEqual(initialResult, "true")
        
        // Update all salaries to be <= 70000
        updateFieldValue("departments", "[{\"name\": \"Engineering\", \"employees\": [{\"name\": \"Alice\", \"salary\": 65000}, {\"name\": \"Bob\", \"salary\": 45000}]}, {\"name\": \"Marketing\", \"employees\": [{\"name\": \"Charlie\", \"salary\": 40000}, {\"name\": \"Diana\", \"salary\": 60000}]}, {\"name\": \"Sales\", \"employees\": [{\"name\": \"Eve\", \"salary\": 35000}, {\"name\": \"Frank\", \"salary\": 28000}]}]")
        
        let updatedResult = getFieldValue("advanced_example_nested")
        XCTAssertEqual(updatedResult, "false", "No employee > 70000 should return false")
    }
    
    /// Test: Update data points to have no errors
    func testDynamicUpdateNoErrors() {
        // Initial: should be true (multiple error conditions)
        let initialResult = getFieldValue("advanced_example_error_detection")
        XCTAssertEqual(initialResult, "true")
        
        // Update all data points to be valid
        updateFieldValue("data_points", "[{\"id\": 1, \"value\": 10, \"label\": \"Point A\", \"hasError\": false}, {\"id\": 2, \"value\": 5, \"label\": \"Point B\", \"hasError\": false}, {\"id\": 3, \"value\": 15, \"label\": \"Point C\", \"hasError\": false}, {\"id\": 4, \"value\": 20, \"label\": \"Point D\", \"hasError\": false}]")
        
        let updatedResult = getFieldValue("advanced_example_error_detection")
        XCTAssertEqual(updatedResult, "false", "No error conditions should return false")
    }
    
    /// Test: Update electronics to have no cheap Electronics
    func testDynamicUpdateNoCheapElectronics() {
        // Initial: should be true (Headphones is $45)
        let initialResult = getFieldValue("advanced_example_combined")
        XCTAssertEqual(initialResult, "true")
        
        // Update all Electronics to be expensive
        updateFieldValue("electronics", "[{\"name\": \"Laptop\", \"category\": \"Electronics\", \"price\": 999}, {\"name\": \"Phone\", \"category\": \"Electronics\", \"price\": 699}, {\"name\": \"Headphones\", \"category\": \"Electronics\", \"price\": 150}, {\"name\": \"Mouse\", \"category\": \"Accessories\", \"price\": 25}]")
        
        let updatedResult = getFieldValue("advanced_example_combined")
        XCTAssertEqual(updatedResult, "false", "No Electronics < $50 should return false")
    }
}
