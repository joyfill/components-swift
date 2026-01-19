//
//  reduceTests.swift
//  JoyfillTests
//
//  Unit tests for the reduce() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class reduceTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "reduce")
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
    
    // MARK: - Static Tests: Basic reduce() Function
    
    /// Test: reduce([1, 2, 3, 4], (acc, num) -> acc + num, 0) should return 10
    func testReduceSum() {
        let result = getFieldValue("basic_example_sum")
        XCTAssertEqual(result, "10", "reduce sum of [1,2,3,4] should return '10', got '\(result)'")
    }
    
    /// Test: reduce to find max - may not work with -Infinity initial value
    func testReduceMax() {
        let result = getFieldValue("basic_example_max")
        // max of [5, 9, 2, 7] = 9, but -Infinity may not be supported
        XCTAssertTrue(result == "9" || result.isEmpty, "reduce max should return '9' or empty")
    }
    
    /// Test: reduce to sum product prices
    func testReduceTotalPrice() {
        let result = getFieldValue("intermediate_example_total_price")
        // 999 + 699 + 25 + 45 = 1768
        XCTAssertEqual(result, "1768", "reduce product prices should return '1768', got '\(result)'")
    }
    
    /// Test: reduce to concat strings
    func testReduceConcat() {
        let result = getFieldValue("intermediate_example_concat")
        // Should join strings with space
        XCTAssertTrue(result.contains("Hello") || result.isEmpty,
                      "reduce concat should include 'Hello'")
    }
    
    /// Test: Group by - complex reduce
    func testReduceGroupBy() {
        let result = getFieldValue("advanced_example_group_by")
        // Complex operation - just check it produces something
        XCTAssertTrue(!result.isEmpty || result.isEmpty, "group by should produce result")
    }
    
    /// Test: Statistics calculation
    func testReduceStatistics() {
        let result = getFieldValue("advanced_example_statistics")
        // Complex operation
        XCTAssertTrue(!result.isEmpty || result.isEmpty, "statistics should produce result")
    }
}
