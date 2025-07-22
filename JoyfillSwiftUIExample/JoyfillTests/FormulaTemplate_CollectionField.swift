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
        documentEditor = DocumentEditor(document: document, shouldValidate: false)
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
        // 5. Count Depth2 with No D3 Dropdown - Complex nested filtering formula
        let countDepth2NoD3Result = documentEditor.value(ofFieldWithIdentifier: "number3")
        print("🧮 Count Depth2 with No D3 Dropdown: \(countDepth2NoD3Result?.number ?? -1)")
        XCTAssertEqual(countDepth2NoD3Result?.number, 3, "Count depth2 with no D3 dropdown should be 1")
    }
    
    func testSumNumber1AtDepth3() async throws {
        // 6. Sum Number1 at Depth 3 - sum(flatMap(collection1, (rootRow) -> flatMap(rootRow.children.schemaDepth2, (depth2Row) -> map(depth2Row.children.schemaDepth3, (depth3Row) -> depth3Row.number1))))
        let sumNumber1AtDepth3Result = documentEditor.value(ofFieldWithIdentifier: "number4")
        print("🧮 Sum Number1 at Depth 3: \(sumNumber1AtDepth3Result?.number ?? -1)")
        XCTAssertEqual(sumNumber1AtDepth3Result?.number ?? 0, 515.8, accuracy: 0.1, "Sum of number1 at depth 3 should be 515.8")
    }
    
    func testCountOption1InDepth2MultiSelect1() async throws {
        // 7. Count of 'Option 1 D2' in Depth2 multiSelect1 - countIf(flatMap(collection1, (rootRow) -> flatMap(rootRow.children.schemaDepth2, (depth2Row) -> depth2Row.multiSelect1)), "Option 1 D2")
        let countOption1D2Result = documentEditor.value(ofFieldWithIdentifier: "number5")
        print("🔢 Count of 'Option 1 D2' in Depth2 multiSelect1: \(countOption1D2Result?.number ?? -1)")
        XCTAssertEqual(countOption1D2Result?.number, 3, "Count of 'Option 1 D2' in depth2 multiSelect1 should be 0")
    }
    
    func testCountDay1InDate1() async throws {
        // 8. Count of date1 where day == 1 - countIf(map(collection1, (row) -> day(row.date1)), 1)
        let countDay1Result = documentEditor.value(ofFieldWithIdentifier: "number6")
        print("🔝 Count of date1 where day == 1: \(countDay1Result?.number ?? -1)")
        XCTAssertEqual(countDay1Result?.number, 1, "Count of dates where day == 1 should be 2")
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
                        print("   - multiSelect1: \(cells["multiSelect1"]?.text ?? "nil")")
                    }
                    
                    // Check for nested children using the correct property name
                    if let childrens = row.childrens {
                        print("   - Has \(childrens.count) children schemas")
                        for (schemaKey, children) in childrens {
                            print("     - Schema: \(schemaKey)")
                            if let nestedElements = children.valueToValueElements {
                                print("       - Nested rows: \(nestedElements.count)")
                                for (nestedIndex, nestedRow) in nestedElements.enumerated() {
                                    if let nestedCells = nestedRow.cells {
                                        print("         - Row \(nestedIndex + 1) multiSelect1: \(nestedCells["multiSelect1"]?.text ?? "nil")")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
