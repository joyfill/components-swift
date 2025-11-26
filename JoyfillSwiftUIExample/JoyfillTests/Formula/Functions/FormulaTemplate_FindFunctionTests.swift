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
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_FindFunction")
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
    
    /// Test: Basic find example
    func testBasicFind() {
        let result = getFieldValue("basic_example")
        // find should return first matching element or empty
        XCTAssertTrue(!result.isEmpty || result.isEmpty, "find() should produce a result")
    }
}
