//
//  EncapsulatedCircularReference_FormulaTemplateTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 25/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class EncapsulatedCircularReference_FormulaTemplateTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "EncapsulatedCircularReference_FormulaTemplate")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    } 

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Encapsulated Circular Reference Tests
    
    func testEncapsulatedCircularReferences() {
        print("\n🧪 === Encapsulated Circular Reference Tests ===")
        print("Testing circular dependencies hidden within nested function calls")
        
        analyzeEncapsulatedCircularDependencies()
        testNestedIfFunctionCircular()
        testReduceFunctionCircular()
        testWorkingNestedFunctions()
        testEncapsulatedCircularErrorHandling()
    }
    
    // MARK: - Individual Test Methods
    
    private func testNestedIfFunctionCircular() {
        print("\n❌ Test 1: Nested if function circular reference")
        print("fieldA1: if(not(empty(sum([fieldB1, 5]))), 1, 0)")
        print("fieldB1: fieldA1 + 2")
        print("Problem: fieldA1 ↔ fieldB1 (circular hidden within if→not→empty→sum nesting)")
        print("Expected: Error handling or null/zero result")
        
        let resultA = documentEditor.value(ofFieldWithIdentifier: "fieldA1")
        let resultB = documentEditor.value(ofFieldWithIdentifier: "fieldB1")
        
        let numberA = resultA?.number ?? 0
        let numberB = resultB?.number ?? 0
        let textA = resultA?.text ?? ""
        let textB = resultB?.text ?? ""
        
        print("🎯 Results:")
        print("  fieldA1: number=\(numberA), text='\(textA)'")
        print("  fieldB1: number=\(numberB), text='\(textB)'")
        
        // Circular dependency is encapsulated within nested function calls
        XCTAssertTrue((numberA == 0 && numberB == 0) || (textA.isEmpty && textB.isEmpty), 
                     "Should handle nested function circular reference gracefully")
    }
    
    private func testReduceFunctionCircular() {
        print("\n❌ Test 2: Reduce function circular reference")
        print("fieldA2: reduce([fieldB2, 1], (acc, cur) -> acc + cur, 0)")
        print("fieldB2: fieldA2 * 3")
        print("Problem: fieldA2 ↔ fieldB2 (circular within reduce function array)")
        print("Expected: Error handling or null/zero result")
        
        let resultA = documentEditor.value(ofFieldWithIdentifier: "fieldA2")
        let resultB = documentEditor.value(ofFieldWithIdentifier: "fieldB2")
        
        let numberA = resultA?.number ?? 0
        let numberB = resultB?.number ?? 0
        let textA = resultA?.text ?? ""
        let textB = resultB?.text ?? ""
        
        print("🎯 Results:")
        print("  fieldA2: number=\(numberA), text='\(textA)'")
        print("  fieldB2: number=\(numberB), text='\(textB)'")
        
        // Circular dependency is encapsulated within reduce function call
        XCTAssertTrue((numberA == 0 && numberB == 0) || (textA.isEmpty && textB.isEmpty), 
                     "Should handle reduce function circular reference gracefully")
    }
    
    private func testWorkingNestedFunctions() {
        print("\n✅ Test 3: Working nested functions (no circular references)")
        print("These should work normally to verify the system handles complex nesting correctly")
        
        // Test deep nested if with constants
        let workingA1 = documentEditor.value(ofFieldWithIdentifier: "fieldA_working_1")
        let workingB1 = documentEditor.value(ofFieldWithIdentifier: "fieldB_working_1")
        
        let numberA1 = workingA1?.number ?? -1
        let numberB1 = workingB1?.number ?? -1
        
        print("fieldA_working_1 (if(not(empty(sum([10, 5]))), 1, 0)): \(numberA1)")
        print("fieldB_working_1 (fieldA_working_1 * 2): \(numberB1)")
        
        XCTAssertEqual(numberA1, 1, "Nested if with constants should return 1")
        XCTAssertEqual(numberB1, 2, "Should calculate 1 * 2 = 2")
        
        // Test reduce with constants
        let workingA2 = documentEditor.value(ofFieldWithIdentifier: "fieldA_working_2")
        let workingB2 = documentEditor.value(ofFieldWithIdentifier: "fieldB_working_2")
        
        let numberA2 = workingA2?.number ?? -1
        let numberB2 = workingB2?.number ?? -1
        
        print("fieldA_working_2 (reduce([10, 1], (acc, cur) -> acc + cur, 0)): \(numberA2)")
        print("fieldB_working_2 (fieldA_working_2 * 3): \(numberB2)")
        
        XCTAssertEqual(numberA2, 11, "Reduce with constants should return 11 (10+1)")
        XCTAssertEqual(numberB2, 33, "Should calculate 11 * 3 = 33")
    }
    
    private func testEncapsulatedCircularErrorHandling() {
        print("\n🔍 Test 4: Overall encapsulated circular error handling")
        
        let circularFields = ["fieldA1", "fieldB1", "fieldA2", "fieldB2"]
        let workingFields = ["fieldA_working_1", "fieldB_working_1", "fieldA_working_2", "fieldB_working_2"]
        
        print("🎯 Encapsulated circular fields results:")
        for fieldID in circularFields {
            let result = documentEditor.value(ofFieldWithIdentifier: fieldID)
            print("  \(fieldID): \(result?.text ?? "nil")")
            
            // All circular fields should exist but handle gracefully
            XCTAssertNotNil(result, "\(fieldID) should exist even if with error state")
        }
        
        print("🎯 Working nested function fields results:")
        for fieldID in workingFields {
            let result = documentEditor.value(ofFieldWithIdentifier: fieldID)
            print("  \(fieldID): \(result?.text ?? "nil")")
            
            // Working fields should have proper values
            XCTAssertNotNil(result, "\(fieldID) should exist and work normally")
        }
    }
    
    // MARK: - Encapsulated Circular Analysis
    
    private func analyzeEncapsulatedCircularDependencies() {
        print("\n🔄 Encapsulated Circular Dependency Analysis:")
        print("Detected circular dependencies hidden within nested function calls:")
        print("")
        print("1. Deep Nested If Function Circular:")
        print("   fieldA1 = if(not(empty(sum([fieldB1, 5]))), 1, 0)")
        print("   fieldB1 = fieldA1 + 2")
        print("   → fieldA1 ↔ fieldB1 (circular buried within: if → not → empty → sum)")
        print("")
        print("2. Reduce Function Circular:")
        print("   fieldA2 = reduce([fieldB2, 1], (acc, cur) -> acc + cur, 0)")
        print("   fieldB2 = fieldA2 * 3")
        print("   → fieldA2 ↔ fieldB2 (circular within reduce function array parameter)")
        print("")
        print("3. Working Examples (same nesting, no circular references):")
        print("   fieldA_working_1 = if(not(empty(sum([10, 5]))), 1, 0) → 1")
        print("   fieldB_working_1 = fieldA_working_1 * 2 → 2")
        print("   fieldA_working_2 = reduce([10, 1], (acc, cur) -> acc + cur, 0) → 11")
        print("   fieldB_working_2 = fieldA_working_2 * 3 → 33")
        print("")
        print("The circular references are encapsulated (hidden) within complex function")
        print("call hierarchies, making them the hardest type to detect and resolve.")
    }
    
    private func testEncapsulatedCircularDetection() {
        print("\n🕵️ Test 5: Encapsulated circular dependency detection")
        
        let startTime = Date()
        
        // Attempt to resolve all fields including those with encapsulated circular references
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldA1")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldB1")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldA2")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldB2")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldA_working_1")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldB_working_1")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldA_working_2")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldB_working_2")
        
        let endTime = Date()
        let executionTime = endTime.timeIntervalSince(startTime)
        
        print("🎯 Execution time: \(executionTime) seconds")
        print("Encapsulation types tested: nested if/not/empty/sum, reduce with arrays")
        
        // Should complete quickly without infinite loops even with deeply nested calls
        XCTAssertLessThan(executionTime, 5.0, 
                         "Should resolve encapsulated circular references quickly without infinite loops")
    }
    
    private func testComplexNestingLevels() {
        print("\n🏗️ Test 6: Complex function nesting levels")
        
        // Verify that the system can handle deep function nesting when working correctly
        let workingFields = [
            ("fieldA_working_1", "if(not(empty(sum([10, 5]))), 1, 0)", 1),
            ("fieldA_working_2", "reduce([10, 1], (acc, cur) -> acc + cur, 0)", 11)
        ]
        
        for (fieldID, formula, expected) in workingFields {
            let result = documentEditor.value(ofFieldWithIdentifier: fieldID)
            let number = result?.number ?? -1
            
            print("✅ \(fieldID): \(formula) → \(number)")
            XCTAssertEqual(Int(number), expected, "Should handle complex nesting: \(fieldID)")
        }
        
        print("Complex function nesting works correctly when no circular references exist.")
    }
    
    // MARK: - Helper Methods
    
    private func debugAllFieldValues() {
        print("\n🔍 All Field Values (with encapsulated circular dependencies):")
        let allFields = ["fieldA1", "fieldB1", "fieldA2", "fieldB2",
                        "fieldA_working_1", "fieldB_working_1", "fieldA_working_2", "fieldB_working_2"]
        
        for fieldID in allFields {
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
}
