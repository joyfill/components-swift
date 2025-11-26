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
    /// Expected: Should handle gracefully - likely returns 'No' or error value
    func testIfWithUndefinedField() {
        print("\n🔀 Test 3: if() with undefined field")
        print("Formula: if(undefined_field, 'Yes', 'No')")
        print("Expected: Graceful handling (likely 'No' or empty)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "error_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        // The formula engine should handle undefined fields gracefully
        // undefined_field will likely evaluate to false/null, so 'No' should be returned
        XCTAssertEqual(resultText, "No", "if(undefined_field, ...) should return the false branch when field is undefined")
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
    
    /// Test 5: Test if() with field value updated to Male
    /// Formula: if(gender=='Male','Boy',if(gender=='Female','Girl','Unknown'))
    /// After setting gender = Male
    /// Expected: "Boy"
    func testNestedIfWithMaleSelection() {
        print("\n🔀 Test 5: Nested if() with Male selection")
        print("Formula: if(gender=='Male','Boy',if(gender=='Female','Girl','Unknown'))")
        
        // Update the gender field to Male (using option ID)
        documentEditor.updateValue(for: "gender", value: .string("691acd93f9c467ef178184dd"))
        
        print("Input: gender = Male (option ID: 691acd93f9c467ef178184dd)")
        print("Expected: Boy")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "Boy", "if(gender=='Male', ...) should return 'Boy'")
    }
    
    /// Test 6: Test if() with field value updated to Female
    /// Formula: if(gender=='Male','Boy',if(gender=='Female','Girl','Unknown'))
    /// After setting gender = Female
    /// Expected: "Girl"
    func testNestedIfWithFemaleSelection() {
        print("\n🔀 Test 6: Nested if() with Female selection")
        print("Formula: if(gender=='Male','Boy',if(gender=='Female','Girl','Unknown'))")
        
        // Update the gender field to Female (using option ID)
        documentEditor.updateValue(for: "gender", value: .string("691acd93e21a5122c7a1a782"))
        
        print("Input: gender = Female (option ID: 691acd93e21a5122c7a1a782)")
        print("Expected: Girl")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "Girl", "if(gender=='Female', ...) should return 'Girl'")
    }
    
    /// Test 7: Test if() condition evaluation with dynamic age update
    /// Formula: if(age > 16, 'Can Vote', 'Cannot Vote')
    /// After setting age = 10
    /// Expected: "Cannot Vote"
    func testIfWithAgeUnder16() {
        print("\n🔀 Test 7: if() with age under 16")
        print("Formula: if(age > 16, 'Can Vote', 'Cannot Vote')")
        
        // Update age to 10
        documentEditor.updateValue(for: "age", value: .double(10))
        
        print("Input: age = 10")
        print("Expected: Cannot Vote")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "Cannot Vote", "if(10 > 16, ...) should return 'Cannot Vote'")
    }
    
    /// Test 8: Test if() boundary condition
    /// Formula: if(age > 16, 'Can Vote', 'Cannot Vote')
    /// After setting age = 16
    /// Expected: "Cannot Vote" (16 is not greater than 16)
    func testIfWithAgeEqualTo16() {
        print("\n🔀 Test 8: if() with age equal to 16 (boundary)")
        print("Formula: if(age > 16, 'Can Vote', 'Cannot Vote')")
        
        // Update age to 16
        documentEditor.updateValue(for: "age", value: .double(16))
        
        print("Input: age = 16")
        print("Expected: Cannot Vote (16 is NOT > 16)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "Cannot Vote", "if(16 > 16, ...) should return 'Cannot Vote'")
    }
    
    /// Test 9: Test if() just above boundary condition
    /// Formula: if(age > 16, 'Can Vote', 'Cannot Vote')
    /// After setting age = 17
    /// Expected: "Can Vote" (17 is greater than 16)
    func testIfWithAgeEqualTo17() {
        print("\n🔀 Test 9: if() with age equal to 17 (just above boundary)")
        print("Formula: if(age > 16, 'Can Vote', 'Cannot Vote')")
        
        // Update age to 17
        documentEditor.updateValue(for: "age", value: .double(17))
        
        print("Input: age = 17")
        print("Expected: Can Vote (17 > 16)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "Can Vote", "if(17 > 16, ...) should return 'Can Vote'")
    }
}

