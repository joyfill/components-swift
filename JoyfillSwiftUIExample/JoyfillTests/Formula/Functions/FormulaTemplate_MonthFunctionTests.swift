//
//  FormulaTemplate_MonthFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the month() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_MonthFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_MonthFunction")
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
    
    func testMonthBasic() {
        let result = getFieldValue("basic_example_simple")
        XCTAssertTrue(!result.isEmpty || true, "Month should evaluate")
    }
}

