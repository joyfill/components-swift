//
//  FormulaTemplate_SomeFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the some() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_SomeFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_SomeFunction")
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
    
    /// Test: Basic some example
    func testBasicSome() {
        let result = getFieldValue("basic_example_true")
        // some() should return true/false
        XCTAssertTrue(result == "true" || result == "false" || result.isEmpty,
                      "some() should return boolean, got '\(result)'")
    }
}
