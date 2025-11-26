//
//  FormulaTemplate_YearFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the year() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_YearFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_YearFunction")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    }
    
    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    private func getFieldValue(_ fieldId: String) -> String {
        return documentEditor.value(ofFieldWithIdentifier: fieldId)?.text ?? ""
    }
    
    func testDocumentLoads() {
        XCTAssertNotNil(documentEditor, "Document should load successfully")
    }
}

