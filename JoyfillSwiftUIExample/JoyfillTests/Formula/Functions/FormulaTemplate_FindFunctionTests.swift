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
    // Note: find() returns the FIRST matching element. Scalars render plainly ("12"); object
    // matches render as "{key: value, ...}" with non-deterministic key order, so object results
    // are asserted on stable kept/dropped tokens rather than an exact string.

    /// Test: Document loads successfully
    func testDocumentLoads() {
        XCTAssertNotNil(documentEditor, "DocumentEditor should load successfully")
    }
    
    /// Test: find([5, 12, 8, 130, 44], num > 10) returns the first match, 12.
    func testBasicFindNumber() {
        let result = getFieldValue("basic_example_number")
        XCTAssertEqual(result, "12", "First number > 10 should be exactly 12")
    }

    /// Test: find(users, user.id == "user123") returns Alice's record.
    func testBasicFindUser() {
        let result = getFieldValue("basic_example_user")
        XCTAssertTrue(result.contains("Alice") && result.contains("user123"), "Should find Alice/user123, got '\(result)'")
        XCTAssertFalse(result.contains("Bob"), "Should not return Bob, got '\(result)'")
        XCTAssertFalse(result.contains("Charlie"), "Should not return Charlie, got '\(result)'")
    }

    /// Test: find(products, price < 50) returns the first match, Mouse(25).
    func testIntermediateFindProduct() {
        let result = getFieldValue("intermediate_example_product")
        XCTAssertTrue(result.contains("Mouse") && result.contains("25"), "Should find Mouse(25), got '\(result)'")
        XCTAssertFalse(result.contains("Keyboard"), "Keyboard(45) comes later, should not be the first match, got '\(result)'")
    }

    /// Test: find([10,20,30,40,50], num > 25 && even index) returns 30 (index 2).
    func testIntermediateFindWithIndex() {
        let result = getFieldValue("intermediate_example_index")
        XCTAssertEqual(result, "30", "First number > 25 at an even index should be exactly 30")
    }
    
    /// Test: find(inventory, inStock && onSale && price < 100) returns Mouse(25).
    func testAdvancedComplexFind() {
        let result = getFieldValue("advanced_example_complex")
        XCTAssertTrue(result.contains("Mouse") && result.contains("25"), "Should find Mouse meeting all conditions, got '\(result)'")
        XCTAssertFalse(result.contains("Laptop"), "Laptop(onSale=false) should not match, got '\(result)'")
    }
    
    /// Test: find(departments, any employee salary > 50000) returns the first match, Engineering.
    func testAdvancedNestedFind() {
        let result = getFieldValue("advanced_example_nested")
        XCTAssertTrue(result.contains("Engineering"), "Should find Engineering (Alice 75000), got '\(result)'")
        XCTAssertFalse(result.contains("Marketing"), "Engineering is first, Marketing should not be returned, got '\(result)'")
        XCTAssertFalse(result.contains("Sales"), "Sales has no employee > 50000, got '\(result)'")
    }
    
    /// Test: find(tasks, dueDate == "2023-12-05") returns the "Review code" task.
    func testAdvancedDateFind() {
        let result = getFieldValue("advanced_example_date")
        XCTAssertTrue(result.contains("Review code") && result.contains("2023-12-05"), "Should find the 2023-12-05 task, got '\(result)'")
        XCTAssertFalse(result.contains("Complete project"), "Should not return the 2023-12-15 task, got '\(result)'")
    }
    
    // MARK: - Dynamic Update Tests

    /// Test: Update users so a different record carries id "user123".
    func testDynamicUpdateUsersMatch() {
        XCTAssertTrue(getFieldValue("basic_example_user").contains("Alice"), "Baseline finds Alice")

        updateFieldValue("users", "[{\"id\": \"user456\", \"name\": \"Bob\"}, {\"id\": \"user123\", \"name\": \"Charlie\"}, {\"id\": \"user789\", \"name\": \"Diana\"}]")
        
        let updatedResult = getFieldValue("basic_example_user")
        XCTAssertTrue(updatedResult.contains("Charlie") && updatedResult.contains("user123"), "Should now find Charlie/user123, got '\(updatedResult)'")
        XCTAssertFalse(updatedResult.contains("Alice"), "Alice no longer present, got '\(updatedResult)'")
    }
    
    /// Test: Update products so Keyboard becomes the first match under $50.
    func testDynamicUpdateProductsFirstCheap() {
        XCTAssertTrue(getFieldValue("intermediate_example_product").contains("Mouse"), "Baseline finds Mouse")

        updateFieldValue("products", "[{\"name\": \"Laptop\", \"price\": 999}, {\"name\": \"Phone\", \"price\": 699}, {\"name\": \"Keyboard\", \"price\": 45}, {\"name\": \"Mouse\", \"price\": 55}]")
        
        let updatedResult = getFieldValue("intermediate_example_product")
        XCTAssertTrue(updatedResult.contains("Keyboard") && updatedResult.contains("45"), "First < $50 should now be Keyboard(45), got '\(updatedResult)'")
        XCTAssertFalse(updatedResult.contains("Mouse"), "Mouse(55) no longer matches < 50, got '\(updatedResult)'")
    }
    
    /// Test: Update inventory so Phone is the first product meeting the complex condition.
    func testDynamicUpdateInventoryComplexMatch() {
        XCTAssertTrue(getFieldValue("advanced_example_complex").contains("Mouse"), "Baseline finds Mouse")

        updateFieldValue("inventory", "[{\"name\": \"Laptop\", \"price\": 999, \"inStock\": true, \"onSale\": false}, {\"name\": \"Phone\", \"price\": 49, \"inStock\": true, \"onSale\": true}, {\"name\": \"Mouse\", \"price\": 25, \"inStock\": false, \"onSale\": true}, {\"name\": \"Keyboard\", \"price\": 45, \"inStock\": false, \"onSale\": true}]")
        
        let updatedResult = getFieldValue("advanced_example_complex")
        XCTAssertTrue(updatedResult.contains("Phone") && updatedResult.contains("49"), "First match should now be Phone(49), got '\(updatedResult)'")
        XCTAssertFalse(updatedResult.contains("Mouse"), "Mouse is now out of stock, got '\(updatedResult)'")
    }
    
    /// Test: Update departments so Marketing becomes the first with a high earner.
    func testDynamicUpdateDepartmentsMatch() {
        XCTAssertTrue(getFieldValue("advanced_example_nested").contains("Engineering"), "Baseline finds Engineering")

        updateFieldValue("departments", "[{\"name\": \"Engineering\", \"employees\": [{\"name\": \"Alice\", \"salary\": 45000}, {\"name\": \"Bob\", \"salary\": 45000}]}, {\"name\": \"Marketing\", \"employees\": [{\"name\": \"Charlie\", \"salary\": 40000}, {\"name\": \"Diana\", \"salary\": 60000}]}, {\"name\": \"Sales\", \"employees\": [{\"name\": \"Eve\", \"salary\": 35000}, {\"name\": \"Frank\", \"salary\": 30000}]}]")
        
        let updatedResult = getFieldValue("advanced_example_nested")
        XCTAssertTrue(updatedResult.contains("Marketing"), "First dept with salary > 50000 should now be Marketing, got '\(updatedResult)'")
    }
    
    /// Test: Update tasks so a different task carries the matching due date.
    func testDynamicUpdateTasksMatch() {
        XCTAssertTrue(getFieldValue("advanced_example_date").contains("Review code"), "Baseline finds Review code")

        updateFieldValue("tasks", "[{\"title\": \"Complete project\", \"dueDate\": \"2023-12-15\"}, {\"title\": \"Submit report\", \"dueDate\": \"2023-12-05\"}, {\"title\": \"Update documentation\", \"dueDate\": \"2023-12-20\"}]")
        
        let updatedResult = getFieldValue("advanced_example_date")
        XCTAssertTrue(updatedResult.contains("Submit report") && updatedResult.contains("2023-12-05"), "Should now find Submit report, got '\(updatedResult)'")
        XCTAssertFalse(updatedResult.contains("Review code"), "Review code no longer present, got '\(updatedResult)'")
    }
}
