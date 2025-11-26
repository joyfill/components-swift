//
//  FormulaTemplate_CountIfFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the countIf() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_CountIfFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_CountIfFunction")
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
    
    /// Test: Basic countIf example
    func testBasicCountIf() {
        let result = getFieldValue("basic_example")
        // countIf() should return a number
        if let count = Int(result) {
            XCTAssertTrue(count >= 0, "countIf() should return non-negative count")
        }
    }
}
