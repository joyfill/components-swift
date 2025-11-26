//
//  FormulaTemplate_ConcatFunctionTests.swift
//  JoyfillTests
//
//  Created on 26/11/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

/// Tests for the `concat()` formula function
/// The concat() function concatenates strings, arrays, or field values together.
/// Syntax: concat(value1, value2, ...)
class FormulaTemplate_ConcatFunctionTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_ConcatFunction")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Static Evaluation Tests
    
    /// Test 1: Basic concat() with two strings
    /// Formula: concat("joy", "fill")
    /// Expected: "joyfill"
    func testConcatTwoStrings() {
        print("\n🔀 Test 1: concat() with two strings")
        print("Formula: concat(\"joy\", \"fill\")")
        print("Expected: joyfill")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "basic_example_strings")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "joyfill", "concat(\"joy\", \"fill\") should return 'joyfill'")
    }
    
    /// Test 2: Basic concat() with multiple strings and spaces
    /// Formula: concat("joy", " ", "fill", " ", "rocks")
    /// Expected: "joy fill rocks"
    func testConcatMultipleStrings() {
        print("\n🔀 Test 2: concat() with multiple strings")
        print("Formula: concat(\"joy\", \" \", \"fill\", \" \", \"rocks\")")
        print("Expected: joy fill rocks")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "basic_example_multiple")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "joy fill rocks", "concat with multiple args should return 'joy fill rocks'")
    }
    
    /// Test 3: Intermediate concat() with arrays
    /// Formula: concat([1, 2], [3, 4])
    /// Expected: Array concatenation result (format may vary)
    func testConcatArrays() {
        print("\n🔀 Test 3: concat() with arrays")
        print("Formula: concat([1, 2], [3, 4])")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_arrays")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        // Array concatenation might produce different formats
        // Check that it contains the expected numbers
        XCTAssertTrue(
            resultText.contains("1") && resultText.contains("2") && 
            resultText.contains("3") && resultText.contains("4"),
            "concat([1, 2], [3, 4]) should contain all numbers"
        )
    }
    
    /// Test 4: Intermediate concat() with field references
    /// Formula: concat("User: ", userName, " (", userRole, ")")
    /// Initial: userName = "John", userRole = "Admin"
    /// Expected: "User: John (Admin)"
    func testConcatWithFieldReferences() {
        print("\n🔀 Test 4: concat() with field references")
        print("Formula: concat(\"User: \", userName, \" (\", userRole, \")\")")
        print("Initial: userName = John, userRole = Admin")
        print("Expected: User: John (Admin)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_fields")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "User: John (Admin)", "Should concatenate field values correctly")
    }
    
    /// Test 5: Verify initial field values
    func testInitialFieldValues() {
        print("\n🔀 Test 5: Verify initial field values")
        
        let userName = documentEditor.value(ofFieldWithIdentifier: "userName")?.text ?? ""
        let userRole = documentEditor.value(ofFieldWithIdentifier: "userRole")?.text ?? ""
        
        print("📊 userName = '\(userName)'")
        print("📊 userRole = '\(userRole)'")
        
        XCTAssertEqual(userName, "John", "userName should be 'John'")
        XCTAssertEqual(userRole, "Admin", "userRole should be 'Admin'")
    }
    
    /// Test 6: Advanced concat() with date and conditionals (no items selected)
    /// Formula: concat("Report for ", date(...), ": ", if(empty(selectedItems), "No items selected", ...))
    /// Initial: selectedItems = empty
    /// Expected: "Report for <date>: No items selected"
    func testAdvancedConcatNoItemsSelected() {
        print("\n🔀 Test 6: Advanced concat() - no items selected")
        print("Formula: concat(\"Report for \", date(...), \": \", if(empty(selectedItems), \"No items selected\", ...))")
        print("Initial: selectedItems = (empty)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        // Check that it starts with "Report for" and ends with "No items selected"
        XCTAssertTrue(resultText.hasPrefix("Report for "), "Should start with 'Report for '")
        XCTAssertTrue(resultText.hasSuffix("No items selected"), "Should end with 'No items selected' when no items")
    }
    
    // MARK: - Dynamic Update Tests
    
    /// Test 7: Dynamic update - change userName
    /// Formula: concat("User: ", userName, " (", userRole, ")")
    /// Update: userName = "Jane"
    /// Expected: "User: Jane (Admin)"
    func testDynamicUpdateUserName() {
        print("\n🔀 Test 7: Dynamic update - change userName")
        print("Formula: concat(\"User: \", userName, \" (\", userRole, \")\")")
        
        // Initial: "User: John (Admin)"
        var result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_fields")
        XCTAssertEqual(result?.text ?? "", "User: John (Admin)", "Initial should be 'User: John (Admin)'")
        
        // Update userName to "Jane"
        documentEditor.updateValue(for: "userName", value: .string("Jane"))
        print("Updated: userName = Jane")
        
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_fields")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "User: Jane (Admin)", "Should update to 'User: Jane (Admin)'")
    }
    
    /// Test 8: Dynamic update - change userRole
    /// Formula: concat("User: ", userName, " (", userRole, ")")
    /// Update: userRole = "Editor"
    /// Expected: "User: John (Editor)"
    func testDynamicUpdateUserRole() {
        print("\n🔀 Test 8: Dynamic update - change userRole")
        print("Formula: concat(\"User: \", userName, \" (\", userRole, \")\")")
        
        // Update userRole to "Editor"
        documentEditor.updateValue(for: "userRole", value: .string("Editor"))
        print("Updated: userRole = Editor")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_fields")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "User: John (Editor)", "Should update to 'User: John (Editor)'")
    }
    
    /// Test 9: Dynamic update - change both userName and userRole
    /// Formula: concat("User: ", userName, " (", userRole, ")")
    /// Update: userName = "Alice", userRole = "Viewer"
    /// Expected: "User: Alice (Viewer)"
    func testDynamicUpdateBothFields() {
        print("\n🔀 Test 9: Dynamic update - change both fields")
        print("Formula: concat(\"User: \", userName, \" (\", userRole, \")\")")
        
        documentEditor.updateValue(for: "userName", value: .string("Alice"))
        documentEditor.updateValue(for: "userRole", value: .string("Viewer"))
        print("Updated: userName = Alice, userRole = Viewer")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_fields")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "User: Alice (Viewer)", "Should update to 'User: Alice (Viewer)'")
    }
    
    /// Test 10: Dynamic update - empty userName
    /// Formula: concat("User: ", userName, " (", userRole, ")")
    /// Update: userName = ""
    /// Expected: "User:  (Admin)" (with space preserved)
    func testDynamicUpdateEmptyUserName() {
        print("\n🔀 Test 10: Dynamic update - empty userName")
        print("Formula: concat(\"User: \", userName, \" (\", userRole, \")\")")
        
        documentEditor.updateValue(for: "userName", value: .string(""))
        print("Updated: userName = '' (empty)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_fields")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "User:  (Admin)", "Empty userName should still concatenate")
    }
    
    /// Test 11: Dynamic update - special characters in userName
    /// Formula: concat("User: ", userName, " (", userRole, ")")
    /// Update: userName = "John O'Brien"
    /// Expected: "User: John O'Brien (Admin)"
    func testDynamicUpdateSpecialCharacters() {
        print("\n🔀 Test 11: Dynamic update - special characters")
        print("Formula: concat(\"User: \", userName, \" (\", userRole, \")\")")
        
        documentEditor.updateValue(for: "userName", value: .string("John O'Brien"))
        print("Updated: userName = John O'Brien")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_fields")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "User: John O'Brien (Admin)", "Special characters should be preserved")
    }
    
    /// Test 12: Dynamic update - Unicode in userName
    /// Formula: concat("User: ", userName, " (", userRole, ")")
    /// Update: userName = "José García"
    /// Expected: "User: José García (Admin)"
    func testDynamicUpdateUnicode() {
        print("\n🔀 Test 12: Dynamic update - Unicode characters")
        print("Formula: concat(\"User: \", userName, \" (\", userRole, \")\")")
        
        documentEditor.updateValue(for: "userName", value: .string("José García"))
        print("Updated: userName = José García")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_fields")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "User: José García (Admin)", "Unicode characters should be preserved")
    }
    
    /// Test 13: Sequence test - multiple updates
    func testDynamicUpdateSequence() {
        print("\n🔀 Test 13: Dynamic update sequence")
        print("Formula: concat(\"User: \", userName, \" (\", userRole, \")\")")
        
        var result: ValueUnion?
        
        // Step 1: Initial state
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_fields")
        XCTAssertEqual(result?.text ?? "", "User: John (Admin)", "Step 1: Initial state")
        print("Step 1 - Initial: \(result?.text ?? "")")
        
        // Step 2: Change userName
        documentEditor.updateValue(for: "userName", value: .string("Bob"))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_fields")
        XCTAssertEqual(result?.text ?? "", "User: Bob (Admin)", "Step 2: userName=Bob")
        print("Step 2 - userName=Bob: \(result?.text ?? "")")
        
        // Step 3: Change userRole
        documentEditor.updateValue(for: "userRole", value: .string("Manager"))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_fields")
        XCTAssertEqual(result?.text ?? "", "User: Bob (Manager)", "Step 3: userRole=Manager")
        print("Step 3 - userRole=Manager: \(result?.text ?? "")")
        
        // Step 4: Change both
        documentEditor.updateValue(for: "userName", value: .string("Carol"))
        documentEditor.updateValue(for: "userRole", value: .string("CEO"))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_fields")
        XCTAssertEqual(result?.text ?? "", "User: Carol (CEO)", "Step 4: Both changed")
        print("Step 4 - userName=Carol, userRole=CEO: \(result?.text ?? "")")
        
        // Step 5: Reset to original
        documentEditor.updateValue(for: "userName", value: .string("John"))
        documentEditor.updateValue(for: "userRole", value: .string("Admin"))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_fields")
        XCTAssertEqual(result?.text ?? "", "User: John (Admin)", "Step 5: Reset to original")
        print("Step 5 - Reset: \(result?.text ?? "")")
        
        print("✅ Sequence test completed")
    }
    
    /// Test 14: Long string concatenation
    func testConcatLongStrings() {
        print("\n🔀 Test 14: Long string concatenation")
        print("Formula: concat(\"User: \", userName, \" (\", userRole, \")\")")
        
        let longName = "Bartholomew Christopher Davidson III"
        let longRole = "Senior Vice President of Engineering Operations"
        
        documentEditor.updateValue(for: "userName", value: .string(longName))
        documentEditor.updateValue(for: "userRole", value: .string(longRole))
        print("Updated: userName = \(longName)")
        print("Updated: userRole = \(longRole)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_fields")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        let expected = "User: \(longName) (\(longRole))"
        XCTAssertEqual(resultText, expected, "Long strings should concatenate correctly")
    }
    
    /// Test 15: Whitespace handling
    func testConcatWhitespaceHandling() {
        print("\n🔀 Test 15: Whitespace handling")
        print("Formula: concat(\"User: \", userName, \" (\", userRole, \")\")")
        
        documentEditor.updateValue(for: "userName", value: .string("  John  "))
        documentEditor.updateValue(for: "userRole", value: .string("  Admin  "))
        print("Updated: userName = '  John  ', userRole = '  Admin  '")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_fields")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        // Whitespace should be preserved
        XCTAssertEqual(resultText, "User:   John   (  Admin  )", "Whitespace should be preserved")
    }
    
    /// Test 16: Numeric values in userName (coercion test)
    func testConcatNumericCoercion() {
        print("\n🔀 Test 16: Numeric value coercion")
        print("Formula: concat(\"User: \", userName, \" (\", userRole, \")\")")
        
        // Set userName to a numeric-like string
        documentEditor.updateValue(for: "userName", value: .string("12345"))
        print("Updated: userName = '12345'")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_fields")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "User: 12345 (Admin)", "Numeric strings should concatenate correctly")
    }
}

