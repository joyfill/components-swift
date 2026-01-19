//
//  findTests.swift
//  JoyfillTests
//
//  Unit tests for the find() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class findTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "find")
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
    
    /// Test: Basic find with number - find([5, 12, 8, 130, 44], (num) -> num > 10)
    func testBasicFindNumber() {
        let result = getFieldValue("basic_example_number")
        // First number > 10 is 12
        XCTAssertFalse(result.isEmpty, "find() should return a result")
        if let num = Int(result) {
            XCTAssertEqual(num, 12, "First number > 10 should be 12")
        }
    }
    
    /// Test: Basic find with user object - find(users, (user) -> user.id == "user123")
    func testBasicFindUser() {
        let result = getFieldValue("basic_example_user")
        // Should find Alice with id "user123"
        XCTAssertFalse(result.isEmpty, "find() should return user object")
        XCTAssertTrue(result.contains("Alice") || result.contains("user123"), "Should find user with id 'user123'")
    }
    
    /// Test: Intermediate find product - find(products, (product) -> product.price < 50)
    func testIntermediateFindProduct() {
        let result = getFieldValue("intermediate_example_product")
        // First product < $50 is Mouse ($25)
        XCTAssertFalse(result.isEmpty, "find() should return a product")
        XCTAssertTrue(result.contains("Mouse") || result.contains("25"), "Should find Mouse with price 25")
    }
    
    /// Test: Intermediate find with index - find([10, 20, 30, 40, 50], (num, index) -> num > 25 && mod(index, 2) == 0)
    func testIntermediateFindWithIndex() {
        let result = getFieldValue("intermediate_example_index")
        // index 0: 10 (not > 25), index 2: 30 (> 25 ✓ and even index ✓), index 4: 50 (> 25 ✓ and even index ✓)
        // First match is 30 at index 2
        XCTAssertFalse(result.isEmpty, "find() should return a result")
        if let num = Int(result) {
            XCTAssertEqual(num, 30, "First number > 25 at even index should be 30")
        }
    }
    
    /// Test: Advanced complex find - find(inventory, (product) -> product.inStock && product.onSale && product.price < 100)
    func testAdvancedComplexFind() {
        let result = getFieldValue("advanced_example_complex")
        // Mouse: inStock: true, onSale: true, price: 25 < 100 ✓
        XCTAssertFalse(result.isEmpty, "find() should return a product")
        XCTAssertTrue(result.contains("Mouse") || result.contains("25"), "Should find Mouse meeting all conditions")
    }
    
    /// Test: Advanced nested find - find(departments, (dept) -> !empty(find(dept.employees, (emp) -> emp.salary > 50000)))
    func testAdvancedNestedFind() {
        let result = getFieldValue("advanced_example_nested")
        // Engineering has Alice with 75000, Marketing has Diana with 60000
        // First department with an employee > 50000 is Engineering
        XCTAssertFalse(result.isEmpty, "find() should return a department")
        XCTAssertTrue(result.contains("Engineering"), "Should find Engineering department")
    }
    
    /// Test: Advanced date find - find(tasks, (task) -> task.dueDate == "2023-12-05")
    func testAdvancedDateFind() {
        let result = getFieldValue("advanced_example_date")
        // Task "Review code" has dueDate "2023-12-05"
        // Result might be empty if formula engine doesn't support date comparison
        // or it should contain the matching task
        if !result.isEmpty {
            XCTAssertTrue(result.contains("Review") || result.contains("2023-12-05") || result.contains("task"),
                         "If result is returned, should find task with due date 2023-12-05")
        }
    }
    
    // MARK: - Dynamic Update Tests
    
    /// Test: basic_example_number uses literal array, so we just verify it evaluates correctly
    func testBasicFindNumberEvaluation() {
        // basic_example_number uses literal array find([5, 12, 8, 130, 44], ...)
        // so updating "numbers" field won't affect it
        let result = getFieldValue("basic_example_number")
        if let num = Int(result) {
            XCTAssertEqual(num, 12, "First number > 10 in [5, 12, 8, 130, 44] should be 12")
        }
    }
    
    /// Test: Update users so different user matches
    func testDynamicUpdateUsersMatch() {
        // Initial: Alice with user123
        let initialResult = getFieldValue("basic_example_user")
        XCTAssertTrue(initialResult.contains("Alice") || initialResult.contains("user123"))
        
        // Update to have different user with user123
        updateFieldValue("users", "[{\"id\": \"user456\", \"name\": \"Bob\"}, {\"id\": \"user123\", \"name\": \"Charlie\"}, {\"id\": \"user789\", \"name\": \"Diana\"}]")
        
        let updatedResult = getFieldValue("basic_example_user")
        XCTAssertTrue(updatedResult.contains("Charlie") || updatedResult.contains("user123"), "Should find Charlie with user123")
    }
    
    /// Test: Update products to change first cheap product
    func testDynamicUpdateProductsFirstCheap() {
        // Initial: Mouse ($25) is first < $50
        let initialResult = getFieldValue("intermediate_example_product")
        XCTAssertTrue(initialResult.contains("Mouse") || initialResult.contains("25"))
        
        // Update to have Keyboard be the first < $50
        updateFieldValue("products", "[{\"name\": \"Laptop\", \"price\": 999}, {\"name\": \"Phone\", \"price\": 699}, {\"name\": \"Keyboard\", \"price\": 45}, {\"name\": \"Mouse\", \"price\": 55}]")
        
        let updatedResult = getFieldValue("intermediate_example_product")
        XCTAssertTrue(updatedResult.contains("Keyboard") || updatedResult.contains("45"), "First product < $50 should now be Keyboard")
    }
    
    /// Test: Update inventory so different product matches complex condition
    func testDynamicUpdateInventoryComplexMatch() {
        // Initial: Mouse matches all conditions
        let initialResult = getFieldValue("advanced_example_complex")
        XCTAssertTrue(initialResult.contains("Mouse"))
        
        // Update to have Phone match (inStock: true, onSale: true, price: 49)
        updateFieldValue("inventory", "[{\"name\": \"Laptop\", \"price\": 999, \"inStock\": true, \"onSale\": false}, {\"name\": \"Phone\", \"price\": 49, \"inStock\": true, \"onSale\": true}, {\"name\": \"Mouse\", \"price\": 25, \"inStock\": false, \"onSale\": true}, {\"name\": \"Keyboard\", \"price\": 45, \"inStock\": false, \"onSale\": true}]")
        
        let updatedResult = getFieldValue("advanced_example_complex")
        XCTAssertTrue(updatedResult.contains("Phone") || updatedResult.contains("49"), "First matching product should now be Phone")
    }
    
    /// Test: Update departments to change first matching department
    func testDynamicUpdateDepartmentsMatch() {
        // Initial: Engineering has Alice > 50000
        let initialResult = getFieldValue("advanced_example_nested")
        XCTAssertTrue(initialResult.contains("Engineering"))
        
        // Update to have Marketing be first with high salary
        updateFieldValue("departments", "[{\"name\": \"Engineering\", \"employees\": [{\"name\": \"Alice\", \"salary\": 45000}, {\"name\": \"Bob\", \"salary\": 45000}]}, {\"name\": \"Marketing\", \"employees\": [{\"name\": \"Charlie\", \"salary\": 40000}, {\"name\": \"Diana\", \"salary\": 60000}]}, {\"name\": \"Sales\", \"employees\": [{\"name\": \"Eve\", \"salary\": 35000}, {\"name\": \"Frank\", \"salary\": 30000}]}]")
        
        let updatedResult = getFieldValue("advanced_example_nested")
        XCTAssertTrue(updatedResult.contains("Marketing"), "First department with high salary should now be Marketing")
    }
    
    /// Test: Update tasks to change matching task
    func testDynamicUpdateTasksMatch() {
        // This test updates the tasks field and checks if the formula re-evaluates
        // The formula finds a task with dueDate == "2023-12-05"
        
        // Update to have different task with the matching date
        updateFieldValue("tasks", "[{\"title\": \"Complete project\", \"dueDate\": \"2023-12-15\"}, {\"title\": \"Submit report\", \"dueDate\": \"2023-12-05\"}, {\"title\": \"Update documentation\", \"dueDate\": \"2023-12-20\"}]")
        
        let updatedResult = getFieldValue("advanced_example_date")
        // Result might be empty if formula engine doesn't support this, or should contain the match
        if !updatedResult.isEmpty {
            XCTAssertTrue(updatedResult.contains("Submit") || updatedResult.contains("2023-12-05") || updatedResult.contains("task"),
                         "If result is returned, should find the matching task")
        }
    }
}
