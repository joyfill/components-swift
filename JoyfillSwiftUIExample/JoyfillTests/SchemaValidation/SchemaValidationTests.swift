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
