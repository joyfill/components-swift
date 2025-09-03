//
//  TableViewModelDocumentEditorDelegateTests.swift
//  JoyfillTests
//
//  Created by iOS developer on 22/7/25
//

import XCTest
import Foundation
import SwiftUI
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
        let fieldHeaderModel = FieldHeaderModel(title: field?.title, required: field?.required, tipDescription: field?.tipDescription, tipTitle: field?.tipTitle, tipVisible: field?.tipVisible)
        let tableDataModel = TableDataModel(
            fieldHeaderModel: fieldHeaderModel,
            mode: Mode.fill,
            documentEditor: documentEditor,
            fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        )
        guard let tableDataModel else { fatalError("TableViewModel not found") }
        return TableViewModel(tableDataModel: tableDataModel)
    }
     
    func testApplyRowEditChanges_AddNewRow() {
        // Given
        let document = createTestDocument()
        let documentEditor = DocumentEditor(document: document, validateSchema: false)
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
    
    func testApplyRowEditChanges_BulkUpdate() {
        // Given
        let document = createTestDocument()
        let documentEditor = DocumentEditor(document: document, validateSchema: false)
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
        let documentEditor = DocumentEditor(document: document, validateSchema: false)
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
        let documentEditor = DocumentEditor(document: document, validateSchema: false)
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
        let documentEditor = DocumentEditor(document: document, validateSchema: false)
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
        let documentEditor = DocumentEditor(document: document, validateSchema: false)
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
}
