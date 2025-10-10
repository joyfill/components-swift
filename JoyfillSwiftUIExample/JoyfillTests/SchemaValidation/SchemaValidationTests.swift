//
//  SchemaValidationtests.swift
//  JoyfillExample
//
//  Created by Vivek on 28/07/25.
//
import XCTest
import Foundation
import SwiftUI
import JoyfillModel
import Joyfill

final class SchemaValidationTests: XCTestCase {
    /// The schema version expected in `SchemaValidationError.details`.
    private let expectedSchemaVersion = "1.0.0"
    private let sdkVersion = "3.0.0-rc4"
    
    func documentEditor(document: JoyDoc) -> DocumentEditor {
        DocumentEditor(document: document)
    }
    
    //Version tests
    // 1. Backward compatiblity, 2. Forward compatiblity, 3. Normal
    func testForwardCompatality() {
        let document = JoyDoc(dictionary: ["v": "2"])
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
                    
        let schemaManager = JoyfillSchemaManager()
        let error = schemaManager.validateSchema(document: document)
        XCTAssertEqual("ERROR_SCHEMA_VERSION", error?.code)
        XCTAssertEqual(expectedSchemaVersion, error?.details.schemaVersion)
        XCTAssertEqual(sdkVersion, error?.details.sdkVersion)
    }
    
    func testVersion() {
        let document = JoyDoc(dictionary: ["v": "1"])
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
                    
        let schemaManager = JoyfillSchemaManager()
        let error = schemaManager.validateSchema(document: document)
        XCTAssertNotEqual("ERROR_SCHEMA_VERSION", error?.code)
        XCTAssertEqual("ERROR_SCHEMA_VALIDATION", error?.code)
        XCTAssertEqual(expectedSchemaVersion, error?.details.schemaVersion)
    }
    
    func testVersionWithPoints() {
        let document = JoyDoc(dictionary: ["v": "1.6.9"])
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .setHeadingText()
            .setTextField()
                    
        let schemaManager = JoyfillSchemaManager()
        let error = schemaManager.validateSchema(document: document)
        XCTAssertTrue(error == nil)
    }
    
    func testValidationWithAllValid() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .setHeadingText()
            .setTextField()
                    
        let schemaManager = JoyfillSchemaManager()
        let error = schemaManager.validateSchema(document: document)
        XCTAssertTrue(error == nil)
    }
    
    func testValidationWithNilVersion() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
                    
        let schemaManager = JoyfillSchemaManager()
        let error = schemaManager.validateSchema(document: document)
        XCTAssertNotEqual("ERROR_SCHEMA_VERSION", error?.code)
        XCTAssertEqual("ERROR_SCHEMA_VALIDATION", error?.code)
        XCTAssertEqual(expectedSchemaVersion, error?.details.schemaVersion)
    }

    func testVersionError_ReturnsCurrentSchemaVersion() {
        let doc = JoyDoc(dictionary: [
            "v": "2",
            "identifier": "ver-doc",
            "name": "Version Doc",
            "fields": [],
            "stage": "published"
        ])
        let manager = JoyfillSchemaManager()
        let error = manager.validateSchema(document: doc)
        
        XCTAssertEqual(error?.code, "ERROR_SCHEMA_VERSION")
        XCTAssertEqual(error?.details.schemaVersion, expectedSchemaVersion)
    }

    func testValidateSchema_RequiredFieldsMissing_ReturnsError() {
        let docMissingFields = JoyDoc(dictionary: [
            "identifier": "doc-missing-fields",
            "name": "Example"
            // deliberately omitting: files / fields / stage
        ])
        
        let schemaManager = JoyfillSchemaManager()
        let error = schemaManager.validateSchema(document: docMissingFields)
        
        XCTAssertNotNil(error, "SchemaManager should report an error when required properties are missing")
        XCTAssertEqual(error?.code, "ERROR_SCHEMA_VALIDATION")
        
        XCTAssertTrue(error?.error?.count ?? 0 > 0, "ValidationErrors array should contain at least one entry")
        XCTAssertEqual(error?.details.schemaVersion, expectedSchemaVersion)
        XCTAssertEqual(error?.details.sdkVersion, sdkVersion)
    }
    
    func testValidateSchema_InvalidPropertyTypes_ReturnsError() {
        let badTypeDoc = JoyDoc(dictionary: [
            "identifier": 12345,
            "name": ["not", "a", "string"],
            "fields": "oops"
        ])
        
        let schemaManager = JoyfillSchemaManager()
        let error = schemaManager.validateSchema(document: badTypeDoc)
        
        XCTAssertNotNil(error, "Error expected when property types are incorrect")
        XCTAssertEqual(error?.code, "ERROR_SCHEMA_VALIDATION")
        XCTAssertTrue((error?.error?.count ?? 0) > 0)
    }
    
    // MARK: - Required property coverage
    func testOmittingRequiredTopLevelPropertiesShouldFail() {
        let requiredKeys = ["files", "fields"]
        let manager = JoyfillSchemaManager()
        
        for key in requiredKeys {
            var dict: [String: Any] = [
                "files": [],
                "fields": []
            ]
            dict.removeValue(forKey: key)
            let doc = JoyDoc(dictionary: dict)
            let error = manager.validateSchema(document: doc)
            XCTAssertEqual("ERROR_SCHEMA_VALIDATION", error?.code, "Missing \(key) must fail validation")
            XCTAssertEqual(expectedSchemaVersion, error?.details.schemaVersion)
        }
    }
    
    func testMinimalValidDocumentPassesSchemaValidation() {
        // Build minimal valid document according to joyfill-schema.swift
        let docDict = minimalValidDocumentDictionary()
        let validDoc = JoyDoc(dictionary: docDict)
        let manager = JoyfillSchemaManager()
        XCTAssertNil(manager.validateSchema(document: validDoc), "Minimal valid document should pass schema validation")
    }

    // Utility to create a minimal valid document dictionary that passes schema
    private func minimalValidDocumentDictionary() -> [String: Any] {
        let page: [String: Any] = [
            "_id": "page1",
            "name": "Page 1",
            "fieldPositions": [],
            "width": 816,
            "height": 1056,
            "cols": 24,
            "rowHeight": 8,
            "layout": "grid",
            "presentation": "normal"
        ]
        let file: [String: Any] = [
            "_id": "file1",
            "name": "File 1",
            "styles": [:],
            "pages": [page],
            "pageOrder": ["page1"],
            "views": []
        ]
        return [
            "files": [file],
            "fields": []
        ]
    }

    // Cover required keys in TemplateFile
    func testMissingRequiredPropertiesInTemplateFileShouldFail() {
        let requiredKeys = ["_id", "pages", "pageOrder"]
        for key in requiredKeys {
            var docDict = minimalValidDocumentDictionary()
            guard var file = (docDict["files"] as? [[String: Any]])?.first else { XCTFail(); return }
            file.removeValue(forKey: key)
            docDict["files"] = [file]
            let doc = JoyDoc(dictionary: docDict)
            let error = JoyfillSchemaManager().validateSchema(document: doc)
            XCTAssertEqual("ERROR_SCHEMA_VALIDATION", error?.code, "Omitting TemplateFile.\(key) must fail")
            XCTAssertEqual(expectedSchemaVersion, error?.details.schemaVersion)
        }
    }

    // Cover required keys inside Page object
    func testMissingRequiredPropertiesInPageShouldFail() {
        let requiredKeys = ["_id", "name", "fieldPositions", "width", "height", "cols", "rowHeight", "layout", "presentation"]
        for key in requiredKeys {
            var docDict = minimalValidDocumentDictionary()
            guard var file = (docDict["files"] as? [[String: Any]])?.first,
                  var page = (file["pages"] as? [[String: Any]])?.first else { XCTFail(); return }
            page.removeValue(forKey: key)
            file["pages"] = [page]
            docDict["files"] = [file]
            let doc = JoyDoc(dictionary: docDict)
            let error = JoyfillSchemaManager().validateSchema(document: doc)
            XCTAssertEqual("ERROR_SCHEMA_VALIDATION", error?.code, "Omitting Page.\(key) must fail")
            XCTAssertEqual(expectedSchemaVersion, error?.details.schemaVersion)
        }
    }

    // Cover required keys in Field objects across multiple types
    func testMissingRequiredFieldPropertiesShouldFail() {
        let fieldTypes = ["text", "image", "number", "date", "dropdown", "signature"]
        let requiredKeys = ["_id", "file", "type"]
        let manager = JoyfillSchemaManager()
        
        for fType in fieldTypes {
            for key in requiredKeys {
                var docDict = minimalValidDocumentDictionary()
                var field: [String: Any] = [
                    "_id": "field1_\(fType)",
                    "type": fType,
                    "file": "file1"
                ]
                field.removeValue(forKey: key)
                docDict["fields"] = [field]
                let doc = JoyDoc(dictionary: docDict)
                let error = manager.validateSchema(document: doc)
                XCTAssertEqual("ERROR_SCHEMA_VALIDATION", error?.code, "Missing \(key) in \(fType) field should fail")
                XCTAssertEqual(expectedSchemaVersion, error?.details.schemaVersion)
            }
        }
    }

    func testMinimalFieldsValidPass() {
        let fieldTypes = ["text", "image", "number", "date", "dropdown", "signature"]
        for fType in fieldTypes {
            var docDict = minimalValidDocumentDictionary()
            var field: [String: Any] = [
                "_id": "field_\(fType)",
                "type": fType,
                "file": "file1"
            ]
            if fType == "dropdown" {
                field["options"] = []
            }
            docDict["fields"] = [field]
            let doc = JoyDoc(dictionary: docDict)
            let err = JoyfillSchemaManager().validateSchema(document: doc)
            XCTAssertNil(err, "Field of type \(fType) with required keys should pass validation")
        }
    }

    // MARK: - Type-mismatch tests
    func testTypeMismatch_TopLevelPropertiesShouldFail() {
        var cases: [(String, Any)] = [
            ("files", "not-array"), // should be array
            ("fields", "not-array")  // should be array
        ]
        for (key, badValue) in cases {
            var dict = minimalValidDocumentDictionary()
            dict[key] = badValue
            let doc = JoyDoc(dictionary: dict)
            let err = JoyfillSchemaManager().validateSchema(document: doc)
            XCTAssertEqual("ERROR_SCHEMA_VALIDATION", err?.code, "Type mismatch for top-level key \(key) should fail")
            XCTAssertEqual(expectedSchemaVersion, err?.details.schemaVersion)
        }
    }

    func testTypeMismatch_TemplateFilePropertiesShouldFail() {
        let mismatches: [(String, Any)] = [
            ("styles", "not-object"),         // expects object
            ("pages", "not-array"),
            ("pageOrder", "not-array"),
            ("views", "not-array")
        ]
        for (prop, badVal) in mismatches {
            var docDict = minimalValidDocumentDictionary()
            var file = (docDict["files"] as! [[String: Any]])[0]
            file[prop] = badVal
            docDict["files"] = [file]
            let doc = JoyDoc(dictionary: docDict)
            let err = JoyfillSchemaManager().validateSchema(document: doc)
            XCTAssertEqual("ERROR_SCHEMA_VALIDATION", err?.code, "Type mismatch for TemplateFile.\(prop) should fail")
            XCTAssertEqual(expectedSchemaVersion, err?.details.schemaVersion)
        }
    }

    func testTypeMismatch_PagePropertiesShouldFail() {
        let mismatches: [(String, Any)] = [
            ("width", "not-number"),
            ("fieldPositions", "not-array"),
            ("cols", "not-number")
        ]
        for (prop, badVal) in mismatches {
            var docDict = minimalValidDocumentDictionary()
            var file = (docDict["files"] as! [[String: Any]])[0]
            var page = (file["pages"] as! [[String: Any]])[0]
            page[prop] = badVal
            file["pages"] = [page]
            docDict["files"] = [file]
            let doc = JoyDoc(dictionary: docDict)
            let err = JoyfillSchemaManager().validateSchema(document: doc)
            XCTAssertEqual("ERROR_SCHEMA_VALIDATION", err?.code, "Type mismatch for Page.\(prop) should fail")
            XCTAssertEqual(expectedSchemaVersion, err?.details.schemaVersion)
        }
    }

    func testTypeMismatch_FieldPropertiesShouldFail() {
        let mismatches: [(String, Any)] = [
            ("_id", 12345),     // should be string
            ("file", 42),       // should be string
            ("type", ["text"]) // should be string
        ]
        for (prop, badVal) in mismatches {
            var docDict = minimalValidDocumentDictionary()
            var field: [String: Any] = [
                "_id": "field_text",
                "type": "text",
                "file": "file1"
            ]
            field[prop] = badVal
            docDict["fields"] = [field]
            let doc = JoyDoc(dictionary: docDict)
            let err = JoyfillSchemaManager().validateSchema(document: doc)
            XCTAssertEqual("ERROR_SCHEMA_VALIDATION", err?.code, "Type mismatch for Field.\(prop) should fail")
            XCTAssertEqual(expectedSchemaVersion, err?.details.schemaVersion)
        }
    }
}

private class MockFormChangeEvent: FormChangeEvent {
    var capturedError: JoyfillError?

    func onChange(changes: [Change], document: JoyDoc) {}
    func onFocus(event: FieldIdentifier) {}
    func onBlur(event: FieldIdentifier) {}
    func onUpload(event: UploadEvent) {}
    func onCapture(event: CaptureEvent) {}
    func onError(error: JoyfillError) { capturedError = error }
}

extension SchemaValidationTests {
    // Ensures that the onError callback is triggered with the correct error when schema validation fails.
    func testDocumentEditor_OnErrorCallbackIsTriggered() {
        let invalidDoc = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
        let mockEvents = MockFormChangeEvent()

        _ = DocumentEditor(document: invalidDoc, events: mockEvents) // validateSchema defaults to `true`

        XCTAssertNotNil(mockEvents.capturedError, "onError should be called for invalid document")
        if case .schemaValidationError(let schemaError) = mockEvents.capturedError! {
            XCTAssertEqual(schemaError.code, "ERROR_SCHEMA_VALIDATION")
        } else {
            XCTFail("Expected schemaValidationError")
        }
    }

    func testDocumentEditor_WithValidationDisabled_ShouldNotTriggerError() {
        let invalidDoc = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
        let mockEvents = MockFormChangeEvent()

        let editor = DocumentEditor(document: invalidDoc, events: mockEvents, validateSchema: false)

        XCTAssertNil(mockEvents.capturedError, "onError should NOT be called when validation is disabled")
        XCTAssertNil(editor.schemaError, "schemaError should be nil when validation is disabled")
    }
    
    func testOnErrorWithValidDocument() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .setHeadingText()
            .setTextField()
        
        let mockEvents = MockFormChangeEvent()

        let editor = DocumentEditor(document: document, events: mockEvents)
        XCTAssertNil(mockEvents.capturedError, "onError should NOT be called when document is valid")
        XCTAssertNil(editor.schemaError, "schemaError should be nil when document is valid")
    }
}
