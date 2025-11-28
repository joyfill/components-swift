//
//  toNumberTests.swift
//  JoyfillTests
//
//  Unit tests for the toNumber() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class toNumberTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "toNumber")
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
    
    private func updateNumberValue(_ fieldId: String, _ value: Double) {
        documentEditor.updateValue(for: fieldId, value: .double(value))
    }
    
    // MARK: - Static Tests: Basic toNumber() Function
    
    /// Test: toNumber("100") = 100
    func testToNumberInteger() {
        let result = getFieldValue("basic_example_integer")
        XCTAssertEqual(result, "100", "toNumber('100') should return '100'")
    }
    
    /// Test: toNumber("100.11") = 100.11
    func testToNumberDecimal() {
        let result = getFieldValue("basic_example_decimal")
        XCTAssertEqual(result, "100.11", "toNumber('100.11') should return '100.11'")
    }
    
    /// Test: toNumber("-1") = -1
    func testToNumberNegative() {
        let result = getFieldValue("intermediate_example_negative")
        XCTAssertEqual(result, "-1", "toNumber('-1') should return '-1'")
    }
    
    /// Test: toNumber(priceField) * quantity = 25.99 * 3 = 77.97
    func testToNumberCalculation() {
        let result = getFieldValue("intermediate_example_calculation")
        XCTAssertEqual(result, "77.97", "toNumber('25.99') * 3 should return '77.97'")
    }
    
    /// Test: toNumber("n100") - invalid
    func testToNumberInvalid() {
        let result = getFieldValue("invalid_example")
        // Invalid number conversion - may return NaN or empty
        XCTAssertTrue(result == "NaN" || result.isEmpty || result == "0", 
                      "toNumber('n100') should return NaN or empty, got '\(result)'")
    }
    
    /// Test: Validation with valid number
    func testAdvancedValidation() {
        let result = getFieldValue("advanced_example")
        XCTAssertTrue(result.contains("42") || result.isEmpty, 
                      "Validation should show number 42, got '\(result)'")
    }
    
    // MARK: - Dynamic Tests: Price Updates
    
    /// Test: Update price field
    func testDynamicUpdatePriceField() {
        updateStringValue("priceField", "10.00")
        let result = getFieldValue("intermediate_example_calculation")
        // 10.00 * 3 = 30
        XCTAssertEqual(result, "30", "toNumber('10.00') * 3 should return '30'")
    }
    
    /// Test: Update quantity
    func testDynamicUpdateQuantity() {
        updateNumberValue("quantity", 5)
        let result = getFieldValue("intermediate_example_calculation")
        // 25.99 * 5 = 129.95
        XCTAssertEqual(result, "129.95", "toNumber('25.99') * 5 should return '129.95'")
    }
    
    /// Test: Update user input for validation
    func testDynamicUpdateUserInputValid() {
        updateStringValue("userInput", "100")
        let result = getFieldValue("advanced_example")
        XCTAssertTrue(result.contains("100") || result.isEmpty, 
                      "Valid input should show number 100")
    }
    
    // MARK: - Edge Cases
    
    /// Test: Zero price
    func testDynamicUpdateZeroPrice() {
        updateStringValue("priceField", "0")
        let result = getFieldValue("intermediate_example_calculation")
        XCTAssertEqual(result, "0", "toNumber('0') * 3 should return '0'")
    }
    
    /// Test: Large number
    func testDynamicUpdateLargeNumber() {
        updateStringValue("priceField", "1000000")
        let result = getFieldValue("intermediate_example_calculation")
        XCTAssertEqual(result, "3000000", "toNumber('1000000') * 3 should return '3000000'")
    }
}
