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
}
