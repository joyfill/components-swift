//
//  modTests.swift
//  JoyfillTests
//
//  Unit tests for the mod() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class modTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "mod")
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
    
    // MARK: - Static Tests: Basic mod() Function
    
    /// Test: mod(19, 12) = 7
    func testModBasic() {
        let result = getFieldValue("basic_example")
        XCTAssertEqual(result, "7", "mod(19, 12) should return '7'")
    }
    
    /// Test: mod(-19, 12) - behavior depends on implementation
    func testModNegative() {
        let result = getFieldValue("basic_example_negative")
        // Could be -7 or 5 depending on implementation
        XCTAssertTrue(result == "-7" || result == "5", "mod(-19, 12) should return '-7' or '5'")
    }
    
    /// Test: mod(50, 12) = 2
    func testModFieldReferences() {
        let result = getFieldValue("intermediate_example")
        XCTAssertEqual(result, "2", "mod(50, 12) should return '2'")
    }
    
    /// Test: Day of week - mod(15 + 3 - 1, 7) + 1 = mod(17, 7) + 1 = 3 + 1 = 4
    func testDayOfWeek() {
        let result = getFieldValue("advanced_example_day")
        XCTAssertEqual(result, "4", "Day 15 starting on Wednesday should be '4'")
    }
    
    /// Test: Row 4 is even - "Even Row Style"
    func testRowStyleEven() {
        let result = getFieldValue("advanced_example_style")
        XCTAssertEqual(result, "Even Row Style", "Row 4 should have 'Even Row Style'")
    }
    
    // MARK: - Dynamic Tests: Total and Item Price
    
    /// Test: Update total amount
    func testDynamicUpdateTotalAmount() {
        updateNumberValue("totalAmount", 100)
        let result = getFieldValue("intermediate_example")
        // mod(100, 12) = 4
        XCTAssertEqual(result, "4", "mod(100, 12) should return '4'")
    }
    
    /// Test: Update item price
    func testDynamicUpdateItemPrice() {
        updateNumberValue("itemPrice", 10)
        let result = getFieldValue("intermediate_example")
        // mod(50, 10) = 0
        XCTAssertEqual(result, "0", "mod(50, 10) should return '0'")
    }
    
    // MARK: - Dynamic Tests: Day of Week
    
    /// Test: Update day number
    func testDynamicUpdateDayNumber() {
        updateNumberValue("dayNumber", 7)
        let result = getFieldValue("advanced_example_day")
        // mod(7 + 3 - 1, 7) + 1 = mod(9, 7) + 1 = 2 + 1 = 3
        XCTAssertEqual(result, "3", "Day 7 starting on Wednesday should be '3'")
    }
    
    /// Test: Update starting day
    func testDynamicUpdateStartingDay() {
        updateNumberValue("startingDay", 1)
        let result = getFieldValue("advanced_example_day")
        // mod(15 + 1 - 1, 7) + 1 = mod(15, 7) + 1 = 1 + 1 = 2
        XCTAssertEqual(result, "2", "Day 15 starting on Monday should be '2'")
    }
    
    // MARK: - Dynamic Tests: Row Styling
    
    /// Test: Odd row
    func testDynamicUpdateOddRow() {
        updateNumberValue("rowNumber", 3)
        let result = getFieldValue("advanced_example_style")
        XCTAssertEqual(result, "Odd Row Style", "Row 3 should have 'Odd Row Style'")
    }
    
    /// Test: Row 1 is odd
    func testDynamicUpdateRow1() {
        updateNumberValue("rowNumber", 1)
        let result = getFieldValue("advanced_example_style")
        XCTAssertEqual(result, "Odd Row Style", "Row 1 should have 'Odd Row Style'")
    }
    
    /// Test: Row 0 is even
    func testDynamicUpdateRow0() {
        updateNumberValue("rowNumber", 0)
        let result = getFieldValue("advanced_example_style")
        XCTAssertEqual(result, "Even Row Style", "Row 0 should have 'Even Row Style'")
    }
    
    // MARK: - Sequence Test
    
    /// Test: Sequence of row updates
    func testDynamicUpdateSequence() {
        updateNumberValue("rowNumber", 1)
        XCTAssertEqual(getFieldValue("advanced_example_style"), "Odd Row Style", "Row 1")
        
        updateNumberValue("rowNumber", 2)
        XCTAssertEqual(getFieldValue("advanced_example_style"), "Even Row Style", "Row 2")
        
        updateNumberValue("rowNumber", 3)
        XCTAssertEqual(getFieldValue("advanced_example_style"), "Odd Row Style", "Row 3")
        
        updateNumberValue("rowNumber", 4)
        XCTAssertEqual(getFieldValue("advanced_example_style"), "Even Row Style", "Row 4")
    }
    
    // MARK: - Edge Cases
    
    /// Test: Exact multiple
    func testDynamicExactMultiple() {
        updateNumberValue("totalAmount", 24)
        let result = getFieldValue("intermediate_example")
        // mod(24, 12) = 0
        XCTAssertEqual(result, "0", "mod(24, 12) should return '0'")
    }
    
    /// Test: Zero dividend
    func testDynamicZeroDividend() {
        updateNumberValue("totalAmount", 0)
        let result = getFieldValue("intermediate_example")
        // mod(0, 12) = 0
        XCTAssertEqual(result, "0", "mod(0, 12) should return '0'")
    }
}
