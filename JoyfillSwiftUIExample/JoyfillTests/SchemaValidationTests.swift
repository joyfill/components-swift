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
    
    // MARK: - Working Test Cases for Schema Validation
    
    func testInvalidDocument_ShouldFailSchemaValidation() {
        // Arrange: Create an invalid document with missing required fields
        let invalidDocument = JoyDoc(dictionary: [
            "identifier": "test-doc",
            "name": "Invalid Doc"
            // Missing required fields like "fields", "stage", etc.
        ])
        
        // Act
        let result = schemaManager.validateSchema(document: invalidDocument)
        
        // Assert
        XCTAssertNotNil(result, "Invalid document should fail schema validation")
        XCTAssertEqual(result?.code, "ERROR_SCHEMA_VALIDATION")
        XCTAssertNotNil(result?.error, "Validation error should contain error details")
    }
    
    func testDocumentEditorWithSchemaValidation_InvalidDocument() {
        // Arrange: Create a document that will fail validation
        let invalidDocument = JoyDoc(dictionary: [
            "identifier": "test-doc",
            "name": "Test Doc"
            // Missing required fields
        ])
        
        // Act: Create DocumentEditor (which internally runs schema validation)
        let documentEditor = DocumentEditor(document: invalidDocument)
        
        // Assert: Should have schema error stored
        XCTAssertNotNil(documentEditor.schemaError, "DocumentEditor should detect schema error")
        XCTAssertEqual(documentEditor.schemaError?.code, "ERROR_SCHEMA_VALIDATION")
    }
    
    func testMissingRequiredFields_ShouldFailValidation() {
        // Arrange: Document missing critical required fields
        let documentWithMissingFields = JoyDoc(dictionary: [
            "identifier": "missing-fields-test"
            // Missing name, fields, stage, etc.
        ])
        
        // Act
        let result = schemaManager.validateSchema(document: documentWithMissingFields)
        
        // Assert
        XCTAssertNotNil(result, "Document with missing required fields should fail")
        XCTAssertEqual(result?.code, "ERROR_SCHEMA_VALIDATION")
        XCTAssertTrue(result!.error!.count > 0, "Should have validation errors")
    }
    
    func testUnsupportedVersion_ShouldFailVersionValidation() {
        // Arrange: Document with unsupported version
        let futureVersionDocument = JoyDoc(dictionary: [
            "v": "2.0.0", // Unsupported major version
            "identifier": "future-doc",
            "name": "Future Version Doc",
            "fields": [],
            "stage": "published"
        ])
        
        // Act
        let result = schemaManager.validateSchema(document: futureVersionDocument)
        
        // Assert
        XCTAssertNotNil(result, "Document with unsupported version should fail")
        XCTAssertEqual(result?.code, "ERROR_SCHEMA_VERSION")
        XCTAssertTrue(result!.message.contains("Unsupported JoyDoc version"), "Should indicate version incompatibility")
        XCTAssertEqual(result?.details.schemaVersion, "2.0.0")
    }
    
    func testNoVersion_ShouldDefaultToV1AndValidate() {
        // Arrange: Document without version (should default to v1.x.x)
        let noVersionDocument = JoyDoc(dictionary: [
            "identifier": "no-version-doc",
            "name": "No Version Doc"
            // No "v" field - should default to v1.x.x
        ])
        
        // Act
        let result = schemaManager.validateSchema(document: noVersionDocument)
        
        // Assert: Should not fail due to version (but may fail schema validation)
        // The important thing is that version validation passes (no ERROR_SCHEMA_VERSION)
        if let error = result {
            XCTAssertEqual(error.code, "ERROR_SCHEMA_VALIDATION", "Should fail schema validation, not version validation")
            XCTAssertNotEqual(error.code, "ERROR_SCHEMA_VERSION", "Should not fail version validation")
        }
        // If no error, that's also fine - means both version and schema passed
    }
    
    func testEmptyDocument_ShouldFailValidation() {
        // Arrange: Completely empty document
        let emptyDocument = JoyDoc(dictionary: [:])
        
        // Act
        let result = schemaManager.validateSchema(document: emptyDocument)
        
        // Assert
        XCTAssertNotNil(result, "Empty document should fail validation")
        XCTAssertEqual(result?.code, "ERROR_SCHEMA_VALIDATION")
    }
    
    func testInvalidJSONStructure_ShouldFailValidation() {
        // Arrange: Document with invalid field types
        let invalidStructureDocument = JoyDoc(dictionary: [
            "identifier": 12345, // Should be string
            "name": ["not", "a", "string"], // Should be string
            "fields": "not-an-array" // Should be array
        ])
        
        // Act
        let result = schemaManager.validateSchema(document: invalidStructureDocument)
        
        // Assert
        XCTAssertNotNil(result, "Document with invalid structure should fail")
        XCTAssertEqual(result?.code, "ERROR_SCHEMA_VALIDATION")
        XCTAssertTrue(result!.error!.count > 0, "Should have multiple validation errors")
    }
    
    func testMalformedVersion_ShouldHandleGracefully() {
        // Arrange: Document with malformed version string
        let malformedVersionDocument = JoyDoc(dictionary: [
            "v": "not-a-version",
            "identifier": "malformed-version-doc",
            "name": "Malformed Version Doc",
            "fields": [],
            "stage": "published"
        ])
        
        // Act
        let result = schemaManager.validateSchema(document: malformedVersionDocument)
        
        // Assert: Should treat as v1.x.x and continue with schema validation
        if let error = result {
            // Should not fail on version, only on schema if there are schema issues
            XCTAssertNotEqual(error.code, "ERROR_SCHEMA_VERSION", "Should not fail version validation with malformed version")
        }
    }
    
    func testSchemaValidationPerformance() {
        // Arrange: Create a moderately complex document for performance testing
        let performanceDocument = JoyDoc(dictionary: [
            "identifier": "perf-test-doc",
            "name": "Performance Test Document",
            // Add more fields to make it realistic
        ])
        
        // Act & Assert: Measure performance
        measure {
            _ = schemaManager.validateSchema(document: performanceDocument)
        }
    }
}
