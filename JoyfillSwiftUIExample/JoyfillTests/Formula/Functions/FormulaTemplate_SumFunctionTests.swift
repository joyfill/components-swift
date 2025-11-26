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
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_SumFunction")
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
    
    private func getFieldNumber(_ fieldId: String) -> Double? {
        return documentEditor.value(ofFieldWithIdentifier: fieldId)?.number
    }
    
    private func updateNumberValue(_ fieldId: String, _ value: Double) {
        documentEditor.updateValue(for: fieldId, value: .double(value))
    }
    
    private func updateBoolValue(_ fieldId: String, _ value: Bool) {
        documentEditor.updateValue(for: fieldId, value: .bool(value))
    }
    
    // MARK: - Static Tests: Basic sum() Function
    
    /// Test: sum(10, 20, 30) should return 60
    func testSumOfNumbers() {
        let result = getFieldValue("basic_example_numbers")
        XCTAssertEqual(result, "60", "sum(10, 20, 30) should return '60'")
    }
    
    /// Test: sum([10, 20, 30]) should return 60
    func testSumOfArray() {
        let result = getFieldValue("basic_example_array")
        XCTAssertEqual(result, "60", "sum([10, 20, 30]) should return '60'")
    }
    
    // MARK: - Static Tests: Initial Field Values
    
    /// Test: Verify initial field values
    func testInitialFieldValues() {
        XCTAssertEqual(getFieldNumber("subtotal"), 100.0, "Initial subtotal should be 100")
        XCTAssertEqual(getFieldNumber("tax"), 8.0, "Initial tax should be 8")
        XCTAssertEqual(getFieldNumber("price1"), 25.0, "Initial price1 should be 25")
        XCTAssertEqual(getFieldNumber("price2"), 30.0, "Initial price2 should be 30")
        XCTAssertEqual(getFieldNumber("price3"), 15.0, "Initial price3 should be 15")
        XCTAssertEqual(getFieldNumber("shipping"), 10.0, "Initial shipping should be 10")
        XCTAssertEqual(getFieldNumber("shippingCost"), 15.0, "Initial shippingCost should be 15")
        XCTAssertEqual(getFieldNumber("insuranceCost"), 5.0, "Initial insuranceCost should be 5")
    }
    
    /// Test: sum(subtotal, tax) with 100 + 8 = 108
    func testSumOfFieldReferences() {
        let result = getFieldValue("intermediate_example_fields")
        XCTAssertEqual(result, "108", "sum(subtotal, tax) should return '108'")
    }
    
    /// Test: sum([price1, price2, price3], shipping) = 25 + 30 + 15 + 10 = 80
    func testSumOfArrayAndField() {
        let result = getFieldValue("intermediate_example_array")
        XCTAssertEqual(result, "80", "sum([25, 30, 15], 10) should return '80'")
    }
    
    /// Test: Advanced example with map and conditionals
    /// sum(map(lineItems, (item) -> item.quantity * item.price), if(includeShipping, shippingCost, 0), if(includeInsurance, insuranceCost, 0))
    /// lineItems: [2*25, 1*30, 3*15] = [50, 30, 45] = 125
    /// includeShipping=true → 15, includeInsurance=false → 0
    /// Total: 125 + 15 + 0 = 140
    func testAdvancedExampleInitialState() {
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "140", "Advanced example with shipping should return '140'")
    }
    
    // MARK: - Dynamic Tests: Subtotal and Tax
    
    /// Test: Update subtotal
    func testDynamicUpdateSubtotal() {
        updateNumberValue("subtotal", 200)
        let result = getFieldValue("intermediate_example_fields")
        XCTAssertEqual(result, "208", "sum(200, 8) should return '208'")
    }
    
    /// Test: Update tax
    func testDynamicUpdateTax() {
        updateNumberValue("tax", 15)
        let result = getFieldValue("intermediate_example_fields")
        XCTAssertEqual(result, "115", "sum(100, 15) should return '115'")
    }
    
    /// Test: Update both subtotal and tax
    func testDynamicUpdateSubtotalAndTax() {
        updateNumberValue("subtotal", 50)
        updateNumberValue("tax", 5)
        let result = getFieldValue("intermediate_example_fields")
        XCTAssertEqual(result, "55", "sum(50, 5) should return '55'")
    }
    
    // MARK: - Dynamic Tests: Prices Array
    
    /// Test: Update price1
    func testDynamicUpdatePrice1() {
        updateNumberValue("price1", 50)
        let result = getFieldValue("intermediate_example_array")
        // 50 + 30 + 15 + 10 = 105
        XCTAssertEqual(result, "105", "sum([50, 30, 15], 10) should return '105'")
    }
    
    /// Test: Update price2
    func testDynamicUpdatePrice2() {
        updateNumberValue("price2", 100)
        let result = getFieldValue("intermediate_example_array")
        // 25 + 100 + 15 + 10 = 150
        XCTAssertEqual(result, "150", "sum([25, 100, 15], 10) should return '150'")
    }
    
    /// Test: Update shipping
    func testDynamicUpdateShipping() {
        updateNumberValue("shipping", 0)
        let result = getFieldValue("intermediate_example_array")
        // 25 + 30 + 15 + 0 = 70
        XCTAssertEqual(result, "70", "sum([25, 30, 15], 0) should return '70'")
    }
    
    // MARK: - Dynamic Tests: Advanced Example with Checkboxes
    
    /// Test: Disable shipping
    func testDynamicUpdateDisableShipping() {
        updateBoolValue("includeShipping", false)
        let result = getFieldValue("advanced_example")
        // 125 + 0 + 0 = 125
        XCTAssertEqual(result, "125", "Without shipping, total should be '125'")
    }
    
    /// Test: Enable insurance
    func testDynamicUpdateEnableInsurance() {
        updateBoolValue("includeInsurance", true)
        let result = getFieldValue("advanced_example")
        // 125 + 15 + 5 = 145
        XCTAssertEqual(result, "145", "With shipping and insurance, total should be '145'")
    }
    
    /// Test: Disable shipping, enable insurance
    func testDynamicUpdateSwapOptions() {
        updateBoolValue("includeShipping", false)
        updateBoolValue("includeInsurance", true)
        let result = getFieldValue("advanced_example")
        // 125 + 0 + 5 = 130
        XCTAssertEqual(result, "130", "With only insurance, total should be '130'")
    }
    
    /// Test: Update shippingCost
    func testDynamicUpdateShippingCost() {
        updateNumberValue("shippingCost", 25)
        let result = getFieldValue("advanced_example")
        // 125 + 25 + 0 = 150
        XCTAssertEqual(result, "150", "With higher shipping cost, total should be '150'")
    }
    
    // MARK: - Sequence Test
    
    /// Test: Complex sequence of changes
    func testDynamicUpdateSequence() {
        // Initial: 140
        XCTAssertEqual(getFieldValue("advanced_example"), "140", "Step 1: Initial state")
        
        // Disable shipping: 125
        updateBoolValue("includeShipping", false)
        XCTAssertEqual(getFieldValue("advanced_example"), "125", "Step 2: Disabled shipping")
        
        // Enable insurance: 130
        updateBoolValue("includeInsurance", true)
        XCTAssertEqual(getFieldValue("advanced_example"), "130", "Step 3: Enabled insurance")
        
        // Enable shipping again: 145
        updateBoolValue("includeShipping", true)
        XCTAssertEqual(getFieldValue("advanced_example"), "145", "Step 4: Enabled shipping again")
        
        // Update insurance cost: 150
        updateNumberValue("insuranceCost", 10)
        XCTAssertEqual(getFieldValue("advanced_example"), "150", "Step 5: Increased insurance")
    }
    
    // MARK: - Edge Cases
    
    /// Test: Zero values
    func testDynamicUpdateZeroValues() {
        updateNumberValue("subtotal", 0)
        updateNumberValue("tax", 0)
        let result = getFieldValue("intermediate_example_fields")
        XCTAssertEqual(result, "0", "sum(0, 0) should return '0'")
    }
    
    /// Test: Negative values
    func testDynamicUpdateNegativeValues() {
        updateNumberValue("subtotal", 100)
        updateNumberValue("tax", -10)
        let result = getFieldValue("intermediate_example_fields")
        XCTAssertEqual(result, "90", "sum(100, -10) should return '90'")
    }
    
    /// Test: Decimal values
    func testDynamicUpdateDecimalValues() {
        updateNumberValue("price1", 25.50)
        updateNumberValue("price2", 30.25)
        updateNumberValue("price3", 15.25)
        updateNumberValue("shipping", 10.00)
        let result = getFieldValue("intermediate_example_array")
        XCTAssertEqual(result, "81", "sum with decimals should return '81'")
    }
}
