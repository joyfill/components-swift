//
//  FormulaTemplate_NotFunctionTests.swift
//  JoyfillTests
//
//  Created on 26/11/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

/// Tests for the `not()` formula function
/// The not() function returns the logical negation of a boolean value.
/// - not(true) returns false
/// - not(false) returns true
/// Syntax: not(condition)
class FormulaTemplate_NotFunctionTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_NotFunction")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Static Evaluation Tests
    
    /// Test 1: Basic not() with true literal
    /// Formula: not(true)
    /// Expected: false
    func testNotWithTrue() {
        print("\n🔀 Test 1: not() with true")
        print("Formula: not(true)")
        print("Expected: false")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "basic_example_true")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "not(true) should return 'false'")
    }
    
    /// Test 2: Basic not() with false literal
    /// Formula: not(false)
    /// Expected: true
    func testNotWithFalse() {
        print("\n🔀 Test 2: not() with false")
        print("Formula: not(false)")
        print("Expected: true")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "basic_example_false")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "true", "not(false) should return 'true'")
    }
    
    /// Test 3: Intermediate not() with field comparison
    /// Formula: not(age < 18)
    /// Initial: age = 15
    /// Expected: false (15 < 18 is true, so not(true) = false)
    func testNotWithFieldComparison_InitialState() {
        print("\n🔀 Test 3: not() with field comparison (initial)")
        print("Formula: not(age < 18)")
        print("Initial: age = 15")
        print("Expected: false (15 < 18 is true, so not(true) = false)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "not(15 < 18) should return 'false'")
    }
    
    /// Test 4: Advanced not() with nested functions
    /// Formula: not(and(status == 'Active', or(country == 'USA', country == 'Canada'), age >= 18))
    /// Initial: age = 15, status = nil, country = nil
    /// Expected: true (and() returns false with no selections, so not(false) = true)
    func testAdvancedNotWithNestedFunctions_InitialState() {
        print("\n🔀 Test 4: Advanced not() with nested functions (initial)")
        print("Formula: not(and(status == 'Active', or(country == 'USA', country == 'Canada'), age >= 18))")
        print("Initial: age = 15, status = nil, country = nil")
        print("Expected: true (and() fails on all conditions)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "true", "not(and(...)) should return 'true' when and() is false")
    }
    
    /// Test 5: Verify initial field values
    func testInitialFieldValues() {
        print("\n🔀 Test 5: Verify initial field values")
        
        let age = documentEditor.value(ofFieldWithIdentifier: "age")?.number ?? -1
        print("📊 age = \(age)")
        
        XCTAssertEqual(age, 15.0, "Age should be 15")
    }
    
    // MARK: - Dynamic Update Tests
    
    /// Test 6: Dynamic update - age to 18 or above
    /// Formula: not(age < 18)
    /// Update: age = 18
    /// Expected: true (18 < 18 is false, so not(false) = true)
    func testDynamicUpdateAgeAtBoundary() {
        print("\n🔀 Test 6: Dynamic update - age at boundary 18")
        print("Formula: not(age < 18)")
        
        // Initial: false (15 < 18 is true)
        var result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "false", "Initial should be false")
        
        // Update age to 18
        documentEditor.updateValue(for: "age", value: .int(18))
        print("Updated: age = 18")
        
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "true", "not(18 < 18) should return 'true' (18 is NOT < 18)")
    }
    
    /// Test 7: Dynamic update - age above 18
    /// Formula: not(age < 18)
    /// Update: age = 25
    /// Expected: true (25 < 18 is false, so not(false) = true)
    func testDynamicUpdateAgeAboveBoundary() {
        print("\n🔀 Test 7: Dynamic update - age above 18")
        print("Formula: not(age < 18)")
        
        documentEditor.updateValue(for: "age", value: .int(25))
        print("Updated: age = 25")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "true", "not(25 < 18) should return 'true'")
    }
    
    /// Test 8: Dynamic update - age just below boundary
    /// Formula: not(age < 18)
    /// Update: age = 17
    /// Expected: false (17 < 18 is true, so not(true) = false)
    func testDynamicUpdateAgeJustBelowBoundary() {
        print("\n🔀 Test 8: Dynamic update - age just below 18")
        print("Formula: not(age < 18)")
        
        documentEditor.updateValue(for: "age", value: .int(17))
        print("Updated: age = 17")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "not(17 < 18) should return 'false'")
    }
    
    /// Test 9: Dynamic update - make advanced example false (all conditions true)
    /// Formula: not(and(status == 'Active', or(country == 'USA', country == 'Canada'), age >= 18))
    /// Update: status = Active, country = USA, age = 21
    /// Expected: false (all and() conditions true, so not(true) = false)
    func testDynamicUpdateAdvancedToFalse() {
        print("\n🔀 Test 9: Dynamic update - advanced example to false")
        print("Formula: not(and(status == 'Active', or(country == 'USA', country == 'Canada'), age >= 18))")
        
        // Initial: true (and() fails)
        var result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        XCTAssertEqual(result?.text ?? "", "true", "Initial should be true")
        
        // Set all conditions to make and() true
        documentEditor.updateValue(for: "status", value: .string("Active"))
        documentEditor.updateValue(for: "country", value: .string("USA"))
        documentEditor.updateValue(for: "age", value: .int(21))
        print("Updated: status = Active, country = USA, age = 21")
        
        result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "not(and(true, true, true)) should return 'false'")
    }
    
    /// Test 10: Dynamic update - with Canada instead of USA
    /// Formula: not(and(status == 'Active', or(country == 'USA', country == 'Canada'), age >= 18))
    /// Update: status = Active, country = Canada, age = 21
    /// Expected: false (Canada satisfies or(), so and() is true, not(true) = false)
    func testDynamicUpdateAdvancedWithCanada() {
        print("\n🔀 Test 10: Dynamic update - advanced with Canada")
        print("Formula: ...or(country == 'USA', country == 'Canada')...")
        
        documentEditor.updateValue(for: "status", value: .string("Active"))
        documentEditor.updateValue(for: "country", value: .string("Canada"))
        documentEditor.updateValue(for: "age", value: .int(21))
        print("Updated: status = Active, country = Canada, age = 21")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "Canada should satisfy or(), making not(and(...)) = false")
    }
    
    /// Test 11: Dynamic update - country = Other breaks and()
    /// Formula: not(and(status == 'Active', or(country == 'USA', country == 'Canada'), age >= 18))
    /// Update: status = Active, country = Other, age = 21
    /// Expected: true (or() fails, so and() is false, not(false) = true)
    func testDynamicUpdateAdvancedWithOtherCountry() {
        print("\n🔀 Test 11: Dynamic update - country = Other")
        print("Formula: ...or(country == 'USA', country == 'Canada')...")
        
        documentEditor.updateValue(for: "status", value: .string("Active"))
        documentEditor.updateValue(for: "country", value: .string("Other"))
        documentEditor.updateValue(for: "age", value: .int(21))
        print("Updated: status = Active, country = Other, age = 21")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "true", "Other doesn't match, and() fails, not(false) = true")
    }
    
    /// Test 12: Dynamic update - status = Inactive breaks and()
    /// Formula: not(and(status == 'Active', or(country == 'USA', country == 'Canada'), age >= 18))
    /// Update: status = Inactive, country = USA, age = 21
    /// Expected: true (status condition fails, so and() is false, not(false) = true)
    func testDynamicUpdateAdvancedWithInactiveStatus() {
        print("\n🔀 Test 12: Dynamic update - status = Inactive")
        print("Formula: ...status == 'Active'...")
        
        documentEditor.updateValue(for: "status", value: .string("Inactive"))
        documentEditor.updateValue(for: "country", value: .string("USA"))
        documentEditor.updateValue(for: "age", value: .int(21))
        print("Updated: status = Inactive, country = USA, age = 21")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "true", "Inactive != Active, and() fails, not(false) = true")
    }
    
    /// Test 13: Dynamic update - age < 18 breaks and()
    /// Formula: not(and(status == 'Active', or(country == 'USA', country == 'Canada'), age >= 18))
    /// Update: status = Active, country = USA, age = 17
    /// Expected: true (age condition fails, so and() is false, not(false) = true)
    func testDynamicUpdateAdvancedWithAgeBelowThreshold() {
        print("\n🔀 Test 13: Dynamic update - age < 18 in advanced")
        print("Formula: ...age >= 18...")
        
        documentEditor.updateValue(for: "status", value: .string("Active"))
        documentEditor.updateValue(for: "country", value: .string("USA"))
        documentEditor.updateValue(for: "age", value: .int(17))
        print("Updated: status = Active, country = USA, age = 17")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "true", "17 < 18, and() fails, not(false) = true")
    }
    
    /// Test 14: Dynamic update - age at boundary 18 in advanced
    /// Formula: not(and(status == 'Active', or(country == 'USA', country == 'Canada'), age >= 18))
    /// Update: status = Active, country = USA, age = 18
    /// Expected: false (18 >= 18, so and() is true, not(true) = false)
    func testDynamicUpdateAdvancedAgeBoundary18() {
        print("\n🔀 Test 14: Dynamic update - age = 18 in advanced (>= check)")
        print("Formula: ...age >= 18...")
        
        documentEditor.updateValue(for: "status", value: .string("Active"))
        documentEditor.updateValue(for: "country", value: .string("USA"))
        documentEditor.updateValue(for: "age", value: .int(18))
        print("Updated: status = Active, country = USA, age = 18")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "false", "18 >= 18, and() passes, not(true) = false")
    }
    
    /// Test 15: Sequence test - toggle between true/false
    func testDynamicUpdateSequence() {
        print("\n🔀 Test 15: Dynamic update sequence")
        print("Formula: not(age < 18)")
        
        var result: ValueUnion?
        
        // Step 1: Initial state - age = 15 (false)
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "false", "Step 1: Initial state (age=15)")
        print("Step 1 - age=15: \(result?.text ?? "")")
        
        // Step 2: Set age to 20 (true)
        documentEditor.updateValue(for: "age", value: .int(20))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "true", "Step 2: age=20")
        print("Step 2 - age=20: \(result?.text ?? "")")
        
        // Step 3: Set age to 10 (false)
        documentEditor.updateValue(for: "age", value: .int(10))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "false", "Step 3: age=10")
        print("Step 3 - age=10: \(result?.text ?? "")")
        
        // Step 4: Set age to exactly 18 (true - boundary)
        documentEditor.updateValue(for: "age", value: .int(18))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "true", "Step 4: age=18 (boundary)")
        print("Step 4 - age=18: \(result?.text ?? "")")
        
        // Step 5: Set age to 17 (false)
        documentEditor.updateValue(for: "age", value: .int(17))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "false", "Step 5: age=17")
        print("Step 5 - age=17: \(result?.text ?? "")")
        
        print("✅ Sequence test completed")
    }
    
    /// Test 16: Sequence test for advanced formula
    func testAdvancedSequenceTest() {
        print("\n🔀 Test 16: Advanced sequence test")
        print("Formula: not(and(status == 'Active', or(country == 'USA', country == 'Canada'), age >= 18))")
        
        var result: ValueUnion?
        
        // Step 1: Initial state (true - and fails)
        result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        XCTAssertEqual(result?.text ?? "", "true", "Step 1: Initial state")
        print("Step 1 - Initial: \(result?.text ?? "")")
        
        // Step 2: Set age to 21 (still true - status/country not set)
        documentEditor.updateValue(for: "age", value: .int(21))
        result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        XCTAssertEqual(result?.text ?? "", "true", "Step 2: age=21 only")
        print("Step 2 - age=21: \(result?.text ?? "")")
        
        // Step 3: Set status to Active (still true - country not set)
        documentEditor.updateValue(for: "status", value: .string("Active"))
        result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        XCTAssertEqual(result?.text ?? "", "true", "Step 3: age=21, status=Active")
        print("Step 3 - status=Active: \(result?.text ?? "")")
        
        // Step 4: Set country to USA (false - all conditions now pass)
        documentEditor.updateValue(for: "country", value: .string("USA"))
        result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        XCTAssertEqual(result?.text ?? "", "false", "Step 4: All conditions met")
        print("Step 4 - country=USA: \(result?.text ?? "")")
        
        // Step 5: Change status to Pending (true - status fails)
        documentEditor.updateValue(for: "status", value: .string("Pending"))
        result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        XCTAssertEqual(result?.text ?? "", "true", "Step 5: status=Pending")
        print("Step 5 - status=Pending: \(result?.text ?? "")")
        
        // Step 6: Change status back to Active (false again)
        documentEditor.updateValue(for: "status", value: .string("Active"))
        result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        XCTAssertEqual(result?.text ?? "", "false", "Step 6: status=Active again")
        print("Step 6 - status=Active: \(result?.text ?? "")")
        
        print("✅ Advanced sequence test completed")
    }
}

