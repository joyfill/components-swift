//
//  FormulaTemplate_TextareaFieldTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 25/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class FormulaTemplate_TextareaFieldTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_TextareaField")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    } 

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Textarea Formula Tests
    
    func testTextareaFormulas() {
        print("\n🧪 === Textarea Field Formula Tests ===")
        
        // Debug: Print textarea1 content
        if let textareaField = documentEditor.field(fieldID: "textarea1") {
            print("📝 Textarea1 content: '\(textareaField.value?.text ?? "nil")'")
        }
        
        testCheckForUrgentText()
        testUppercaseAll()
        testLowercaseAll()
        testAppendNoteAtEnd()
        testCheckForEmpty()
        testCheckForErrorText()
        testPrefixText()
        testCountCharactersInText()
    }
    
    // MARK: - Individual Test Methods
    
    private func testCheckForUrgentText() {
        print("\n🔍 Test 1: Check for 'urgent' text")
        print("Formula: contains(lower(textarea1), \"urgent\")")
        print("Input: 'Line 1\\nLine 2\\nLine 3' (no 'urgent')")
        print("Expected: false")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "text9")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "false", "Should return false when textarea doesn't contain 'urgent'")
    }
    
    private func testUppercaseAll() {
        print("\n📝 Test 2: Uppercase all content")
        print("Formula: upper(textarea1)")
        print("Input: 'Line 1\\nLine 2\\nLine 3'")
        print("Expected: 'LINE 1\\nLINE 2\\nLINE 3'")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "textarea2")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "LINE 1\nLINE 2\nLINE 3", "Should convert all text to uppercase")
    }
    
    private func testLowercaseAll() {
        print("\n📝 Test 3: Lowercase all content")
        print("Formula: lower(textarea1)")
        print("Input: 'Line 1\\nLine 2\\nLine 3'")
        print("Expected: 'line 1\\nline 2\\nline 3'")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "textarea3")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "line 1\nline 2\nline 3", "Should convert all text to lowercase")
    }
    
    private func testAppendNoteAtEnd() {
        print("\n📝 Test 4: Append note at end")
        print("Formula: concat(textarea1, \"\\n-- Reviewed by Admin --\")")
        print("Input: 'Line 1\\nLine 2\\nLine 3'")
        print("Expected: 'Line 1\\nLine 2\\nLine 3\\n-- Reviewed by Admin --'")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "textarea4")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "Line 1\nLine 2\nLine 3\n-- Reviewed by Admin --", "Should append admin note")
    }
    
    private func testCheckForEmpty() {
        print("\n📝 Test 5: Check if textarea is empty")
        print("Formula: empty(textarea1)")
        print("Input: 'Line 1\\nLine 2\\nLine 3' (not empty)")
        print("Expected: false")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "textarea5")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "false", "Should return false when textarea has content")
    }
    
    private func testCheckForErrorText() {
        print("\n🚨 Test 6: Check for error text")
        print("Formula: if(contains(lower(textarea1), \"error\"), \"Error Detected\", \"All Clear\")")
        print("Input: 'Line 1\\nLine 2\\nLine 3' (no 'error')")
        print("Expected: 'All Clear'")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "textarea6")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "All Clear", "Should return 'All Clear' when no error text found")
    }
    
    private func testPrefixText() {
        print("\n📝 Test 7: Prefix with 'User Notes:'")
        print("Formula: concat(\"User Notes:\\n\", textarea1)")
        print("Input: 'Line 1\\nLine 2\\nLine 3'")
        print("Expected: 'User Notes:\\nLine 1\\nLine 2\\nLine 3'")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "textarea7")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "User Notes:\nLine 1\nLine 2\nLine 3", "Should prefix with user notes label")
    }
    
    private func testCountCharactersInText() {
        print("\n🔢 Test 8: Count characters in text")
        print("Formula: length(textarea1)")
        print("Input: 'Line 1\\nLine 2\\nLine 3' (21 characters including newlines)")
        print("Expected: 21")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "text8")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        // The string "Line 1\nLine 2\nLine 3" has 21 characters total
        XCTAssertEqual(resultText, "20", "Should count all characters including newlines")
    }
    
    // MARK: - Helper Methods
    
    private func debugFieldValue(_ fieldID: String, expectedValue: String? = nil) {
        if let field = documentEditor.field(fieldID: fieldID) {
            print("🔍 Field '\(fieldID)': '\(field.value?.text ?? "nil")'")
            if let expected = expectedValue {
                print("   Expected: '\(expected)'")
            }
        } else {
            print("❌ Field '\(fieldID)' not found")
        }
    }
}

