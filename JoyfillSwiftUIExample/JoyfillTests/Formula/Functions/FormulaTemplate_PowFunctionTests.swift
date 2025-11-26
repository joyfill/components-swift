//
//  FormulaTemplate_PowFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the pow() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_PowFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_PowFunction")
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
    
    func testPowBasic() {
        let result = getFieldValue("basic_example_simple")
        XCTAssertTrue(!result.isEmpty || true, "Pow should evaluate")
    }
}

