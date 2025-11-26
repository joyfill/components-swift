//
//  FormulaTemplate_MaxFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the max() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_MaxFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_MaxFunction")
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
    
    // MARK: - Static Tests: Basic max() Function
    
    /// Test: max(10, 14, 3) should return 14
    func testMaxOfNumbers() {
        let result = getFieldValue("basic_example")
        XCTAssertEqual(result, "14", "max(10, 14, 3) should return '14'")
    }
    
    /// Test: max([10, 14, 3]) should return 14
    func testMaxOfArray() {
        let result = getFieldValue("intermediate_example_array")
        XCTAssertEqual(result, "14", "max([10, 14, 3]) should return '14'")
    }
    
    /// Test: max(10, [14, 3]) should return 14
    func testMaxOfMixed() {
        let result = getFieldValue("intermediate_example_mixed")
        XCTAssertEqual(result, "14", "max(10, [14, 3]) should return '14'")
    }
    
    // MARK: - Static Tests: Initial Field Values
    
    /// Test: Verify initial field values
    func testInitialFieldValues() {
        XCTAssertEqual(getFieldNumber("price1"), 25.0, "Initial price1 should be 25")
        XCTAssertEqual(getFieldNumber("price2"), 30.0, "Initial price2 should be 30")
        XCTAssertEqual(getFieldNumber("price3"), 15.0, "Initial price3 should be 15")
        XCTAssertEqual(getFieldNumber("score"), 85.0, "Initial score should be 85")
        XCTAssertEqual(getFieldNumber("baseValue"), 50.0, "Initial baseValue should be 50")
    }
    
    /// Test: max(price1, price2, price3) with 25, 30, 15 → 30
    func testMaxOfFieldReferences() {
        let result = getFieldValue("intermediate_example_fields")
        XCTAssertEqual(result, "30", "max(25, 30, 15) should return '30'")
    }
    
    /// Test: Grade curve with max score (92)
    /// score=85 >= max(78,92,88,65,82) - 10 = 82 → "A"
    func testGradeCurve() {
        let result = getFieldValue("advanced_example_grade")
        XCTAssertEqual(result, "A", "Score 85 with max 92 should give 'A'")
    }
    
    /// Test: Dynamic range - max(concat([50], [25, 30, 15])) = max([50, 25, 30, 15]) = 50
    func testDynamicRange() {
        let result = getFieldValue("advanced_example_dynamic")
        XCTAssertEqual(result, "50", "max([50, 25, 30, 15]) should return '50'")
    }
    
    // MARK: - Dynamic Tests: Price Updates
    
    /// Test: Update price1 to be highest
    func testDynamicUpdatePrice1Highest() {
        updateNumberValue("price1", 100)
        let result = getFieldValue("intermediate_example_fields")
        XCTAssertEqual(result, "100", "max(100, 30, 15) should return '100'")
    }
    
    /// Test: Update price3 to be highest
    func testDynamicUpdatePrice3Highest() {
        updateNumberValue("price3", 50)
        let result = getFieldValue("intermediate_example_fields")
        XCTAssertEqual(result, "50", "max(25, 30, 50) should return '50'")
    }
    
    /// Test: All prices equal
    func testDynamicUpdateAllPricesEqual() {
        updateNumberValue("price1", 20)
        updateNumberValue("price2", 20)
        updateNumberValue("price3", 20)
        let result = getFieldValue("intermediate_example_fields")
        XCTAssertEqual(result, "20", "max(20, 20, 20) should return '20'")
    }
    
    // MARK: - Dynamic Tests: Score Updates for Grade Curve
    
    /// Test: Score below B threshold
    func testDynamicUpdateScoreB() {
        updateNumberValue("score", 75)
        let result = getFieldValue("advanced_example_grade")
        // max=92, B threshold = 92-20=72, score 75 >= 72 → "B"
        XCTAssertEqual(result, "B", "Score 75 should give 'B'")
    }
    
    /// Test: Score at C threshold
    func testDynamicUpdateScoreC() {
        updateNumberValue("score", 65)
        let result = getFieldValue("advanced_example_grade")
        // max=92, C threshold = 92-30=62, score 65 >= 62 → "C"
        XCTAssertEqual(result, "C", "Score 65 should give 'C'")
    }
    
    /// Test: Score at D threshold
    func testDynamicUpdateScoreD() {
        updateNumberValue("score", 55)
        let result = getFieldValue("advanced_example_grade")
        // max=92, D threshold = 92-40=52, score 55 >= 52 → "D"
        XCTAssertEqual(result, "D", "Score 55 should give 'D'")
    }
    
    /// Test: Score below D threshold
    func testDynamicUpdateScoreF() {
        updateNumberValue("score", 50)
        let result = getFieldValue("advanced_example_grade")
        // max=92, D threshold = 92-40=52, score 50 < 52 → "F"
        XCTAssertEqual(result, "F", "Score 50 should give 'F'")
    }
    
    /// Test: Update max score affects curve
    func testDynamicUpdateMaxScore() {
        updateNumberValue("score2", 100)  // New max
        updateNumberValue("score", 85)
        let result = getFieldValue("advanced_example_grade")
        // max=100, A threshold = 100-10=90, score 85 < 90 → "B"
        XCTAssertEqual(result, "B", "Score 85 with max 100 should give 'B'")
    }
    
    // MARK: - Dynamic Tests: Base Value
    
    /// Test: Update baseValue to be highest
    func testDynamicUpdateBaseValueHighest() {
        updateNumberValue("baseValue", 100)
        let result = getFieldValue("advanced_example_dynamic")
        XCTAssertEqual(result, "100", "max with baseValue=100 should return '100'")
    }
    
    /// Test: Update baseValue to be lowest
    func testDynamicUpdateBaseValueLowest() {
        updateNumberValue("baseValue", 10)
        let result = getFieldValue("advanced_example_dynamic")
        XCTAssertEqual(result, "30", "max([10, 25, 30, 15]) should return '30'")
    }
    
    // MARK: - Sequence Test
    
    /// Test: Complex sequence of changes
    func testDynamicUpdateSequence() {
        // Initial max prices is 30
        XCTAssertEqual(getFieldValue("intermediate_example_fields"), "30", "Step 1")
        
        // Make price1 highest
        updateNumberValue("price1", 50)
        XCTAssertEqual(getFieldValue("intermediate_example_fields"), "50", "Step 2")
        
        // Make price3 highest
        updateNumberValue("price3", 75)
        XCTAssertEqual(getFieldValue("intermediate_example_fields"), "75", "Step 3")
        
        // Equalize all
        updateNumberValue("price1", 40)
        updateNumberValue("price2", 40)
        updateNumberValue("price3", 40)
        XCTAssertEqual(getFieldValue("intermediate_example_fields"), "40", "Step 4")
    }
    
    // MARK: - Edge Cases
    
    /// Test: Zero values
    func testDynamicUpdateZeroValues() {
        updateNumberValue("price1", 0)
        updateNumberValue("price2", 0)
        updateNumberValue("price3", 0)
        let result = getFieldValue("intermediate_example_fields")
        XCTAssertEqual(result, "0", "max(0, 0, 0) should return '0'")
    }
    
    /// Test: Negative values
    func testDynamicUpdateNegativeValues() {
        updateNumberValue("price1", -10)
        updateNumberValue("price2", -5)
        updateNumberValue("price3", -20)
        let result = getFieldValue("intermediate_example_fields")
        XCTAssertEqual(result, "-5", "max(-10, -5, -20) should return '-5'")
    }
    
    /// Test: Mix of positive and negative
    func testDynamicUpdateMixedValues() {
        updateNumberValue("price1", -10)
        updateNumberValue("price2", 5)
        updateNumberValue("price3", -20)
        let result = getFieldValue("intermediate_example_fields")
        XCTAssertEqual(result, "5", "max(-10, 5, -20) should return '5'")
    }
}
