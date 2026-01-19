//
//  sqrtTests.swift
//  JoyfillTests
//
//  Unit tests for the sqrt() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class sqrtTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "sqrt")
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
    
    // MARK: - Static Tests: Basic sqrt() Function
    
    /// Test: sqrt(16) should return 4
    func testSqrt16() {
        let result = getFieldValue("basic_example_16")
        XCTAssertEqual(result, "4", "sqrt(16) should return '4'")
    }
    
    /// Test: sqrt(100) should return 10
    func testSqrt100() {
        let result = getFieldValue("basic_example_100")
        XCTAssertEqual(result, "10", "sqrt(100) should return '10'")
    }
    
    /// Test: sqrt(area) with area=25 should return 5
    func testSqrtFromField() {
        let result = getFieldValue("intermediate_example_area")
        XCTAssertEqual(result, "5", "sqrt(25) should return '5'")
    }
    
    /// Test: Pythagorean theorem sqrt(3² + 4²) = sqrt(25) = 5
    func testHypotenuse() {
        let result = getFieldValue("intermediate_example_hypotenuse")
        XCTAssertEqual(result, "5", "sqrt(3² + 4²) should return '5'")
    }
    
    /// Test: Error handling for negative number
    func testNegativeNumberError() {
        let result = getFieldValue("advanced_example_error_handling")
        XCTAssertEqual(result, "Cannot calculate square root of negative number", "Should show error for negative")
    }
    
    /// Test: Circle calculation - radius=10, area=314.16, circumference=62.83
    func testCircleCalculation() {
        let result = getFieldValue("advanced_example_circle")
        XCTAssertTrue(result.contains("314.16") || result.contains("314.15"), "Circle area should be ~314.16")
        XCTAssertTrue(result.contains("62.83") || result.contains("62.82"), "Circle circumference should be ~62.83")
    }
    
    // MARK: - Dynamic Tests: Area Updates
    
    /// Test: Update area
    func testDynamicUpdateArea() {
        updateNumberValue("area", 49)
        let result = getFieldValue("intermediate_example_area")
        XCTAssertEqual(result, "7", "sqrt(49) should return '7'")
    }
    
    /// Test: Non-perfect square
    func testDynamicUpdateNonPerfectSquare() {
        updateNumberValue("area", 2)
        let result = getFieldValue("intermediate_example_area")
        XCTAssertTrue(result.hasPrefix("1.41"), "sqrt(2) should be ~1.414")
    }
    
    // MARK: - Dynamic Tests: Pythagorean Theorem
    
    /// Test: 5-12-13 triangle
    func testDynamic5_12_13Triangle() {
        updateNumberValue("x", 5)
        updateNumberValue("y", 12)
        let result = getFieldValue("intermediate_example_hypotenuse")
        XCTAssertEqual(result, "13", "sqrt(5² + 12²) should return '13'")
    }
    
    /// Test: 8-15-17 triangle
    func testDynamic8_15_17Triangle() {
        updateNumberValue("x", 8)
        updateNumberValue("y", 15)
        let result = getFieldValue("intermediate_example_hypotenuse")
        XCTAssertEqual(result, "17", "sqrt(8² + 15²) should return '17'")
    }
    
    // MARK: - Dynamic Tests: Error Handling
    
    /// Test: Positive number shows calculation
    func testDynamicPositiveNumber() {
        updateNumberValue("number", 9)
        let result = getFieldValue("advanced_example_error_handling")
        // Formula: concat("The square root of ", number, " is ", sqrt(number))
        XCTAssertTrue(result.contains("9") && result.contains("3"), "Should show 'The square root of 9 is 3', got '\(result)'")
    }
    
    // MARK: - Dynamic Tests: Circle Radius
    
    /// Test: Update radius
    func testDynamicUpdateRadius() {
        updateNumberValue("radius", 5)
        let result = getFieldValue("advanced_example_circle")
        XCTAssertTrue(result.contains("78.54") || result.contains("78.53"), "Circle with r=5 should have area ~78.54")
    }
    
    // MARK: - Edge Cases
    
    /// Test: sqrt(0)
    func testDynamicUpdateSqrtZero() {
        updateNumberValue("area", 0)
        let result = getFieldValue("intermediate_example_area")
        XCTAssertEqual(result, "0", "sqrt(0) should return '0'")
    }
    
    /// Test: sqrt(1)
    func testDynamicUpdateSqrtOne() {
        updateNumberValue("area", 1)
        let result = getFieldValue("intermediate_example_area")
        XCTAssertEqual(result, "1", "sqrt(1) should return '1'")
    }
    
    // MARK: - NEW DYNAMIC TESTS: Missing Field Updates
    
    /// Test: Update x only (y stays constant)
    func testDynamicUpdate_XOnly() {
        // y stays 4, update x: 3 → 6
        updateNumberValue("x", 6)
        let result = getFieldValue("intermediate_example_hypotenuse")
        // sqrt(36 + 16) = sqrt(52) ≈ 7.211
        XCTAssertTrue(result.hasPrefix("7.2"), "sqrt(6² + 4²) should be ~7.21, got '\(result)'")
    }
    
    /// Test: Update y only (x stays constant)
    func testDynamicUpdate_YOnly() {
        // x stays 3, update y: 4 → 8
        updateNumberValue("y", 8)
        let result = getFieldValue("intermediate_example_hypotenuse")
        // sqrt(9 + 64) = sqrt(73) ≈ 8.544
        XCTAssertTrue(result.hasPrefix("8.5"), "sqrt(3² + 8²) should be ~8.54, got '\(result)'")
    }
    
    /// Test: Update both x and y
    func testDynamicUpdate_BothXY() {
        updateNumberValue("x", 6)
        updateNumberValue("y", 8)
        let result = getFieldValue("intermediate_example_hypotenuse")
        // sqrt(36 + 64) = sqrt(100) = 10
        XCTAssertEqual(result, "10", "sqrt(6² + 8²) should be '10', got '\(result)'")
    }
    
    /// Test: Change number from negative to positive
    func testDynamicUpdate_NegativeToPositive() {
        // Initial: number = -4 (error message)
        var result = getFieldValue("advanced_example_error_handling")
        XCTAssertEqual(result, "Cannot calculate square root of negative number", "Should show error for -4")
        
        // Update to positive
        updateNumberValue("number", 16)
        result = getFieldValue("advanced_example_error_handling")
        XCTAssertTrue(result.contains("16") && result.contains("4"), "Should show 'The square root of 16 is 4', got '\(result)'")
    }
    
    // MARK: - NEW EDGE CASES: Perfect Squares
    
    /// Test: sqrt(4) = 2
    func testEdgeCase_PerfectSquare_4() {
        updateNumberValue("area", 4)
        let result = getFieldValue("intermediate_example_area")
        XCTAssertEqual(result, "2", "sqrt(4) should return '2', got '\(result)'")
    }
    
    /// Test: sqrt(9) = 3
    func testEdgeCase_PerfectSquare_9() {
        updateNumberValue("area", 9)
        let result = getFieldValue("intermediate_example_area")
        XCTAssertEqual(result, "3", "sqrt(9) should return '3', got '\(result)'")
    }
    
    /// Test: sqrt(144) = 12
    func testEdgeCase_PerfectSquare_144() {
        updateNumberValue("area", 144)
        let result = getFieldValue("intermediate_example_area")
        XCTAssertEqual(result, "12", "sqrt(144) should return '12', got '\(result)'")
    }
    
    // MARK: - NEW EDGE CASES: Decimals & Small Numbers
    
    /// Test: sqrt(0.25) = 0.5
    func testEdgeCase_DecimalPerfectSquare() {
        updateNumberValue("area", 0.25)
        let result = getFieldValue("intermediate_example_area")
        XCTAssertEqual(result, "0.5", "sqrt(0.25) should return '0.5', got '\(result)'")
    }
    
    /// Test: sqrt(0.01) = 0.1
    func testEdgeCase_VerySmallNumber() {
        updateNumberValue("area", 0.01)
        let result = getFieldValue("intermediate_example_area")
        XCTAssertEqual(result, "0.1", "sqrt(0.01) should return '0.1', got '\(result)'")
    }
    
    /// Test: sqrt(0.5) ≈ 0.707
    func testEdgeCase_SmallDecimal() {
        updateNumberValue("area", 0.5)
        let result = getFieldValue("intermediate_example_area")
        XCTAssertTrue(result.hasPrefix("0.70"), "sqrt(0.5) should be ~0.707, got '\(result)'")
    }
    
    // MARK: - NEW EDGE CASES: Large Numbers
    
    /// Test: sqrt(1000000) = 1000
    func testEdgeCase_LargeNumber() {
        updateNumberValue("area", 1000000)
        let result = getFieldValue("intermediate_example_area")
        XCTAssertEqual(result, "1000", "sqrt(1000000) should return '1000', got '\(result)'")
    }
    
    /// Test: sqrt(999999) ≈ 999.9995
    func testEdgeCase_VeryLargeNonPerfect() {
        updateNumberValue("area", 999999)
        let result = getFieldValue("intermediate_example_area")
        XCTAssertTrue(result.hasPrefix("999.99"), "sqrt(999999) should be ~999.9995, got '\(result)'")
    }
    
    // MARK: - NEW EDGE CASES: Special Triangles
    
    /// Test: Isosceles triangle (equal sides)
    func testEdgeCase_IsoscelesTriangle() {
        updateNumberValue("x", 5)
        updateNumberValue("y", 5)
        let result = getFieldValue("intermediate_example_hypotenuse")
        // sqrt(25 + 25) = sqrt(50) ≈ 7.071
        XCTAssertTrue(result.hasPrefix("7.07"), "sqrt(5² + 5²) should be ~7.07, got '\(result)'")
    }
    
    /// Test: Degenerate triangle (one side is zero)
    func testEdgeCase_DegenerateTriangle() {
        updateNumberValue("x", 0)
        updateNumberValue("y", 5)
        let result = getFieldValue("intermediate_example_hypotenuse")
        // sqrt(0 + 25) = 5
        XCTAssertEqual(result, "5", "sqrt(0² + 5²) should be '5', got '\(result)'")
    }
    
    // MARK: - NEW SEQUENCE TESTS
    
    /// Test: Sequence of perfect squares
    func testSequence_PerfectSquares() {
        var result: String
        
        // Step 1: sqrt(4) = 2
        updateNumberValue("area", 4)
        result = getFieldValue("intermediate_example_area")
        XCTAssertEqual(result, "2", "Step 1: sqrt(4) should be '2', got '\(result)'")
        
        // Step 2: sqrt(9) = 3
        updateNumberValue("area", 9)
        result = getFieldValue("intermediate_example_area")
        XCTAssertEqual(result, "3", "Step 2: sqrt(9) should be '3', got '\(result)'")
        
        // Step 3: sqrt(16) = 4
        updateNumberValue("area", 16)
        result = getFieldValue("intermediate_example_area")
        XCTAssertEqual(result, "4", "Step 3: sqrt(16) should be '4', got '\(result)'")
        
        // Step 4: sqrt(25) = 5
        updateNumberValue("area", 25)
        result = getFieldValue("intermediate_example_area")
        XCTAssertEqual(result, "5", "Step 4: sqrt(25) should be '5', got '\(result)'")
        
        // Step 5: sqrt(36) = 6
        updateNumberValue("area", 36)
        result = getFieldValue("intermediate_example_area")
        XCTAssertEqual(result, "6", "Step 5: sqrt(36) should be '6', got '\(result)'")
    }
    
    /// Test: Sequence of radius updates for circle formula
    func testSequence_RadiusUpdates() {
        var result: String
        
        // Step 1: Initial radius = 10
        result = getFieldValue("advanced_example_circle")
        XCTAssertTrue(result.contains("10") && result.contains("314."), "Step 1: radius 10, got '\(result)'")
        
        // Step 2: radius = 20
        updateNumberValue("radius", 20)
        result = getFieldValue("advanced_example_circle")
        XCTAssertTrue(result.contains("20") && result.contains("1256."), "Step 2: radius 20, got '\(result)'")
        
        // Step 3: radius = 5
        updateNumberValue("radius", 5)
        result = getFieldValue("advanced_example_circle")
        XCTAssertTrue(result.contains("5") && result.contains("78.5"), "Step 3: radius 5, got '\(result)'")
        
        // Step 4: radius = 1
        updateNumberValue("radius", 1)
        result = getFieldValue("advanced_example_circle")
        XCTAssertTrue(result.contains("1") && result.contains("3.14"), "Step 4: radius 1, got '\(result)'")
    }
    
    // MARK: - NEW PRECISION TEST
    
    /// Test: Irrational result precision
    func testPrecision_IrrationalResult() {
        updateNumberValue("area", 3)
        let result = getFieldValue("intermediate_example_area")
        // sqrt(3) ≈ 1.7320508...
        XCTAssertTrue(result.hasPrefix("1.73"), "sqrt(3) should be ~1.732, got '\(result)'")
    }
}
