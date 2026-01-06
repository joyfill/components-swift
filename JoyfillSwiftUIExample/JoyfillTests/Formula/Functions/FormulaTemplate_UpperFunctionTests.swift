//
//  upperTests.swift
//  JoyfillTests
//
//  Created on 26/11/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

/// Tests for the `upper()` formula function
/// The upper() function converts a string to uppercase.
/// Syntax: upper(string)
class upperTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "upper")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Static Evaluation Tests
    
    /// Test 1: Basic upper() with lowercase string
    /// Formula: upper("joy")
    /// Expected: "JOY"
    func testUpperSimpleLowercase() {
        print("\n🔀 Test 1: upper() with lowercase string")
        print("Formula: upper(\"joy\")")
        print("Expected: JOY")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "basic_example_simple")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "JOY", "upper(\"joy\") should return 'JOY'")
    }
    
    /// Test 2: Basic upper() with mixed case string
    /// Formula: upper("Joyfill")
    /// Expected: "JOYFILL"
    func testUpperMixedCase() {
        print("\n🔀 Test 2: upper() with mixed case string")
        print("Formula: upper(\"Joyfill\")")
        print("Expected: JOYFILL")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "basic_example_mixed")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "JOYFILL", "upper(\"Joyfill\") should return 'JOYFILL'")
    }
    
    /// Test 3: Intermediate upper() with field reference
    /// Formula: upper(firstName)
    /// Initial: firstName = "John"
    /// Expected: "JOHN"
    func testUpperWithFieldReference() {
        print("\n🔀 Test 3: upper() with field reference")
        print("Formula: upper(firstName)")
        print("Initial: firstName = 'John'")
        print("Expected: JOHN")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_field")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "JOHN", "upper(firstName) should return 'JOHN'")
    }
    
    /// Test 4: Intermediate upper() with concat
    /// Formula: concat(upper(firstName), " ", upper(lastName))
    /// Initial: firstName = "John", lastName = "Doe"
    /// Expected: "JOHN DOE"
    func testUpperWithConcat() {
        print("\n🔀 Test 4: upper() with concat")
        print("Formula: concat(upper(firstName), \" \", upper(lastName))")
        print("Initial: firstName = 'John', lastName = 'Doe'")
        print("Expected: JOHN DOE")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_concat")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "JOHN DOE", "concat(upper(firstName), \" \", upper(lastName)) should return 'JOHN DOE'")
    }
    
    /// Test 5: Verify initial field values
    func testInitialFieldValues() {
        print("\n🔀 Test 5: Verify initial field values")
        
        let firstName = documentEditor.value(ofFieldWithIdentifier: "firstName")?.text ?? ""
        let lastName = documentEditor.value(ofFieldWithIdentifier: "lastName")?.text ?? ""
        let userInput = documentEditor.value(ofFieldWithIdentifier: "userInput")?.text ?? ""
        let searchTerm = documentEditor.value(ofFieldWithIdentifier: "searchTerm")?.text ?? ""
        
        print("📊 firstName = '\(firstName)'")
        print("📊 lastName = '\(lastName)'")
        print("📊 userInput = '\(userInput)'")
        print("📊 searchTerm = '\(searchTerm)'")
        
        XCTAssertEqual(firstName, "John", "firstName should be 'John'")
        XCTAssertEqual(lastName, "Doe", "lastName should be 'Doe'")
        XCTAssertEqual(userInput, "This is a sample text with Joy in it", "userInput should be correct")
        XCTAssertEqual(searchTerm, "joy", "searchTerm should be 'joy'")
    }
    
    /// Test 6: Advanced upper() for case-insensitive search
    /// Formula: if(contains(upper(userInput), upper(searchTerm)), concat("Found match for: ", searchTerm), "No match found")
    /// Initial: userInput = "This is a sample text with Joy in it", searchTerm = "joy"
    /// Expected: "Found match for: joy"
    func testAdvancedUpperCaseInsensitiveSearch() {
        print("\n🔀 Test 6: Advanced upper() for case-insensitive search")
        print("Formula: if(contains(upper(userInput), upper(searchTerm)), ...)")
        print("Initial: userInput contains 'Joy', searchTerm = 'joy'")
        print("Expected: Found match for: joy")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "Found match for: joy", "Should find 'joy' in 'Joy' using upper()")
    }
    
    // MARK: - Dynamic Update Tests
    
    /// Test 7: Dynamic update - change firstName
    /// Formula: upper(firstName)
    /// Update: firstName = "jane"
    /// Expected: "JANE"
    func testDynamicUpdateFirstName() {
        print("\n🔀 Test 7: Dynamic update - change firstName")
        print("Formula: upper(firstName)")
        
        // Initial: "JOHN"
        var result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_field")
        XCTAssertEqual(result?.text ?? "", "JOHN", "Initial should be 'JOHN'")
        
        // Update firstName
        documentEditor.updateValue(for: "firstName", value: .string("jane"))
        print("Updated: firstName = 'jane'")
        
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_field")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "JANE", "upper('jane') should return 'JANE'")
    }
    
    /// Test 8: Dynamic update - change lastName
    /// Formula: concat(upper(firstName), " ", upper(lastName))
    /// Update: lastName = "smith"
    /// Expected: "JOHN SMITH"
    func testDynamicUpdateLastName() {
        print("\n🔀 Test 8: Dynamic update - change lastName")
        print("Formula: concat(upper(firstName), \" \", upper(lastName))")
        
        documentEditor.updateValue(for: "lastName", value: .string("smith"))
        print("Updated: lastName = 'smith'")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_concat")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "JOHN SMITH", "Should be 'JOHN SMITH'")
    }
    
    /// Test 9: Dynamic update - change both names
    /// Formula: concat(upper(firstName), " ", upper(lastName))
    /// Update: firstName = "alice", lastName = "wonderland"
    /// Expected: "ALICE WONDERLAND"
    func testDynamicUpdateBothNames() {
        print("\n🔀 Test 9: Dynamic update - change both names")
        print("Formula: concat(upper(firstName), \" \", upper(lastName))")
        
        documentEditor.updateValue(for: "firstName", value: .string("alice"))
        documentEditor.updateValue(for: "lastName", value: .string("wonderland"))
        print("Updated: firstName = 'alice', lastName = 'wonderland'")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_concat")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "ALICE WONDERLAND", "Should be 'ALICE WONDERLAND'")
    }
    
    /// Test 10: Dynamic update - searchTerm not found
    /// Formula: if(contains(upper(userInput), upper(searchTerm)), ...)
    /// Update: searchTerm = "xyz"
    /// Expected: "No match found"
    func testDynamicUpdateSearchNotFound() {
        print("\n🔀 Test 10: Dynamic update - search term not found")
        print("Formula: if(contains(upper(userInput), upper(searchTerm)), ...)")
        
        // Initial: "Found match for: joy"
        var result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        XCTAssertEqual(result?.text ?? "", "Found match for: joy", "Initial should find match")
        
        // Update searchTerm to something not in userInput
        documentEditor.updateValue(for: "searchTerm", value: .string("xyz"))
        print("Updated: searchTerm = 'xyz'")
        
        result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "No match found", "Should not find 'xyz'")
    }
    
    /// Test 11: Dynamic update - search with different case
    /// Formula: if(contains(upper(userInput), upper(searchTerm)), ...)
    /// Update: searchTerm = "SAMPLE"
    /// Expected: "Found match for: SAMPLE"
    func testDynamicUpdateSearchDifferentCase() {
        print("\n🔀 Test 11: Dynamic update - search with uppercase term")
        print("Formula: if(contains(upper(userInput), upper(searchTerm)), ...)")
        
        documentEditor.updateValue(for: "searchTerm", value: .string("SAMPLE"))
        print("Updated: searchTerm = 'SAMPLE'")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "advanced_example")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "Found match for: SAMPLE", "Should find 'SAMPLE' in 'sample'")
    }
    
    /// Test 12: Dynamic update - empty firstName
    func testDynamicUpdateEmptyFirstName() {
        print("\n🔀 Test 12: Dynamic update - empty firstName")
        print("Formula: upper(firstName)")
        
        documentEditor.updateValue(for: "firstName", value: .string(""))
        print("Updated: firstName = '' (empty)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_field")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "", "upper('') should return ''")
    }
    
    /// Test 13: Dynamic update - already uppercase
    func testDynamicUpdateAlreadyUppercase() {
        print("\n🔀 Test 13: Dynamic update - already uppercase")
        print("Formula: upper(firstName)")
        
        documentEditor.updateValue(for: "firstName", value: .string("MARY"))
        print("Updated: firstName = 'MARY'")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_field")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "MARY", "upper('MARY') should return 'MARY'")
    }
    
    /// Test 14: Sequence test - firstName variations
    func testDynamicUpdateSequence() {
        print("\n🔀 Test 14: Dynamic update sequence")
        print("Formula: upper(firstName)")
        
        var result: ValueUnion?
        
        // Step 1: Initial
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_field")
        XCTAssertEqual(result?.text ?? "", "JOHN", "Step 1: Initial")
        print("Step 1 - 'John': \(result?.text ?? "")")
        
        // Step 2: lowercase
        documentEditor.updateValue(for: "firstName", value: .string("bob"))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_field")
        XCTAssertEqual(result?.text ?? "", "BOB", "Step 2: lowercase")
        print("Step 2 - 'bob': \(result?.text ?? "")")
        
        // Step 3: mixed case
        documentEditor.updateValue(for: "firstName", value: .string("cArOl"))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_field")
        XCTAssertEqual(result?.text ?? "", "CAROL", "Step 3: mixed case")
        print("Step 3 - 'cArOl': \(result?.text ?? "")")
        
        // Step 4: with spaces
        documentEditor.updateValue(for: "firstName", value: .string("mary jane"))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_field")
        XCTAssertEqual(result?.text ?? "", "MARY JANE", "Step 4: with spaces")
        print("Step 4 - 'mary jane': \(result?.text ?? "")")
        
        // Step 5: with numbers
        documentEditor.updateValue(for: "firstName", value: .string("john123"))
        result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_field")
        XCTAssertEqual(result?.text ?? "", "JOHN123", "Step 5: with numbers")
        print("Step 5 - 'john123': \(result?.text ?? "")")
        
        print("✅ Sequence test completed")
    }
    
    /// Test 15: Unicode handling
    func testUpperUnicode() {
        print("\n🔀 Test 15: Unicode handling")
        print("Formula: upper(firstName)")
        
        documentEditor.updateValue(for: "firstName", value: .string("josé"))
        print("Updated: firstName = 'josé'")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_field")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "JOSÉ", "upper('josé') should return 'JOSÉ'")
    }
    
    /// Test 16: Special characters preserved
    func testUpperSpecialCharacters() {
        print("\n🔀 Test 16: Special characters preserved")
        print("Formula: upper(firstName)")
        
        documentEditor.updateValue(for: "firstName", value: .string("o'brien"))
        print("Updated: firstName = \"o'brien\"")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example_field")
        let resultText = result?.text ?? ""
        print("🎯 Result: \(resultText)")
        
        XCTAssertEqual(resultText, "O'BRIEN", "upper(\"o'brien\") should return \"O'BRIEN\"")
    }
}

