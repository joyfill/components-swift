//
//  floorTests.swift
//  JoyfillTests
//
//  Unit tests for the floor() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class floorTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "floor")
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
    
    private func updateNumberValue(_ fieldId: String, _ value: Double) {
        documentEditor.updateValue(for: fieldId, value: .double(value))
    }
    
    private func updateStringValue(_ fieldId: String, _ value: String) {
        documentEditor.updateValue(for: fieldId, value: .string(value))
    }

    // MARK: - Static Tests: Basic floor() Function
    
    /// Test: floor(4.9) should return 4
    func testFloorDecimal() {
        let result = getFieldValue("basic_example_decimal")
        XCTAssertEqual(result, "4", "floor(4.9) should return '4'")
    }
    
    /// Test: floor(4) should return 4
    func testFloorInteger() {
        let result = getFieldValue("basic_example_integer")
        XCTAssertEqual(result, "4", "floor(4) should return '4'")
    }
    
    /// Test: floor(-4.3) should return -5 (rounds away from zero)
    func testFloorNegative() {
        let result = getFieldValue("intermediate_example_negative")
        XCTAssertEqual(result, "-5", "floor(-4.3) should return '-5'")
    }
    
    /// Test: floor(50 / 12.99) = floor(3.85) = 3
    func testFloorItemsCalculation() {
        let result = getFieldValue("intermediate_example_items")
        XCTAssertEqual(result, "3", "floor(50 / 12.99) should return '3'")
    }
    
    /// Test: Advanced formula with the perishable branch.
    /// inventoryType == "perishable" -> floor(daysRemaining / 7) * weeklyDiscount
    /// = floor(17 / 7) * 5 = floor(2.43) * 5 = 2 * 5 = 10
    func testAdvancedFormulaResult() {
        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "10", "perishable branch: floor(17 / 7) * 5 should be 10")
    }
    
    // MARK: - Dynamic Tests: Total Amount / Item Price
    
    /// Test: Update total amount
    func testDynamicUpdateTotalAmount() {
        updateNumberValue("totalAmount", 100)
        let result = getFieldValue("intermediate_example_items")
        // floor(100 / 12.99) = floor(7.7) = 7
        XCTAssertEqual(result, "7", "floor(100 / 12.99) should return '7'")
    }
    
    /// Test: Update item price
    func testDynamicUpdateItemPrice() {
        updateNumberValue("itemPrice", 10)
        let result = getFieldValue("intermediate_example_items")
        // floor(50 / 10) = floor(5) = 5
        XCTAssertEqual(result, "5", "floor(50 / 10) should return '5'")
    }
    
    // MARK: - Dynamic Tests: Division Floor
    
    /// Test: Different total amounts with floor division
    func testDynamicUpdateLargerTotal() {
        updateNumberValue("totalAmount", 150)
        let result = getFieldValue("intermediate_example_items")
        // floor(150 / 12.99) = floor(11.55) = 11
        XCTAssertEqual(result, "11", "floor(150 / 12.99) should return '11'")
    }
    
    /// Test: Small total that results in 0
    func testDynamicUpdateSmallTotal() {
        updateNumberValue("totalAmount", 5)
        let result = getFieldValue("intermediate_example_items")
        // floor(5 / 12.99) = floor(0.38) = 0
        XCTAssertEqual(result, "0", "floor(5 / 12.99) should return '0'")
    }
    
    // MARK: - Edge Cases
    
    /// Test: Zero total
    func testDynamicUpdateZeroTotal() {
        updateNumberValue("totalAmount", 0)
        let result = getFieldValue("intermediate_example_items")
        XCTAssertEqual(result, "0", "floor(0 / 12.99) should return '0'")
    }
    
    /// Test: Exact division
    func testDynamicUpdateExactDivision() {
        updateNumberValue("totalAmount", 50)
        updateNumberValue("itemPrice", 10)
        let result = getFieldValue("intermediate_example_items")
        XCTAssertEqual(result, "5", "floor(50 / 10) should return '5'")
    }

    // MARK: - Dynamic Tests: Advanced Branching Formula

    /// Test: Switching inventoryType to the seasonal option takes the seasonal branch.
    /// floor(monthsRemaining) * monthlyDiscount = floor(2.7) * 10 = 2 * 10 = 20
    func testDynamicUpdateSeasonalBranch() {
        XCTAssertEqual(getFieldValue("advanced_example"), "10", "Baseline is the perishable branch")

        updateStringValue("inventoryType", "691acd93e21a5122c7a1a798") // seasonal

        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "20", "seasonal branch: floor(2.7) * 10 should be 20")
    }

    /// Test: Switching inventoryType to the "other" option falls through to 0.
    func testDynamicUpdateOtherBranch() {
        XCTAssertEqual(getFieldValue("advanced_example"), "10", "Baseline is the perishable branch")

        updateStringValue("inventoryType", "691acd93e21a5122c7a1a799") // other

        let result = getFieldValue("advanced_example")
        XCTAssertEqual(result, "0", "non-perishable, non-seasonal branch should be 0")
    }
}
