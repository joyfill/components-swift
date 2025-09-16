//
//  JoyfillResolverTemplate_ComplexWorkingTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 25/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class JoyfillResolverTemplate_ComplexWorkingTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "JoyfillResolverTemplate_ComplexWorking")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    } 

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Complex Resolver Tests
    
    func testComplexWorkingResolver() {
        print("\n🧪 === Complex Working Resolver Tests ===")
        print("Testing complex multi-level field dependency resolution")
        
        debugBaseValues()
        testField5Calculation()
        testField4Calculation()
        testField3Calculation()
        testField1Calculation()
        testComplexDependencyChain()
    }
    
    // MARK: - Individual Test Methods
    
    private func testField5Calculation() {
        print("\n🔢 Test 1: Field5 = field6 + field7")
        print("Formula: field6 + field7")
        print("Input: 1 + 2")
        print("Expected: 3")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field5")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 3, "Should calculate field5 as field6 + field7 = 1 + 2 = 3")
    }
    
    private func testField4Calculation() {
        print("\n🔢 Test 2: Field4 = field5 + field6 + field7")
        print("Formula: field5 + field6 + field7")
        print("Input: 3 + 1 + 2 (field5 from previous calculation)")
        print("Expected: 6")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field4")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 6, "Should calculate field4 as field5 + field6 + field7 = 3 + 1 + 2 = 6")
    }
    
    private func testField3Calculation() {
        print("\n🔢 Test 3: Field3 = field4 + 3")
        print("Formula: field4 + 3")
        print("Input: 6 + 3 (field4 from previous calculation)")
        print("Expected: 9")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field3")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 9, "Should calculate field3 as field4 + 3 = 6 + 3 = 9")
    }
    
    private func testField1Calculation() {
        print("\n🔢 Test 4: Field1 = field2 + field3")
        print("Formula: field2 + field3")
        print("Input: 5 + 9 (field3 from previous calculation)")
        print("Expected: 14")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field1")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 14, "Should calculate field1 as field2 + field3 = 5 + 9 = 14")
    }
    
    private func testComplexDependencyChain() {
        print("\n🔗 Test 5: Complete complex dependency chain")
        print("Complex dependency chain:")
        print("  Base values: field6=1, field7=2, field2=5")
        print("  Level 1: field5 = field6 + field7 = 1 + 2 = 3")
        print("  Level 2: field4 = field5 + field6 + field7 = 3 + 1 + 2 = 6")
        print("  Level 3: field3 = field4 + 3 = 6 + 3 = 9")
        print("  Level 4: field1 = field2 + field3 = 5 + 9 = 14")
        
        let field6 = documentEditor.value(ofFieldWithIdentifier: "field6")?.number ?? -1
        let field7 = documentEditor.value(ofFieldWithIdentifier: "field7")?.number ?? -1
        let field2 = documentEditor.value(ofFieldWithIdentifier: "field2")?.number ?? -1
        let field5 = documentEditor.value(ofFieldWithIdentifier: "field5")?.number ?? -1
        let field4 = documentEditor.value(ofFieldWithIdentifier: "field4")?.number ?? -1
        let field3 = documentEditor.value(ofFieldWithIdentifier: "field3")?.number ?? -1
        let field1 = documentEditor.value(ofFieldWithIdentifier: "field1")?.number ?? -1
        
        print("🎯 Complete Results:")
        print("  Base values:")
        print("    field6: \(field6) (base)")
        print("    field7: \(field7) (base)")
        print("    field2: \(field2) (base)")
        print("  Calculated values:")
        print("    field5: \(field5) (level 1: \(field6) + \(field7))")
        print("    field4: \(field4) (level 2: \(field5) + \(field6) + \(field7))")
        print("    field3: \(field3) (level 3: \(field4) + 3)")
        print("    field1: \(field1) (level 4: \(field2) + \(field3))")
        
        // Verify base values
        XCTAssertEqual(field6, 1, "Field6 should have base value 1")
        XCTAssertEqual(field7, 2, "Field7 should have base value 2")
        XCTAssertEqual(field2, 5, "Field2 should have base value 5")
        
        // Verify calculated values in dependency order
        XCTAssertEqual(field5, 3, "Field5 should be calculated as 3")
        XCTAssertEqual(field4, 6, "Field4 should be calculated as 6")
        XCTAssertEqual(field3, 9, "Field3 should be calculated as 9")
        XCTAssertEqual(field1, 14, "Field1 should be calculated as 14")
    }
    
    // MARK: - Dependency Analysis
    
    private func analyzeDependencyLevels() {
        print("\n📊 Dependency Level Analysis:")
        print("Level 0 (Base): field6, field7, field2")
        print("Level 1: field5 (depends on field6, field7)")
        print("Level 2: field4 (depends on field5, field6, field7)")
        print("Level 3: field3 (depends on field4)")
        print("Level 4: field1 (depends on field2, field3)")
        
        // This tests the resolver's ability to handle complex multi-level dependencies
        // without circular references
    }
    
    // MARK: - Helper Methods
    
    private func debugBaseValues() {
        print("\n🔍 Base Field Values:")
        print("  field2: \(documentEditor.field(fieldID: "field2")?.value?.number ?? -1)")
        print("  field6: \(documentEditor.field(fieldID: "field6")?.value?.number ?? -1)")
        print("  field7: \(documentEditor.field(fieldID: "field7")?.value?.number ?? -1)")
    }
    
    private func debugAllFieldValues() {
        print("\n🔍 All Field Values:")
        let fieldIDs = ["field1", "field2", "field3", "field4", "field5", "field6", "field7"]
        
        for fieldID in fieldIDs {
            if let field = documentEditor.field(fieldID: fieldID) {
                let hasFormula = field.dictionary["formulas"] != nil
                let value = field.value?.number ?? -1
                let status = hasFormula ? "calculated" : "base"
                print("  \(fieldID): \(value) (\(status))")
            } else {
                print("  \(fieldID): not found")
            }
        }
    }
    
    private func debugFieldValue(_ fieldID: String, expectedValue: Double? = nil) {
        if let field = documentEditor.field(fieldID: fieldID) {
            print("🔍 Field '\(fieldID)': \(field.value?.number ?? -1)")
            if let expected = expectedValue {
                print("   Expected: \(expected)")
            }
        } else {
            print("❌ Field '\(fieldID)' not found")
        }
    }
}