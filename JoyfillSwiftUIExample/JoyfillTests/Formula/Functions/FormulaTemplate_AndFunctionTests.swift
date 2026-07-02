//
//  andTests.swift
//  JoyfillTests
//
//  Created on 26/11/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

/// Tests for the `and()` formula function
/// The and() function returns true only if ALL conditions are true.
/// Syntax: and(condition1, condition2, ...)
class andTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "and")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Static Evaluation Tests
    
    /// Test 1: Basic and() with all true literals
    /// Formula: and(true, true)
    /// Expected: true
    func testAndWithAllTrue() {
        print("\n🔀 Test 1: and() with all true")
        print("Formula: and(true, true)")
        print("Expected: true")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "basic_example_true")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "true", "and(true, true) should return 'true'")
    }
    
    /// Test 2: Basic and() with one false
    /// Formula: and(true, false)
    /// Expected: false
    func testAndWithOneFalse() {
        print("\n🔀 Test 2: and() with one false")
        print("Formula: and(true, false)")
        print("Expected: false")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "basic_example_false")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "and(true, false) should return 'false'")
    }
    
    /// Test 3: Intermediate and() with field comparisons
    /// Formula: and(age > 18, gender === 'Female')
    /// Initial: age = 20, gender = nil
    /// Expected: false (gender condition fails - no selection)
    func testAndWithFieldComparisons_InitialState() {
        print("\n🔀 Test 3: and() with field comparisons (initial)")
        print("Formula: and(age > 18, gender === 'Female')")
        print("Initial: age = 20, gender = (no selection)")
        print("Expected: false (gender not 'Female')")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "and() should return 'false' when gender is not Female")
    }
    
    /// Test 4: Advanced and() with multiple conditions and nested functions
    /// Formula: and(length(name) > 0, age >= 18, or(country === 'USA', country === 'Canada'), not(hasVoted))
    /// Initial: name = "John Doe", age = 20, country = nil, hasVoted = false
    /// Expected: false (country condition fails - no selection)
    func testAdvancedAndWithNestedFunctions_InitialState() {
        print("\n🔀 Test 4: Advanced and() with nested functions (initial)")
        print("Formula: and(length(name) > 0, age >= 18, or(country === 'USA', country === 'Canada'), not(hasVoted))")
        print("Initial: name='John Doe', age=20, country=(nil), hasVoted=false")
        print("Expected: false (country is not USA or Canada)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "and() should return 'false' when country is not selected")
    }
    
    /// Test 5: Verify initial field values
    func testInitialFieldValues() {
        print("\n🔀 Test 5: Verify initial field values")
        
        let age = documentEditor.value(ofFieldWithIdentifier: "age")?.number ?? -1
        let name = documentEditor.value(ofFieldWithIdentifier: "name")?.text ?? ""
        
        print("📊 age = \(age)")
        print("📊 name = '\(name)'")
        
        XCTAssertEqual(age, 20.0, "Age should be 20")
        XCTAssertEqual(name, "John Doe", "Name should be 'John Doe'")
    }
    
    // MARK: - Dynamic Update Tests
    
    /// Test 6: Dynamic update - set gender to Female, making intermediate true
    /// Formula: and(age > 18, gender === 'Female')
    /// Update: gender = Female
    /// Expected: true (both conditions now pass: age=20 > 18, gender='Female')
    func testDynamicUpdateGenderToFemale() {
        print("\n🔀 Test 6: Dynamic update - gender to Female")
        print("Formula: and(age > 18, gender === 'Female')")
        
        // Initial: false
        var result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "false", "Initial should be false")
        
        // Update gender to Female
        documentEditor.updateValue(for: "gender", value: .string("Female"))
        print("Updated: gender = Female")
        
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "true", "and(20 > 18, 'Female' === 'Female') should return 'true'")
    }
    
    /// Test 7: Dynamic update - set gender to Male, keeping intermediate false
    /// Formula: and(age > 18, gender === 'Female')
    /// Update: gender = Male
    /// Expected: false (gender condition fails)
    func testDynamicUpdateGenderToMale() {
        print("\n🔀 Test 7: Dynamic update - gender to Male")
        print("Formula: and(age > 18, gender === 'Female')")
        
        // Update gender to Male
        documentEditor.updateValue(for: "gender", value: .string("Male"))
        print("Updated: gender = Male")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "and(20 > 18, 'Male' === 'Female') should return 'false'")
    }
    
    /// Test 8: Dynamic update - reduce age below 18
    /// Formula: and(age > 18, gender === 'Female')
    /// Update: age = 15, gender = Female
    /// Expected: false (age condition fails)
    func testDynamicUpdateAgeBelowThreshold() {
        print("\n🔀 Test 8: Dynamic update - age below 18")
        print("Formula: and(age > 18, gender === 'Female')")
        
        // Set gender to Female first
        documentEditor.updateValue(for: "gender", value: .string("Female"))
        
        // Set age to 15 (below 18)
        documentEditor.updateValue(for: "age", value: .int(15))
        print("Updated: age = 15, gender = Female")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "and(15 > 18, 'Female' === 'Female') should return 'false'")
    }
    
    /// Test 9: Dynamic update - age at boundary (18)
    /// Formula: and(age > 18, gender === 'Female')
    /// Update: age = 18, gender = Female
    /// Expected: false (18 is NOT > 18)
    func testDynamicUpdateAgeBoundary18() {
        print("\n🔀 Test 9: Dynamic update - age boundary at 18")
        print("Formula: and(age > 18, gender === 'Female')")
        
        documentEditor.updateValue(for: "gender", value: .string("Female"))
        documentEditor.updateValue(for: "age", value: .int(18))
        print("Updated: age = 18, gender = Female")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "and(18 > 18, ...) should return 'false' (boundary)")
    }
    
    /// Test 10: Dynamic update - age just above boundary (19)
    /// Formula: and(age > 18, gender === 'Female')
    /// Update: age = 19, gender = Female
    /// Expected: true
    func testDynamicUpdateAgeBoundary19() {
        print("\n🔀 Test 10: Dynamic update - age just above boundary")
        print("Formula: and(age > 18, gender === 'Female')")
        
        documentEditor.updateValue(for: "gender", value: .string("Female"))
        documentEditor.updateValue(for: "age", value: .int(19))
        print("Updated: age = 19, gender = Female")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "true", "and(19 > 18, 'Female' === 'Female') should return 'true'")
    }
    
    /// Test 11: Dynamic update - make advanced example true
    /// Formula: and(length(name) > 0, age >= 18, or(country === 'USA', country === 'Canada'), not(hasVoted))
    /// Update: country = USA (all conditions now pass)
    /// Expected: true
    func testDynamicUpdateAdvancedToTrue() {
        print("\n🔀 Test 11: Dynamic update - advanced example to true")
        print("Formula: and(length(name) > 0, age >= 18, or(country === 'USA', country === 'Canada'), not(hasVoted))")
        
        // Set country to USA - all conditions should now pass
        // name = "John Doe" (length > 0 ✓)
        // age = 20 (>= 18 ✓)
        // country = USA (or(USA, Canada) ✓)
        // hasVoted = false (not(false) = true ✓)
        documentEditor.updateValue(for: "country", value: .string("USA"))
        print("Updated: country = USA")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "true", "All conditions met, should return 'true'")
    }
    
    /// Test 12: Dynamic update - set country to Canada
    /// Formula: and(length(name) > 0, age >= 18, or(country === 'USA', country === 'Canada'), not(hasVoted))
    /// Expected: true (Canada satisfies the or condition)
    func testDynamicUpdateCountryCanada() {
        print("\n🔀 Test 12: Dynamic update - country to Canada")
        print("Formula: ...or(country === 'USA', country === 'Canada')...")
        
        documentEditor.updateValue(for: "country", value: .string("Canada"))
        print("Updated: country = Canada")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "true", "Canada should satisfy or(USA, Canada)")
    }
    
    /// Test 13: Dynamic update - set country to Other (non-matching)
    /// Formula: and(..., or(country === 'USA', country === 'Canada'), ...)
    /// Expected: false (Other doesn't match USA or Canada)
    func testDynamicUpdateCountryOther() {
        print("\n🔀 Test 13: Dynamic update - country to Other")
        print("Formula: ...or(country === 'USA', country === 'Canada')...")
        
        documentEditor.updateValue(for: "country", value: .string("Other"))
        print("Updated: country = Other")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "Other should NOT satisfy or(USA, Canada)")
    }
    
    /// Test 14: Dynamic update - clear name (empty string)
    /// Formula: and(length(name) > 0, ...)
    /// Expected: false (length(name) = 0)
    func testDynamicUpdateEmptyName() {
        print("\n🔀 Test 14: Dynamic update - empty name")
        print("Formula: and(length(name) > 0, ...)")
        
        // First make it true
        documentEditor.updateValue(for: "country", value: .string("USA"))
        var result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        XCTAssertEqual(result?.text ?? "", "true", "Should be true with all conditions met")
        
        // Now clear the name
        documentEditor.updateValue(for: "name", value: .string(""))
        print("Updated: name = '' (empty)")
        
        result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "length('') > 0 should fail")
    }
    
    /// Test 15: Dynamic update - age below 18 in advanced formula
    /// Formula: and(..., age >= 18, ...)
    /// Expected: false
    func testDynamicUpdateAdvancedAgeBelowThreshold() {
        print("\n🔀 Test 15: Dynamic update - age below 18 in advanced")
        print("Formula: and(..., age >= 18, ...)")
        
        documentEditor.updateValue(for: "country", value: .string("USA"))
        documentEditor.updateValue(for: "age", value: .int(17))
        print("Updated: age = 17, country = USA")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "age >= 18 fails when age = 17")
    }
    
    /// Test 16: Dynamic update - age at boundary 18 in advanced (>= operator)
    /// Formula: and(..., age >= 18, ...)
    /// Expected: true (18 >= 18 is true)
    func testDynamicUpdateAdvancedAgeBoundary18() {
        print("\n🔀 Test 16: Dynamic update - age = 18 in advanced (>= check)")
        print("Formula: and(..., age >= 18, ...)")
        
        documentEditor.updateValue(for: "country", value: .string("USA"))
        documentEditor.updateValue(for: "age", value: .int(18))
        print("Updated: age = 18, country = USA")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "true", "age >= 18 passes when age = 18")
    }
    
    /// Test 17: Dynamic update - hasVoted makes not(hasVoted) false
    /// Formula: and(..., not(hasVoted))
    /// Expected: false (not(true) = false)
    func testDynamicUpdateHasVotedTrue() {
        print("\n🔀 Test 17: Dynamic update - hasVoted = true")
        print("Formula: and(..., not(hasVoted))")
        
        // First make everything else true
        documentEditor.updateValue(for: "country", value: .string("USA"))
        var result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        XCTAssertEqual(result?.text ?? "", "true", "Should be true initially")
        
        // Now set hasVoted to true - this should make not(hasVoted) = false
        documentEditor.updateValue(for: "hasVoted", value: .bool(true))
        print("Updated: hasVoted = true")
        
        result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "not(true) should return false")
    }
    
    /// Test 18: Sequence test - toggle multiple conditions
    func testDynamicUpdateSequence() {
        print("\n🔀 Test 18: Dynamic update sequence")
        print("Formula: and(age > 18, gender === 'Female')")
        
        var result: ValueUnion?
        
        // Step 1: Initial state (false)
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "false", "Step 1: Initial state")
        print("Step 1 - Initial: \(result?.text ?? "")")
        
        // Step 2: Set gender to Female (true)
        documentEditor.updateValue(for: "gender", value: .string("Female"))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "true", "Step 2: Female selected")
        print("Step 2 - gender=Female: \(result?.text ?? "")")
        
        // Step 3: Lower age to 10 (false)
        documentEditor.updateValue(for: "age", value: .int(10))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "false", "Step 3: Age too low")
        print("Step 3 - age=10: \(result?.text ?? "")")
        
        // Step 4: Raise age to 25 (true again)
        documentEditor.updateValue(for: "age", value: .int(25))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "true", "Step 4: Age high enough")
        print("Step 4 - age=25: \(result?.text ?? "")")
        
        // Step 5: Change gender to Male (false)
        documentEditor.updateValue(for: "gender", value: .string("Male"))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "false", "Step 5: Gender changed to Male")
        print("Step 5 - gender=Male: \(result?.text ?? "")")
        
        print("✅ Sequence test completed")
    }
    
    // MARK: - Additional Edge Case Tests
    
    /// Test 19: Single character name
    /// Formula: and(length(name) > 0, ...)
    /// Expected: true (length("A") = 1 > 0)
    func testDynamicUpdateSingleCharacterName() {
        print("\n🔀 Test 19: Single character name")
        print("Formula: and(length(name) > 0, ...)")
        
        documentEditor.updateValue(for: "country", value: .string("USA"))
        documentEditor.updateValue(for: "name", value: .string("A"))
        print("Updated: name = 'A'")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "true", "Single character name should satisfy length(name) > 0")
    }
    
    /// Test 20: Negative age
    /// Formula: and(age > 18, gender === 'Female')
    /// Expected: false
    func testDynamicUpdateNegativeAge() {
        print("\n🔀 Test 20: Negative age")
        print("Formula: and(age > 18, gender === 'Female')")
        
        documentEditor.updateValue(for: "gender", value: .string("Female"))
        documentEditor.updateValue(for: "age", value: .int(-5))
        print("Updated: age = -5, gender = Female")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "Negative age should fail age > 18 check")
    }
    
    /// Test 21: Very large age
    /// Formula: and(age > 18, gender === 'Female')
    /// Expected: true
    func testDynamicUpdateVeryLargeAge() {
        print("\n🔀 Test 21: Very large age")
        print("Formula: and(age > 18, gender === 'Female')")
        
        documentEditor.updateValue(for: "gender", value: .string("Female"))
        documentEditor.updateValue(for: "age", value: .int(150))
        print("Updated: age = 150, gender = Female")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "true", "Very large age should still pass age > 18")
    }
    
    /// Test 22: Whitespace-only name
    /// Formula: and(length(name) > 0, ...)
    /// Expected: true (length("   ") = 3 > 0)
    func testDynamicUpdateWhitespaceName() {
        print("\n🔀 Test 22: Whitespace-only name")
        print("Formula: and(length(name) > 0, ...)")
        
        documentEditor.updateValue(for: "country", value: .string("USA"))
        documentEditor.updateValue(for: "name", value: .string("   "))
        print("Updated: name = '   ' (3 spaces)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "true", "Whitespace name has length > 0")
    }
    
    /// Test 23: Clear gender after selection
    /// Formula: and(age > 18, gender === 'Female')
    /// Expected: false after clearing
    func testDynamicClearGenderAfterSelection() {
        print("\n🔀 Test 23: Clear gender after selection")
        print("Formula: and(age > 18, gender === 'Female')")
        
        // First select Female (makes formula true)
        documentEditor.updateValue(for: "gender", value: .string("Female"))
        var result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "true", "Should be true with Female selected")
        print("Step 1 - gender=Female: \(result?.text ?? "")")
        
        // Now clear the selection
        documentEditor.updateValue(for: "gender", value: .string(""))
        print("Step 2 - Cleared gender")
        
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "Should be false when gender is cleared")
    }
    
    /// Test 24: Clear country after selection
    /// Formula: and(..., or(country === 'USA', country === 'Canada'), ...)
    /// Expected: false after clearing
    func testDynamicClearCountryAfterSelection() {
        print("\n🔀 Test 24: Clear country after selection")
        print("Formula: and(..., or(country === 'USA', country === 'Canada'), ...)")
        
        documentEditor.updateValue(for: "country", value: .string("USA"))
        var result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        XCTAssertEqual(result?.text ?? "", "true", "Should be true with USA selected")
        print("Step 1 - country=USA: \(result?.text ?? "")")
        
        // Clear country selection
        documentEditor.updateValue(for: "country", value: .string(""))
        print("Step 2 - Cleared country")
        
        result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "Should be false when country is cleared")
    }
    
    /// Test 25: Toggle hasVoted multiple times
    /// Formula: and(..., not(hasVoted))
    /// Expected: formula changes as hasVoted toggles
    func testDynamicToggleHasVotedMultipleTimes() {
        print("\n🔀 Test 25: Toggle hasVoted multiple times")
        print("Formula: and(..., not(hasVoted))")
        
        documentEditor.updateValue(for: "country", value: .string("USA"))
        
        // Step 1: hasVoted = false (initial) → formula = true
        var result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        XCTAssertEqual(result?.text ?? "", "true", "Step 1: hasVoted=false, formula=true")
        print("Step 1 - hasVoted=false: \(result?.text ?? "")")
        
        // Step 2: hasVoted = true → formula = false
        documentEditor.updateValue(for: "hasVoted", value: .bool(true))
        result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        XCTAssertEqual(result?.text ?? "", "false", "Step 2: hasVoted=true, formula=false")
        print("Step 2 - hasVoted=true: \(result?.text ?? "")")
        
        // Step 3: hasVoted = false again → formula = true
        documentEditor.updateValue(for: "hasVoted", value: .bool(false))
        result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        XCTAssertEqual(result?.text ?? "", "true", "Step 3: hasVoted=false again, formula=true")
        print("Step 3 - hasVoted=false: \(result?.text ?? "")")
        
        print("✅ Toggle test completed")
    }
    
    /// Test 26: All conditions fail simultaneously
    /// Formula: and(length(name) > 0, age >= 18, or(country === 'USA', country === 'Canada'), not(hasVoted))
    /// Expected: false
    func testDynamicAllConditionsFail() {
        print("\n🔀 Test 26: All conditions fail simultaneously")
        print("Formula: and(length(name) > 0, age >= 18, or(country === 'USA', country === 'Canada'), not(hasVoted))")
        
        documentEditor.updateValue(for: "name", value: .string(""))            // length = 0
        documentEditor.updateValue(for: "age", value: .int(10))                // age < 18
        documentEditor.updateValue(for: "country", value: .string("Other"))    // not USA/Canada
        documentEditor.updateValue(for: "hasVoted", value: .bool(true))        // not(true) = false
        print("Updated: name='', age=10, country=Other, hasVoted=true")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "All conditions failing should return false")
    }
    
    /// Test 27: Age exactly at boundary for advanced (>= 18)
    /// Already covered in Test 16, but testing with all other conditions false
    /// Formula: and(..., age >= 18, ...)
    /// Expected: false (other conditions fail)
    func testDynamicAgeBoundaryWithOtherFailures() {
        print("\n🔀 Test 27: Age at boundary with other failures")
        print("Formula: and(..., age >= 18, ...)")
        
        documentEditor.updateValue(for: "age", value: .int(18))
        documentEditor.updateValue(for: "country", value: .string("Other"))  // Fails or condition
        print("Updated: age=18, country=Other")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "Even with age >= 18, other conditions can make it fail")
    }
    
    /// Test 28: Zero age
    /// Formula: and(age > 18, gender === 'Female')
    /// Expected: false
    func testDynamicUpdateZeroAge() {
        print("\n🔀 Test 28: Zero age")
        print("Formula: and(age > 18, gender === 'Female')")
        
        documentEditor.updateValue(for: "gender", value: .string("Female"))
        documentEditor.updateValue(for: "age", value: .int(0))
        print("Updated: age = 0, gender = Female")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "Zero age should fail age > 18 check")
    }
}

