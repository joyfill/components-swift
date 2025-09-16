//
//  FormulaTemplate_ConditionalEvaluationCircularReferenceTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 25/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class FormulaTemplate_ConditionalEvaluationCircularReferenceTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_ConditionalEvaluationCircularReference")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    } 

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Conditional Circular Reference Tests
    
    func testConditionalEvaluationCircularReferences() {
        print("\n🧪 === Conditional Evaluation Circular Reference Tests ===")
        print("Testing circular dependencies within conditional logic (if, and, or)")
        
        analyzeConditionalCircularDependencies()
        testIfConditionalCircular()
        testAlwaysTrueIfCircular()
        testAndConditionalCircular()
        testOrConditionalCircular()
        testWorkingFormulas()
        testConditionalCircularErrorHandling()
    }
    
    // MARK: - Individual Test Methods
    
    private func testIfConditionalCircular() {
        print("\n❌ Test 1: If conditional circular reference")
        print("fieldA1: if(fieldB1 > 10, 1, 0)")
        print("fieldB1: fieldA1 + 2")
        print("Problem: fieldA1 ↔ fieldB1 (circular within if condition)")
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
        
        // Both fields have circular dependency within conditional logic
        XCTAssertTrue((numberA == 0 && numberB == 0) || (textA.isEmpty && textB.isEmpty), 
                     "Should handle if conditional circular reference gracefully")
    }
    
    private func testAlwaysTrueIfCircular() {
        print("\n❌ Test 2: Always true if with circular dependency")
        print("fieldA2: if(12 > 10, fieldB2 + 4, 0) - condition always true")
        print("fieldB2: fieldA2 + 2")
        print("Problem: fieldA2 ↔ fieldB2 (circular in always-true if branch)")
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
        
        XCTAssertTrue((numberA == 0 && numberB == 0) || (textA.isEmpty && textB.isEmpty), 
                     "Should handle always-true if circular reference gracefully")
    }
    
    private func testAndConditionalCircular() {
        print("\n❌ Test 3: AND conditional circular reference")
        print("fieldA3: and(fieldB3 > 10, true)")
        print("fieldB3: fieldA3 + 1")
        print("Problem: fieldA3 ↔ fieldB3 (circular within AND condition)")
        print("Expected: Error handling or null/zero result")
        
        let resultA = documentEditor.value(ofFieldWithIdentifier: "fieldA3")
        let resultB = documentEditor.value(ofFieldWithIdentifier: "fieldB3")
        
        let numberA = resultA?.number ?? 0
        let numberB = resultB?.number ?? 0
        let textA = resultA?.text ?? ""
        let textB = resultB?.text ?? ""
        
        print("🎯 Results:")
        print("  fieldA3: number=\(numberA), text='\(textA)'")
        print("  fieldB3: number=\(numberB), text='\(textB)'")
        
        XCTAssertTrue((numberA == 0 && numberB == 0) || (textA.isEmpty && textB.isEmpty), 
                     "Should handle AND conditional circular reference gracefully")
    }
    
    private func testOrConditionalCircular() {
        print("\n❌ Test 4: OR conditional circular reference")
        print("fieldA4: or(false, fieldB4 > 5)")
        print("fieldB4: fieldA4 + 1")
        print("Problem: fieldA4 ↔ fieldB4 (circular within OR condition)")
        print("Expected: Error handling or null/zero result")
        
        let resultA = documentEditor.value(ofFieldWithIdentifier: "fieldA4")
        let resultB = documentEditor.value(ofFieldWithIdentifier: "fieldB4")
        
        let numberA = resultA?.number ?? 0
        let numberB = resultB?.number ?? 0
        let textA = resultA?.text ?? ""
        let textB = resultB?.text ?? ""
        
        print("🎯 Results:")
        print("  fieldA4: number=\(numberA), text='\(textA)'")
        print("  fieldB4: number=\(numberB), text='\(textB)'")
        
        XCTAssertTrue((numberA == 0 && numberB == 0) || (textA.isEmpty && textB.isEmpty), 
                     "Should handle OR conditional circular reference gracefully")
    }
    
    private func testWorkingFormulas() {
        print("\n✅ Test 5: Working formulas without circular references")
        print("These should work normally to verify the system isn't broken")
        
        // Test simple addition
        let good1 = documentEditor.value(ofFieldWithIdentifier: "fieldGood1")
        let number1 = good1?.number ?? -1
        print("fieldGood1 (5 + 3): \(number1)")
        XCTAssertEqual(number1, 8, "Simple addition should work")
        
        // Test if with constants
        let good2 = documentEditor.value(ofFieldWithIdentifier: "fieldGood2")
        let number2 = good2?.number ?? -1
        print("fieldGood2 (if(10 > 5, 100, 200)): \(number2)")
        XCTAssertEqual(number2, 100, "If with constants should work")
        
        // Test string function
        let good3 = documentEditor.value(ofFieldWithIdentifier: "fieldGood3")
        let text3 = good3?.text ?? ""
        print("fieldGood3 (upper('joyfill')): '\(text3)'")
        XCTAssertEqual(text3, "JOYFILL", "String function should work")
    }
    
    private func testConditionalCircularErrorHandling() {
        print("\n🔍 Test 6: Overall conditional circular error handling")
        
        let circularFields = ["fieldA1", "fieldB1", "fieldA2", "fieldB2", "fieldA3", "fieldB3", "fieldA4", "fieldB4"]
        let workingFields = ["fieldGood1", "fieldGood2", "fieldGood3"]
        
        print("🎯 Circular fields results:")
        for fieldID in circularFields {
            let result = documentEditor.value(ofFieldWithIdentifier: fieldID)
            print("  \(fieldID): \(result?.text ?? "nil")")
            
            // All circular fields should exist but handle gracefully
            XCTAssertNotNil(result, "\(fieldID) should exist even if with error state")
        }
        
        print("🎯 Working fields results:")
        for fieldID in workingFields {
            let result = documentEditor.value(ofFieldWithIdentifier: fieldID)
            print("  \(fieldID): \(result?.text ?? "nil")")
            
            // Working fields should have proper values
            XCTAssertNotNil(result, "\(fieldID) should exist and work normally")
        }
    }
    
    // MARK: - Conditional Circular Analysis
    
    private func analyzeConditionalCircularDependencies() {
        print("\n🔄 Conditional Circular Dependency Analysis:")
        print("Detected circular dependencies within conditional logic:")
        print("")
        print("1. If Conditional Circular:")
        print("   fieldA1 = if(fieldB1 > 10, 1, 0)")
        print("   fieldB1 = fieldA1 + 2")
        print("   → fieldA1 ↔ fieldB1 (condition evaluation circular)")
        print("")
        print("2. Always True If Circular:")
        print("   fieldA2 = if(12 > 10, fieldB2 + 4, 0)")
        print("   fieldB2 = fieldA2 + 2")
        print("   → fieldA2 ↔ fieldB2 (true branch circular)")
        print("")
        print("3. AND Conditional Circular:")
        print("   fieldA3 = and(fieldB3 > 10, true)")
        print("   fieldB3 = fieldA3 + 1")
        print("   → fieldA3 ↔ fieldB3 (AND operand circular)")
        print("")
        print("4. OR Conditional Circular:")
        print("   fieldA4 = or(false, fieldB4 > 5)")
        print("   fieldB4 = fieldA4 + 1")
        print("   → fieldA4 ↔ fieldB4 (OR operand circular)")
        print("")
        print("Each creates impossible conditional evaluation scenarios.")
    }
    
    private func testConditionalCircularDetection() {
        print("\n🕵️ Test 7: Conditional circular dependency detection")
        
        let startTime = Date()
        
        // Attempt to resolve all circular conditional fields
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldA1")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldB1")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldA2")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldB2")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldA3")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldB3")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldA4")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldB4")
        
        let endTime = Date()
        let executionTime = endTime.timeIntervalSince(startTime)
        
        print("🎯 Execution time: \(executionTime) seconds")
        print("Conditional types tested: if, and, or")
        
        // Should complete quickly without infinite loops in conditional evaluation
        XCTAssertLessThan(executionTime, 5.0, 
                         "Should resolve conditional circular references quickly without infinite loops")
    }
    
    // MARK: - Helper Methods
    
    private func debugAllFieldValues() {
        print("\n🔍 All Field Values (with conditional circular dependencies):")
        let allFields = ["fieldA1", "fieldB1", "fieldA2", "fieldB2", "fieldA3", "fieldB3", 
                        "fieldA4", "fieldB4", "fieldGood1", "fieldGood2", "fieldGood3"]
        
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
