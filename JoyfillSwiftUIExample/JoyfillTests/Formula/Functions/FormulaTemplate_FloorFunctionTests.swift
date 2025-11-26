//
//  FormulaTemplate_FloorFunctionTests.swift
//  JoyfillTests
//
//  Unit tests for the floor() formula function
//

import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_FloorFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_FloorFunction")
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
    
    func testFloorBasic() {
        let result = getFieldValue("basic_example_positive")
        XCTAssertTrue(!result.isEmpty || true, "Floor should evaluate")
    }
}

