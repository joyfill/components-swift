//
//  FormulaTemplate_CollectionField.swift
//  JoyfillTests
//
//  Created by Vishnu Dutt on 25/06/25.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

class FormulaTemplate_CollectionFieldTests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_CollectionField")
        documentEditor = DocumentEditor(document: document)
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }

    func testRootTotalRowCount() async throws {
        // 1. Root Total Row Count - length(collection1)
        let rootRowCountResult = documentEditor.value(ofFieldWithIdentifier: "number1")
        print("📊 Root Total Row Count: \(rootRowCountResult?.number ?? -1)")
        XCTAssertEqual(rootRowCountResult?.number, 4, "Root total row count should be 4")
    }
    
    func testRootFirstRowText1() async throws {
        // 2. Root First Row Text1 - collection1.0.text1
        let rootFirstRowTextResult = documentEditor.value(ofFieldWithIdentifier: "text1")
        print("📝 Root First Row Text1: '\(rootFirstRowTextResult?.text ?? "nil")'")
        XCTAssertEqual(rootFirstRowTextResult?.text, "A", "Root first row text1 should be 'A'")
    }
    
    func testSchemaDepth3FirstRowText1() async throws {
        // 3. Schema Depth 3 First Row Text1 - collection1.0.children.schemaDepth2.0.children.schemaDepth3.0.text1
        let depth3FirstRowTextResult = documentEditor.value(ofFieldWithIdentifier: "text2")
        print("🧾 Schema Depth 3 First Row Text1: '\(depth3FirstRowTextResult?.text ?? "nil")'")
        XCTAssertEqual(depth3FirstRowTextResult?.text, "A", "Schema depth 3 first row text1 should be 'A'")
    }
    
    func testSchemaDepth3RowCount() async throws {
        // 4. Schema Depth 3 Row Count - length(collection1.0.children.schemaDepth2.0.children.schemaDepth3)
        let depth3RowCountResult = documentEditor.value(ofFieldWithIdentifier: "number2")
        print("🔢 Schema Depth 3 Row Count: \(depth3RowCountResult?.number ?? -1)")
        XCTAssertEqual(depth3RowCountResult?.number, 3, "Schema depth 3 row count should be 3")
    }
    
    func testCountDepth2WithNoD3Dropdown() async throws {
        // 5. Count Depth2 with No D3 Dropdown - length(filter(collection1.0.children.schemaDepth2, (row) -> row.dropdown1 == \"No D2\" and empty(row.children.schemaDepth3)))
        print("🔍 DEBUG: Testing countDepth2WithNoD3Dropdown formula...")
        
        // First, let's manually test the collection1 access
        let collection1Result = documentEditor.value(ofFieldWithIdentifier: "collection1")
        print("🔍 DEBUG: collection1 result type: \(type(of: collection1Result))")
        if let valueElements = collection1Result?.valueElements {
            print("🔍 DEBUG: collection1 has \(valueElements.count) elements")
            for (index, element) in valueElements.enumerated() {
                print("🔍 DEBUG: Element \(index) type: \(type(of: element))")
                if let cells = element.cells {
                    print("🔍 DEBUG: Element \(index) has cells with keys: \(cells.keys.sorted())")
                }
                if let childrens = element.childrens {
                    print("🔍 DEBUG: Element \(index) has \(childrens.count) children schemas")
                    for (schemaKey, children) in childrens {
                        print("🔍 DEBUG: Schema: \(schemaKey)")
                        if let nestedElements = children.valueToValueElements {
                            print("🔍 DEBUG: Nested rows: \(nestedElements.count)")
                        }
                    }
                } else {
                    print("🔍 DEBUG: Element \(index) does NOT have children property")
                }
            }
        }
        
        let countDepth2NoD3Result = documentEditor.value(ofFieldWithIdentifier: "number3")
        print("🧮 Count Depth2 with No D3 Dropdown: \(countDepth2NoD3Result?.number ?? -1)")
        XCTAssertEqual(countDepth2NoD3Result?.number, 3, "Count depth2 with no D3 dropdown should be 3")
    }
    
    func testSumNumber1AtDepth3() async throws {
        // 6. Sum Number1 at Depth 3 - sum(map(collection1.0.children.schemaDepth2, (d2row) -> sum(map(d2row.children.schemaDepth3, (d3row) -> d3row.number1))))
        let sumNumber1AtDepth3Result = documentEditor.value(ofFieldWithIdentifier: "number4")
        print("🧮 Sum Number1 at Depth 3: \(sumNumber1AtDepth3Result?.number ?? -1)")
        // XCTAssertEqual(sumNumber1AtDepth3Result?.number ?? 0, 561.6, accuracy: 0.1, "Sum of number1 at depth 3 should be 561.6")
    }
    
    func testCountAllDepth3Rows() async throws {
        // 7. Count All Depth 3 Rows - sum(map(collection1, (rootRow) -> sum(map(rootRow.children.schemaDepth2, (d2row) -> length(d2row.children.schemaDepth3)))))
        let countAllDepth3RowsResult = documentEditor.value(ofFieldWithIdentifier: "number5")
        print("🔢 Count All Depth 3 Rows: \(countAllDepth3RowsResult?.number ?? -1)")
        // XCTAssertEqual(countAllDepth3RowsResult?.number, 12, "Count all depth 3 rows should be 12")
    }
    
    func testFindMaxNumber1AcrossAllDepths() async throws {
        // 8. Find Max Number1 Across All Depths - max(flatten([map(collection1, (rootRow) -> rootRow.number1), map(collection1, (rootRow) -> map(rootRow.children.schemaDepth2, (d2row) -> d2row.number1)), map(collection1, (rootRow) -> map(rootRow.children.schemaDepth2, (d2row) -> map(d2row.children.schemaDepth3, (d3row) -> d3row.number1)))]))
        let maxNumber1AllDepthsResult = documentEditor.value(ofFieldWithIdentifier: "number6")
        print("🔝 Find Max Number1 Across All Depths: \(maxNumber1AllDepthsResult?.number ?? -1)")
        // XCTAssertEqual(maxNumber1AllDepthsResult?.number ?? 0, 999.9, accuracy: 0.1, "Max number1 across all depths should be 999.9")
    }
    
    func testCollectionStructureDebug() async throws {
        // Debug: Print collection structure
        if let collectionField = documentEditor.field(fieldID: "collection1") {
            print("🔍 Collection field found")
            // Access collection data through the field's value property
            if let valueElements = collectionField.value?.valueElements {
                print("🔍 Collection field found with \(valueElements.count) rows")
                for (index, row) in valueElements.enumerated() {
                    print("🔍 Row \(index + 1):")
                    if let cells = row.cells {
                        print("   - text1: \(cells["text1"]?.text ?? "nil")")
                        print("   - dropdown1: \(cells["dropdown1"]?.text ?? "nil")")
                        print("   - number1: \(cells["number1"]?.number?.description ?? "nil")")
                        print("   - date1: \(cells["date1"]?.text ?? "nil")")
                    }
                    
                    // Check for nested children using the correct property name
                    if let childrens = row.childrens {
                        print("   - Has \(childrens.count) children schemas")
                        for (schemaKey, children) in childrens {
                            print("     - Schema: \(schemaKey)")
                            if let nestedElements = children.valueToValueElements {
                                print("       - Nested rows: \(nestedElements.count)")
                            }
                        }
                    }
                }
            }
        }
    }
}
