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
        if let error = schemaManager.validateSchema(document: document) {
            XCTAssertEqual("ERROR_SCHEMA_VERSION", error.code)
        }
        //check sdkversion and schema version
    }
    
    func testVersion() {
        let document = JoyDoc(dictionary: ["v": "1"])
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
                    
        let schemaManager = JoyfillSchemaManager()
        if let error = schemaManager.validateSchema(document: document) {
            XCTAssertNotEqual("ERROR_SCHEMA_VERSION", error.code)
            XCTAssertEqual("ERROR_SCHEMA_VALIDATION", error.code)
        }
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
        if let error = schemaManager.validateSchema(document: document) {
            XCTAssertNotEqual("ERROR_SCHEMA_VERSION", error.code)
            XCTAssertEqual("ERROR_SCHEMA_VALIDATION", error.code)
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
