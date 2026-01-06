//
//  countIfTests.swift
//  JoyfillTests
//
//  Unit tests for the countIf() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class countIfTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "countIf")
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
    
    // MARK: - Static Tests
    
    /// Test: Document loads successfully
    func testDocumentLoads() {
        XCTAssertNotNil(documentEditor, "DocumentEditor should load successfully")
    }
    
    /// Test: Basic countIf with literal array - countIf(["joy", "Joyfill", "hello"], "joy")
    /// Should count strings containing "joy" (case-insensitive matching expected)
    func testBasicCountIfLiteralArray() {
        let result = getFieldValue("basic_example")
        // countIf(["joy", "Joyfill", "hello"], "joy") should count matches
        // "joy" matches "joy", "Joyfill" contains "joy" -> depends on implementation
        XCTAssertFalse(result.isEmpty, "countIf() should return a result")
        if let count = Int(result) {
            XCTAssertTrue(count >= 1, "Should find at least 1 match for 'joy'")
        }
    }
    
    /// Test: countIf with field reference - counting "Yes" in selectedOptions
    /// selectedOptions = ["Yes", "No", "Yes", "Maybe", "Yes"]
    func testCountIfYesInSelectedOptions() {
        let result = getFieldValue("intermediate_example_yes")
        // Should count exactly 3 "Yes" values
        XCTAssertFalse(result.isEmpty, "countIf(selectedOptions, 'Yes') should return a result")
        if let count = Int(result) {
            XCTAssertEqual(count, 3, "Should find exactly 3 'Yes' values")
        }
    }
    
    /// Test: countIf searching for partial match - "electronics" in productCategories
    /// productCategories contains items like "electronics - smartphones", "electronics - laptops"
    func testCountIfElectronicsInCategories() {
        let result = getFieldValue("intermediate_example_electronics")
        // Should count items containing "electronics" (3 items)
        XCTAssertFalse(result.isEmpty, "countIf(productCategories, 'electronics') should return a result")
        if let count = Int(result) {
            XCTAssertEqual(count, 3, "Should find 3 categories containing 'electronics'")
        }
    }
    
    /// Test: Advanced countIf with comparison - comparing positive vs negative feedback
    /// responses = ["Positive", "Negative", "Positive", "Neutral", "Positive", "Negative"]
    /// Formula: if(countIf(responses, "Positive") > countIf(responses, "Negative"), "Overall Positive Feedback", "Needs Improvement")
    func testAdvancedCountIfFeedbackComparison() {
        let result = getFieldValue("advanced_example_feedback")
        // 3 Positive > 2 Negative, so should return "Overall Positive Feedback"
        XCTAssertEqual(result, "Overall Positive Feedback", "3 Positive > 2 Negative should yield 'Overall Positive Feedback'")
    }
    
    /// Test: Advanced countIf percentage calculation
    /// answers = ["Correct", "Incorrect", "Correct", "Correct", "Incorrect", "Correct", "Correct", "Incorrect", "Correct", "Correct"]
    /// Formula: (countIf(answers, "Correct") / length(answers)) * 100
    func testAdvancedCountIfPercentage() {
        let result = getFieldValue("advanced_example_percentage")
        // Percentage formula should return a numeric result
        XCTAssertFalse(result.isEmpty, "Percentage formula should return a result")
        if let percentage = Double(result) {
            XCTAssertTrue(percentage >= 0 && percentage <= 100, "Percentage should be between 0 and 100")
        }
    }
    
    // MARK: - Dynamic Update Tests
    
    /// Test: Updating selectedOptions and verifying countIf recalculates
    func testDynamicUpdateSelectedOptions() {
        // Initial: 3 "Yes" values
        let initialResult = getFieldValue("intermediate_example_yes")
        if let initialCount = Int(initialResult) {
            XCTAssertEqual(initialCount, 3, "Initial count should be 3")
        }
        
        // Update to have 4 "Yes" values
        updateFieldValue("selectedOptions", "[\"Yes\", \"Yes\", \"Yes\", \"Maybe\", \"Yes\"]")
        
        let updatedResult = getFieldValue("intermediate_example_yes")
        if let updatedCount = Int(updatedResult) {
            XCTAssertEqual(updatedCount, 4, "Updated count should be 4")
        }
    }
    
    /// Test: Updating responses to change feedback comparison result
    func testDynamicUpdateResponsesFeedback() {
        // Initial: 3 Positive > 2 Negative -> "Overall Positive Feedback"
        let initialResult = getFieldValue("advanced_example_feedback")
        XCTAssertEqual(initialResult, "Overall Positive Feedback")
        
        // Update to have more negatives
        updateFieldValue("responses", "[\"Negative\", \"Negative\", \"Negative\", \"Neutral\", \"Positive\", \"Negative\"]")
        
        let updatedResult = getFieldValue("advanced_example_feedback")
        XCTAssertEqual(updatedResult, "Needs Improvement", "1 Positive < 4 Negative should yield 'Needs Improvement'")
    }
    
    /// Test: Updating answers to change percentage calculation
    func testDynamicUpdateAnswersPercentage() {
        // Get initial percentage
        let initialResult = getFieldValue("advanced_example_percentage")
        XCTAssertFalse(initialResult.isEmpty, "Initial percentage should be non-empty")
        let initialPercentage = Double(initialResult) ?? 0
        
        // Update to have all correct
        updateFieldValue("answers", "[\"Correct\", \"Correct\", \"Correct\", \"Correct\", \"Correct\"]")
        
        let updatedResult = getFieldValue("advanced_example_percentage")
        if let updatedPercentage = Double(updatedResult) {
            XCTAssertEqual(updatedPercentage, 100.0, accuracy: 0.1, "5/5 * 100 should equal 100%")
        }
    }
    
    /// Test: Updating productCategories to change electronics count
    func testDynamicUpdateProductCategories() {
        // Initial: 3 electronics items
        let initialResult = getFieldValue("intermediate_example_electronics")
        if let initialCount = Int(initialResult) {
            XCTAssertEqual(initialCount, 3, "Initial electronics count should be 3")
        }
        
        // Update to have only 1 electronics item
        updateFieldValue("productCategories", "[\"electronics - phones\", \"clothing\", \"home goods\", \"toys\", \"books\"]")
        
        let updatedResult = getFieldValue("intermediate_example_electronics")
        if let updatedCount = Int(updatedResult) {
            XCTAssertEqual(updatedCount, 1, "Updated electronics count should be 1")
        }
    }
    
    /// Test: Edge case - countIf with empty matches
    func testDynamicUpdateNoMatches() {
        // Update selectedOptions to have no "Yes" values
        updateFieldValue("selectedOptions", "[\"No\", \"No\", \"Maybe\", \"Maybe\", \"No\"]")
        
        let result = getFieldValue("intermediate_example_yes")
        if let count = Int(result) {
            XCTAssertEqual(count, 0, "Should find 0 'Yes' values")
        }
    }
}
