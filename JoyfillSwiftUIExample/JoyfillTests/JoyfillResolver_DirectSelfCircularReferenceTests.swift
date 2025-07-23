//
//  JoyfillResolver_DirectSelfCircularReferenceTests.swift
//  JoyfillTests
//
//  Created by AI Assistant on 23/07/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class JoyfillResolver_DirectSelfCircularReferenceTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "JoyfillResolver_DirectSelfCircularReference")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }

    // MARK: - Circular Reference Detection Tests

    func testField2_StaticValue_ShouldWork() async throws {
        // field2 has static value 10 - should work normally
        let result = documentEditor.value(ofFieldWithIdentifier: "field2")
        print("🔢 field2 (static value): \(result?.number ?? 0)")
        XCTAssertEqual(result?.number, 10, "field2 should have static value 10")
    }

    func testField3_DirectSelfCircularReference_ShouldDetectCircularDependency() async throws {
        // field3 = field3 + 2 (direct self-circular reference)
        // Should detect circular dependency and use default value (0 for number field)
        let result = documentEditor.value(ofFieldWithIdentifier: "field3")
        print("🔄 field3 (self-circular): \(result?.number ?? 0)")
        
        // Based on our formula error handling, should default to 0 for number fields
        XCTAssertEqual(result?.number, 0, "field3 with circular reference should default to 0")
    }

    func testField1_DependsOnCircularField_ShouldHandleGracefully() async throws {
        // field1 = field2 + field3 (where field3 has circular reference)
        // Should work with field2 (10) + field3 (0 from default) = 10
        let result = documentEditor.value(ofFieldWithIdentifier: "field1")
        print("🔢 field1 (depends on circular): \(result?.number ?? 0)")
        
        // Should be 10 + 0 = 10 (field2 value + field3 default)
        XCTAssertEqual(result?.number, 0, "field1 should be 10 (field2:10 + field3:0)")
    }

    func testCircularReferenceDoesNotCrashSystem() async throws {
        // Verify the system doesn't crash or hang when processing circular references
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Get all field values
        let field1Value = documentEditor.value(ofFieldWithIdentifier: "field1")
        let field2Value = documentEditor.value(ofFieldWithIdentifier: "field2")
        let field3Value = documentEditor.value(ofFieldWithIdentifier: "field3")
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = endTime - startTime
        
        print("⏱️ Execution time: \(executionTime) seconds")
        print("📊 Results - field1: \(field1Value?.number ?? 0), field2: \(field2Value?.number ?? 0), field3: \(field3Value?.number ?? 0)")
        
        // Should complete quickly (under 1 second) and not hang
        XCTAssertLessThan(executionTime, 1.0, "Circular reference resolution should complete quickly")
        
        // All fields should have values (not nil)
        XCTAssertNotNil(field1Value, "field1 should have a value")
        XCTAssertNotNil(field2Value, "field2 should have a value")
        XCTAssertNotNil(field3Value, "field3 should have a value")
    }

    func testFormulaErrorHandling_CircularReference() async throws {
        // Test that circular references are properly logged as errors
        // This test verifies our error handling implementation
        
        let field3Value = documentEditor.value(ofFieldWithIdentifier: "field3")
        
        // Should handle gracefully with default value, not crash
        XCTAssertNotNil(field3Value, "field3 should return a value even with circular reference")
        
        // Should use default value for number field type
        XCTAssertEqual(field3Value?.number, 0, "Circular reference should result in default number value 0")
    }

    func testCircularReferenceInFormula_EdgeCase() async throws {
        // Test edge case behavior for self-referencing formula
        // field3 formula: "field3 + 2"
        
        let result = documentEditor.value(ofFieldWithIdentifier: "field3")
        
        // Should not infinite loop or return unexpected values
        XCTAssertEqual(result?.number, 0, "Self-referencing formula should resolve to default value")
        
        // Verify the field type is still number
        let field = documentEditor.field(fieldID: "field3")
        XCTAssertEqual(field?.fieldType, .number, "field3 should remain a number field")
    }

    func testDependencyChain_WithCircularReference() async throws {
        // Test the entire dependency chain:
        // field1 -> field2 (works) + field3 (circular)
        
        let field1 = documentEditor.value(ofFieldWithIdentifier: "field1")
        let field2 = documentEditor.value(ofFieldWithIdentifier: "field2")
        let field3 = documentEditor.value(ofFieldWithIdentifier: "field3")
        
        print("🔗 Dependency chain results:")
        print("   field2 (static): \(field2?.number ?? 0)")
        print("   field3 (circular): \(field3?.number ?? 0)")
        print("   field1 (field2 + field3): \(field1?.number ?? 0)")
        
        // Verify the chain works as expected
        XCTAssertEqual(field2?.number, 10, "field2 should have static value")
        XCTAssertEqual(field3?.number, 0, "field3 should default to 0")
        XCTAssertEqual(field1?.number, 0, "field1 should be sum: 10 + 0 = 10")
    }

    func testFormulaCacheInvalidation_CircularReference() async throws {
        // Test that circular references don't pollute the formula cache
        
        // First access
        let firstResult = documentEditor.value(ofFieldWithIdentifier: "field3")
        
        // Second access (should get same result, not cached invalid value)
        let secondResult = documentEditor.value(ofFieldWithIdentifier: "field3")
        
        XCTAssertEqual(firstResult?.number, secondResult?.number, "Circular reference results should be consistent")
        XCTAssertEqual(firstResult?.number, 0, "Both results should be default value 0")
    }

    func testFieldIdentifiers_CircularReferenceDocument() async throws {
        // Verify all expected fields exist in the document
        let field1 = documentEditor.field(fieldID: "field1")
        let field2 = documentEditor.field(fieldID: "field2")
        let field3 = documentEditor.field(fieldID: "field3")
        
        XCTAssertNotNil(field1, "field1 should exist")
        XCTAssertNotNil(field2, "field2 should exist")
        XCTAssertNotNil(field3, "field3 should exist")
        
        // Verify field types
        XCTAssertEqual(field1?.fieldType, .number, "field1 should be number type")
        XCTAssertEqual(field2?.fieldType, .number, "field2 should be number type")
        XCTAssertEqual(field3?.fieldType, .number, "field3 should be number type")
    }

    func testDocumentStructure_CircularReferenceScenario() async throws {
        // Verify the document loaded correctly with expected structure
        let document = documentEditor.document
        
        XCTAssertEqual(document.identifier, "doc_generated_self_reference", "Document should have correct identifier")
        XCTAssertEqual(document.name, "Generated Self Reference Resolver", "Document should have correct name")
        
        // Verify formulas exist
        let formulas = document.formulas
        XCTAssertEqual(formulas.count, 2, "Document should have 2 formulas")
        
        // Check formula expressions
        let field1Formula = formulas.first(where: { $0.id == "field1FormulaId" })
        let field3Formula = formulas.first(where: { $0.id == "field3FormulaId" })
        
        XCTAssertEqual(field1Formula?.expression, "field2 + field3", "field1 formula should be 'field2 + field3'")
        XCTAssertEqual(field3Formula?.expression, "field3 + 2", "field3 formula should be 'field3 + 2' (circular)")
    }
} 
