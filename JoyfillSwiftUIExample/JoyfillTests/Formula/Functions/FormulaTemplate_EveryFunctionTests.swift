//
//  FormulaTemplate_EveryFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the every() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_EveryFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_EveryFunction")
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
    
    /// Test: Basic every with all conditions true - every([6, 7, 8, 9], (num) -> num > 5)
    func testBasicEveryAllTrue() {
        let result = getFieldValue("basic_example_true")
        // All numbers [6, 7, 8, 9] are > 5, so should return true
        XCTAssertEqual(result, "true", "every([6, 7, 8, 9], (num) -> num > 5) should return true")
    }
    
    /// Test: Basic every with some conditions false - every([4, 6, 8, 10], (num) -> num > 5)
    func testBasicEverySomeFalse() {
        let result = getFieldValue("basic_example_false")
        // 4 is not > 5, so should return false
        XCTAssertEqual(result, "false", "every([4, 6, 8, 10], (num) -> num > 5) should return false because 4 <= 5")
    }
    
    /// Test: Intermediate every with object property - every(products, (product) -> product.inStock)
    /// products = [{inStock: true}, {inStock: true}, {inStock: false}, {inStock: true}]
    func testIntermediateEveryProductsInStock() {
        let result = getFieldValue("intermediate_example_products")
        // Mouse has inStock: false, so should return false
        XCTAssertEqual(result, "false", "Not all products are in stock, should return false")
    }
    
    /// Test: Intermediate every with index - every(numbers, (num, index) -> if(mod(index, 2) == 0, mod(num, 2) == 0, true))
    /// numbers = [2, 3, 4, 5, 6, 7] - checks if even-indexed items are even numbers
    func testIntermediateEveryWithIndex() {
        let result = getFieldValue("intermediate_example_indices")
        // index 0: 2 (even) ✓, index 2: 4 (even) ✓, index 4: 6 (even) ✓
        // Odd indices are always true
        XCTAssertEqual(result, "true", "All even-indexed items are even numbers")
    }
    
    /// Test: Advanced nested every - every(departments, (dept) -> every(dept.employees, (emp) -> emp.salary > 30000))
    func testAdvancedNestedEvery() {
        let result = getFieldValue("advanced_example_nested")
        // Sales dept has Frank with salary 28000 < 30000, so should return false
        XCTAssertEqual(result, "false", "Not all employees in all departments have salary > 30000")
    }
    
    /// Test: Advanced form validation - every with multiple validation conditions
    /// Form: {name: "John Doe", email: "john.doe@example.com", password: "securepass"}
    func testAdvancedFormValidation() {
        let result = getFieldValue("advanced_example_validation")
        // All conditions: !empty(name) ✓, !empty(email) ✓, contains(email, "@") ✓, length(password) >= 8 ✓
        XCTAssertEqual(result, "true", "All form validation conditions should pass")
    }
    
    /// Test: Advanced combined - every with filter
    /// every(filter(electronics, (p) -> p.category == "Electronics"), (p) -> p.warranty > 0)
    func testAdvancedEveryCombined() {
        let result = getFieldValue("advanced_example_combined")
        // Headphones has warranty: 0, so not all Electronics have warranty > 0
        XCTAssertEqual(result, "false", "Not all Electronics have warranty > 0")
    }
    
    // MARK: - Dynamic Update Tests
    
    /// Test: Update products to have all in stock
    func testDynamicUpdateAllProductsInStock() {
        // Initial: should be false (Mouse is out of stock)
        let initialResult = getFieldValue("intermediate_example_products")
        XCTAssertEqual(initialResult, "false")
        
        // Update all products to be in stock
        updateFieldValue("products", "[{\"name\": \"Laptop\", \"price\": 999, \"inStock\": true}, {\"name\": \"Phone\", \"price\": 699, \"inStock\": true}, {\"name\": \"Mouse\", \"price\": 25, \"inStock\": true}, {\"name\": \"Keyboard\", \"price\": 45, \"inStock\": true}]")
        
        let updatedResult = getFieldValue("intermediate_example_products")
        XCTAssertEqual(updatedResult, "true", "All products in stock should return true")
    }
    
    /// Test: Update numbers array to fail even-index check
    func testDynamicUpdateNumbersFailCheck() {
        // Initial: should be true
        let initialResult = getFieldValue("intermediate_example_indices")
        XCTAssertEqual(initialResult, "true")
        
        // Update to have odd number at even index
        updateFieldValue("numbers", "[3, 3, 4, 5, 6, 7]")
        
        let updatedResult = getFieldValue("intermediate_example_indices")
        XCTAssertEqual(updatedResult, "false", "Odd number at index 0 should return false")
    }
    
    /// Test: Update departments so all employees have high salary
    func testDynamicUpdateDepartmentsHighSalary() {
        // Initial: should be false (Frank has 28000)
        let initialResult = getFieldValue("advanced_example_nested")
        XCTAssertEqual(initialResult, "false")
        
        // Update all salaries to be > 30000
        updateFieldValue("departments", "[{\"name\": \"Engineering\", \"employees\": [{\"name\": \"Alice\", \"salary\": 75000}, {\"name\": \"Bob\", \"salary\": 45000}]}, {\"name\": \"Marketing\", \"employees\": [{\"name\": \"Charlie\", \"salary\": 40000}, {\"name\": \"Diana\", \"salary\": 60000}]}, {\"name\": \"Sales\", \"employees\": [{\"name\": \"Eve\", \"salary\": 35000}, {\"name\": \"Frank\", \"salary\": 35000}]}]")
        
        let updatedResult = getFieldValue("advanced_example_nested")
        XCTAssertEqual(updatedResult, "true", "All employees > 30000 should return true")
    }
    
    /// Test: Update form to fail validation
    func testDynamicUpdateFormValidationFail() {
        // Initial: should be true
        let initialResult = getFieldValue("advanced_example_validation")
        XCTAssertEqual(initialResult, "true")
        
        // Update form with short password (< 8 chars)
        updateFieldValue("form", "{\"name\": \"John\", \"email\": \"john@example.com\", \"password\": \"short\"}")
        
        let updatedResult = getFieldValue("advanced_example_validation")
        XCTAssertEqual(updatedResult, "false", "Password < 8 chars should fail validation")
    }
    
    /// Test: Update electronics to have all warranties > 0
    func testDynamicUpdateElectronicsWarranty() {
        // Initial: should be false (Headphones has warranty: 0)
        let initialResult = getFieldValue("advanced_example_combined")
        XCTAssertEqual(initialResult, "false")
        
        // Update all Electronics to have warranty > 0
        updateFieldValue("electronics", "[{\"name\": \"Laptop\", \"category\": \"Electronics\", \"warranty\": 12}, {\"name\": \"Phone\", \"category\": \"Electronics\", \"warranty\": 24}, {\"name\": \"Headphones\", \"category\": \"Electronics\", \"warranty\": 6}, {\"name\": \"Mouse\", \"category\": \"Accessories\", \"warranty\": 6}]")
        
        let updatedResult = getFieldValue("advanced_example_combined")
        XCTAssertEqual(updatedResult, "true", "All Electronics with warranty > 0 should return true")
    }
}
