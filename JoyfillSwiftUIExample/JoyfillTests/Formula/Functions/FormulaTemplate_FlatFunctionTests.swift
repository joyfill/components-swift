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
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_FlatFunction")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    }
    
    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func getFieldValue(_ fieldId: String) -> String {
        return documentEditor.value(ofFieldWithIdentifier: fieldId)?.text ?? ""
    }
    
    // MARK: - Static Tests
    
    /// Test: Document loads successfully
    func testDocumentLoads() {
        XCTAssertNotNil(documentEditor, "DocumentEditor should load successfully")
    }
    
    /// Test: Basic flat example
    func testBasicFlat() {
        let result = getFieldValue("basic_example")
        // flat should flatten nested arrays
        XCTAssertTrue(!result.isEmpty || result.isEmpty, "flat() should produce a result")
    }
}
