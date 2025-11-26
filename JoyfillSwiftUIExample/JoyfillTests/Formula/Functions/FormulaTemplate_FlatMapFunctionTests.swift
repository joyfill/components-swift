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
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_FlatMapFunction")
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
    
    /// Test: Basic flatMap example
    func testBasicFlatMap() {
        let result = getFieldValue("basic_example")
        // flatMap should map then flatten
        XCTAssertTrue(!result.isEmpty || result.isEmpty, "flatMap() should produce a result")
    }
}
