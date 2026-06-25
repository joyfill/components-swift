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
    
    private func updateStringValue(_ fieldId: String, _ value: String) {
        documentEditor.updateValue(for: fieldId, value: .string(value))
    }

    // MARK: - Static Tests: Basic reduce() Function
    
    /// Test: reduce([1, 2, 3, 4], (acc, num) -> acc + num, 0) should return 10
    func testReduceSum() {
        let result = getFieldValue("basic_example_sum")
        XCTAssertEqual(result, "10", "reduce sum of [1,2,3,4] should return '10', got '\(result)'")
    }
    
    /// Test: reduce([5, 9, 2, 7], max, -Infinity) - the -Infinity seed is unsupported, so the
    /// formula resolves to empty.
    func testReduceMax() {
        let result = getFieldValue("basic_example_max")
        XCTAssertEqual(result, "", "reduce max with -Infinity seed resolves to empty, got '\(result)'")
    }
    
    /// Test: reduce(products, (total, product) -> total + product.price, 0) = 999+699+25+45 = 1768
    func testReduceTotalPrice() {
        let result = getFieldValue("intermediate_example_total_price")
        XCTAssertEqual(result, "1768", "reduce product prices should return '1768', got '\(result)'")
    }
    
    /// Test: reduce(strings, concat with space) joins ["Hello","World","!"] → "Hello World !"
    func testReduceConcat() {
        let result = getFieldValue("intermediate_example_concat")
        XCTAssertEqual(result, "Hello World !", "reduce concat should join with spaces, got '\(result)'")
    }

    /// Test: Group-by uses a block-body lambda returning an object, which is unsupported, so the
    /// formula resolves to empty.
    func testReduceGroupBy() {
        let result = getFieldValue("advanced_example_group_by")
        XCTAssertEqual(result, "", "group-by (block-body/object reduce) resolves to empty, got '\(result)'")
    }

    /// Test: Statistics uses a block-body lambda returning an object, which is unsupported, so the
    /// formula resolves to empty.
    func testReduceStatistics() {
        let result = getFieldValue("advanced_example_statistics")
        XCTAssertEqual(result, "", "statistics (block-body/object reduce) resolves to empty, got '\(result)'")
    }

    /// Test: Frequency map uses a block-body lambda returning an object, which is unsupported, so
    /// the formula resolves to empty.
    func testReduceFrequency() {
        let result = getFieldValue("advanced_example_frequency")
        XCTAssertEqual(result, "", "frequency (block-body/object reduce) resolves to empty, got '\(result)'")
    }

    // MARK: - Dynamic Tests

    /// Test: Updating the strings array re-runs the concat reduce with the new values.
    func testDynamicUpdateStringsConcat() {
        XCTAssertEqual(getFieldValue("intermediate_example_concat"), "Hello World !", "Initial concat")

        updateStringValue("strings", "[\"Foo\", \"Bar\", \"Baz\"]")
        XCTAssertEqual(getFieldValue("intermediate_example_concat"), "Foo Bar Baz",
                       "After update, concat should join the new strings")
    }

    /// Test: Updating the products array re-runs the total-price reduce (10 + 20 = 30).
    func testDynamicUpdateProductsTotal() {
        XCTAssertEqual(getFieldValue("intermediate_example_total_price"), "1768", "Initial total")

        updateStringValue("products", "[{\"name\": \"A\", \"price\": 10}, {\"name\": \"B\", \"price\": 20}]")
        XCTAssertEqual(getFieldValue("intermediate_example_total_price"), "30",
                       "After update, total should be sum of the new product prices")
    }

    /// Test: Updating the numbers array does not change the statistics output - it stays empty,
    /// because the block-body/object reduce is unsupported.
    func testDynamicUpdateNumbersStatisticsStaysEmpty() {
        XCTAssertEqual(getFieldValue("advanced_example_statistics"), "", "Initial: empty")

        updateStringValue("numbers", "[20, 4, 50, 1]")
        XCTAssertEqual(getFieldValue("advanced_example_statistics"), "",
                       "After update: still empty (block-body reduce unsupported)")
    }

    /// Test: Updating the fruits array does not change the frequency output - it stays empty,
    /// because the block-body/object reduce is unsupported.
    func testDynamicUpdateFruitsFrequencyStaysEmpty() {
        XCTAssertEqual(getFieldValue("advanced_example_frequency"), "", "Initial: empty")

        updateStringValue("fruits", "[\"x\", \"y\", \"x\"]")
        XCTAssertEqual(getFieldValue("advanced_example_frequency"), "",
                       "After update: still empty (block-body reduce unsupported)")
    }
}
