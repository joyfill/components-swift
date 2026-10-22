//
//  TableViewModelDocumentEditorDelegateTests.swift
//  JoyfillTests
//
//  Created by iOS developer on 22/7/25
//

import XCTest
import Foundation
import SwiftUI
import Combine
import JoyfillModel
@testable import Joyfill

final class TableViewModelDocumentEditorDelegateTests: XCTestCase {
     
    private let fileID = "685750ef698da1ab427761ba"
    private let pageID = "685750efeb612f4fac5819dd"
    private let tableFieldID = "685750f0489567f18eb8a9ec"
    
    // MARK: - Test Helpers
    
    private func createTestDocument() -> JoyDoc {
        sampleJSONDocument(fileName: "ChangerHandlerUnit")
    }
    
    private func createTableViewModel(documentEditor: DocumentEditor) -> TableViewModel {
        let field = documentEditor.field(fieldID: tableFieldID)
        let fieldHeaderModel = FieldHeaderModel(title: field?.title, required: field?.required, tipDescription: field?.tipDescription, tipTitle: field?.tipTitle, tipVisible: field?.tipVisible, visibleLimitInFields: documentEditor.decoratorConfig.visibleLimitInFields)
        let tableDataModel = TableDataModel(
            fieldHeaderModel: fieldHeaderModel,
            mode: Mode.fill,
            documentEditor: documentEditor,
            fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        )
        guard let tableDataModel else { fatalError("TableViewModel not found") }
        return TableViewModel(tableDataModel: tableDataModel)
    }
    
    func waitForMainQueueToDrain(file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Drain main queue")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
    }
     
    func testApplyRowEditChanges_AddNewRow() {
        // Given
        let document = createTestDocument()
        let documentEditor = DocumentEditor(document: document, config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)
        
        let changeDict: [String: Any] = [
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "v": 1,
            "_id": "685750eff3216b45ffe73c80",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "pageId": "685750efeb612f4fac5819dd",
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "fileId": "685750ef698da1ab427761ba",
            "sdk": "swift",
            "change": [
                "targetRowIndex": 4,
                "row": [
                    "_id": "68b676812ef759de776c02cd",
                    "cells": [:] as [String: Any]
                ]
            ],
            "createdOn": 1756788353.9459882,
            "fieldId": "685750f0489567f18eb8a9ec",
            "target": "field.value.rowCreate"
        ]
        
        let change = Change(dictionary: changeDict)
        documentEditor.change(changes: [change])
        
        let updatedNumberOfRows = viewModel.tableDataModel.valueToValueElements?.count
        let updatedNumberOFRowsFromDocumentEditor = documentEditor.field(fieldID: "685750f0489567f18eb8a9ec")?.valueToValueElements?.count
        XCTAssertEqual(updatedNumberOfRows, 5, "Rows should be updated")
        XCTAssertEqual(updatedNumberOFRowsFromDocumentEditor, 5, "Rows should be updated from document")
    }
    
    // A grouped `field.value.bulkRowCreate` (v: 2) with two entries under `change.rows`
    // replays both rows through insertRow(for:).
    func testApplyRowEditChanges_BulkRowCreateGroupedRows() {
        let document = createTestDocument()
        let documentEditor = DocumentEditor(document: document, config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)

        let changeDict: [String: Any] = [
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "v": 2,
            "_id": "685750eff3216b45ffe73c80",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "pageId": "685750efeb612f4fac5819dd",
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "fileId": "685750ef698da1ab427761ba",
            "sdk": "swift",
            "change": [
                "rows": [
                    [
                        "targetRowIndex": 4,
                        "row": ["_id": "68b676812ef759de776c02cd", "cells": [:] as [String: Any]]
                    ],
                    [
                        "targetRowIndex": 5,
                        "row": ["_id": "68b676812ef759de776c02ce", "cells": [:] as [String: Any]]
                    ]
                ]
            ],
            "createdOn": 1756788353.9459882,
            "fieldId": "685750f0489567f18eb8a9ec",
            "target": "field.value.bulkRowCreate"
        ]

        let change = Change(dictionary: changeDict)
        documentEditor.change(changes: [change])

        XCTAssertEqual(viewModel.tableDataModel.valueToValueElements?.count, 6, "Both grouped rows should be inserted")
        XCTAssertEqual(documentEditor.field(fieldID: "685750f0489567f18eb8a9ec")?.valueToValueElements?.count, 6)
    }

    func testApplyRowEditChanges_BulkUpdate() {
        // Given
        let document = createTestDocument()
        let documentEditor = DocumentEditor(document: document, config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)
        
        let changeDict1: [String: Any] = [
            "createdOn": 1756788529.5156889,
            "sdk": "swift",
            "pageId": "685750efeb612f4fac5819dd",
            "_id": "685750eff3216b45ffe73c80",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "v": 1,
            "change": [
                "rowId": "684c3fedfed2b76677110b19",
                "row": [
                    "cells": [
                        "684c3fedce82027a49234dd3": "Testing"
                    ] as [String: Any],
                    "_id": "684c3fedfed2b76677110b19"
                ] as [String: Any]
            ] as [String: Any],
            "target": "field.value.rowUpdate",
            "fileId": "685750ef698da1ab427761ba",
            "fieldId": "685750f0489567f18eb8a9ec",
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "fieldPositionId": "6857510f4313cfbfb43c516c"
        ]
        
        let changeDict2: [String: Any] = [
            "pageId": "685750efeb612f4fac5819dd",
            "fileId": "685750ef698da1ab427761ba",
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "target": "field.value.rowUpdate",
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "change": [
                "rowId": "68575b4059f586b81549fc07",
                "row": [
                    "cells": [
                        "684c3fedce82027a49234dd3": "Testing"
                    ] as [String: Any],
                    "_id": "68575b4059f586b81549fc07"
                ] as [String: Any]
            ] as [String: Any],
            "createdOn": 1756792012.1351039,
            "_id": "685750eff3216b45ffe73c80",
            "sdk": "swift",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "v": 1,
            "fieldId": "685750f0489567f18eb8a9ec"
        ]
        
        let changeDict3: [String: Any] = [
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "pageId": "685750efeb612f4fac5819dd",
            "v": 1,
            "target": "field.value.rowUpdate",
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "fileId": "685750ef698da1ab427761ba",
            "fieldId": "685750f0489567f18eb8a9ec",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "sdk": "swift",
            "change": [
                "rowId": "68575b41d49ad2d821193a3d",
                "row": [
                    "_id": "68575b41d49ad2d821193a3d",
                    "cells": [
                        "684c3fedce82027a49234dd3": "Testing"
                    ] as [String: Any]
                ] as [String: Any]
            ] as [String: Any],
            "createdOn": 1756792012.135124,
            "_id": "685750eff3216b45ffe73c80"
        ]

        let changeDict4: [String: Any] = [
            "createdOn": 1756792012.1351318,
            "change": [
                "row": [
                    "cells": [
                        "684c3fedce82027a49234dd3": "Testing"
                    ] as [String: Any],
                    "_id": "68599845cb06457892ce27b4"
                ] as [String: Any],
                "rowId": "68599845cb06457892ce27b4"
            ] as [String: Any],
            "fileId": "685750ef698da1ab427761ba",
            "fieldId": "685750f0489567f18eb8a9ec",
            "_id": "685750eff3216b45ffe73c80",
            "sdk": "swift",
            "pageId": "685750efeb612f4fac5819dd",
            "target": "field.value.rowUpdate",
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "v": 1,
            "fieldPositionId": "6857510f4313cfbfb43c516c"
        ]
        
        let change1 = Change(dictionary: changeDict1)
        let change2 = Change(dictionary: changeDict2)
        let change3 = Change(dictionary: changeDict3)
        let change4 = Change(dictionary: changeDict4)
        documentEditor.change(changes: [change1, change2, change3, change4])
        // Ensure that main-queue work has executed before asserting
        waitForMainQueueToDrain()
        
        let updatedRows = viewModel.tableDataModel.valueToValueElements
        let updatedRowsFromDocumentEditor = documentEditor.field(fieldID: "685750f0489567f18eb8a9ec")?.valueToValueElements
        
        let ChangeValue1 = updatedRows?.first(where: {$0.id == "684c3fedfed2b76677110b19"})?.cells?["684c3fedce82027a49234dd3"]
        let ChangeValue2 = updatedRows?.first(where: {$0.id == "684c3fedfed2b76677110b19"})?.cells?["684c3fedce82027a49234dd3"]
        let ChangeValue3 = updatedRows?.first(where: {$0.id == "684c3fedfed2b76677110b19"})?.cells?["684c3fedce82027a49234dd3"]
        let ChangeValue4 = updatedRows?.first(where: {$0.id == "684c3fedfed2b76677110b19"})?.cells?["684c3fedce82027a49234dd3"]
        XCTAssertEqual(ChangeValue1?.text, "Testing", "Value should be equal")
        XCTAssertEqual(ChangeValue2?.text, "Testing", "Value should be equal")
        XCTAssertEqual(ChangeValue3?.text, "Testing", "Value should be equal")
        XCTAssertEqual(ChangeValue4?.text, "Testing", "Value should be equal")
        
        let ChangeValueFromDocument1 = updatedRowsFromDocumentEditor?.first(where: {$0.id == "684c3fedfed2b76677110b19"})?.cells?["684c3fedce82027a49234dd3"]
        let ChangeValueFromDocument2 = updatedRowsFromDocumentEditor?.first(where: {$0.id == "684c3fedfed2b76677110b19"})?.cells?["684c3fedce82027a49234dd3"]
        let ChangeValueFromDocument3 = updatedRowsFromDocumentEditor?.first(where: {$0.id == "684c3fedfed2b76677110b19"})?.cells?["684c3fedce82027a49234dd3"]
        let ChangeValueFromDocument4 = updatedRowsFromDocumentEditor?.first(where: {$0.id == "684c3fedfed2b76677110b19"})?.cells?["684c3fedce82027a49234dd3"]
        XCTAssertEqual(ChangeValueFromDocument1?.text, "Testing", "Value should be equal")
        XCTAssertEqual(ChangeValueFromDocument2?.text, "Testing", "Value should be equal")
        XCTAssertEqual(ChangeValueFromDocument3?.text, "Testing", "Value should be equal")
        XCTAssertEqual(ChangeValueFromDocument4?.text, "Testing", "Value should be equal")
    }
    
    func testApplyRowEditChanges_AddAndInsert() {
        // Given
        let document = createTestDocument()
        let documentEditor = DocumentEditor(document: document, config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)
        
        let changeDict1: [String: Any] = [
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "createdOn": 1756805237.0875859,
            "sdk": "swift",
            "_id": "685750eff3216b45ffe73c80",
            "fileId": "685750ef698da1ab427761ba",
            "pageId": "685750efeb612f4fac5819dd",
            "target": "field.value.rowCreate",
            "change": [
                "row": [
                    "_id": "68b6b87562dd1def0b9e4087",
                    "cells": [:] as [String: Any]
                ] as [String: Any],
                "targetRowIndex": 4
            ] as [String: Any],
            "fieldId": "685750f0489567f18eb8a9ec",
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "v": 1
        ]
        
        let changeDict2: [String: Any] = [
            "createdOn": 1756805238.684514,
            "v": 1,
            "_id": "685750eff3216b45ffe73c80",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "fieldId": "685750f0489567f18eb8a9ec",
            "fileId": "685750ef698da1ab427761ba",
            "sdk": "swift",
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "change": [
                "row": [
                    "_id": "68b6b876727664214d96171b",
                    "cells": [:] as [String: Any]
                ] as [String: Any],
                "targetRowIndex": 5
            ] as [String: Any],
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "target": "field.value.rowCreate",
            "pageId": "685750efeb612f4fac5819dd"
        ]
        
        let changeDict3: [String: Any] = [
            "fieldId": "685750f0489567f18eb8a9ec",
            "createdOn": 1756805245.2682791,
            "target": "field.value.rowUpdate",
            "pageId": "685750efeb612f4fac5819dd",
            "fileId": "685750ef698da1ab427761ba",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "_id": "685750eff3216b45ffe73c80",
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "change": [
                "rowId": "68b6b876727664214d96171b",
                "row": [
                    "_id": "68b6b876727664214d96171b",
                    "cells": [
                        "684c3fedce82027a49234dd3": "New row"
                    ] as [String: Any]
                ] as [String: Any]
            ] as [String: Any],
            "sdk": "swift",
            "v": 1
        ]
        
        let change1 = Change(dictionary: changeDict1)
        let change2 = Change(dictionary: changeDict2)
        let change3 = Change(dictionary: changeDict3)
        documentEditor.change(changes: [change1, change2, change3])
        // Ensure that main-queue work has executed before asserting
        waitForMainQueueToDrain()
        
        // Get the updated rows from both sources
        let updatedRows = viewModel.tableDataModel.valueToValueElements
        let updatedRowsFromDocumentEditor = documentEditor.field(fieldID: "685750f0489567f18eb8a9ec")?.valueToValueElements
        XCTAssertEqual(updatedRows?.count, 6, "rows count should be 6")
        XCTAssertEqual(updatedRowsFromDocumentEditor?.count, 6, "rows count should be 6 from document")
        
        
        let ChangeValue1 = updatedRows?.first(where: {$0.id == "68b6b876727664214d96171b"})?.cells?["684c3fedce82027a49234dd3"]
        XCTAssertEqual(ChangeValue1?.text, "New row", "Value should be equal")
        
        let ChangeValueFromDocument1 = updatedRowsFromDocumentEditor?.first(where: {$0.id == "68b6b876727664214d96171b"})?.cells?["684c3fedce82027a49234dd3"]
        XCTAssertEqual(ChangeValueFromDocument1?.text, "New row", "Value should be equal from document")
    }
     
    func testApplyRowEditChanges_DeleteAndAddRow() {
        // Given
        let document = createTestDocument()
        let documentEditor = DocumentEditor(document: document, config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)
        
        // 1) rowDelete — "684c3fedfed2b76677110b19"
        let changeDict1: [String: Any] = [
            "target": "field.value.rowDelete",
            "pageId": "685750efeb612f4fac5819dd",
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "createdOn": 1756880014.0128169,
            "fieldId": "685750f0489567f18eb8a9ec",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "sdk": "swift",
            "fileId": "685750ef698da1ab427761ba",
            "_id": "685750eff3216b45ffe73c80",
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "change": [
                "rowId": "684c3fedfed2b76677110b19"
            ] as [String: Any],
            "v": 1
        ]

        // 2) rowDelete — "68575b4059f586b81549fc07"
        let changeDict2: [String: Any] = [
            "pageId": "685750efeb612f4fac5819dd",
            "sdk": "swift",
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "target": "field.value.rowDelete",
            "_id": "685750eff3216b45ffe73c80",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "fieldId": "685750f0489567f18eb8a9ec",
            "fileId": "685750ef698da1ab427761ba",
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "change": [
                "rowId": "68575b4059f586b81549fc07"
            ] as [String: Any],
            "createdOn": 1756880014.012841,
            "v": 1
        ]

        // 3) rowDelete — "68575b41d49ad2d821193a3d"
        let changeDict3: [String: Any] = [
            "sdk": "swift",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "target": "field.value.rowDelete",
            "_id": "685750eff3216b45ffe73c80",
            "v": 1,
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "change": [
                "rowId": "68575b41d49ad2d821193a3d"
            ] as [String: Any],
            "createdOn": 1756880014.01285,
            "fileId": "685750ef698da1ab427761ba",
            "pageId": "685750efeb612f4fac5819dd",
            "fieldId": "685750f0489567f18eb8a9ec"
        ]

        // 4) rowDelete — "68599845cb06457892ce27b4"
        let changeDict4: [String: Any] = [
            "createdOn": 1756880014.0128579,
            "_id": "685750eff3216b45ffe73c80",
            "sdk": "swift",
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "v": 1,
            "fileId": "685750ef698da1ab427761ba",
            "target": "field.value.rowDelete",
            "fieldId": "685750f0489567f18eb8a9ec",
            "change": [
                "rowId": "68599845cb06457892ce27b4"
            ] as [String: Any],
            "pageId": "685750efeb612f4fac5819dd"
        ]

        // 5) rowCreate — new row at index 0 with id "68b7dc8fca504878fa8b36fb"
        let changeDict5: [String: Any] = [
            "identifier": "doc_685750eff3216b45ffe73c80",
            "v": 1,
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "createdOn": 1756880015.9110088,
            "target": "field.value.rowCreate",
            "change": [
                "targetRowIndex": 0,
                "row": [
                    "_id": "68b7dc8fca504878fa8b36fb",
                    "cells": [:] as [String: Any]
                ] as [String: Any]
            ] as [String: Any],
            "_id": "685750eff3216b45ffe73c80",
            "pageId": "685750efeb612f4fac5819dd",
            "fileId": "685750ef698da1ab427761ba",
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "sdk": "swift",
            "fieldId": "685750f0489567f18eb8a9ec"
        ]

        // 6) rowUpdate — set "Demo" into cell "684c3fedce82027a49234dd3" for the new row
        let changeDict6: [String: Any] = [
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "fieldId": "685750f0489567f18eb8a9ec",
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "target": "field.value.rowUpdate",
            "createdOn": 1756880020.799511,
            "v": 1,
            "change": [
                "row": [
                    "cells": [
                        "684c3fedce82027a49234dd3": "Demo"
                    ] as [String: Any],
                    "_id": "68b7dc8fca504878fa8b36fb"
                ] as [String: Any],
                "rowId": "68b7dc8fca504878fa8b36fb"
            ] as [String: Any],
            "identifier": "doc_685750eff3216b45ffe73c80",
            "fileId": "685750ef698da1ab427761ba",
            "sdk": "swift",
            "_id": "685750eff3216b45ffe73c80",
            "pageId": "685750efeb612f4fac5819dd"
        ]
        
        let change1 = Change(dictionary: changeDict1)
        let change2 = Change(dictionary: changeDict2)
        let change3 = Change(dictionary: changeDict3)
        let change4 = Change(dictionary: changeDict4)
        let change5 = Change(dictionary: changeDict5)
        let change6 = Change(dictionary: changeDict6)
        documentEditor.change(changes: [change1, change2, change3, change4, change5, change6])
        // Ensure that main-queue work has executed before asserting
        waitForMainQueueToDrain()
        
        // Get the updated rows from both sources
        let updatedRows = viewModel.tableDataModel.valueToValueElements?.filter({$0.deleted != true})
        let updatedRowsFromDocumentEditor = documentEditor.field(fieldID: "685750f0489567f18eb8a9ec")?.valueToValueElements?.filter({$0.deleted != true})
        XCTAssertEqual(updatedRows?.count, 1, "rows count should be 1")
        XCTAssertEqual(updatedRowsFromDocumentEditor?.count, 1, "rows count should be 1 from document")
        
        
        let ChangeValue1 = updatedRows?.first(where: {$0.id == "68b7dc8fca504878fa8b36fb"})?.cells?["684c3fedce82027a49234dd3"]
        XCTAssertEqual(ChangeValue1?.text, "Demo", "Value should be equal")
        
        let ChangeValueFromDocument1 = updatedRowsFromDocumentEditor?.first(where: {$0.id == "68b7dc8fca504878fa8b36fb"})?.cells?["684c3fedce82027a49234dd3"]
        XCTAssertEqual(ChangeValueFromDocument1?.text, "Demo", "Value should be equal from document")
    }
    
    func testApplyRowEditChanges_MoveUpRow() {
        // Given
        let document = createTestDocument()
        let documentEditor = DocumentEditor(document: document, config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)
          
        // 1) rowMove — move row to index 0
        let changeDict: [String: Any] = [
            "fileId": "685750ef698da1ab427761ba",
            "createdOn": 1756896778.8767009,
            "sdk": "swift",
            "fieldId": "685750f0489567f18eb8a9ec",
            "change": [
                "rowId": "68575b41d49ad2d821193a3d",
                "targetRowIndex": 0
            ] as [String: Any],
            "target": "field.value.rowMove",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "v": 1,
            "_id": "685750eff3216b45ffe73c80",
            "pageId": "685750efeb612f4fac5819dd",
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "fieldPositionId": "6857510f4313cfbfb43c516c"
        ]

        
        let change = Change(dictionary: changeDict)
        documentEditor.change(changes: [change])
    
        // Get the updated rows from both sources
        let updatedRows = viewModel.tableDataModel.valueToValueElements
        let updatedRowsFromDocumentEditor = documentEditor.field(fieldID: "685750f0489567f18eb8a9ec")?.valueToValueElements
        XCTAssertEqual(updatedRows?.count, 4, "rows count should be 4")
        XCTAssertEqual(updatedRowsFromDocumentEditor?.count, 4, "rows count should be 4 from document")
        
        let rowOrder = viewModel.tableDataModel.rowOrder.firstIndex(where: {$0 == "68575b41d49ad2d821193a3d"})
        XCTAssertEqual(rowOrder, 0, "Value should be equal")
        
        let rowOrderForDocument = documentEditor.field(fieldID: "685750f0489567f18eb8a9ec")?.rowOrder?.firstIndex(where: {$0 == "68575b41d49ad2d821193a3d"})
        XCTAssertEqual(rowOrderForDocument, 0, "Value should be equal")
    }
    
    func testApplyRowEditChanges_MoveDownRow() {
        // Given
        let document = createTestDocument()
        let documentEditor = DocumentEditor(document: document, config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)
        
        // 1) rowMove — move row to index 4
        let changeDict: [String: Any] = [
            "fileId": "685750ef698da1ab427761ba",
            "target": "field.value.rowMove",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "fieldId": "685750f0489567f18eb8a9ec",
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "createdOn": 1756898953.7263479,
            "change": [
                "targetRowIndex": 3,
                "rowId": "684c3fedfed2b76677110b19"
            ] as [String: Any],
            "_id": "685750eff3216b45ffe73c80",
            "v": 1,
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "pageId": "685750efeb612f4fac5819dd",
            "sdk": "swift"
        ]
        
        let change = Change(dictionary: changeDict)
        documentEditor.change(changes: [change])
    
        // Get the updated rows from both sources
        let updatedRows = viewModel.tableDataModel.valueToValueElements
        let updatedRowsFromDocumentEditor = documentEditor.field(fieldID: "685750f0489567f18eb8a9ec")?.valueToValueElements
        XCTAssertEqual(updatedRows?.count, 4, "rows count should be 4")
        XCTAssertEqual(updatedRowsFromDocumentEditor?.count, 4, "rows count should be 4 from document")
        
        let rowOrder = viewModel.tableDataModel.rowOrder.firstIndex(where: {$0 == "684c3fedfed2b76677110b19"})
        XCTAssertEqual(rowOrder, 3, "Value should be equal")
        
        let rowOrderForDocument = documentEditor.field(fieldID: "685750f0489567f18eb8a9ec")?.rowOrder?.firstIndex(where: {$0 == "684c3fedfed2b76677110b19"})
        XCTAssertEqual(rowOrderForDocument, 3, "Value should be equal")
    }

    // Regression: applyRowEditChanges must bump the target cell's id in cellModels
    // (via isBulkEdit: true) so the updated value survives the next filterRowsIfNeeded()
    // call (e.g. Insert Below). Without the id bump, SwiftUI reuses the old cell view
    // and the value appears to vanish from the grid after a row operation.
    func testApplyRowEditChanges_CellIdIsBumpedAndValueSurvivesFilterRowsIfNeeded() {
        // Arrange
        let document = createTestDocument()
        let documentEditor = DocumentEditor(document: document, config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)

        let rowID = "684c3fedfed2b76677110b19"
        let colID = "684c3fedce82027a49234dd3"
        let newValue = "CellIdBumpTest"

        guard let rowIndex = viewModel.tableDataModel.rowOrder.firstIndex(of: rowID) else {
            XCTFail("Row '\(rowID)' not found in rowOrder"); return
        }
        guard let colIndex = viewModel.tableDataModel.tableColumns.firstIndex(where: { $0.id == colID }) else {
            XCTFail("Column '\(colID)' not found in tableColumns"); return
        }

        // Snapshot cell id before the change
        let cellIDBefore = viewModel.tableDataModel.cellModels[rowIndex].cells[colIndex].id

        let changeDict: [String: Any] = [
            "target": "field.value.rowUpdate",
            "pageId": pageID,
            "fileId": fileID,
            "fieldId": tableFieldID,
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "_id": "685750eff3216b45ffe73c80",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "sdk": "swift",
            "v": 1,
            "createdOn": 1756788529.0,
            "change": [
                "rowId": rowID,
                "row": [
                    "_id": rowID,
                    "cells": [colID: newValue]
                ] as [String: Any]
            ] as [String: Any]
        ]

        // Act — applyRowEditChanges is the path taken when the row edit form is open
        viewModel.applyRowEditChanges(change: Change(dictionary: changeDict))

        // Assert 1: cellModels cell id was bumped (isBulkEdit: true → UUID())
        let cellIDAfter = viewModel.tableDataModel.cellModels[rowIndex].cells[colIndex].id
        XCTAssertNotEqual(cellIDBefore, cellIDAfter,
            "applyRowEditChanges should bump cell id in cellModels (isBulkEdit: true)")

        // Assert 2: value updated in cellModels
        XCTAssertEqual(viewModel.tableDataModel.cellModels[rowIndex].cells[colIndex].data.title, newValue,
            "cellModels should reflect the Change-API value after applyRowEditChanges")

        // Assert 3: simulate a row operation (Insert Below / move) — filterRowsIfNeeded()
        // for table fields sets filteredcellModels = cellModels; the bumped id + value must survive
        viewModel.tableDataModel.filterRowsIfNeeded()

        guard let filteredIndex = viewModel.tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == rowID }) else {
            XCTFail("Row '\(rowID)' not found in filteredcellModels after filterRowsIfNeeded()"); return
        }

        XCTAssertEqual(
            viewModel.tableDataModel.filteredcellModels[filteredIndex].cells[colIndex].id,
            cellIDAfter,
            "filteredcellModels should carry the bumped cell id after filterRowsIfNeeded()")

        XCTAssertEqual(
            viewModel.tableDataModel.filteredcellModels[filteredIndex].cells[colIndex].data.title,
            newValue,
            "filteredcellModels should retain the Change-API value after filterRowsIfNeeded()")
    }

    // Regression: insertBelow() previously left tableDataModel.valueToValueElements
    // stale relative to rowOrder. The fix appends the new element to the in-memory
    // value array; this test pins the invariant so a future revert is caught here
    // rather than as a confusing downstream symptom in bulk-edit / delete flows.
    func testInsertBelow_KeepsValueElementsAndRowOrderInSync() {
        let document = createTestDocument()
        let documentEditor = DocumentEditor(document: document, config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)

        let initialNonDeletedCount = (viewModel.tableDataModel.valueToValueElements ?? [])
            .filter { !($0.deleted ?? false) }
            .count
        let initialRowOrderCount = viewModel.tableDataModel.rowOrder.count
        XCTAssertEqual(initialNonDeletedCount, initialRowOrderCount,
                       "Precondition: non-deleted valueElements count should equal rowOrder count")

        guard let firstRowID = viewModel.tableDataModel.rowOrder.first else {
            XCTFail("Fixture has no rows to select for insertBelow")
            return
        }
        viewModel.tableDataModel.selectedRows = [firstRowID]

        let newRowID = viewModel.insertBelow()
        XCTAssertNotNil(newRowID, "insertBelow should return the new row's id")

        let nonDeletedCount = (viewModel.tableDataModel.valueToValueElements ?? [])
            .filter { !($0.deleted ?? false) }
            .count
        let updatedRowOrderCount = viewModel.tableDataModel.rowOrder.count

        XCTAssertEqual(nonDeletedCount, initialNonDeletedCount + 1,
                       "valueToValueElements should grow by 1 after insertBelow")
        XCTAssertEqual(updatedRowOrderCount, initialRowOrderCount + 1,
                       "rowOrder should grow by 1 after insertBelow")
        XCTAssertEqual(nonDeletedCount, updatedRowOrderCount,
                       "valueToValueElements and rowOrder must stay in sync after insertBelow")

        if let newID = newRowID {
            XCTAssertTrue(viewModel.tableDataModel.rowOrder.contains(newID),
                          "rowOrder should contain the newly inserted row id")
            XCTAssertTrue((viewModel.tableDataModel.valueToValueElements ?? []).contains(where: { $0.id == newID }),
                          "valueToValueElements should contain the newly inserted row")
        }
    }

    // MARK: - clearFocusColumnIfNeeded publish-count invariant (NO-2237)
    func testClearFocusColumnIfNeeded_publishesOnlyWhenFocusIsSet() {
        // Given
        let document = createTestDocument()
        let documentEditor = DocumentEditor(document: document, config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)
        viewModel.tableDataModel.navigationIntent.focusColumnId = nil

        var emissions = 0
        let cancellable = viewModel.objectWillChange.sink { _ in emissions += 1 }

        // When focus is already nil -> guard skips the write -> no publish (the perf fix)
        viewModel.clearFocusColumnIfNeeded()
        XCTAssertEqual(emissions, 0, "clearing when focusColumnId is already nil must not publish")

        // When focus is set -> the set publishes once, the guarded clear publishes once -> 2 total
        viewModel.tableDataModel.navigationIntent.focusColumnId = "col-1"
        viewModel.clearFocusColumnIfNeeded()
        XCTAssertEqual(emissions, 2, "setting then clearing focusColumnId should publish exactly twice")
        XCTAssertNil(viewModel.tableDataModel.navigationIntent.focusColumnId, "focus must still clear")

        _ = cancellable
    }

    // MARK: - bulkEdit(changes:) — regression coverage for RUID 5ZYFSV
    // The crash keyed row edits by column *index*; these lock in the columnID-keyed path.

    private let textColumnID = "684c3fedce82027a49234dd3"
    private let rowA = "684c3fedfed2b76677110b19"
    private let rowB = "68575b4059f586b81549fc07"
    private let rowUnselected = "68575b41d49ad2d821193a3d"

    private func cellText(_ documentEditor: DocumentEditor, row: String, column: String) -> String? {
        documentEditor.field(fieldID: tableFieldID)?.valueToValueElements?
            .first(where: { $0.id == row })?.cells?[column]?.text
    }

    private func cellValue(_ documentEditor: DocumentEditor, row: String, column: String) -> ValueUnion? {
        documentEditor.field(fieldID: tableFieldID)?.valueToValueElements?
            .first(where: { $0.id == row })?.cells?[column]
    }

    // Core of the fix: changes are keyed by columnID, so each entry must land in its
    // own column across every type in the switch, on all selected rows.
    func testBulkEdit_mapsEachColumnIDToItsOwnColumnAcrossTypes() async {
        let documentEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)

        let dropdownColumnID = "684c3feda4ab2268f6ac00c8"
        let numberColumnID   = "685752cf6a8d05a425d48836"
        let multiColumnID    = "685752c9b183f6583d205cc6"
        let barcodeColumnID  = "685752d672047e707b378e18"
        let dropdownOptionID = "684c3fed30e4ee677ad0defe"          // "No D1"
        let multiOptionIDs   = ["685752c91cb4780a9fb7382a", "685752c903c9a5c96e9a4549"]

        viewModel.tableDataModel.selectedRows = [rowA, rowB]

        await viewModel.bulkEdit(changes: [
            textColumnID:     .string("BulkText"),
            dropdownColumnID: .string(dropdownOptionID),
            numberColumnID:   .double(42),
            multiColumnID:    .array(multiOptionIDs),
            barcodeColumnID:  .string("BC-123"),
        ])
        waitForMainQueueToDrain()

        for row in [rowA, rowB] {
            XCTAssertEqual(cellValue(documentEditor, row: row, column: textColumnID)?.text, "BulkText", "text column on \(row)")
            XCTAssertEqual(cellValue(documentEditor, row: row, column: dropdownColumnID)?.text, dropdownOptionID, "dropdown column on \(row)")
            XCTAssertEqual(cellValue(documentEditor, row: row, column: numberColumnID)?.number, 42, "number column on \(row)")
            XCTAssertEqual(cellValue(documentEditor, row: row, column: multiColumnID)?.multiSelector, multiOptionIDs, "multiSelect column on \(row)")
            XCTAssertEqual(cellValue(documentEditor, row: row, column: barcodeColumnID)?.text, "BC-123", "barcode column on \(row)")
        }
    }

    func testBulkEdit_appliesValueToAllSelectedRows() async {
        let documentEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)

        let unselectedBefore = cellText(documentEditor, row: rowUnselected, column: textColumnID)
        viewModel.tableDataModel.selectedRows = [rowA, rowB]

        await viewModel.bulkEdit(changes: [textColumnID: .string("Testing")])
        waitForMainQueueToDrain()

        XCTAssertEqual(cellText(documentEditor, row: rowA, column: textColumnID), "Testing", "Selected row A should get the bulk value")
        XCTAssertEqual(cellText(documentEditor, row: rowB, column: textColumnID), "Testing", "Selected row B should get the bulk value")
        XCTAssertEqual(cellText(documentEditor, row: rowUnselected, column: textColumnID), unselectedBefore, "Unselected row must be untouched")
    }

    func testBulkEdit_unknownColumnID_isNoOpAndDoesNotCrash() async {
        let documentEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)

        let before = cellText(documentEditor, row: rowA, column: textColumnID)
        viewModel.tableDataModel.selectedRows = [rowA, rowB]

        await viewModel.bulkEdit(changes: ["nonexistent-column-id": .string("ShouldNotApply")])
        waitForMainQueueToDrain()

        XCTAssertEqual(cellText(documentEditor, row: rowA, column: textColumnID), before, "An unknown columnID must not mutate any cell")
    }

    func testBulkEdit_emptyChanges_isNoOp() async {
        let documentEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)

        let before = cellText(documentEditor, row: rowA, column: textColumnID)
        viewModel.tableDataModel.selectedRows = [rowA, rowB]

        await viewModel.bulkEdit(changes: [:])
        waitForMainQueueToDrain()

        XCTAssertEqual(cellText(documentEditor, row: rowA, column: textColumnID), before, "Empty changes must be a no-op")
    }

    func testBulkEdit_rowWithFewerCellsThanColumns_doesNotCrash() async {
        let documentEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)

        XCTAssertGreaterThan(viewModel.tableDataModel.tableColumns.count, 0, "Fixture must have columns for this test to be meaningful")
        guard let idx = viewModel.tableDataModel.cellModels.firstIndex(where: { $0.rowID == rowA }) else {
            return XCTFail("Row \(rowA) not found in cellModels")
        }
        viewModel.tableDataModel.cellModels[idx].cells = []
        viewModel.tableDataModel.selectedRows = [rowA]

        await viewModel.bulkEdit(changes: [textColumnID: .string("Testing")])
        waitForMainQueueToDrain()

        XCTAssertEqual(cellText(documentEditor, row: rowA, column: textColumnID), "Testing", "bulkEdit must complete and persist despite a truncated cells array")
    }

    // MARK: - maxRows (row limit) coverage
    //
    // `maxRows` is a document-supplied field property that caps how many rows a user may add.
    // Absent = no limit (default). The UI disables every add surface once reached (`canAddRows`),
    // while the external change API only warns (`isRowLimitReached`) and still applies received rows
    // so offline clients stay in sync. These tests pin: the model getter/setter, the gate math (incl.
    // deleted-row exclusion & live recompute), and the external preserve-and-warn behavior at the limit.

    /// Returns the fixture document with `maxRows` set (or cleared) on the table field.
    private func documentWithMaxRows(_ maxRows: Int?) -> JoyDoc {
        var document = createTestDocument()
        var fields = document.fields
        guard let idx = fields.firstIndex(where: { $0.id == tableFieldID }) else {
            XCTFail("Table field \(tableFieldID) not found in fixture")
            return document
        }
        fields[idx].maxRows = maxRows
        document.fields = fields
        return document
    }

    private func nonDeletedCount(_ documentEditor: DocumentEditor) -> Int {
        documentEditor.field(fieldID: tableFieldID)?.valueToValueElements?
            .filter { !($0.deleted ?? false) }.count ?? 0
    }

    /// Builds an external `field.value.rowCreate` change for the table field.
    private func rowCreateChange(rowID: String, index: Int) -> Change {
        Change(dictionary: [
            "target": "field.value.rowCreate",
            "pageId": pageID,
            "fileId": fileID,
            "fieldId": tableFieldID,
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "_id": "685750eff3216b45ffe73c80",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "sdk": "swift",
            "v": 1,
            "createdOn": 1756788353.0,
            "change": [
                "targetRowIndex": index,
                "row": [
                    "_id": rowID,
                    "cells": [:] as [String: Any]
                ] as [String: Any]
            ] as [String: Any]
        ])
    }

    // MARK: Model property

    func testMaxRows_absentByDefault_readsNil() {
        let field = createTestDocument().fields.first { $0.id == tableFieldID }
        XCTAssertNil(field?.maxRows, "maxRows must be nil when the JSON omits it")
    }

    func testMaxRows_property_roundTripsThroughDictionary() {
        var field = createTestDocument().fields.first { $0.id == tableFieldID }
        field?.maxRows = 7
        XCTAssertEqual(field?.maxRows, 7, "maxRows setter/getter should round-trip")
        XCTAssertEqual(field?.dictionary["maxRows"] as? Int, 7, "maxRows should persist into the backing dictionary")
    }

    // MARK: canAddRows gate

    func testCanAddRow_trueWhenNoLimit() {
        let documentEditor = DocumentEditor(document: documentWithMaxRows(nil), config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)
        XCTAssertTrue(viewModel.tableDataModel.canAddRows(), "No maxRows means rows can always be added")
    }

    func testCanAddRow_falseWhenAtLimit() {
        let documentEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false))
        let count = nonDeletedCount(documentEditor)
        let limitedEditor = DocumentEditor(document: documentWithMaxRows(count), config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: limitedEditor)
        XCTAssertFalse(viewModel.tableDataModel.canAddRows(), "At the limit, canAddRow must be false (add surfaces disabled)")
    }

    func testCanAddRow_trueWhenBelowLimit() {
        let documentEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false))
        let count = nonDeletedCount(documentEditor)
        let limitedEditor = DocumentEditor(document: documentWithMaxRows(count + 1), config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: limitedEditor)
        XCTAssertTrue(viewModel.tableDataModel.canAddRows(), "Below the limit, canAddRow must be true")
    }

    func testCanAddRow_recomputesAfterAddingRow() {
        let baseEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false))
        let count = nonDeletedCount(baseEditor)
        let documentEditor = DocumentEditor(document: documentWithMaxRows(count + 1), config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)

        XCTAssertTrue(viewModel.tableDataModel.canAddRows(), "Precondition: one slot remains")
        viewModel.addRow()
        XCTAssertFalse(viewModel.tableDataModel.canAddRows(), "After filling the last slot, canAddRow must flip to false")
    }

    func testCanAddRow_ignoresDeletedRows() {
        let baseEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false))
        let count = nonDeletedCount(baseEditor)
        // Set the limit to exactly the current count so we start at the limit.
        let documentEditor = DocumentEditor(document: documentWithMaxRows(count), config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)
        XCTAssertFalse(viewModel.tableDataModel.canAddRows(), "Precondition: starts at the limit")

        // Deleting a row should drop the non-deleted count below the limit and re-open adding.
        guard let firstRowID = viewModel.tableDataModel.rowOrder.first else {
            return XCTFail("Fixture has no rows to delete")
        }
        viewModel.deleteSelectedRow([firstRowID])
        XCTAssertTrue(viewModel.tableDataModel.canAddRows(), "Deleted rows must not count toward maxRows")
    }

    // MARK: isRowLimitReached (engine helper)

    func testIsRowLimitReached_falseWhenNoLimit() {
        let documentEditor = DocumentEditor(document: documentWithMaxRows(nil), config: DocumentEditorConfig(validateSchema: false))
        XCTAssertFalse(documentEditor.isRowLimitReached(fieldID: tableFieldID), "No maxRows means the limit is never reached")
    }

    func testIsRowLimitReached_trueAtLimit() {
        let baseEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false))
        let count = nonDeletedCount(baseEditor)
        let documentEditor = DocumentEditor(document: documentWithMaxRows(count), config: DocumentEditorConfig(validateSchema: false))
        XCTAssertTrue(documentEditor.isRowLimitReached(fieldID: tableFieldID), "At the row count, the limit is reached")
    }

    func testIsRowLimitReached_falseBelowLimit() {
        let baseEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false))
        let count = nonDeletedCount(baseEditor)
        let documentEditor = DocumentEditor(document: documentWithMaxRows(count + 1), config: DocumentEditorConfig(validateSchema: false))
        XCTAssertFalse(documentEditor.isRowLimitReached(fieldID: tableFieldID), "Below the limit, not reached")
    }

    // MARK: External change API (preserve received rows + warn)

    func testExternalRowCreate_preservedWhenAtLimit() {
        let baseEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false))
        let count = nonDeletedCount(baseEditor)
        let documentEditor = DocumentEditor(document: documentWithMaxRows(count), config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)

        documentEditor.change(changes: [rowCreateChange(rowID: "max_rows_preserved_row", index: count)])

        XCTAssertEqual(nonDeletedCount(documentEditor), count + 1, "A received rowCreate at the limit must still be applied so offline clients stay in sync")
        XCTAssertNotNil(documentEditor.field(fieldID: tableFieldID)?.valueToValueElements?.first { $0.id == "max_rows_preserved_row" },
                        "The received row must be inserted")
        XCTAssertTrue(viewModel.tableDataModel.valueToValueElements?.contains { $0.id == "max_rows_preserved_row" } ?? false,
                      "The received row must reach the view model")
    }

    func testExternalRowCreate_preservedPastLimit() {
        let baseEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false))
        let count = nonDeletedCount(baseEditor)
        // One slot free: first create is below the limit, the second is past it — both must apply.
        let documentEditor = DocumentEditor(document: documentWithMaxRows(count + 1), config: DocumentEditorConfig(validateSchema: false))

        documentEditor.change(changes: [rowCreateChange(rowID: "max_rows_allowed_row", index: count)])
        XCTAssertEqual(nonDeletedCount(documentEditor), count + 1, "First external rowCreate below the limit should succeed")

        documentEditor.change(changes: [rowCreateChange(rowID: "max_rows_second_row", index: count + 1)])
        XCTAssertEqual(nonDeletedCount(documentEditor), count + 2, "A received rowCreate past the limit must still be applied so offline clients stay in sync")
        XCTAssertNotNil(documentEditor.field(fieldID: tableFieldID)?.valueToValueElements?.first { $0.id == "max_rows_second_row" },
                        "The received over-limit row must be inserted")
    }

    func testExternalRowCreate_allowedWhenNoLimit() {
        let documentEditor = DocumentEditor(document: documentWithMaxRows(nil), config: DocumentEditorConfig(validateSchema: false))
        let count = nonDeletedCount(documentEditor)

        documentEditor.change(changes: [rowCreateChange(rowID: "no_limit_row", index: count)])

        XCTAssertEqual(nonDeletedCount(documentEditor), count + 1, "With no maxRows, external rowCreate must behave as before")
        XCTAssertNotNil(documentEditor.field(fieldID: tableFieldID)?.valueToValueElements?.first { $0.id == "no_limit_row" },
                        "The new row should be inserted when there is no limit")
    }

    // MARK: remainingRowCapacity (drives the duplicate popover's on-screen message)

    func testRemainingRowCapacity_nilWhenNoLimit() {
        let documentEditor = DocumentEditor(document: documentWithMaxRows(nil), config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)
        XCTAssertNil(viewModel.tableDataModel.remainingRowCapacity, "No maxRows means unlimited capacity (nil)")
    }

    func testRemainingRowCapacity_valueBelowLimit() {
        let baseEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false))
        let count = nonDeletedCount(baseEditor)
        let documentEditor = DocumentEditor(document: documentWithMaxRows(count + 2), config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)
        XCTAssertEqual(viewModel.tableDataModel.remainingRowCapacity, 2, "Two slots below the limit should report 2 remaining")
    }

    func testRemainingRowCapacity_zeroAtLimit() {
        let baseEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false))
        let count = nonDeletedCount(baseEditor)
        let documentEditor = DocumentEditor(document: documentWithMaxRows(count), config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)
        XCTAssertEqual(viewModel.tableDataModel.remainingRowCapacity, 0, "At the limit, remaining capacity is 0")
    }

    func testRemainingRowCapacity_clampedToZeroWhenOverLimit() {
        let baseEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false))
        let count = nonDeletedCount(baseEditor)
        // maxRows below the current count (e.g. lowered after rows already exist) must not go negative.
        let documentEditor = DocumentEditor(document: documentWithMaxRows(max(count - 1, 0)), config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)
        XCTAssertEqual(viewModel.tableDataModel.remainingRowCapacity, 0, "Over the limit, remaining capacity clamps to 0 (never negative)")
    }

    func testRemainingRowCapacity_ignoresDeletedRows() {
        let baseEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false))
        let count = nonDeletedCount(baseEditor)
        let documentEditor = DocumentEditor(document: documentWithMaxRows(count), config: DocumentEditorConfig(validateSchema: false))
        let viewModel = createTableViewModel(documentEditor: documentEditor)
        XCTAssertEqual(viewModel.tableDataModel.remainingRowCapacity, 0, "Precondition: starts at the limit")

        guard let firstRowID = viewModel.tableDataModel.rowOrder.first else {
            return XCTFail("Fixture has no rows to delete")
        }
        viewModel.deleteSelectedRow([firstRowID])
        XCTAssertEqual(viewModel.tableDataModel.remainingRowCapacity, 1, "Deleting a row frees one slot; deleted rows don't count")
    }

    // MARK: duplicateRow (block + warn when quantity would exceed the limit)

    func testDuplicateRow_blockedWhenQuantityExceedsLimit() {
        let baseEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false))
        let count = nonDeletedCount(baseEditor)
        // One free slot, but the user asks to duplicate 3 rows.
        let documentEditor = DocumentEditor(document: documentWithMaxRows(count + 1), config: DocumentEditorConfig(validateSchema: false, display: DisplayConfig(enableRowDuplicates: true)))
        let viewModel = createTableViewModel(documentEditor: documentEditor)

        guard let firstRowID = viewModel.tableDataModel.rowOrder.first else {
            return XCTFail("Fixture has no rows to duplicate")
        }
        viewModel.duplicateRow(rowID: firstRowID, quantity: 3)

        XCTAssertEqual(viewModel.tableDataModel.nondeletedRowsCount, count,
                       "Duplicating more rows than the remaining capacity must be blocked (no-op)")
    }

    func testDuplicateRow_allowedWhenQuantityFitsLimit() {
        let baseEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false))
        let count = nonDeletedCount(baseEditor)
        // Exactly two free slots, duplicate two rows — fills to the limit.
        let documentEditor = DocumentEditor(document: documentWithMaxRows(count + 2), config: DocumentEditorConfig(validateSchema: false, display: DisplayConfig(enableRowDuplicates: true)))
        let viewModel = createTableViewModel(documentEditor: documentEditor)

        guard let firstRowID = viewModel.tableDataModel.rowOrder.first else {
            return XCTFail("Fixture has no rows to duplicate")
        }
        viewModel.duplicateRow(rowID: firstRowID, quantity: 2)

        XCTAssertEqual(viewModel.tableDataModel.nondeletedRowsCount, count + 2,
                       "Duplicating within the remaining capacity should succeed and fill to the limit")
    }

    func testDuplicateRow_allowedWhenNoLimit() {
        let documentEditor = DocumentEditor(document: documentWithMaxRows(nil), config: DocumentEditorConfig(validateSchema: false, display: DisplayConfig(enableRowDuplicates: true)))
        let viewModel = createTableViewModel(documentEditor: documentEditor)
        let count = viewModel.tableDataModel.nondeletedRowsCount

        guard let firstRowID = viewModel.tableDataModel.rowOrder.first else {
            return XCTFail("Fixture has no rows to duplicate")
        }
        viewModel.duplicateRow(rowID: firstRowID, quantity: 5)

        XCTAssertEqual(viewModel.tableDataModel.nondeletedRowsCount, count + 5,
                       "With no maxRows, duplicating any quantity should succeed")
    }

    // With row duplication disabled, duplicating through the VM must be a no-op that leaves the
    // existing rows intact rather than wiping them.
    func testDuplicateRow_disabled_leavesRowsIntact() {
        let documentEditor = DocumentEditor(document: createTestDocument(), config: DocumentEditorConfig(validateSchema: false, display: DisplayConfig(enableRowDuplicates: false)))
        let viewModel = createTableViewModel(documentEditor: documentEditor)
        let rowsBefore = viewModel.tableDataModel.rowOrder

        guard let firstRowID = rowsBefore.first else {
            return XCTFail("Fixture has no rows to duplicate")
        }
        viewModel.duplicateRow(rowID: firstRowID, quantity: 2)

        XCTAssertEqual(viewModel.tableDataModel.rowOrder, rowsBefore,
                       "Duplication disabled must be a no-op, not a wipe of the live rows")
        XCTAssertFalse(viewModel.tableDataModel.valueToValueElements?.isEmpty ?? true,
                       "The field's elements must not be cleared when duplication is disabled")
    }
}
