//
//  FormulaTemplate_IfFunctionTests.swift
//  JoyfillTests
//
//  Created on 26/11/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

/// Tests for the `if()` formula function
/// The if() function evaluates a condition and returns one of two values based on the result.
/// Syntax: if(condition, value_if_true, value_if_false)
class FormulaTemplate_IfFunctionTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_IfFunction")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - If Function Tests
    
    /// Test 1: Basic if() with literal boolean true
    /// Formula: if(true, 'It is true', 'It is false')
    /// Expected: "It is true"
    func testIfWithLiteralTrue() {
        print("\n🔀 Test 1: if() with literal true")
        print("Formula: if(true, 'It is true', 'It is false')")
        print("Expected: It is true")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "basic_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "It is true", "if(true, ...) should return the true branch")
    }
    
    /// Test 2: Intermediate if() with comparison operator
    /// Formula: if(age > 16, 'Can Vote', 'Cannot Vote')
    /// Input: age = 30
    /// Expected: "Can Vote"
    func testIfWithComparisonGreaterThan() {
        print("\n🔀 Test 2: if() with comparison (>)")
        print("Formula: if(age > 16, 'Can Vote', 'Cannot Vote')")
        print("Input: age = 30")
        print("Expected: Can Vote")
        
        // First verify the age field value
        let ageValue = documentEditor.value(ofFieldWithIdentifier: "age")
        print("📊 Age value: \(ageValue?.number ?? -1)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "Can Vote", "if(30 > 16, ...) should return 'Can Vote'")
    }
    
    /// Test 3: if() with undefined field reference (error handling)
    /// Formula: if(undefined_field, 'Yes', 'No')
    /// Expected: Empty string (formula engine returns empty on invalid reference error)
    func testIfWithUndefinedField() {
        print("\n🔀 Test 3: if() with undefined field")
        print("Formula: if(undefined_field, 'Yes', 'No')")
        print("Expected: Empty string (formula error returns empty)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "error_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        // The formula engine returns empty string when there's an invalid reference error
        // This is the current behavior - formula fails and returns ""
        XCTAssertEqual(resultText, "", "if(undefined_field, ...) should return empty string due to invalid reference error")
    }
    
    /// Test 4: Advanced nested if() with equality operator
    /// Formula: if(gender=='Male','Boy',if(gender=='Female','Girl','Unknown'))
    /// Input: gender = nil (no value selected)
    /// Expected: "Unknown" (neither Male nor Female)
    func testNestedIfWithNoSelection() {
        print("\n🔀 Test 4: Nested if() with no selection")
        print("Formula: if(gender=='Male','Boy',if(gender=='Female','Girl','Unknown'))")
        print("Input: gender = (no selection)")
        print("Expected: Unknown")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        // When gender has no value, neither condition matches
        XCTAssertEqual(resultText, "Unknown", "Nested if() with no matching condition should return 'Unknown'")
    }
    
    /// Test 5: Verify initial age value is correctly loaded
    /// The JSON has age = 30, so we verify this loaded correctly
    func testAgeFieldInitialValue() {
        print("\n🔀 Test 5: Verify age field initial value")
        print("Expected: 30.0 (from JSON)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "age")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 30.0, "Age field should be initialized to 30 from JSON")
    }
    
    /// Test 6: Verify gender field has no initial selection
    /// The JSON doesn't set a value for gender dropdown
    func testGenderFieldNoInitialValue() {
        print("\n🔀 Test 6: Verify gender field has no initial value")
        print("Expected: nil or empty (no selection)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "gender")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        // Gender should have no initial selection
        XCTAssertTrue(resultText.isEmpty, "Gender field should have no initial selection")
    }
}

