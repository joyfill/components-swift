//
//  FormulaTemplate_FlatMapFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the flatMap() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_FlatMapFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_FlatMapFunction")
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

