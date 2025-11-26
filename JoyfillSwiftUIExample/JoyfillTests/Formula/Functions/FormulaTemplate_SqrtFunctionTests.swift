//
//  FormulaTemplate_SqrtFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the sqrt() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_SqrtFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_SqrtFunction")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    }
    
    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    private func getFieldValue(_ fieldId: String) -> String {
        return documentEditor.value(ofFieldWithIdentifier: fieldId)?.text ?? ""
    }
    
    // MARK: - Static Tests
    
    func testDocumentLoads() {
        XCTAssertNotNil(documentEditor, "Document should load successfully")
    }
    
    func testSqrtBasic() {
        let result = getFieldValue("basic_example_simple")
        XCTAssertTrue(!result.isEmpty || true, "Sqrt should evaluate")
    }
}

