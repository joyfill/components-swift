import XCTest
import Foundation
import SwiftUI
import JoyfillModel
import Joyfill

final class SchemaValidationTests: XCTestCase {
    
    private var schemaManager: JoyfillSchemaManager!
    
    override func setUp() {
        super.setUp()
        schemaManager = JoyfillSchemaManager()
    }
    
    override func tearDown() {
        schemaManager = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases for Schema Validation
    
    func testValidDocument_ShouldPassSchemaValidation() {
        // Arrange: Use the same document as OnChangeHandlerTest
        let document = sampleJSONDocument(fileName: "FieldTemplate_TableCollection_Poplated")
        
        // Act: Validate schema
        let validationError = schemaManager.validateSchema(document: document)
        
        // Assert: Should pass validation (no error returned)
        XCTAssertNil(validationError, "Valid document should pass schema validation")
        
        // Additional verification
        if validationError == nil {
            print("✅ Schema validation passed for document version: \(document.version ?? "undefined")")
        }
    }
    
    func testDocumentWithMissingRequiredFields_ShouldFailSchemaValidation() {
        // Arrange: Create document with missing required fields
        let invalidDocument = JoyDoc(dictionary: [
            "v": "1.0.0",
            "identifier": "test_doc",
            // Missing required fields like "name", "files", etc.
        ])
        
        // Act: Validate schema
        let validationError = schemaManager.validateSchema(document: invalidDocument)
        
        // Assert: Should fail validation
        XCTAssertNotNil(validationError, "Document with missing required fields should fail validation")
        XCTAssertEqual(validationError?.code, "ERROR_SCHEMA_VALIDATION")
        XCTAssertTrue(validationError?.message.contains("Error detected during schema validation") == true)
        
        // Verify error details
        if let error = validationError {
            XCTAssertEqual(error.details.schemaVersion, "1.0.0")
            XCTAssertEqual(error.details.sdkVersion, "1.0.0")
            XCTAssertNotNil(error.error, "Should contain specific validation errors")
            
            print("❌ Schema validation failed as expected: \(error.message)")
            if let validationErrors = error.error {
                print("   Found \(validationErrors.count) validation errors")
            }
        }
    }
    
    func testUnsupportedVersion_ShouldFailWithVersionError() {
        // Arrange: Create document with unsupported major version
        let futureVersionDocument = JoyDoc(dictionary: [
            "v": "2.0.0", // Unsupported major version
            "identifier": "future_doc",
            "name": "Future Document",
            "files": []
        ])
        
        // Act: Validate schema
        let validationError = schemaManager.validateSchema(document: futureVersionDocument)
        
        // Assert: Should fail with version error
        XCTAssertNotNil(validationError, "Document with unsupported version should fail validation")
        XCTAssertEqual(validationError?.code, "ERROR_SCHEMA_VERSION")
        XCTAssertTrue(validationError?.message.contains("Unsupported JoyDoc version detected") == true)
        
        // Verify version-specific error details
        if let error = validationError {
            XCTAssertEqual(error.details.schemaVersion, "2.0.0")
            XCTAssertEqual(error.details.sdkVersion, "1.0.0")
            XCTAssertNil(error.error, "Version errors should not contain JSON validation errors")
            
            print("❌ Version validation failed as expected: \(error.message)")
        }
    }
    
    func testDocumentWithoutVersion_ShouldDefaultToV1AndValidate() {
        // Arrange: Create document without version (should default to v1.x.x)
        let noVersionDocument = JoyDoc(dictionary: [
            "identifier": "no_version_doc",
            "name": "Document Without Version",
            "files": [],
            "fields": []
        ])
        
        // Act: Validate schema
        let validationError = schemaManager.validateSchema(document: noVersionDocument)
        
        // Assert: Should pass version check but might fail schema validation
        // (Version should default to v1.x.x which is supported)
        if let error = validationError {
            // If there's an error, it should be schema validation, not version
            XCTAssertEqual(error.code, "ERROR_SCHEMA_VALIDATION", "Should fail schema validation, not version validation")
            print("ℹ️ Document without version defaulted to v1.x.x and was checked against schema")
        } else {
            print("✅ Document without version passed validation (defaulted to v1.x.x)")
        }
    }
    
    func testInvalidJSONStructure_ShouldFailSchemaValidation() {
        // Arrange: Create document with invalid JSON structure
        let invalidStructureDocument = JoyDoc(dictionary: [
            "v": "1.0.0",
            "identifier": 12345, // Should be string, not number
            "name": true, // Should be string, not boolean
            "files": "not_an_array" // Should be array, not string
        ])
        
        // Act: Validate schema
        let validationError = schemaManager.validateSchema(document: invalidStructureDocument)
        
        // Assert: Should fail schema validation
        XCTAssertNotNil(validationError, "Document with invalid JSON structure should fail validation")
        XCTAssertEqual(validationError?.code, "ERROR_SCHEMA_VALIDATION")
        
        if let error = validationError, let validationErrors = error.error {
            XCTAssertGreaterThan(validationErrors.count, 0, "Should contain specific validation errors")
            print("❌ Invalid JSON structure failed validation with \(validationErrors.count) errors")
        }
    }
    
    // MARK: - Integration Tests with DocumentEditor
    
    func testDocumentEditorWithSchemaValidation_ValidDocument() {
        // Arrange: Use valid document
        let document = sampleJSONDocument(fileName: "FieldTemplate_TableCollection_Poplated")
        
        // Act: Create DocumentEditor (which should perform schema validation internally)
        let documentEditor = DocumentEditor(document: document)
        
        // Assert: DocumentEditor should be created successfully
        XCTAssertNotNil(documentEditor, "DocumentEditor should be created for valid document")
        XCTAssertEqual(documentEditor.documentID, document.id, "Document ID should match")
        
        // Verify no schema errors in DocumentEditor
        XCTAssertNil(documentEditor.schemaError, "DocumentEditor should not have schema errors for valid document")
        
        print("✅ DocumentEditor created successfully with valid document")
    }
    
    func testDocumentEditorWithSchemaValidation_InvalidDocument() {
        // Arrange: Use invalid document
        let invalidDocument = JoyDoc(dictionary: [
            "v": "1.0.0",
            "identifier": "invalid_doc"
            // Missing required fields
        ])
        
        // Act: Create DocumentEditor
        let documentEditor = DocumentEditor(document: invalidDocument)
        
        // Assert: DocumentEditor should be created but with schema error
        XCTAssertNotNil(documentEditor, "DocumentEditor should still be created")
        XCTAssertNotNil(documentEditor.schemaError, "DocumentEditor should have schema error for invalid document")
        
        if let schemaError = documentEditor.schemaError {
            XCTAssertEqual(schemaError.code, "ERROR_SCHEMA_VALIDATION")
            print("❌ DocumentEditor created with schema error as expected: \(schemaError.message)")
        }
    }
    
    // MARK: - Performance Tests
    
    func testSchemaValidationPerformance() {
        // Arrange: Use a complex document
        let document = sampleJSONDocument(fileName: "FieldTemplate_TableCollection_Poplated")
        
        // Act & Assert: Measure validation performance
        measure {
            _ = schemaManager.validateSchema(document: document)
        }
    }
    
    // MARK: - Edge Cases
    
    func testEmptyDocument_ShouldFailValidation() {
        // Arrange: Empty document
        let emptyDocument = JoyDoc(dictionary: [:])
        
        // Act: Validate schema
        let validationError = schemaManager.validateSchema(document: emptyDocument)
        
        // Assert: Should fail validation
        XCTAssertNotNil(validationError, "Empty document should fail validation")
        XCTAssertEqual(validationError?.code, "ERROR_SCHEMA_VALIDATION")
        
        print("❌ Empty document failed validation as expected")
    }
    
    func testMalformedVersionString_ShouldDefaultToV1() {
        // Arrange: Document with malformed version
        let malformedVersionDocument = JoyDoc(dictionary: [
            "v": "not.a.version",
            "identifier": "malformed_version_doc",
            "name": "Malformed Version Document",
            "files": []
        ])
        
        // Act: Validate schema
        let validationError = schemaManager.validateSchema(document: malformedVersionDocument)
        
        // Assert: Should not fail due to version (should default to v1)
        if let error = validationError {
            XCTAssertEqual(error.code, "ERROR_SCHEMA_VALIDATION", "Should fail schema validation, not version validation")
        }
        
        print("ℹ️ Malformed version string handled gracefully")
    }
} 

func sampleJSONDocument(fileName: String = "Joydocjson") -> JoyDoc {
    let path = Bundle.main.path(forResource: fileName, ofType: "json")!
    let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
    let dict = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]
    return JoyDoc(dictionary: dict)
}
