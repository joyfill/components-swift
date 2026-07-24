//
//  CollectionViewModelDocumentEditorDelegateTests.swift
//  JoyfillTests
//
//  Created by iOS developer on 22/7/25
//

import XCTest
import Foundation
import SwiftUI
import JoyfillModel
@testable import Joyfill

final class CollectionViewModelDocumentEditorDelegateTests: XCTestCase {
    
    private let fileID = "685750ef698da1ab427761ba"
    private let pageID = "685750efeb612f4fac5819dd"
    private let tableFieldID = "6857510fbfed1553e168161b"
    
    // MARK: - Test Helpers
    
    private func createTestDocument() -> JoyDoc {
        sampleJSONDocument(fileName: "ChangerHandlerUnit")
    }
    
    private func createCollectionViewModel(documentEditor: DocumentEditor) async throws -> CollectionViewModel {
        let field = documentEditor.field(fieldID: tableFieldID)
        let fieldHeaderModel = FieldHeaderModel(title: field?.title, required: field?.required, tipDescription: field?.tipDescription, tipTitle: field?.tipTitle, tipVisible: field?.tipVisible, visibleLimitInFields: documentEditor.decoratorConfig.visibleLimitInFields)
        let tableDataModel = TableDataModel(
            fieldHeaderModel: fieldHeaderModel,
            mode: Mode.fill,
            documentEditor: documentEditor,
            fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        )
        guard let tableDataModel else { fatalError("TableViewModel not found") }
        return try await CollectionViewModel(tableDataModel: tableDataModel)
    }
    
    func waitForMainQueueToDrain(file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Drain main queue")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
    }
    
    func testApplyRowEditChanges_AddNewRow() async throws {
        let document = createTestDocument()
        let documentEditor = DocumentEditor(document: document, validateSchema: false)
        
        let viewModel = try await createCollectionViewModel(documentEditor: documentEditor)
        sleep(10)
        
        let changeDict: [String: Any] = [
            "fieldIdentifier": "field_68575112847f32f878c77daf",
            "_id": "685750eff3216b45ffe73c80",
            "fieldPositionId": "68575112158ff5dbaa9f78e1",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "v": 1,
            "pageId": "685750efeb612f4fac5819dd",
            "sdk": "swift",
            "target": "field.value.rowCreate",
            "fileId": "685750ef698da1ab427761ba",
            "fieldId": "6857510fbfed1553e168161b",
            "createdOn": 1756809956.175348,
            "change": [
                "row": [
                    "_id": "68b6cae471b0cf51b557e9e2",
                    "cells": [:] as [String: Any],
                    "children": [
                        "685753949107b403e2e4a949": [
                            "value": [] as [Any]
                        ] as [String: Any]
                    ] as [String: Any]
                ] as [String: Any],
                "schemaId": "collectionSchemaId",
                "targetRowIndex": 4,
                "parentPath": ""
            ] as [String: Any]
        ]
        
        let change = Change(dictionary: changeDict)
        documentEditor.change(changes: [change])
        
        let updatedNumberOfRows = viewModel.tableDataModel.valueToValueElements?.count
        let updatedNumberOFRowsFromDocumentEditor = documentEditor.field(fieldID: "6857510fbfed1553e168161b")?.valueToValueElements?.count
        XCTAssertEqual(updatedNumberOfRows, 5, "Rows should be updated")
        XCTAssertEqual(updatedNumberOFRowsFromDocumentEditor, 5, "Rows should be updated")
    }
    
    func testApplyRowEditChanges_BulkUpdate() async throws {
        let document = createTestDocument()
        let documentEditor = DocumentEditor(document: document, validateSchema: false)
        let viewModel = try await createCollectionViewModel(documentEditor: documentEditor)
        sleep(10)
        
        let changeDict1: [String: Any] = [
            "pageId": "685750efeb612f4fac5819dd",
            "fieldIdentifier": "field_68575112847f32f878c77daf",
            "_id": "685750eff3216b45ffe73c80",
            "fieldPositionId": "68575112158ff5dbaa9f78e1",
            "change": [
                "schemaId": "collectionSchemaId",
                "row": [
                    "_id": "68575bb9cdb3707c78d6b2ff",
                    "cells": [
                        "684c3fedb0afd867adaeb3b4": "Testing"
                    ] as [String: Any]
                ] as [String: Any],
                "parentPath": "",
                "rowId": "68575bb9cdb3707c78d6b2ff"
            ] as [String: Any],
            "fieldId": "6857510fbfed1553e168161b",
            "target": "field.value.rowUpdate",
            "v": 1,
            "fileId": "685750ef698da1ab427761ba",
            "createdOn": 1756812875.717525,
            "sdk": "swift",
            "identifier": "doc_685750eff3216b45ffe73c80"
        ]
        
        let changeDict2: [String: Any] = [
            "target": "field.value.rowUpdate",
            "fieldIdentifier": "field_68575112847f32f878c77daf",
            "fileId": "685750ef698da1ab427761ba",
            "createdOn": 1756812875.717535,
            "identifier": "doc_685750eff3216b45ffe73c80",
            "pageId": "685750efeb612f4fac5819dd",
            "fieldPositionId": "68575112158ff5dbaa9f78e1",
            "sdk": "swift",
            "change": [
                "schemaId": "collectionSchemaId",
                "parentPath": "",
                "rowId": "685765dcf190077e95796c41",
                "row": [
                    "cells": [
                        "684c3fedb0afd867adaeb3b4": "Testing"
                    ] as [String: Any],
                    "_id": "685765dcf190077e95796c41"
                ] as [String: Any]
            ] as [String: Any],
            "_id": "685750eff3216b45ffe73c80",
            "fieldId": "6857510fbfed1553e168161b",
            "v": 1
        ]
        
        let changeDict3: [String: Any] = [
            "identifier": "doc_685750eff3216b45ffe73c80",
            "pageId": "685750efeb612f4fac5819dd",
            "createdOn": 1756812875.7175369,
            "fileId": "685750ef698da1ab427761ba",
            "_id": "685750eff3216b45ffe73c80",
            "fieldPositionId": "68575112158ff5dbaa9f78e1",
            "sdk": "swift",
            "fieldId": "6857510fbfed1553e168161b",
            "v": 1,
            "target": "field.value.rowUpdate",
            "fieldIdentifier": "field_68575112847f32f878c77daf",
            "change": [
                "row": [
                    "_id": "68582dd76e0e93dd2017372a",
                    "cells": [
                        "684c3fedb0afd867adaeb3b4": "Testing"
                    ] as [String: Any]
                ] as [String: Any],
                "schemaId": "collectionSchemaId",
                "parentPath": "",
                "rowId": "68582dd76e0e93dd2017372a"
            ] as [String: Any]
        ]
        
        let changeDict4: [String: Any] = [
            "fileId": "685750ef698da1ab427761ba",
            "target": "field.value.rowUpdate",
            "fieldId": "6857510fbfed1553e168161b",
            "fieldIdentifier": "field_68575112847f32f878c77daf",
            "pageId": "685750efeb612f4fac5819dd",
            "sdk": "swift",
            "change": [
                "rowId": "68582dde1b30a59b4272a5c7",
                "schemaId": "collectionSchemaId",
                "parentPath": "",
                "row": [
                    "_id": "68582dde1b30a59b4272a5c7",
                    "cells": [
                        "684c3fedb0afd867adaeb3b4": "Testing"
                    ] as [String: Any]
                ] as [String: Any]
            ] as [String: Any],
            "createdOn": 1756812875.71754,
            "identifier": "doc_685750eff3216b45ffe73c80",
            "_id": "685750eff3216b45ffe73c80",
            "v": 1,
            "fieldPositionId": "68575112158ff5dbaa9f78e1"
        ]
        
        let change1 = Change(dictionary: changeDict1)
        let change2 = Change(dictionary: changeDict2)
        let change3 = Change(dictionary: changeDict3)
        let change4 = Change(dictionary: changeDict4)
        documentEditor.change(changes: [change1, change2, change3, change4])
        waitForMainQueueToDrain()
        let updatedRows = viewModel.tableDataModel.valueToValueElements
        let updatedRowsFromDocumentEditor = documentEditor.field(fieldID: "6857510fbfed1553e168161b")?.valueToValueElements
        
        let ChangeValue1 = updatedRows?.first(where: {$0.id == "68575bb9cdb3707c78d6b2ff"})?.cells?["684c3fedb0afd867adaeb3b4"]
        let ChangeValue2 = updatedRows?.first(where: {$0.id == "685765dcf190077e95796c41"})?.cells?["684c3fedb0afd867adaeb3b4"]
        let ChangeValue3 = updatedRows?.first(where: {$0.id == "68582dd76e0e93dd2017372a"})?.cells?["684c3fedb0afd867adaeb3b4"]
        let ChangeValue4 = updatedRows?.first(where: {$0.id == "68582dde1b30a59b4272a5c7"})?.cells?["684c3fedb0afd867adaeb3b4"]
        XCTAssertEqual(ChangeValue1?.text, "Testing", "Value should be equal")
        XCTAssertEqual(ChangeValue2?.text, "Testing", "Value should be equal")
        XCTAssertEqual(ChangeValue3?.text, "Testing", "Value should be equal")
        XCTAssertEqual(ChangeValue4?.text, "Testing", "Value should be equal")
        
        let ChangeValueFromDocument1 = updatedRowsFromDocumentEditor?.first(where: {$0.id == "68575bb9cdb3707c78d6b2ff"})?.cells?["684c3fedb0afd867adaeb3b4"]
        let ChangeValueFromDocument2 = updatedRowsFromDocumentEditor?.first(where: {$0.id == "685765dcf190077e95796c41"})?.cells?["684c3fedb0afd867adaeb3b4"]
        let ChangeValueFromDocument3 = updatedRowsFromDocumentEditor?.first(where: {$0.id == "68582dd76e0e93dd2017372a"})?.cells?["684c3fedb0afd867adaeb3b4"]
        let ChangeValueFromDocument4 = updatedRowsFromDocumentEditor?.first(where: {$0.id == "68582dde1b30a59b4272a5c7"})?.cells?["684c3fedb0afd867adaeb3b4"]
        XCTAssertEqual(ChangeValueFromDocument1?.text, "Testing", "Value should be equal")
        XCTAssertEqual(ChangeValueFromDocument2?.text, "Testing", "Value should be equal")
        XCTAssertEqual(ChangeValueFromDocument3?.text, "Testing", "Value should be equal")
        XCTAssertEqual(ChangeValueFromDocument4?.text, "Testing", "Value should be equal")
    }
    
    func testApplyRowEditChanges_AddAndInsert() async throws {
        let document = createTestDocument()
        let documentEditor = DocumentEditor(document: document, validateSchema: false)
        let viewModel = try await createCollectionViewModel(documentEditor: documentEditor)
        sleep(10)
        let changeDict1: [String: Any] = [
            "fieldIdentifier": "field_68575112847f32f878c77daf",
            "_id": "685750eff3216b45ffe73c80",
            "fieldId": "6857510fbfed1553e168161b",
            "v": 1,
            "sdk": "swift",
            "fileId": "685750ef698da1ab427761ba",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "fieldPositionId": "68575112158ff5dbaa9f78e1",
            "pageId": "685750efeb612f4fac5819dd",
            "change": [
                "parentPath": "",
                "schemaId": "collectionSchemaId",
                "targetRowIndex": 4,
                "row": [
                    "cells": [:] as [String: Any],
                    "_id": "68b6e21dbf076c55c4c4c23d",
                    "children": [
                        "685753949107b403e2e4a949": [
                            "value": [] as [Any]
                        ] as [String: Any]
                    ] as [String: Any]
                ] as [String: Any]
            ] as [String: Any],
            "createdOn": 1756815901.14731,
            "target": "field.value.rowCreate"
        ]
        
        let changeDict2: [String: Any] = [
            "fieldPositionId": "68575112158ff5dbaa9f78e1",
            "target": "field.value.rowUpdate",
            "fieldId": "6857510fbfed1553e168161b",
            "createdOn": 1756815907.229795,
            "pageId": "685750efeb612f4fac5819dd",
            "fieldIdentifier": "field_68575112847f32f878c77daf",
            "v": 1,
            "sdk": "swift",
            "_id": "685750eff3216b45ffe73c80",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "fileId": "685750ef698da1ab427761ba",
            "change": [
                "rowId": "68b6e21dbf076c55c4c4c23d",
                "row": [
                    "_id": "68b6e21dbf076c55c4c4c23d",
                    "cells": [
                        "684c3fedb0afd867adaeb3b4": "New row"
                    ] as [String: Any]
                ] as [String: Any],
                "parentPath": "",
                "schemaId": "collectionSchemaId"
            ] as [String: Any]
        ]
        
        let change1 = Change(dictionary: changeDict1)
        let change2 = Change(dictionary: changeDict2)
        documentEditor.change(changes: [change1, change2])
        // Ensure that main-queue work has executed before asserting
        waitForMainQueueToDrain()
        
        // Get the updated rows from both sources
        let updatedRows = viewModel.tableDataModel.valueToValueElements
        let updatedRowsFromDocumentEditor = documentEditor.field(fieldID: "6857510fbfed1553e168161b")?.valueToValueElements
        XCTAssertEqual(updatedRows?.count, 5, "rows count should be 6")
        XCTAssertEqual(updatedRowsFromDocumentEditor?.count, 5, "rows count should be 6 from document")
        
        
        let ChangeValue1 = updatedRows?.first(where: {$0.id == "68b6e21dbf076c55c4c4c23d"})?.cells?["684c3fedb0afd867adaeb3b4"]
        XCTAssertEqual(ChangeValue1?.text, "New row", "Value should be equal")
        
        let ChangeValueFromDocument1 = updatedRowsFromDocumentEditor?.first(where: {$0.id == "68b6e21dbf076c55c4c4c23d"})?.cells?["684c3fedb0afd867adaeb3b4"]
        XCTAssertEqual(ChangeValueFromDocument1?.text, "New row", "Value should be equal from document")
    }
    
    func testApplyRowEditChanges_DeleteAddAndInsert() async throws {
        let document = createTestDocument()
        let documentEditor = DocumentEditor(document: document, validateSchema: false)
        let viewModel = try await createCollectionViewModel(documentEditor: documentEditor)
        sleep(10)
        // 1) rowDelete — "68575bb9cdb3707c78d6b2ff"
        let changeDict1: [String: Any] = [
            "v": 1,
            "fieldPositionId": "68575112158ff5dbaa9f78e1",
            "target": "field.value.rowDelete",
            "_id": "685750eff3216b45ffe73c80",
            "fileId": "685750ef698da1ab427761ba",
            "createdOn": 1756891232.610369,
            "identifier": "doc_685750eff3216b45ffe73c80",
            "change": [
                "rowId": "68575bb9cdb3707c78d6b2ff",
                "parentPath": "",
                "schemaId": "collectionSchemaId"
            ] as [String: Any],
            "fieldId": "6857510fbfed1553e168161b",
            "pageId": "685750efeb612f4fac5819dd",
            "fieldIdentifier": "field_68575112847f32f878c77daf",
            "sdk": "swift"
        ]

        // 2) rowDelete — "685765dcf190077e95796c41"
        let changeDict2: [String: Any] = [
            "fileId": "685750ef698da1ab427761ba",
            "fieldIdentifier": "field_68575112847f32f878c77daf",
            "sdk": "swift",
            "change": [
                "rowId": "685765dcf190077e95796c41",
                "schemaId": "collectionSchemaId",
                "parentPath": ""
            ] as [String: Any],
            "createdOn": 1756891232.6103849,
            "fieldId": "6857510fbfed1553e168161b",
            "v": 1,
            "pageId": "685750efeb612f4fac5819dd",
            "_id": "685750eff3216b45ffe73c80",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "fieldPositionId": "68575112158ff5dbaa9f78e1",
            "target": "field.value.rowDelete"
        ]

        // 3) rowDelete — "68582dd76e0e93dd2017372a"
        let changeDict3: [String: Any] = [
            "fileId": "685750ef698da1ab427761ba",
            "fieldIdentifier": "field_68575112847f32f878c77daf",
            "v": 1,
            "change": [
                "schemaId": "collectionSchemaId",
                "rowId": "68582dd76e0e93dd2017372a",
                "parentPath": ""
            ] as [String: Any],
            "sdk": "swift",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "target": "field.value.rowDelete",
            "pageId": "685750efeb612f4fac5819dd",
            "fieldPositionId": "68575112158ff5dbaa9f78e1",
            "createdOn": 1756891232.610394,
            "_id": "685750eff3216b45ffe73c80",
            "fieldId": "6857510fbfed1553e168161b"
        ]

        // 4) rowDelete — "68582dde1b30a59b4272a5c7"
        let changeDict4: [String: Any] = [
            "fieldIdentifier": "field_68575112847f32f878c77daf",
            "fieldPositionId": "68575112158ff5dbaa9f78e1",
            "createdOn": 1756891232.610404,
            "target": "field.value.rowDelete",
            "fieldId": "6857510fbfed1553e168161b",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "_id": "685750eff3216b45ffe73c80",
            "fileId": "685750ef698da1ab427761ba",
            "change": [
                "parentPath": "",
                "schemaId": "collectionSchemaId",
                "rowId": "68582dde1b30a59b4272a5c7"
            ] as [String: Any],
            "pageId": "685750efeb612f4fac5819dd",
            "sdk": "swift",
            "v": 1
        ]

        // 5) rowCreate — new row at index 0 with id "68b80861acbc45d5fb5d16b9" (with children)
        let changeDict5: [String: Any] = [
            "fieldId": "6857510fbfed1553e168161b",
            "fieldIdentifier": "field_68575112847f32f878c77daf",
            "target": "field.value.rowCreate",
            "change": [
                "schemaId": "collectionSchemaId",
                "parentPath": "",
                "row": [
                    "cells": [:] as [String: Any],
                    "children": [
                        "685753949107b403e2e4a949": [
                            "value": [] as [Any]
                        ] as [String: Any]
                    ] as [String: Any],
                    "_id": "68b80861acbc45d5fb5d16b9"
                ] as [String: Any],
                "targetRowIndex": 0
            ] as [String: Any],
            "identifier": "doc_685750eff3216b45ffe73c80",
            "fileId": "685750ef698da1ab427761ba",
            "fieldPositionId": "68575112158ff5dbaa9f78e1",
            "pageId": "685750efeb612f4fac5819dd",
            "createdOn": 1756891233.8103271,
            "v": 1,
            "sdk": "swift",
            "_id": "685750eff3216b45ffe73c80"
        ]

        // 6) rowUpdate — set "New row" for "68b80861acbc45d5fb5d16b9"
        let changeDict6: [String: Any] = [
            "target": "field.value.rowUpdate",
            "_id": "685750eff3216b45ffe73c80",
            "createdOn": 1756891239.80039,
            "fileId": "685750ef698da1ab427761ba",
            "fieldPositionId": "68575112158ff5dbaa9f78e1",
            "v": 1,
            "change": [
                "rowId": "68b80861acbc45d5fb5d16b9",
                "row": [
                    "cells": [
                        "684c3fedb0afd867adaeb3b4": "New row"
                    ] as [String: Any],
                    "_id": "68b80861acbc45d5fb5d16b9"
                ] as [String: Any],
                "parentPath": "",
                "schemaId": "collectionSchemaId"
            ] as [String: Any],
            "sdk": "swift",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "pageId": "685750efeb612f4fac5819dd",
            "fieldIdentifier": "field_68575112847f32f878c77daf",
            "fieldId": "6857510fbfed1553e168161b"
        ]
        
        let change1 = Change(dictionary: changeDict1)
        let change2 = Change(dictionary: changeDict2)
        let change3 = Change(dictionary: changeDict3)
        let change4 = Change(dictionary: changeDict4)
        let change5 = Change(dictionary: changeDict5)
        let change6 = Change(dictionary: changeDict6)
        documentEditor.change(changes: [change1, change2, change3, change4, change5, change6])
        waitForMainQueueToDrain()
        // Get the updated rows from both sources
        let updatedRows = viewModel.tableDataModel.valueToValueElements
        let updatedRowsFromDocumentEditor = documentEditor.field(fieldID: "6857510fbfed1553e168161b")?.valueToValueElements
        XCTAssertEqual(updatedRows?.count, 1, "rows count should be 1")
        XCTAssertEqual(updatedRowsFromDocumentEditor?.count, 1, "rows count should be 1 from document")
        
        
        let ChangeValue1 = updatedRows?.first(where: {$0.id == "68b80861acbc45d5fb5d16b9"})?.cells?["684c3fedb0afd867adaeb3b4"]
        XCTAssertEqual(ChangeValue1?.text, "New row", "Value should be equal")
        
        let ChangeValueFromDocument1 = updatedRowsFromDocumentEditor?.first(where: {$0.id == "68b80861acbc45d5fb5d16b9"})?.cells?["684c3fedb0afd867adaeb3b4"]
        XCTAssertEqual(ChangeValueFromDocument1?.text, "New row", "Value should be equal from document")
    }
    
    func testApplyRowEditChanges_MoveUpRow() async throws{
        // Given
        let document = createTestDocument()
        let documentEditor = DocumentEditor(document: document, validateSchema: false)
        let viewModel = try await createCollectionViewModel(documentEditor: documentEditor)
        sleep(10)
        let changeDict: [String: Any] = [
            "identifier": "doc_685750eff3216b45ffe73c80",
            "fieldId": "6857510fbfed1553e168161b",
            "fieldPositionId": "68575112158ff5dbaa9f78e1",
            "sdk": "swift",
            "fileId": "685750ef698da1ab427761ba",
            "pageId": "685750efeb612f4fac5819dd",
            "createdOn": 1756900592.3140302,
            "fieldIdentifier": "field_68575112847f32f878c77daf",
            "change": [
                "targetRowIndex": 0,
                "rowId": "68582dde1b30a59b4272a5c7",
                "parentPath": "",
                "schemaId": "collectionSchemaId"
            ] as [String: Any],
            "target": "field.value.rowMove",
            "_id": "685750eff3216b45ffe73c80",
            "v": 1
        ]

        
        let change = Change(dictionary: changeDict)
        documentEditor.change(changes: [change])
    
        // Get the updated rows from both sources
        let updatedRows = viewModel.tableDataModel.valueToValueElements
        let updatedRowsFromDocumentEditor = documentEditor.field(fieldID: "6857510fbfed1553e168161b")?.valueToValueElements
        XCTAssertEqual(updatedRows?.count, 4, "rows count should be 4")
        XCTAssertEqual(updatedRowsFromDocumentEditor?.count, 4, "rows count should be 4 from document")
        
        let rowIndex = updatedRows?.firstIndex(where: {$0.id == "68582dde1b30a59b4272a5c7"})
        XCTAssertEqual(rowIndex, 0, "Value should be equal")
        
        let rowIndexForDocument = updatedRowsFromDocumentEditor?.firstIndex(where: {$0.id == "68582dde1b30a59b4272a5c7"})
        XCTAssertEqual(rowIndexForDocument, 0, "Value should be equal")
    }
    
    func testApplyRowEditChanges_MoveDownRow() async throws {
        // Given
        let document = createTestDocument()
        let documentEditor = DocumentEditor(document: document, validateSchema: false)
        let viewModel = try await createCollectionViewModel(documentEditor: documentEditor)
        sleep(10)
        let changeDict: [String: Any] = [
            "fieldId": "6857510fbfed1553e168161b",
            "fieldPositionId": "68575112158ff5dbaa9f78e1",
            "createdOn": 1756900688.324821,
            "change": [
                "rowId": "68575bb9cdb3707c78d6b2ff",
                "parentPath": "",
                "schemaId": "collectionSchemaId",
                "targetRowIndex": 3
            ] as [String: Any],
            "identifier": "doc_685750eff3216b45ffe73c80",
            "pageId": "685750efeb612f4fac5819dd",
            "fieldIdentifier": "field_68575112847f32f878c77daf",
            "fileId": "685750ef698da1ab427761ba",
            "_id": "685750eff3216b45ffe73c80",
            "sdk": "swift",
            "target": "field.value.rowMove",
            "v": 1
        ]
        
        let change = Change(dictionary: changeDict)
        documentEditor.change(changes: [change])
    
        // Get the updated rows from both sources
        let updatedRows = viewModel.tableDataModel.valueToValueElements
        let updatedRowsFromDocumentEditor = documentEditor.field(fieldID: "6857510fbfed1553e168161b")?.valueToValueElements
        XCTAssertEqual(updatedRows?.count, 4, "rows count should be 4")
        XCTAssertEqual(updatedRowsFromDocumentEditor?.count, 4, "rows count should be 4 from document")
        
        let rowIndex = updatedRows?.firstIndex(where: {$0.id == "68575bb9cdb3707c78d6b2ff"})
        XCTAssertEqual(rowIndex, 3, "Value should be equal")
        
        let rowIndexForDocument = updatedRowsFromDocumentEditor?.firstIndex(where: {$0.id == "68575bb9cdb3707c78d6b2ff"})
        XCTAssertEqual(rowIndexForDocument, 3, "Value should be equal")
    }

    // MARK: - bulkEdit(changes:) — regression coverage for RUID 5ZYFSV
    // The reported crash was in CollectionViewModel.bulkEdit, which keyed row edits by
    // column *index* and read arrays out of bounds. These lock in the columnID-keyed path.

    private let rootTextColumnID = "684c3fedb0afd867adaeb3b4"
    private let rootRowA = "68575bb9cdb3707c78d6b2ff"
    private let rootRowB = "685765dcf190077e95796c41"
    private let rootRowUnselected = "68582dd76e0e93dd2017372a"

    private func cellText(_ documentEditor: DocumentEditor, row: String, column: String) -> String? {
        documentEditor.field(fieldID: tableFieldID)?.valueToValueElements?
            .first(where: { $0.id == row })?.cells?[column]?.text
    }

    private func cellValue(_ documentEditor: DocumentEditor, row: String, column: String) -> ValueUnion? {
        documentEditor.field(fieldID: tableFieldID)?.valueToValueElements?
            .first(where: { $0.id == row })?.cells?[column]
    }

    // Core of the fix: changes are keyed by columnID, so each entry must land in its
    // own root column across every type in the switch, on all selected rows.
    func testBulkEdit_mapsEachColumnIDToItsOwnColumnAcrossTypes() async throws {
        let documentEditor = DocumentEditor(document: createTestDocument(), validateSchema: false)
        let viewModel = try await createCollectionViewModel(documentEditor: documentEditor)
        sleep(10)

        let dropdownColumnID = "684c3fed52b1d1145f1e2790"
        let numberColumnID   = "685753044b333dd442ea29d4"
        let multiColumnID    = "6857530158fb7edb102344fa"
        let barcodeColumnID  = "68575312d8c5679a05ee29e0"
        let dropdownOptionID = "684c3fedf47cc0fea6bca947"          // "No D1"
        let multiOptionIDs   = ["68575301e490d0ce22ae5e7b", "685767dae7cf2193a50ff550"]

        viewModel.tableDataModel.selectedRows = [rootRowA, rootRowB]

        await viewModel.bulkEdit(changes: [
            rootTextColumnID: .string("BulkText"),
            dropdownColumnID: .string(dropdownOptionID),
            numberColumnID:   .double(42),
            multiColumnID:    .array(multiOptionIDs),
            barcodeColumnID:  .string("BC-123"),
        ])
        waitForMainQueueToDrain()

        for row in [rootRowA, rootRowB] {
            XCTAssertEqual(cellValue(documentEditor, row: row, column: rootTextColumnID)?.text, "BulkText", "text column on \(row)")
            XCTAssertEqual(cellValue(documentEditor, row: row, column: dropdownColumnID)?.text, dropdownOptionID, "dropdown column on \(row)")
            XCTAssertEqual(cellValue(documentEditor, row: row, column: numberColumnID)?.number, 42, "number column on \(row)")
            XCTAssertEqual(cellValue(documentEditor, row: row, column: multiColumnID)?.multiSelector, multiOptionIDs, "multiSelect column on \(row)")
            XCTAssertEqual(cellValue(documentEditor, row: row, column: barcodeColumnID)?.text, "BC-123", "barcode column on \(row)")
        }
    }

    func testBulkEdit_appliesValueToAllSelectedRows() async throws {
        let documentEditor = DocumentEditor(document: createTestDocument(), validateSchema: false)
        let viewModel = try await createCollectionViewModel(documentEditor: documentEditor)
        sleep(10)

        let unselectedBefore = cellText(documentEditor, row: rootRowUnselected, column: rootTextColumnID)
        viewModel.tableDataModel.selectedRows = [rootRowA, rootRowB]

        await viewModel.bulkEdit(changes: [rootTextColumnID: .string("Testing")])
        waitForMainQueueToDrain()

        XCTAssertEqual(cellText(documentEditor, row: rootRowA, column: rootTextColumnID), "Testing", "Selected root row A should get the bulk value")
        XCTAssertEqual(cellText(documentEditor, row: rootRowB, column: rootTextColumnID), "Testing", "Selected root row B should get the bulk value")
        XCTAssertEqual(cellText(documentEditor, row: rootRowUnselected, column: rootTextColumnID), unselectedBefore, "Unselected root row must be untouched")
    }

    func testBulkEdit_unknownColumnID_isNoOpAndDoesNotCrash() async throws {
        let documentEditor = DocumentEditor(document: createTestDocument(), validateSchema: false)
        let viewModel = try await createCollectionViewModel(documentEditor: documentEditor)
        sleep(10)

        let before = cellText(documentEditor, row: rootRowA, column: rootTextColumnID)
        viewModel.tableDataModel.selectedRows = [rootRowA, rootRowB]

        await viewModel.bulkEdit(changes: ["nonexistent-column-id": .string("ShouldNotApply")])
        waitForMainQueueToDrain()

        XCTAssertEqual(cellText(documentEditor, row: rootRowA, column: rootTextColumnID), before, "An unknown columnID must not mutate any cell")
    }

    func testBulkEdit_emptyChanges_isNoOp() async throws {
        let documentEditor = DocumentEditor(document: createTestDocument(), validateSchema: false)
        let viewModel = try await createCollectionViewModel(documentEditor: documentEditor)
        sleep(10)

        let before = cellText(documentEditor, row: rootRowA, column: rootTextColumnID)
        viewModel.tableDataModel.selectedRows = [rootRowA, rootRowB]

        await viewModel.bulkEdit(changes: [:])
        waitForMainQueueToDrain()

        XCTAssertEqual(cellText(documentEditor, row: rootRowA, column: rootTextColumnID), before, "Empty changes must be a no-op")
    }

    func testBulkEdit_rowWithFewerCellsThanColumns_doesNotCrash() async throws {
        let documentEditor = DocumentEditor(document: createTestDocument(), validateSchema: false)
        let viewModel = try await createCollectionViewModel(documentEditor: documentEditor)
        sleep(10)

        guard let idx = viewModel.tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == rootRowA }) else {
            return XCTFail("Row \(rootRowA) not found in filteredcellModels")
        }
        viewModel.tableDataModel.selectedRows = [rootRowA]
        viewModel.tableDataModel.filteredcellModels[idx].cells = []

        await viewModel.bulkEdit(changes: [rootTextColumnID: .string("Testing")])
        waitForMainQueueToDrain()

        XCTAssertEqual(cellText(documentEditor, row: rootRowA, column: rootTextColumnID), "Testing", "bulkEdit must complete and persist despite a truncated cells array")
    }
}
