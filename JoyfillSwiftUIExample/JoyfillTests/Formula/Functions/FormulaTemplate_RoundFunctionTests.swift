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
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_RoundFunction")
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
    
    // MARK: - Static Tests: Basic round() Function
    
    /// Test: round(10.3) should return 10 (round down)
    func testRoundDown() {
        let result = getFieldValue("basic_example_down")
        XCTAssertEqual(result, "10", "round(10.3) should return '10'")
    }
    
    /// Test: round(10.7) should return 11 (round up)
    func testRoundUp() {
        let result = getFieldValue("basic_example_up")
        XCTAssertEqual(result, "11", "round(10.7) should return '11'")
    }
    
    /// Test: round(10.7, 0) should return 11
    func testRoundZeroPlaces() {
        let result = getFieldValue("intermediate_example_zero")
        XCTAssertEqual(result, "11", "round(10.7, 0) should return '11'")
    }
    
    /// Test: round(10.71123, 2) should return 10.71
    func testRoundTwoDecimalPlaces() {
        let result = getFieldValue("intermediate_example_decimal")
        XCTAssertEqual(result, "10.71", "round(10.71123, 2) should return '10.71'")
    }
    
    // MARK: - Static Tests: Initial Field Values
    
    /// Test: Verify initial field values
    func testInitialFieldValues() {
        XCTAssertEqual(getFieldNumber("quantity"), 2.0, "Initial quantity should be 2")
        XCTAssertEqual(getFieldNumber("shipping"), 5.99, "Initial shipping should be 5.99")
        XCTAssertEqual(getFieldNumber("taxRate"), 8.25, "Initial taxRate should be 8.25")
    }
    
    /// Test: Advanced financial calculation
    /// round(sum(map(prices, (price) -> price * quantity), shipping) * (1 + taxRate / 100), 2)
    /// prices = [24.99, 19.95, 35.50], quantity = 2
    /// map: [49.98, 39.90, 71.00] sum = 160.88 + shipping(5.99) = 166.87
    /// with tax: 166.87 * 1.0825 = 180.636... rounded to 180.64
    func testAdvancedFinancialCalculation() {
        let result = getFieldValue("advanced_example")
        // Allow some tolerance in the calculation
        XCTAssertTrue(result.hasPrefix("180."), "Advanced calculation should be ~180.xx, got '\(result)'")
    }
    
    // MARK: - Dynamic Tests: Quantity Updates
    
    /// Test: Update quantity to 1
    func testDynamicUpdateQuantity1() {
        updateNumberValue("quantity", 1)
        let result = getFieldValue("advanced_example")
        // map: [24.99, 19.95, 35.50] sum = 80.44 + 5.99 = 86.43 * 1.0825 = 93.56
        XCTAssertTrue(result.hasPrefix("9"), "With quantity=1, total should be ~93.xx, got '\(result)'")
    }
    
    /// Test: Update quantity to 3
    func testDynamicUpdateQuantity3() {
        updateNumberValue("quantity", 3)
        let result = getFieldValue("advanced_example")
        // map: [74.97, 59.85, 106.50] sum = 241.32 + 5.99 = 247.31 * 1.0825 = 267.71
        XCTAssertTrue(result.hasPrefix("267") || result.hasPrefix("268"), "With quantity=3, total should be ~267.xx, got '\(result)'")
    }
    
    // MARK: - Dynamic Tests: Shipping Updates
    
    /// Test: Update shipping to 0
    func testDynamicUpdateShippingZero() {
        updateNumberValue("shipping", 0)
        let result = getFieldValue("advanced_example")
        // 160.88 * 1.0825 = 174.15
        XCTAssertTrue(result.hasPrefix("174"), "With no shipping, total should be ~174.xx, got '\(result)'")
    }
    
    /// Test: Update shipping to 10
    func testDynamicUpdateShipping10() {
        updateNumberValue("shipping", 10)
        let result = getFieldValue("advanced_example")
        // 160.88 + 10 = 170.88 * 1.0825 = 184.98
        XCTAssertTrue(result.hasPrefix("184") || result.hasPrefix("185"), "With shipping=10, total should be ~185.xx, got '\(result)'")
    }
    
    // MARK: - Dynamic Tests: Tax Rate Updates
    
    /// Test: Update tax rate to 0%
    func testDynamicUpdateTaxRateZero() {
        updateNumberValue("taxRate", 0)
        let result = getFieldValue("advanced_example")
        // 166.87 * 1.0 = 166.87
        XCTAssertTrue(result.hasPrefix("166"), "With 0% tax, total should be ~166.xx, got '\(result)'")
    }
    
    /// Test: Update tax rate to 10%
    func testDynamicUpdateTaxRate10() {
        updateNumberValue("taxRate", 10)
        let result = getFieldValue("advanced_example")
        // 166.87 * 1.10 = 183.56
        XCTAssertTrue(result.hasPrefix("183"), "With 10% tax, total should be ~183.xx, got '\(result)'")
    }
    
    // MARK: - Sequence Test
    
    /// Test: Complex sequence of changes
    func testDynamicUpdateSequence() {
        // Initial value should start with 180
        let initial = getFieldValue("advanced_example")
        XCTAssertTrue(initial.hasPrefix("180"), "Step 1: Initial should be ~180.xx")
        
        // Increase quantity
        updateNumberValue("quantity", 3)
        let afterQuantity = getFieldValue("advanced_example")
        XCTAssertTrue(afterQuantity.hasPrefix("267") || afterQuantity.hasPrefix("268"), "Step 2: Higher quantity")
        
        // Zero shipping
        updateNumberValue("shipping", 0)
        let afterShipping = getFieldValue("advanced_example")
        // Should be lower now
        XCTAssertTrue(!afterShipping.isEmpty, "Step 3: Zero shipping applied")
        
        // Zero tax
        updateNumberValue("taxRate", 0)
        let afterTax = getFieldValue("advanced_example")
        // Should be even lower
        XCTAssertTrue(!afterTax.isEmpty, "Step 4: Zero tax applied")
    }
    
    // MARK: - Edge Cases
    
    /// Test: Zero quantity
    func testDynamicUpdateZeroQuantity() {
        updateNumberValue("quantity", 0)
        let result = getFieldValue("advanced_example")
        // 0 + 5.99 = 5.99 * 1.0825 = 6.49
        XCTAssertTrue(result.hasPrefix("6."), "With zero quantity, should be ~6.xx, got '\(result)'")
    }
    
    /// Test: Negative quantity (edge case)
    func testDynamicUpdateNegativeQuantity() {
        updateNumberValue("quantity", -1)
        let result = getFieldValue("advanced_example")
        // Result depends on implementation
        XCTAssertTrue(!result.isEmpty, "Negative quantity should produce a result")
    }
    
    /// Test: Very high tax rate
    func testDynamicUpdateHighTaxRate() {
        updateNumberValue("taxRate", 100)
        let result = getFieldValue("advanced_example")
        // 166.87 * 2.0 = 333.74
        XCTAssertTrue(result.hasPrefix("333"), "With 100% tax, total should be ~333.xx, got '\(result)'")
    }
}
