//
//  FormulaTemplate_SumFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the sum() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_SumFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_SumFunction")
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
    
    func testSumOfNumbers() {
        // sum(10, 20, 30) → 60
        let result = getFieldValue("basic_example_numbers")
        XCTAssertEqual(result, "60", "sum(10, 20, 30) should return '60'")
    }
    
    func testSumOfArray() {
        // sum([10, 20, 30]) → 60
        let result = getFieldValue("basic_example_array")
        XCTAssertEqual(result, "60", "sum([10, 20, 30]) should return '60'")
    }
    
    func testSumOfFields() {
        // sum(subtotal, tax) with subtotal=100, tax=8 → 108
        let result = getFieldValue("intermediate_example_fields")
        XCTAssertEqual(result, "108", "sum(subtotal, tax) should return '108'")
    }
    
    func testSumOfArrayAndField() {
        // sum([price1, price2, price3], shipping) with 25+30+15+10 = 80
        let result = getFieldValue("intermediate_example_array")
        XCTAssertEqual(result, "80", "sum([25, 30, 15], 10) should return '80'")
    }
    
    // MARK: - Dynamic Tests
    
    func testDynamicUpdateSubtotal() {
        updateNumberValue("subtotal", 200)
        let result = getFieldValue("intermediate_example_fields")
        XCTAssertEqual(result, "208", "sum(200, 8) should return '208'")
    }
    
    func testDynamicUpdateTax() {
        updateNumberValue("tax", 15)
        let result = getFieldValue("intermediate_example_fields")
        XCTAssertEqual(result, "115", "sum(100, 15) should return '115'")
    }
    
    func testDynamicUpdatePrices() {
        updateNumberValue("price1", 50)
        let result = getFieldValue("intermediate_example_array")
        XCTAssertEqual(result, "105", "sum([50, 30, 15], 10) should return '105'")
    }
}

