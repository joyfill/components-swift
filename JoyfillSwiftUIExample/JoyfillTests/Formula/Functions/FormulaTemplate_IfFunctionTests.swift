//
//  ifTests.swift
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
class ifTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "if")
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
        
        var result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "Can Vote", "if(30 > 16, ...) should return 'Can Vote'")


        documentEditor.updateValue(for: "age", value: .int(5))

        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")

        print("🎯 Result: \(result?.text ?? "")")

        XCTAssertEqual(result?.text ?? "", "Cannot Vote", "if(30 > 16, ...) should return 'Cannot Vote'")
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
    
    // MARK: - Dynamic Update Tests
    
    /// Test 7: Dynamic update - age under 16
    /// Formula: if(age > 16, 'Can Vote', 'Cannot Vote')
    /// Update age from 30 to 10
    /// Expected: "Cannot Vote"
    func testDynamicUpdateAgeUnder16() {
        print("\n🔀 Test 7: Dynamic update - age under 16")
        print("Formula: if(age > 16, 'Can Vote', 'Cannot Vote')")
        
        // Initial state: age = 30 → "Can Vote"
        var result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "Can Vote", "Initial: age=30 should return 'Can Vote'")
        
        // Update age to 10
        documentEditor.updateValue(for: "age", value: .int(10))
        print("Updated: age = 10")
        
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "Cannot Vote", "if(10 > 16, ...) should return 'Cannot Vote'")
    }
    
    /// Test 8: Dynamic update - age boundary at 16
    /// Formula: if(age > 16, 'Can Vote', 'Cannot Vote')
    /// Update age to 16
    /// Expected: "Cannot Vote" (16 is NOT > 16)
    func testDynamicUpdateAgeBoundary16() {
        print("\n🔀 Test 8: Dynamic update - age boundary at 16")
        print("Formula: if(age > 16, 'Can Vote', 'Cannot Vote')")
        
        // Update age to 16
        documentEditor.updateValue(for: "age", value: .int(16))
        print("Updated: age = 16")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "Cannot Vote", "if(16 > 16, ...) should return 'Cannot Vote' (boundary)")
    }
    
    /// Test 9: Dynamic update - age just above boundary at 17
    /// Formula: if(age > 16, 'Can Vote', 'Cannot Vote')
    /// Update age to 17
    /// Expected: "Can Vote" (17 > 16)
    func testDynamicUpdateAgeBoundary17() {
        print("\n🔀 Test 9: Dynamic update - age boundary at 17")
        print("Formula: if(age > 16, 'Can Vote', 'Cannot Vote')")
        
        // First set age to something below 16
        documentEditor.updateValue(for: "age", value: .int(10))
        var result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "Cannot Vote", "age=10 should return 'Cannot Vote'")
        
        // Now update to 17
        documentEditor.updateValue(for: "age", value: .int(17))
        print("Updated: age = 17")
        
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "Can Vote", "if(17 > 16, ...) should return 'Can Vote'")
    }
    
    /// Test 10: Dynamic update - gender to Male
    /// Formula: if(gender=='Male','Boy',if(gender=='Female','Girl','Unknown'))
    /// Update gender to Male
    /// Expected: "Boy"
    func testDynamicUpdateGenderMale() {
        print("\n🔀 Test 10: Dynamic update - gender to Male")
        print("Formula: if(gender=='Male','Boy',if(gender=='Female','Girl','Unknown'))")
        
        // Initial state: no gender → "Unknown"
        var result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        XCTAssertEqual(result?.text ?? "", "Unknown", "Initial: no gender should return 'Unknown'")
        
        // Update gender to Male (using display value - the formula compares with display value)
        documentEditor.updateValue(for: "gender", value: .string("Male"))
        print("Updated: gender = Male")
        
        result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "Boy", "if(gender=='Male', ...) should return 'Boy'")
    }
    
    /// Test 11: Dynamic update - gender to Female
    /// Formula: if(gender=='Male','Boy',if(gender=='Female','Girl','Unknown'))
    /// Update gender to Female
    /// Expected: "Girl"
    func testDynamicUpdateGenderFemale() {
        print("\n🔀 Test 11: Dynamic update - gender to Female")
        print("Formula: if(gender=='Male','Boy',if(gender=='Female','Girl','Unknown'))")
        
        // Update gender to Female (using display value)
        documentEditor.updateValue(for: "gender", value: .string("Female"))
        print("Updated: gender = Female")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "Girl", "if(gender=='Female', ...) should return 'Girl'")
    }
    
    /// Test 12: Dynamic update - gender switch from Male to Female
    /// Formula: if(gender=='Male','Boy',if(gender=='Female','Girl','Unknown'))
    /// Update gender from Male to Female
    /// Expected: First "Boy", then "Girl"
    func testDynamicUpdateGenderSwitch() {
        print("\n🔀 Test 12: Dynamic update - gender switch Male → Female")
        print("Formula: if(gender=='Male','Boy',if(gender=='Female','Girl','Unknown'))")
        
        // Set to Male first
        documentEditor.updateValue(for: "gender", value: .string("Male"))
        var result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        print("After Male: \(result?.text ?? "")")
        XCTAssertEqual(result?.text ?? "", "Boy", "gender=Male should return 'Boy'")
        
        // Switch to Female
        documentEditor.updateValue(for: "gender", value: .string("Female"))
        result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("After Female: \(resultText)")
        
        XCTAssertEqual(resultText, "Girl", "gender=Female should return 'Girl'")
    }
    
    /// Test 13: Dynamic update - multiple age changes in sequence
    /// Formula: if(age > 16, 'Can Vote', 'Cannot Vote')
    /// Sequence: 30 → 10 → 16 → 17 → 50
    func testDynamicUpdateAgeSequence() {
        print("\n🔀 Test 13: Dynamic update - age sequence")
        print("Formula: if(age > 16, 'Can Vote', 'Cannot Vote')")
        
        // Initial: age = 30 → Can Vote
        var result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "Can Vote", "Initial age=30 → Can Vote")
        print("age=30 → \(result?.text ?? "")")
        
        // age = 10 → Cannot Vote
        documentEditor.updateValue(for: "age", value: .int(10))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "Cannot Vote", "age=10 → Cannot Vote")
        print("age=10 → \(result?.text ?? "")")
        
        // age = 16 → Cannot Vote (boundary)
        documentEditor.updateValue(for: "age", value: .int(16))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "Cannot Vote", "age=16 → Cannot Vote")
        print("age=16 → \(result?.text ?? "")")
        
        // age = 17 → Can Vote
        documentEditor.updateValue(for: "age", value: .int(17))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "Can Vote", "age=17 → Can Vote")
        print("age=17 → \(result?.text ?? "")")
        
        // age = 50 → Can Vote
        documentEditor.updateValue(for: "age", value: .int(50))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "Can Vote", "age=50 → Can Vote")
        print("age=50 → \(result?.text ?? "")")
        
        print("✅ All sequence tests passed")
    }
    
    /// Test 14: Dynamic update - negative age
    /// Formula: if(age > 16, 'Can Vote', 'Cannot Vote')
    /// Update age to -5
    /// Expected: "Cannot Vote"
    func testDynamicUpdateNegativeAge() {
        print("\n🔀 Test 14: Dynamic update - negative age")
        print("Formula: if(age > 16, 'Can Vote', 'Cannot Vote')")
        
        // Update age to -5
        documentEditor.updateValue(for: "age", value: .int(-5))
        print("Updated: age = -5")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "Cannot Vote", "if(-5 > 16, ...) should return 'Cannot Vote'")
    }
    
    /// Test 15: Dynamic update - zero age
    /// Formula: if(age > 16, 'Can Vote', 'Cannot Vote')
    /// Update age to 0
    /// Expected: "Cannot Vote"
    func testDynamicUpdateZeroAge() {
        print("\n🔀 Test 15: Dynamic update - zero age")
        print("Formula: if(age > 16, 'Can Vote', 'Cannot Vote')")
        
        // Update age to 0
        documentEditor.updateValue(for: "age", value: .int(0))
        print("Updated: age = 0")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "Cannot Vote", "if(0 > 16, ...) should return 'Cannot Vote'")
    }
    
    /// Test 16: Dynamic update - large age value
    /// Formula: if(age > 16, 'Can Vote', 'Cannot Vote')
    /// Update age to 1000
    /// Expected: "Can Vote"
    func testDynamicUpdateLargeAge() {
        print("\n🔀 Test 16: Dynamic update - large age")
        print("Formula: if(age > 16, 'Can Vote', 'Cannot Vote')")
        
        // Update age to 1000
        documentEditor.updateValue(for: "age", value: .int(1000))
        print("Updated: age = 1000")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "Can Vote", "if(1000 > 16, ...) should return 'Can Vote'")
    }
}

