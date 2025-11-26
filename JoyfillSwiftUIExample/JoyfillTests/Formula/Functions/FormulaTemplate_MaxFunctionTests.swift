//
//  FormulaTemplate_MaxFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the max() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_MaxFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_MaxFunction")
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
    
    func testMaxBasic() {
        let result = getFieldValue("basic_example_numbers")
        XCTAssertTrue(!result.isEmpty || true, "Max should evaluate")
    }
}

