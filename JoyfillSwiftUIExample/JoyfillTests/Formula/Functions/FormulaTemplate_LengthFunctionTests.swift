//
//  FormulaTemplate_LengthFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the length() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_LengthFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_LengthFunction")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    }
    
    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    private func getFieldValue(_ fieldId: String) -> String {
        return documentEditor.value(ofFieldWithIdentifier: fieldId)?.text ?? ""
    }
    
    private func updateStringValue(_ fieldId: String, _ value: String) {
        documentEditor.updateValue(for: fieldId, value: .string(value))
    }
    
    // MARK: - Static Tests
    
    func testLengthOfString() {
        // length("Joyfill") → 7
        let result = getFieldValue("basic_example_string")
        XCTAssertEqual(result, "7", "length('Joyfill') should return '7'")
    }
    
    func testLengthOfArray() {
        // length(['opt1', 'opt2']) → 2
        let result = getFieldValue("basic_example_array")
        XCTAssertEqual(result, "2", "length(['opt1', 'opt2']) should return '2'")
    }
    
    func testLengthOfField() {
        // length(userName) with "John Smith" → 10
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "10", "length('John Smith') should return '10'")
    }
    
    func testPhoneValidationInitial() {
        // phoneNumber = "123456789" (9 chars) < 10 → invalid
        let result = getFieldValue("advanced_example_validation")
        XCTAssertEqual(result, "Please enter a valid phone number", "9-digit phone should be invalid")
    }
    
    // MARK: - Dynamic Tests
    
    func testDynamicUpdatePhoneValid() {
        updateStringValue("phoneNumber", "1234567890")
        let result = getFieldValue("advanced_example_validation")
        XCTAssertEqual(result, "Valid", "10-digit phone should be valid")
    }
    
    func testDynamicUpdatePhoneInvalid() {
        updateStringValue("phoneNumber", "12345")
        let result = getFieldValue("advanced_example_validation")
        XCTAssertEqual(result, "Please enter a valid phone number", "5-digit phone should be invalid")
    }
    
    func testDynamicUpdateUserName() {
        updateStringValue("userName", "Jane")
        let result = getFieldValue("intermediate_example_field")
        XCTAssertEqual(result, "4", "length('Jane') should return '4'")
    }
}

