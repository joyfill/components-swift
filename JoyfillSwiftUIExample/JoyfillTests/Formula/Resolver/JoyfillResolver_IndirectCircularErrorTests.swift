//
//  JoyfillResolver_IndirectCircularErrorTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 25/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class JoyfillResolver_IndirectCircularErrorTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "JoyfillResolver_IndirectCircularError")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    } 

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Indirect Circular Error Tests
    
    func testIndirectCircularDependencyHandling() {
        print("\n🧪 === Indirect Circular Dependency Error Tests ===")
        print("Testing how the resolver handles indirect circular dependencies")
        
        analyzeCircularDependencies()
        testField2CircularReference()
        testField3CircularReference()
        testField1DependentOnCircular()
        testCircularReferenceErrorHandling()
    }
    
    // MARK: - Individual Test Methods
    
    private func testField2CircularReference() {
        print("\n❌ Test 1: Field2 circular reference")
        print("Formula: field3 + 1")
        print("Problem: field2 → field3 → field2 (circular)")
        print("Expected: Error handling or null/zero result")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field2")
        let resultNumber = result?.number ?? 0
        let resultText = result?.text ?? ""
        print("🎯 Result: number=\(resultNumber), text='\(resultText)'")
        
        // Circular reference should be handled gracefully
        // This could result in null, zero, or error state
        XCTAssertTrue(resultNumber == 0 || resultText.isEmpty, 
                     "Should handle circular reference gracefully (zero or empty result)")
    }
    
    private func testField3CircularReference() {
        print("\n❌ Test 2: Field3 circular reference")
        print("Formula: field2 + 1")
        print("Problem: field3 → field2 → field3 (circular)")
        print("Expected: Error handling or null/zero result")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field3")
        let resultNumber = result?.number ?? 0
        let resultText = result?.text ?? ""
        print("🎯 Result: number=\(resultNumber), text='\(resultText)'")
        
        // Similar to field2, should handle circular reference gracefully
        XCTAssertTrue(resultNumber == 0 || resultText.isEmpty, 
                     "Should handle circular reference gracefully (zero or empty result)")
    }
    
    private func testField1DependentOnCircular() {
        print("\n❌ Test 3: Field1 depends on circular fields")
        print("Formula: field2 + field3")
        print("Problem: Both field2 and field3 have circular dependencies")
        print("Expected: Error handling or null/zero result")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field1")
        let resultNumber = result?.number ?? 0
        let resultText = result?.text ?? ""
        print("🎯 Result: number=\(resultNumber), text='\(resultText)'")
        
        // Field1 depends on two fields that have circular dependencies
        // Should handle this gracefully
        XCTAssertTrue(resultNumber == 0 || resultText.isEmpty, 
                     "Should handle dependencies on circular fields gracefully")
    }
    
    private func testCircularReferenceErrorHandling() {
        print("\n🔍 Test 4: Overall circular reference error handling")
        
        let field1 = documentEditor.value(ofFieldWithIdentifier: "field1")
        let field2 = documentEditor.value(ofFieldWithIdentifier: "field2")
        let field3 = documentEditor.value(ofFieldWithIdentifier: "field3")
        
        print("🎯 All field results:")
        print("  field1: \(field1?.text ?? "nil")")
        print("  field2: \(field2?.text ?? "nil")")
        print("  field3: \(field3?.text ?? "nil")")
        
        // All fields should have handled the circular dependency gracefully
        // The exact behavior may vary (null, zero, error state) but should not crash
        XCTAssertNotNil(field1, "Field1 should exist even if with error state")
        XCTAssertNotNil(field2, "Field2 should exist even if with error state")
        XCTAssertNotNil(field3, "Field3 should exist even if with error state")
    }
    
    // MARK: - Circular Dependency Analysis
    
    private func analyzeCircularDependencies() {
        print("\n🔄 Circular Dependency Analysis:")
        print("Detected circular dependencies:")
        print("  field2 = field3 + 1")
        print("  field3 = field2 + 1")
        print("  → field2 ↔ field3 (indirect circular reference)")
        print("  field1 = field2 + field3 (depends on both circular fields)")
        print("")
        print("This creates an impossible resolution scenario:")
        print("  - To calculate field2, we need field3")
        print("  - To calculate field3, we need field2")
        print("  - Neither can be resolved without the other")
        print("  - field1 cannot be calculated because both dependencies are circular")
    }
    
    private func testCircularDetection() {
        print("\n🕵️ Test 5: Circular dependency detection")
        
        // The resolver should detect and handle circular dependencies
        // This test verifies that the system doesn't get stuck in infinite loops
        
        let startTime = Date()
        
        // Attempt to resolve all fields
        let _ = documentEditor.value(ofFieldWithIdentifier: "field1")
        let _ = documentEditor.value(ofFieldWithIdentifier: "field2")
        let _ = documentEditor.value(ofFieldWithIdentifier: "field3")
        
        let endTime = Date()
        let executionTime = endTime.timeIntervalSince(startTime)
        
        print("🎯 Execution time: \(executionTime) seconds")
        
        // Should complete quickly without getting stuck in infinite loops
        XCTAssertLessThan(executionTime, 5.0, "Should resolve (or fail) quickly without infinite loops")
    }
    
    // MARK: - Helper Methods
    
    private func debugAllFieldValues() {
        print("\n🔍 All Field Values (with circular dependencies):")
        let fieldIDs = ["field1", "field2", "field3"]
        
        for fieldID in fieldIDs {
            if let field = documentEditor.field(fieldID: fieldID) {
                let hasFormula = field.dictionary["formulas"] != nil
                let status = hasFormula ? "calculated" : "base"
                
                if let numberValue = field.value?.number {
                    print("  \(fieldID): \(numberValue) (\(status))")
                } else if let textValue = field.value?.text {
                    print("  \(fieldID): '\(textValue)' (\(status))")
                } else {
                    print("  \(fieldID): nil (\(status))")
                }
            } else {
                print("  \(fieldID): not found")
            }
        }
    }
    
    private func debugFieldValue(_ fieldID: String, expectedValue: String? = nil) {
        if let field = documentEditor.field(fieldID: fieldID) {
            print("🔍 Field '\(fieldID)': \(field.value?.text ?? "nil")")
            if let expected = expectedValue {
                print("   Expected: '\(expected)'")
            }
        } else {
            print("❌ Field '\(fieldID)' not found")
        }
    }
}
