//
//  sumTests.swift
//  JoyfillTests
//
//  Unit tests for the sum() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class sumTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "sum")
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
    
    // MARK: - NEW DYNAMIC TESTS: Missing Field Updates
    
    /// Test: Update price3 (was missing!)
    func testDynamicUpdate_Price3() {
        updateNumberValue("price3", 50)
        let result = getFieldValue("intermediate_example_array")
        // 25 + 30 + 50 + 10 = 115
        XCTAssertEqual(result, "115", "sum([25, 30, 50], 10) should return '115', got '\(result)'")
    }
    
    /// Test: Update all prices at once
    func testDynamicUpdate_AllPrices() {
        updateNumberValue("price1", 10)
        updateNumberValue("price2", 20)
        updateNumberValue("price3", 30)
        let result = getFieldValue("intermediate_example_array")
        // 10 + 20 + 30 + 10 = 70
        XCTAssertEqual(result, "70", "sum([10, 20, 30], 10) should return '70', got '\(result)'")
    }
    
    /// Test: Update insurance cost
    func testDynamicUpdate_InsuranceCost() {
        updateBoolValue("includeInsurance", true)
        updateNumberValue("insuranceCost", 20)
        let result = getFieldValue("advanced_example")
        // 125 + 15 + 20 = 160
        XCTAssertEqual(result, "160", "With updated insurance cost, total should be '160', got '\(result)'")
    }
    
    /// Test: Both options disabled
    func testDynamicUpdate_BothOptionsDisabled() {
        updateBoolValue("includeShipping", false)
        updateBoolValue("includeInsurance", false)
        let result = getFieldValue("advanced_example")
        // Only lineItems: 125
        XCTAssertEqual(result, "125", "With no options, total should be '125', got '\(result)'")
    }
    
    // MARK: - NEW EDGE CASES: Empty & Single Values
    
    /// Test: Sum of single value
    func testEdgeCase_SingleValue() {
        // Set all prices to 0 except price1
        updateNumberValue("price1", 42)
        updateNumberValue("price2", 0)
        updateNumberValue("price3", 0)
        updateNumberValue("shipping", 0)
        let result = getFieldValue("intermediate_example_array")
        XCTAssertEqual(result, "42", "sum with single non-zero value should return '42', got '\(result)'")
    }
    
    /// Test: Sum with all zeros
    func testEdgeCase_AllZeros() {
        updateNumberValue("price1", 0)
        updateNumberValue("price2", 0)
        updateNumberValue("price3", 0)
        updateNumberValue("shipping", 0)
        let result = getFieldValue("intermediate_example_array")
        XCTAssertEqual(result, "0", "sum of all zeros should return '0', got '\(result)'")
    }
    
    // MARK: - NEW EDGE CASES: Negative Values
    
    /// Test: All negative values
    func testEdgeCase_AllNegativeValues() {
        updateNumberValue("subtotal", -50)
        updateNumberValue("tax", -10)
        let result = getFieldValue("intermediate_example_fields")
        XCTAssertEqual(result, "-60", "sum(-50, -10) should return '-60', got '\(result)'")
    }
    
    /// Test: Mixed positive and negative in array
    func testEdgeCase_MixedSignsInArray() {
        updateNumberValue("price1", 100)
        updateNumberValue("price2", -50)
        updateNumberValue("price3", -20)
        updateNumberValue("shipping", 10)
        let result = getFieldValue("intermediate_example_array")
        // 100 + (-50) + (-20) + 10 = 40
        XCTAssertEqual(result, "40", "sum([100, -50, -20], 10) should return '40', got '\(result)'")
    }
    
    // MARK: - NEW EDGE CASES: Large Numbers & Precision
    
    /// Test: Very large numbers
    func testEdgeCase_VeryLargeNumbers() {
        updateNumberValue("subtotal", 999999999)
        updateNumberValue("tax", 1)
        let result = getFieldValue("intermediate_example_fields")
        XCTAssertEqual(result, "1000000000", "sum of large numbers should return '1000000000', got '\(result)'")
    }
    
    /// Test: Floating point precision with small decimals
    func testEdgeCase_FloatingPointPrecision() {
        updateNumberValue("price1", 0.1)
        updateNumberValue("price2", 0.2)
        updateNumberValue("price3", 0.3)
        updateNumberValue("shipping", 0)
        let result = getFieldValue("intermediate_example_array")
        // 0.1 + 0.2 + 0.3 may have floating point issues
        XCTAssertTrue(result.hasPrefix("0.6"), "sum([0.1, 0.2, 0.3], 0) should start with '0.6', got '\(result)'")
    }
    
    // MARK: - NEW SEQUENCE TESTS
    
    /// Test: Sequence of price updates
    func testSequence_PriceUpdates() {
        var result: String
        
        // Step 1: Initial state (25 + 30 + 15 + 10 = 80)
        result = getFieldValue("intermediate_example_array")
        XCTAssertEqual(result, "80", "Step 1: Initial should be '80', got '\(result)'")
        
        // Step 2: Update price1 to 50 (50 + 30 + 15 + 10 = 105)
        updateNumberValue("price1", 50)
        result = getFieldValue("intermediate_example_array")
        XCTAssertEqual(result, "105", "Step 2: Should be '105', got '\(result)'")
        
        // Step 3: Set price1 to 0 (0 + 30 + 15 + 10 = 55)
        updateNumberValue("price1", 0)
        result = getFieldValue("intermediate_example_array")
        XCTAssertEqual(result, "55", "Step 3: Should be '55', got '\(result)'")
        
        // Step 4: Update price1 to 100 (100 + 30 + 15 + 10 = 155)
        updateNumberValue("price1", 100)
        result = getFieldValue("intermediate_example_array")
        XCTAssertEqual(result, "155", "Step 4: Should be '155', got '\(result)'")
        
        // Step 5: Update all prices (10 + 20 + 30 + 10 = 70)
        updateNumberValue("price1", 10)
        updateNumberValue("price2", 20)
        updateNumberValue("price3", 30)
        result = getFieldValue("intermediate_example_array")
        XCTAssertEqual(result, "70", "Step 5: Should be '70', got '\(result)'")
    }
    
    /// Test: Toggle options multiple times
    func testSequence_ToggleOptionsMultipleTimes() {
        var result: String
        
        // Initial: shipping=true, insurance=false (125 + 15 + 0 = 140)
        result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "140", "Step 1: Initial should be '140', got '\(result)'")
        
        // Toggle shipping OFF (125 + 0 + 0 = 125)
        updateBoolValue("includeShipping", false)
        result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "125", "Step 2: Should be '125', got '\(result)'")
        
        // Toggle insurance ON (125 + 0 + 5 = 130)
        updateBoolValue("includeInsurance", true)
        result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "130", "Step 3: Should be '130', got '\(result)'")
        
        // Toggle shipping ON (125 + 15 + 5 = 145)
        updateBoolValue("includeShipping", true)
        result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "145", "Step 4: Should be '145', got '\(result)'")
        
        // Toggle insurance OFF (125 + 15 + 0 = 140)
        updateBoolValue("includeInsurance", false)
        result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "140", "Step 5: Should be '140', got '\(result)'")
        
        // Toggle both OFF (125 + 0 + 0 = 125)
        updateBoolValue("includeShipping", false)
        result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "125", "Step 6: Should be '125', got '\(result)'")
        
        // Toggle both ON (125 + 15 + 5 = 145)
        updateBoolValue("includeShipping", true)
        updateBoolValue("includeInsurance", true)
        result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "145", "Step 7: Should be '145', got '\(result)'")
    }
    
    // MARK: - NEW ADVANCED TESTS: LineItems
    
    /// Test: Update lineItems JSON with different quantities
    func testAdvanced_UpdateLineItemsJSON() {
        // New lineItems: [{quantity: 1, price: 50}, {quantity: 2, price: 25}]
        // Expected: 1*50 + 2*25 = 50 + 50 = 100
        let newLineItems = "[{\"quantity\": 1, \"price\": 50}, {\"quantity\": 2, \"price\": 25}]"
        documentEditor.updateValue(for: "lineItems", value: .string(newLineItems))
        
        let result = getFieldValue("advanced_example")
        // 100 + 15 + 0 = 115
        XCTAssertEqual(result, "115", "With updated lineItems, total should be '115', got '\(result)'")
    }
    
    /// Test: Zero quantity in all line items
    func testAdvanced_ZeroQuantityInLineItems() {
        // All quantities set to 0
        let newLineItems = "[{\"quantity\": 0, \"price\": 25}, {\"quantity\": 0, \"price\": 30}, {\"quantity\": 0, \"price\": 15}]"
        documentEditor.updateValue(for: "lineItems", value: .string(newLineItems))
        
        let result = getFieldValue("advanced_example")
        // 0 + 15 + 0 = 15 (only shipping)
        XCTAssertEqual(result, "15", "With zero quantities, total should be '15' (shipping only), got '\(result)'")
    }
}
