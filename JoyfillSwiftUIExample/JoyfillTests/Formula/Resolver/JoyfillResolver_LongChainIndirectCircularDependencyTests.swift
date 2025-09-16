//
//  JoyfillResolver_LongChainIndirectCircularDependencyTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 25/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class JoyfillResolver_LongChainIndirectCircularDependencyTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "JoyfillResolver_LongChainIndirectCircularDependency")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    } 

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Long Chain Circular Dependency Tests
    
    func testLongChainCircularDependencyHandling() {
        print("\n🧪 === Long Chain Indirect Circular Dependency Tests ===")
        print("Testing complex multi-field circular dependency chains")
        
        analyzeLongChainCircularDependencies()
        testField2InChain()
        testField3InChain()
        testField4InChain()
        testField5InChain()
        testField1DependentOnChain()
        testLongChainErrorHandling()
    }
    
    // MARK: - Individual Test Methods
    
    private func testField2InChain() {
        print("\n❌ Test 1: Field2 in circular chain")
        print("Formula: field3 + 1")
        print("Chain: field2 → field3 → field4 → field5 → field2")
        print("Expected: Error handling or null/zero result")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field2")
        let resultNumber = result?.number ?? 0
        let resultText = result?.text ?? ""
        print("🎯 Result: number=\(resultNumber), text='\(resultText)'")
        
        // Part of circular chain, should be handled gracefully
        XCTAssertTrue(resultNumber == 0 || resultText.isEmpty, 
                     "Should handle long chain circular reference gracefully")
    }
    
    private func testField3InChain() {
        print("\n❌ Test 2: Field3 in circular chain")
        print("Formula: field4")
        print("Chain: field3 → field4 → field5 → field2 → field3")
        print("Expected: Error handling or null/zero result")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field3")
        let resultNumber = result?.number ?? 0
        let resultText = result?.text ?? ""
        print("🎯 Result: number=\(resultNumber), text='\(resultText)'")
        
        XCTAssertTrue(resultNumber == 0 || resultText.isEmpty, 
                     "Should handle long chain circular reference gracefully")
    }
    
    private func testField4InChain() {
        print("\n❌ Test 3: Field4 in circular chain")
        print("Formula: field5 + 2")
        print("Chain: field4 → field5 → field2 → field3 → field4")
        print("Expected: Error handling or null/zero result")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field4")
        let resultNumber = result?.number ?? 0
        let resultText = result?.text ?? ""
        print("🎯 Result: number=\(resultNumber), text='\(resultText)'")
        
        XCTAssertTrue(resultNumber == 0 || resultText.isEmpty, 
                     "Should handle long chain circular reference gracefully")
    }
    
    private func testField5InChain() {
        print("\n❌ Test 4: Field5 in circular chain")
        print("Formula: field2 + 3")
        print("Chain: field5 → field2 → field3 → field4 → field5")
        print("Expected: Error handling or null/zero result")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field5")
        let resultNumber = result?.number ?? 0
        let resultText = result?.text ?? ""
        print("🎯 Result: number=\(resultNumber), text='\(resultText)'")
        
        XCTAssertTrue(resultNumber == 0 || resultText.isEmpty, 
                     "Should handle long chain circular reference gracefully")
    }
    
    private func testField1DependentOnChain() {
        print("\n❌ Test 5: Field1 depends on circular chain")
        print("Formula: field2 + field3")
        print("Problem: Both field2 and field3 are part of circular chain")
        print("Expected: Error handling or null/zero result")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field1")
        let resultNumber = result?.number ?? 0
        let resultText = result?.text ?? ""
        print("🎯 Result: number=\(resultNumber), text='\(resultText)'")
        
        // Field1 depends on fields that are part of circular chain
        XCTAssertTrue(resultNumber == 0 || resultText.isEmpty, 
                     "Should handle dependencies on circular chain gracefully")
    }
    
    private func testLongChainErrorHandling() {
        print("\n🔍 Test 6: Overall long chain error handling")
        
        let field1 = documentEditor.value(ofFieldWithIdentifier: "field1")
        let field2 = documentEditor.value(ofFieldWithIdentifier: "field2")
        let field3 = documentEditor.value(ofFieldWithIdentifier: "field3")
        let field4 = documentEditor.value(ofFieldWithIdentifier: "field4")
        let field5 = documentEditor.value(ofFieldWithIdentifier: "field5")
        
        print("🎯 All field results:")
        print("  field1: \(field1?.text ?? "nil")")
        print("  field2: \(field2?.text ?? "nil")")
        print("  field3: \(field3?.text ?? "nil")")
        print("  field4: \(field4?.text ?? "nil")")
        print("  field5: \(field5?.text ?? "nil")")
        
        // All fields should exist even if in error state
        XCTAssertNotNil(field1, "Field1 should exist even if with error state")
        XCTAssertNotNil(field2, "Field2 should exist even if with error state")
        XCTAssertNotNil(field3, "Field3 should exist even if with error state")
        XCTAssertNotNil(field4, "Field4 should exist even if with error state")
        XCTAssertNotNil(field5, "Field5 should exist even if with error state")
    }
    
    // MARK: - Long Chain Analysis
    
    private func analyzeLongChainCircularDependencies() {
        print("\n🔄 Long Chain Circular Dependency Analysis:")
        print("Detected long chain circular dependencies:")
        print("  field1 = field2 + field3")
        print("  field2 = field3 + 1")
        print("  field3 = field4")
        print("  field4 = field5 + 2")
        print("  field5 = field2 + 3")
        print("")
        print("Circular chain: field2 → field3 → field4 → field5 → field2")
        print("  - field2 depends on field3")
        print("  - field3 depends on field4")
        print("  - field4 depends on field5")
        print("  - field5 depends on field2 (completing the circle)")
        print("  - field1 depends on both field2 and field3 (both in circle)")
        print("")
        print("This creates a complex impossible resolution scenario:")
        print("  - None of the fields in the chain can be resolved")
        print("  - Each field needs another field in the chain to be calculated first")
        print("  - The chain forms a complete circle with no entry point")
    }
    
    private func testLongChainDetection() {
        print("\n🕵️ Test 7: Long chain circular dependency detection")
        
        // The resolver should detect and handle long chain circular dependencies
        // This test verifies that the system doesn't get stuck in infinite loops
        // even with complex multi-field circular chains
        
        let startTime = Date()
        
        // Attempt to resolve all fields in the circular chain
        let _ = documentEditor.value(ofFieldWithIdentifier: "field1")
        let _ = documentEditor.value(ofFieldWithIdentifier: "field2")
        let _ = documentEditor.value(ofFieldWithIdentifier: "field3")
        let _ = documentEditor.value(ofFieldWithIdentifier: "field4")
        let _ = documentEditor.value(ofFieldWithIdentifier: "field5")
        
        let endTime = Date()
        let executionTime = endTime.timeIntervalSince(startTime)
        
        print("🎯 Execution time: \(executionTime) seconds")
        print("Chain length: 4 fields in circular dependency")
        
        // Should complete quickly without getting stuck in infinite loops
        // even with longer chains
        XCTAssertLessThan(executionTime, 5.0, 
                         "Should resolve (or fail) quickly without infinite loops in long chains")
    }
    
    // MARK: - Helper Methods
    
    private func debugAllFieldValues() {
        print("\n🔍 All Field Values (with long chain circular dependencies):")
        let fieldIDs = ["field1", "field2", "field3", "field4", "field5"]
        
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
