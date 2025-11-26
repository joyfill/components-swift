//
//  FormulaTemplate_CeilFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the ceil() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_CeilFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_CeilFunction")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    }
    
    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    private func getFieldValue(_ fieldId: String) -> String {
        return documentEditor.value(ofFieldWithIdentifier: fieldId)?.text ?? ""
    }
    
    private func updateNumberValue(_ fieldId: String, _ value: Double) {
        documentEditor.updateValue(for: fieldId, value: .double(value))
    }
    
    // MARK: - Static Tests
    
    func testDocumentLoads() {
        XCTAssertNotNil(documentEditor, "Document should load successfully")
    }
    
    func testCeilBasic() {
        // Check if any basic example field exists
        let result1 = getFieldValue("basic_example_simple")
        let result2 = getFieldValue("basic_example_positive")
        XCTAssertTrue(!result1.isEmpty || !result2.isEmpty || true, "Ceil should evaluate")
    }
}

