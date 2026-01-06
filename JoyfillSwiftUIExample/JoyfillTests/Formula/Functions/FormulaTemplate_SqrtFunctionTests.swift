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
        XCTAssertTrue(result.contains("3"), "sqrt(9) should show '3'")
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
}
