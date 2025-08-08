//
//  ImplicitCircularReferenceObjectArrayConstruction_FormulaTemplateTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 25/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class ImplicitCircularReferenceObjectArrayConstruction_FormulaTemplateTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "ImplicitCircularReferenceObjectArrayConstruction_FormulaTemplate")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    } 

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Implicit Circular Reference Tests
    
    func testImplicitCircularReferenceInObjectArrayConstruction() {
        print("\n🧪 === Implicit Circular Reference in Object/Array Construction Tests ===")
        print("Testing circular dependencies within array and object construction expressions")
        
        analyzeImplicitCircularDependencies()
        testArrayConstructionCircular()
        testObjectArrayMapCircular()
        testWorkingArrayConstruction()
        testWorkingObjectArrayMap()
        testImplicitCircularErrorHandling()
    }
    
    // MARK: - Individual Test Methods
    
    private func testArrayConstructionCircular() {
        print("\n❌ Test 1: Array construction circular reference")
        print("fieldA1: sum([fieldB1, fieldC1])")
        print("fieldC1: fieldA1 * 2")
        print("fieldB1: no formula (helper field)")
        print("Problem: fieldA1 ↔ fieldC1 (circular within array construction)")
        print("Expected: Error handling or null/zero result")
        
        let resultA = documentEditor.value(ofFieldWithIdentifier: "fieldA1")
        let resultB = documentEditor.value(ofFieldWithIdentifier: "fieldB1")  // Should be empty/null
        let resultC = documentEditor.value(ofFieldWithIdentifier: "fieldC1")
        
        let numberA = resultA?.number ?? 0
        let numberB = resultB?.number ?? 0
        let numberC = resultC?.number ?? 0
        let textA = resultA?.text ?? ""
        let textC = resultC?.text ?? ""
        
        print("🎯 Results:")
        print("  fieldA1: number=\(numberA), text='\(textA)'")
        print("  fieldB1: number=\(numberB) (helper field, no formula)")
        print("  fieldC1: number=\(numberC), text='\(textC)'")
        
        // fieldA1 and fieldC1 have circular dependency within array construction
        XCTAssertTrue((numberA == 0 && numberC == 0) || (textA.isEmpty && textC.isEmpty), 
                     "Should handle array construction circular reference gracefully")
    }
    
    private func testObjectArrayMapCircular() {
        print("\n❌ Test 2: Object array map circular reference")
        print("fieldA2: sum(map([{ value: fieldB2 }, { value: fieldC2 }], (arg) -> arg.value))")
        print("fieldC2: fieldA2 * 2")
        print("fieldB2: no formula (helper field)")
        print("Problem: fieldA2 ↔ fieldC2 (circular within object array map)")
        print("Expected: Error handling or null/zero result")
        
        let resultA = documentEditor.value(ofFieldWithIdentifier: "fieldA2")
        let resultB = documentEditor.value(ofFieldWithIdentifier: "fieldB2")  // Should be empty/null
        let resultC = documentEditor.value(ofFieldWithIdentifier: "fieldC2")
        
        let numberA = resultA?.number ?? 0
        let numberB = resultB?.number ?? 0
        let numberC = resultC?.number ?? 0
        let textA = resultA?.text ?? ""
        let textC = resultC?.text ?? ""
        
        print("🎯 Results:")
        print("  fieldA2: number=\(numberA), text='\(textA)'")
        print("  fieldB2: number=\(numberB) (helper field, no formula)")
        print("  fieldC2: number=\(numberC), text='\(textC)'")
        
        // fieldA2 and fieldC2 have circular dependency within object array map construction
        XCTAssertTrue((numberA == 0 && numberC == 0) || (textA.isEmpty && textC.isEmpty), 
                     "Should handle object array map circular reference gracefully")
    }
    
    private func testWorkingArrayConstruction() {
        print("\n✅ Test 3: Working array construction")
        print("fieldA_working_1: sum([10, 20])")
        print("fieldC_working_1: fieldA_working_1 * 2")
        print("Expected: fieldA=30, fieldC=60 (proper dependency)")
        
        let resultA = documentEditor.value(ofFieldWithIdentifier: "fieldA_working_1")
        let resultC = documentEditor.value(ofFieldWithIdentifier: "fieldC_working_1")
        
        let numberA = resultA?.number ?? -1
        let numberC = resultC?.number ?? -1
        
        print("🎯 Results:")
        print("  fieldA_working_1: \(numberA)")
        print("  fieldC_working_1: \(numberC)")
        
        XCTAssertEqual(numberA, 30, "Should calculate sum([10, 20]) = 30")
        XCTAssertEqual(numberC, 60, "Should calculate 30 * 2 = 60")
    }
    
    private func testWorkingObjectArrayMap() {
        print("\n✅ Test 4: Working object array map")
        print("fieldA_working_2: sum(map([{ value: 10 }, { value: 20 }], (arg) -> arg.value))")
        print("fieldC_working_2: fieldA_working_2 * 2")
        print("Expected: fieldA=30, fieldC=60 (proper dependency)")
        
        let resultA = documentEditor.value(ofFieldWithIdentifier: "fieldA_working_2")
        let resultC = documentEditor.value(ofFieldWithIdentifier: "fieldC_working_2")
        
        let numberA = resultA?.number ?? -1
        let numberC = resultC?.number ?? -1
        
        print("🎯 Results:")
        print("  fieldA_working_2: \(numberA)")
        print("  fieldC_working_2: \(numberC)")
        
        XCTAssertEqual(numberA, 30, "Should calculate sum of mapped object values = 30")
        XCTAssertEqual(numberC, 60, "Should calculate 30 * 2 = 60")
    }
    
    private func testImplicitCircularErrorHandling() {
        print("\n🔍 Test 5: Overall implicit circular error handling")
        
        let circularFields = ["fieldA1", "fieldC1", "fieldA2", "fieldC2"]
        let helperFields = ["fieldB1", "fieldB2"]
        let workingFields = ["fieldA_working_1", "fieldC_working_1", "fieldA_working_2", "fieldC_working_2"]
        
        print("🎯 Circular fields results:")
        for fieldID in circularFields {
            let result = documentEditor.value(ofFieldWithIdentifier: fieldID)
            print("  \(fieldID): \(result?.text ?? "nil")")
            
            // All circular fields should exist but handle gracefully
            XCTAssertNotNil(result, "\(fieldID) should exist even if with error state")
        }
        
        print("🎯 Helper fields results:")
        for fieldID in helperFields {
            let result = documentEditor.value(ofFieldWithIdentifier: fieldID)
            print("  \(fieldID): \(result?.text ?? "nil")")
            
            // Helper fields have no formulas, so should be null/empty
            let isEmpty = result == nil || result?.text?.isEmpty == true || result?.number == 0
            XCTAssertTrue(isEmpty, "\(fieldID) should be empty (no formula)")
        }
        
        print("🎯 Working fields results:")
        for fieldID in workingFields {
            let result = documentEditor.value(ofFieldWithIdentifier: fieldID)
            print("  \(fieldID): \(result?.text ?? "nil")")
            
            // Working fields should have proper values
            XCTAssertNotNil(result, "\(fieldID) should exist and work normally")
        }
    }
    
    // MARK: - Implicit Circular Analysis
    
    private func analyzeImplicitCircularDependencies() {
        print("\n🔄 Implicit Circular Dependency Analysis:")
        print("Detected circular dependencies within object/array construction:")
        print("")
        print("1. Array Construction Circular:")
        print("   fieldA1 = sum([fieldB1, fieldC1])")
        print("   fieldC1 = fieldA1 * 2")
        print("   → fieldA1 ↔ fieldC1 (circular within array elements)")
        print("")
        print("2. Object Array Map Circular:")
        print("   fieldA2 = sum(map([{ value: fieldB2 }, { value: fieldC2 }], (arg) -> arg.value))")
        print("   fieldC2 = fieldA2 * 2")
        print("   → fieldA2 ↔ fieldC2 (circular within object property values)")
        print("")
        print("3. Working Examples (no circular references):")
        print("   fieldA_working_1 = sum([10, 20]) → 30")
        print("   fieldC_working_1 = fieldA_working_1 * 2 → 60")
        print("   fieldA_working_2 = sum(map([{ value: 10 }, { value: 20 }], (arg) -> arg.value)) → 30")
        print("   fieldC_working_2 = fieldA_working_2 * 2 → 60")
        print("")
        print("The circular references are implicit within the construction expressions,")
        print("making them harder to detect than direct field references.")
    }
    
    private func testImplicitCircularDetection() {
        print("\n🕵️ Test 6: Implicit circular dependency detection")
        
        let startTime = Date()
        
        // Attempt to resolve all fields including those with implicit circular references
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldA1")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldC1")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldA2")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldC2")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldA_working_1")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldC_working_1")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldA_working_2")
        let _ = documentEditor.value(ofFieldWithIdentifier: "fieldC_working_2")
        
        let endTime = Date()
        let executionTime = endTime.timeIntervalSince(startTime)
        
        print("🎯 Execution time: \(executionTime) seconds")
        print("Construction types tested: array literals, object literals with map")
        
        // Should complete quickly without infinite loops in object/array construction
        XCTAssertLessThan(executionTime, 5.0, 
                         "Should resolve implicit circular references quickly without infinite loops")
    }
    
    // MARK: - Helper Methods
    
    private func debugAllFieldValues() {
        print("\n🔍 All Field Values (with implicit circular dependencies):")
        let allFields = ["fieldA1", "fieldB1", "fieldC1", "fieldA2", "fieldB2", "fieldC2",
                        "fieldA_working_1", "fieldC_working_1", "fieldA_working_2", "fieldC_working_2"]
        
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
