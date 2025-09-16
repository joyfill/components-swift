//
//  JoyfillResolver_SimpleWorkingTests.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 25/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class JoyfillResolver_SimpleWorkingTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "JoyfillResolver_SimpleWorking")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    } 

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Simple Resolver Tests
    
    func testSimpleWorkingResolver() {
        print("\n🧪 === Simple Working Resolver Tests ===")
        print("Testing basic field dependency resolution without circular references")
        
        debugBaseValues()
        testField3Calculation()
        testField1Calculation()
        testDependencyChain()
    }
    
    // MARK: - Individual Test Methods
    
    private func testField3Calculation() {
        print("\n🔢 Test 1: Field3 = field4 + 3")
        print("Formula: field4 + 3")
        print("Input: 2 + 3")
        print("Expected: 5")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field3")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 5, "Should calculate field3 as field4 + 3 = 2 + 3 = 5")
    }
    
    private func testField1Calculation() {
        print("\n🔢 Test 2: Field1 = field2 + field3")
        print("Formula: field2 + field3")
        print("Input: 5 + 5 (field3 is calculated from previous test)")
        print("Expected: 10")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field1")
        let resultNumber = result?.number ?? -1
        print("🎯 Result: \(resultNumber)")
        
        XCTAssertEqual(resultNumber, 10, "Should calculate field1 as field2 + field3 = 5 + 5 = 10")
    }
    
    private func testDependencyChain() {
        print("\n🔗 Test 3: Complete dependency chain")
        print("Dependency chain: field4 → field3 → field1")
        print("field4 = 2 (base value)")
        print("field3 = field4 + 3 = 2 + 3 = 5")
        print("field1 = field2 + field3 = 5 + 5 = 10")
        print("Expected: All fields resolve correctly")
        
        let field4 = documentEditor.value(ofFieldWithIdentifier: "field4")?.number ?? -1
        let field3 = documentEditor.value(ofFieldWithIdentifier: "field3")?.number ?? -1
        let field2 = documentEditor.value(ofFieldWithIdentifier: "field2")?.number ?? -1
        let field1 = documentEditor.value(ofFieldWithIdentifier: "field1")?.number ?? -1
        
        print("🎯 Results:")
        print("  field4: \(field4) (base)")
        print("  field2: \(field2) (base)")  
        print("  field3: \(field3) (calculated)")
        print("  field1: \(field1) (calculated)")
        
        XCTAssertEqual(field4, 2, "Field4 should have base value 2")
        XCTAssertEqual(field2, 5, "Field2 should have base value 5")
        XCTAssertEqual(field3, 5, "Field3 should be calculated as 5")
        XCTAssertEqual(field1, 10, "Field1 should be calculated as 10")
    }
    
    // MARK: - Helper Methods
    
    private func debugBaseValues() {
        print("\n🔍 Base Field Values:")
        print("  field2 (base): \(documentEditor.field(fieldID: "field2")?.value?.number ?? -1)")
        print("  field4 (base): \(documentEditor.field(fieldID: "field4")?.value?.number ?? -1)")
    }
    
    private func debugAllFieldValues() {
        print("\n🔍 All Field Values:")
        let fieldIDs = ["field1", "field2", "field3", "field4"]
        
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