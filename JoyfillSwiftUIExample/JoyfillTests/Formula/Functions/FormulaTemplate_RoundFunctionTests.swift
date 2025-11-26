//
//  FormulaTemplate_RoundFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the round() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_RoundFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_RoundFunction")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    }
    
    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    private func getFieldValue(_ fieldId: String) -> String {
        return documentEditor.value(ofFieldWithIdentifier: fieldId)?.text ?? ""
    }
    
    private func updateNumberValue(_ fieldId: String, _ value: Double) {
        documentEditor.updateValue(for: fieldId, value: .double(value))
    }
    
    // MARK: - Static Tests
    
    func testRoundDown() {
        // round(10.3) → 10
        let result = getFieldValue("basic_example_down")
        XCTAssertEqual(result, "10", "round(10.3) should return '10'")
    }
    
    func testRoundUp() {
        // round(10.7) → 11
        let result = getFieldValue("basic_example_up")
        XCTAssertEqual(result, "11", "round(10.7) should return '11'")
    }
    
    func testRoundZeroPlaces() {
        // round(10.7, 0) → 11
        let result = getFieldValue("intermediate_example_zero")
        XCTAssertEqual(result, "11", "round(10.7, 0) should return '11'")
    }
    
    func testRoundTwoDecimalPlaces() {
        // round(10.71123, 2) → 10.71
        let result = getFieldValue("intermediate_example_decimal")
        XCTAssertEqual(result, "10.71", "round(10.71123, 2) should return '10.71'")
    }
    
    // MARK: - Dynamic Tests
    
    func testDynamicUpdateQuantity() {
        updateNumberValue("quantity", 3)
        // Advanced formula recalculates
        let result = getFieldValue("advanced_example")
        XCTAssertTrue(!result.isEmpty, "Advanced example should recalculate")
    }
    
    func testDynamicUpdateShipping() {
        updateNumberValue("shipping", 10.99)
        let result = getFieldValue("advanced_example")
        XCTAssertTrue(!result.isEmpty, "Advanced example should recalculate with new shipping")
    }
}

