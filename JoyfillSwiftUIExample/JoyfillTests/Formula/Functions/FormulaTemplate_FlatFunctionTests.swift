//
//  flatTests.swift
//  JoyfillTests
//
//  Unit tests for the flat() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class flatTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "flat")
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
    
    private func updateFieldValue(_ fieldId: String, _ value: String) {
        documentEditor.updateValue(for: fieldId, value: .string(value))
    }
    
    private func updateNumberValue(_ fieldId: String, _ value: Int) {
        documentEditor.updateValue(for: fieldId, value: .double(Double(value)))
    }
    
    // MARK: - Static Tests
    // Note: scalar arrays render as "1.0, 2.0, ..."; a sub-array that remains nested after a
    // bounded flatten renders via its debug form "array([JoyfillFormulas.FormulaValue.number(4.0), ...])".

    /// Test: Document loads successfully
    func testDocumentLoads() {
        XCTAssertNotNil(documentEditor, "DocumentEditor should load successfully")
    }

    /// Test: flat([1, [2, 3]]) fully flattens to [1, 2, 3].
    func testBasicFlatSimple() {
        let result = getFieldValue("basic_example_simple")
        XCTAssertEqual(result, "1.0, 2.0, 3.0", "flat([1, [2, 3]]) should be exactly 1, 2, 3")
    }

    /// Test: flat([1, 2, 3]) leaves an already-flat array unchanged.
    func testBasicFlatUnchanged() {
        let result = getFieldValue("basic_example_unchanged")
        XCTAssertEqual(result, "1.0, 2.0, 3.0", "flat([1, 2, 3]) should remain exactly 1, 2, 3")
    }

    /// Test: flat([0, 1, [2, [3, [4, 5]]]], 2) flattens exactly 2 levels, leaving [4, 5] nested.
    func testIntermediateFlatWithDepth() {
        let result = getFieldValue("intermediate_example_depth")
        XCTAssertEqual(result,
                       "0.0, 1.0, 2.0, 3.0, array([JoyfillFormulas.FormulaValue.number(4.0), JoyfillFormulas.FormulaValue.number(5.0)])",
                       "depth 2 should flatten 0,1,2,3 but leave [4, 5] nested")
    }

    /// Test: flat(nestedData, flattenDepth) = flat([[1,2],[3,[4,5]],6], 2) flattens to [1..6].
    func testIntermediateFlatDynamic() {
        let result = getFieldValue("intermediate_example_dynamic")
        XCTAssertEqual(result, "1.0, 2.0, 3.0, 4.0, 5.0, 6.0", "depth 2 fully flattens nestedData to 1..6")
    }

    /// Test: if(length(flat(responses, 1)) > 0, ...) with [[], ["response1"], []] takes the true branch.
    func testAdvancedFlatResponses() {
        let result = getFieldValue("advanced_example_responses")
        XCTAssertEqual(result, "At least one response received", "Flat array with one response should indicate responses received")
    }

    /// Test: concat("All categories: ", flat(categories, 2)) joins the depth-2 flattened labels.
    func testAdvancedFlatCategories() {
        let result = getFieldValue("advanced_example_categories")
        XCTAssertEqual(result,
                       "All categories: Electronics, Phones, Computers, Clothing, Shirts, Pants",
                       "flat(categories, 2) should fully flatten the category labels in order")
    }
    
    // MARK: - Dynamic Update Tests
    
    /// Test: Updating nestedData recomputes flat(nestedData, 2).
    func testDynamicUpdateNestedData() {
        updateFieldValue("nestedData", "[[10, 20], [30, 40]]")

        let result = getFieldValue("intermediate_example_dynamic")
        XCTAssertEqual(result, "10.0, 20.0, 30.0, 40.0", "flat([[10,20],[30,40]], 2) should be exactly 10,20,30,40")
    }

    /// Test: Lowering flattenDepth to 1 leaves [4, 5] nested in flat(nestedData, 1).
    func testDynamicUpdateFlattenDepth() {
        updateNumberValue("flattenDepth", 1)

        let result = getFieldValue("intermediate_example_dynamic")
        XCTAssertEqual(result,
                       "1.0, 2.0, 3.0, array([JoyfillFormulas.FormulaValue.number(4.0), JoyfillFormulas.FormulaValue.number(5.0)]), 6.0",
                       "depth 1 should flatten one level, leaving [4, 5] nested")
    }
    
    /// Test: Update responses to have no responses
    func testDynamicUpdateNoResponses() {
        // Initial: has one response
        let initialResult = getFieldValue("advanced_example_responses")
        XCTAssertEqual(initialResult, "At least one response received")
        
        // Update to have no responses
        updateFieldValue("responses", "[[], [], []]")
        
        let updatedResult = getFieldValue("advanced_example_responses")
        XCTAssertEqual(updatedResult, "No responses yet", "Empty responses should show 'No responses yet'")
    }
    
    /// Test: Update responses to have multiple responses
    func testDynamicUpdateMultipleResponses() {
        // Update to have multiple responses
        updateFieldValue("responses", "[[\"response1\", \"response2\"], [\"response3\"], [\"response4\"]]")
        
        let result = getFieldValue("advanced_example_responses")
        XCTAssertEqual(result, "At least one response received", "Multiple responses should still show 'At least one response received'")
    }
    
    /// Test: Updating categories recomputes concat + flat(categories, 2) in order.
    func testDynamicUpdateCategories() {
        updateFieldValue("categories", "[[\"Books\", [\"Fiction\", \"Non-Fiction\"]], [\"Music\", [\"Rock\", \"Jazz\"]]]")

        let result = getFieldValue("advanced_example_categories")
        XCTAssertEqual(result,
                       "All categories: Books, Fiction, Non-Fiction, Music, Rock, Jazz",
                       "flat(categories, 2) should fully flatten the updated labels in order")
    }
}
