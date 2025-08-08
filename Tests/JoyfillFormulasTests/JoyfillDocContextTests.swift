//import XCTest
//@testable import JoyfillFormulas
//@testable import JoyfillModel
//
//final class JoyfillDocContextTests: XCTestCase {
//    var testContext: JoyfillDocContext!
//    var testDoc: JoyDoc!
//    
//    override func setUp() {
//        super.setUp()
//        
//        // Create a test JoyDoc with various field types
//        testDoc = createTestJoyDoc()
//        testContext = JoyfillDocContext(joyDoc: testDoc)
//    }
//    
//    override func tearDown() {
//        testContext = nil
//        testDoc = nil
//        super.tearDown()
//    }
//    
//    // MARK: - Simple Reference Tests
//    
//    func testResolveSimpleTextFieldReference() {
//        // Test resolving {firstName}
//        let result = testContext.resolveReference("{firstName}")
//        
//        if case .success(let value) = result {
//            XCTAssertEqual(value, .string("John"))
//        } else {
//            XCTFail("Failed to resolve simple text field reference: \(result)")
//        }
//    }
//    
//    func testResolveSimpleNumberFieldReference() {
//        // Test resolving {age}
//        let result = testContext.resolveReference("{age}")
//        
//        if case .success(let value) = result {
//            XCTAssertEqual(value, .number(30))
//        } else {
//            XCTFail("Failed to resolve simple number field reference: \(result)")
//        }
//    }
//    
//    func testResolveBooleanFieldReference() {
//        // Test resolving {isActive}
//        let result = testContext.resolveReference("{isActive}")
//        
//        if case .success(let value) = result {
//            XCTAssertEqual(value, .boolean(true))
//        } else {
//            XCTFail("Failed to resolve boolean field reference: \(result)")
//        }
//    }
//    
//    func testResolveInvalidFieldReference() {
//        // Test resolving non-existent field
//        let result = testContext.resolveReference("{nonExistentField}")
//        
//        if case .failure(let error) = result {
//            if case .invalidReference = error {
//                // This is the expected failure
//                XCTAssert(true)
//            } else {
//                XCTFail("Expected invalidReference error, got: \(error)")
//            }
//        } else {
//            XCTFail("Expected failure, but got success: \(result)")
//        }
//    }
//    
//    func testInvalidReferenceFormat() {
//        // Test reference without braces
//        let result = testContext.resolveReference("firstName")
//        
//        if case .failure(let error) = result {
//            if case .invalidReference = error {
//                // This is the expected failure
//                XCTAssert(true)
//            } else {
//                XCTFail("Expected invalidReference error, got: \(error)")
//            }
//        } else {
//            XCTFail("Expected failure, but got success: \(result)")
//        }
//    }
//    
//    // MARK: - Collection Reference Tests
//    
//    func testResolveCollectionFieldReference() {
//        // Test resolving {employees} to get entire collection
//        let result = testContext.resolveReference("{employees}")
//        
//        if case .success(let value) = result, case .array(let array) = value {
//            XCTAssertEqual(array.count, 2, "Should return 2 employee records")
//            
//            // Verify first employee data
//            if case .dictionary(let firstEmployee) = array[0] {
//                XCTAssertEqual(firstEmployee["name"], .string("Alice"))
//                XCTAssertEqual(firstEmployee["position"], .string("Developer"))
//                XCTAssertEqual(firstEmployee["salary"], .number(75000))
//            } else {
//                XCTFail("First employee should be a dictionary")
//            }
//        } else {
//            XCTFail("Failed to resolve collection field reference: \(result)")
//        }
//    }
//    
//    func testResolveCollectionRowByIndex() {
//        // Test resolving {employees.1} to get second employee
//        let result = testContext.resolveReference("{employees.1}")
//        
//        if case .success(let value) = result, case .dictionary(let employee) = value {
//            XCTAssertEqual(employee["name"], .string("Bob"))
//            XCTAssertEqual(employee["position"], .string("Manager"))
//            XCTAssertEqual(employee["salary"], .number(90000))
//        } else {
//            XCTFail("Failed to resolve collection row by index: \(result)")
//        }
//    }
//    
//    func testResolveCollectionCellValue() {
//        // Test resolving {employees.0.salary} to get Alice's salary
//        let result = testContext.resolveReference("{employees.0.salary}")
//        
//        if case .success(let value) = result {
//            XCTAssertEqual(value, .number(75000))
//        } else {
//            XCTFail("Failed to resolve collection cell value: \(result)")
//        }
//    }
//    
//    func testResolveCollectionColumn() {
//        // Test resolving {employees.name} to get all names
//        let result = testContext.resolveReference("{employees.name}")
//        
//        if case .success(let value) = result, case .array(let names) = value {
//            XCTAssertEqual(names.count, 2)
//            XCTAssertEqual(names[0], .string("Alice"))
//            XCTAssertEqual(names[1], .string("Bob"))
//        } else {
//            XCTFail("Failed to resolve collection column: \(result)")
//        }
//    }
//    
//    // MARK: - Temporary Variable Tests
//    
//    func testTemporaryVariable() {
//        // Create a context with a temporary variable "current"
//        let contextWithTemp = testContext.contextByAdding(variable: "current", value: .number(42))
//        
//        // Test resolving {current}
//        let result = contextWithTemp.resolveReference("{current}")
//        
//        if case .success(let value) = result {
//            XCTAssertEqual(value, .number(42))
//        } else {
//            XCTFail("Failed to resolve temporary variable: \(result)")
//        }
//        
//        // Original context should not have this variable
//        let originalResult = testContext.resolveReference("{current}")
//        if case .failure = originalResult {
//            // Expected failure
//            XCTAssert(true)
//        } else {
//            XCTFail("Expected failure in original context, but got: \(originalResult)")
//        }
//    }
//    
//    // MARK: - Helper Methods
//    
//    private func createTestJoyDoc() -> JoyDoc {
//        var joyDoc = JoyDoc(dictionary: [:])
//        
//        // Add a text field
//        var firstNameField = JoyDocField(field: [:])
//        firstNameField.fieldType = .text
//        firstNameField.identifier = "firstName"
//        firstNameField.title = "First Name"
//        firstNameField.value = ValueUnion(value: "John")!
//        
//        // Add a number field
//        var ageField = JoyDocField(field: [:])
//        ageField.fieldType = .number
//        ageField.identifier = "age"
//        ageField.title = "Age"
//        ageField.value = ValueUnion(value: 30.0)!
//        
//        // Add a boolean field
//        var isActiveField = JoyDocField(field: [:])
//        isActiveField.fieldType = .text  // Use text since there's no boolean field type
//        isActiveField.identifier = "isActive"
//        isActiveField.title = "Is Active"
//        isActiveField.value = ValueUnion(value: true)!
//        
//        // Create a collection field
//        var employeesField = JoyDocField(field: [:])
//        employeesField.fieldType = .table
//        employeesField.identifier = "employees"
//        employeesField.title = "Employees"
//        
//        // Create rows for the collection
//        var employee1 = ValueElement()
//        
//        // Create cells with safe ValueUnion unwrapping
//        var employee1Cells = [String: ValueUnion]()
//        if let nameValue = ValueUnion(value: "Alice") {
//            employee1Cells["name"] = nameValue
//        }
//        if let positionValue = ValueUnion(value: "Developer") {
//            employee1Cells["position"] = positionValue
//        }
//        if let salaryValue = ValueUnion(value: 75000.0) {
//            employee1Cells["salary"] = salaryValue
//        }
//        employee1.cells = employee1Cells
//        
//        var employee2 = ValueElement()
//        var employee2Cells = [String: ValueUnion]()
//        if let nameValue = ValueUnion(value: "Bob") {
//            employee2Cells["name"] = nameValue
//        }
//        if let positionValue = ValueUnion(value: "Manager") {
//            employee2Cells["position"] = positionValue
//        }
//        if let salaryValue = ValueUnion(value: 90000.0) {
//            employee2Cells["salary"] = salaryValue
//        }
//        employee2.cells = employee2Cells
//        
//        employeesField.value = ValueUnion(value: [employee1, employee2])!
//        
//        // Add fields to the JoyDoc
//        joyDoc.fields = [firstNameField, ageField, isActiveField, employeesField]
//        
//        return joyDoc
//    }
//} 
