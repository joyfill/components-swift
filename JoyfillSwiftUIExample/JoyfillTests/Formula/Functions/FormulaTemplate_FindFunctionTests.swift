//
//  FormulaTemplate_FindFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the find() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_FindFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_FindFunction")
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

