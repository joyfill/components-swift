//
//  FormulaTemplate_FlatFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the flat() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_FlatFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_FlatFunction")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    }
    
    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    func testDocumentLoads() {
        XCTAssertNotNil(documentEditor, "Document should load successfully")
    }
}

