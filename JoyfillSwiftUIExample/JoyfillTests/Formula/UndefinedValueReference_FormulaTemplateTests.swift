//
//  UndefinedValueReference_FormulaTemplateTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 25/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class UndefinedValueReference_FormulaTemplateTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "UndefinedValueReference_FormulaTemplate")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    } 

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Undefined Reference Tests
    
    func testUndefinedValueReferenceHandling() {
        print("\n🧪 === Undefined Value Reference Formula Tests ===")
        print("Testing how the formula system handles references to non-existent fields")
        
        testUndefinedSingleField()
        testUndefinedMultipleFields()
        testValidConstantMath()
        testValidStringFunction()
    }
    
    // MARK: - Individual Test Methods
    
    private func testUndefinedSingleField() {
        print("\n❌ Test 1: Reference to undefined field")
        print("Formula: ghostField + 1")
        print("Expected: Error or null (ghostField doesn't exist)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field1")
        let resultText = result?.text ?? ""
        let resultNumber = result?.number ?? 0
        print("🎯 Result: text='\(resultText)', number=\(resultNumber)")
        
        // When referencing an undefined field, the formula should fail gracefully
        // This could result in null, empty, or error state
        XCTAssertTrue(resultText.isEmpty || resultText == "0" || resultNumber == 0, 
                     "Should handle undefined field reference gracefully (empty or zero result)")
    }
    
    private func testUndefinedMultipleFields() {
        print("\n❌ Test 2: Reference to multiple undefined fields")
        print("Formula: sum([undefined1, undefined2])")
        print("Expected: Error or null (both fields don't exist)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field2")
        let resultText = result?.text ?? ""
        let resultNumber = result?.number ?? 0
        print("🎯 Result: text='\(resultText)', number=\(resultNumber)")
        
        // Similar to above, this should fail gracefully when both referenced fields are undefined
        XCTAssertTrue(resultText.isEmpty || resultText == "0" || resultNumber == 0, 
                     "Should handle multiple undefined field references gracefully")
    }
    
    private func testValidConstantMath() {
        print("\n✅ Test 3: Valid constant math")
        print("Formula: 10 + 5")
        print("Expected: 15 (no field references)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field4")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 15, "Should correctly calculate constant math without field references")
    }
    
    private func testValidStringFunction() {
        print("\n✅ Test 4: Valid string function")
        print("Formula: upper(\"hello\")")
        print("Expected: 'HELLO' (no field references)")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field5")
        let resultText = result?.text ?? ""
        print("🎯 Result: '\(resultText)'")
        
        XCTAssertEqual(resultText, "HELLO", "Should correctly execute string function without field references")
    }
    
    // MARK: - Error Analysis Helper
    
    private func analyzeUndefinedReferences() {
        print("\n🔍 Undefined Reference Analysis:")
        
        let errorFields = ["field1", "field2"]
        let workingFields = ["field4", "field5"]
        
        print("❌ Fields with undefined references:")
        for fieldID in errorFields {
            if let field = documentEditor.field(fieldID: fieldID) {
                print("  - '\(fieldID)': \(field.value?.description ?? "nil")")
            }
        }
        
        print("✅ Fields without references (constants only):")
        for fieldID in workingFields {
            if let field = documentEditor.field(fieldID: fieldID) {
                print("  - '\(fieldID)': \(field.value?.description ?? "nil")")
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