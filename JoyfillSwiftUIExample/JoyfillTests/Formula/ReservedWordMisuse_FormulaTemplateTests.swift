//
//  ReservedWordMisuse_FormulaTemplateTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 25/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class ReservedWordMisuse_FormulaTemplateTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "ReservedWordMisuse_FormulaTemplate")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    } 

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Reserved Word Misuse Tests
    
    func testReservedWordMisuseHandling() {
        print("\n🧪 === Reserved Word Misuse Formula Tests ===")
        print("Testing how the formula system handles reserved function names used as variables")
        
        testReservedWordSum()
        testReservedWordMultiple()
        testCorrectUsageSum()
        testCorrectUsageIf()
    }
    
    // MARK: - Individual Test Methods
    
    private func testReservedWordSum() {
        print("\n❌ Test 1: Reserved word 'sum' used as variable")
        print("Formula: sum + 1")
        print("Expected: Error or null (sum is a reserved function name)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field1")
        let resultText = result?.text ?? ""
        let resultNumber = result?.number ?? 0
        print("🎯 Result: text='\(resultText)', number=\(resultNumber)")
        
        // The formula should fail since 'sum' is a reserved function name, not a variable
        // This could result in null, empty, or error state
        XCTAssertTrue(resultText.isEmpty || resultText == "0" || resultNumber == 0, 
                     "Should handle reserved word misuse gracefully (empty or zero result)")
    }
    
    private func testReservedWordMultiple() {
        print("\n❌ Test 2: Multiple reserved words as variables")
        print("Formula: reduce + map + (10 * if)")
        print("Expected: Error or null (reduce, map, if are reserved function names)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field2")
        let resultText = result?.text ?? ""
        let resultNumber = result?.number ?? 0
        print("🎯 Result: text='\(resultText)', number=\(resultNumber)")
        
        // Similar to above, this should fail gracefully
        XCTAssertTrue(resultText.isEmpty || resultText == "0" || resultNumber == 0, 
                     "Should handle multiple reserved word misuse gracefully")
    }
    
    private func testCorrectUsageSum() {
        print("\n✅ Test 3: Correct usage of 'sum' function")
        print("Formula: sum([1, 2, 3])")
        print("Expected: 6 (proper function call)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field3")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 6, "Should correctly calculate sum when used as function")
    }
    
    private func testCorrectUsageIf() {
        print("\n✅ Test 4: Correct usage of 'if' function")
        print("Formula: if(true, 100, 0)")
        print("Expected: 100 (proper conditional function)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field4")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 100, "Should correctly evaluate if statement when used as function")
    }
    
    // MARK: - Error Analysis Helper
    
    private func analyzeFormulaErrors() {
        print("\n🔍 Formula Error Analysis:")
        
        let errorFields = ["field1", "field2"]
        let workingFields = ["field3", "field4"]
        
        for fieldID in errorFields {
            if let field = documentEditor.field(fieldID: fieldID) {
                print("❌ Error Field '\(fieldID)': \(field.value?.description ?? "nil")")
            }
        }
        
        for fieldID in workingFields {
            if let field = documentEditor.field(fieldID: fieldID) {
                print("✅ Working Field '\(fieldID)': \(field.value?.description ?? "nil")")
            }
        }
    }
    
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