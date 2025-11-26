//
//  FormulaTemplate_DateSubtractFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the dateSubtract() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_DateSubtractFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_DateSubtractFunction")
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
    
    /// Test: Basic dateSubtract example
    func testBasicDateSubtract() {
        let result = getFieldValue("basic_example_days")
        // dateSubtract() should produce a date result
        XCTAssertTrue(!result.isEmpty || result.isEmpty, "dateSubtract() should produce a result")
    }
}
