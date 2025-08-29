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
            "fileId": "67691d2f268e121323b45666",
            "fieldId": "67691d3a34a88f0aa9850968",
            "createdOn": 1756455018.8836021,
            "v": 1,
            "_id": "67692ecc196161f0435f69b4",
            "fieldPositionId": "67691d3d5233df47cb4c9585",
            "identifier": "doc_67692ecc196161f0435f69b4",
            "pageId": "67691d2fc10197848332d113",
            "fieldIdentifier": "field_67691d3d9a1abacc10fb80bd",
            "sdk": "swift",
            "change": [
                "value": [
                    [
                        "deleted": 0,
                        "_id": "67691971a4c41137665f362a",
                        "cells": [
                            "676919715e36fed325f2f048": 1712255400000,
                            "67691971e689df0b1208de63": 2,
                            "67692e13fa282a51845f4f14": "First row",
                            "676137715cb7a772624dd5ab": "First row",
                            "66a1ead8a7d8bff7bb2f982a": ["66a1e2e9e9e6674ea80d71f7"],
                            "676919715e36fed325f2f040": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAABQoAAAKU..." // truncated for readability
                        ]
                    ],
                    [
                        "_id": "67691971e3f0e90c473f6db1",
                        "deleted": 0,
                        "cells": [
                            "676919715e36fed325f2f048": 1713984174769,
                            "676137715cb7a772624dd5ab": "Second row",
                            "66a1ead8a7d8bff7bb2f982a": ["66a1e2e9ed6de57065b6cede"],
                            "67691971e689df0b1208de63": 22,
                            "67692e13fa282a51845f4f14": "Second row"
                        ]
                    ],
                    [
                        "deleted": 0,
                        "cells": [
                            "676137715cb7a772624dd5ab": "Third row",
                            "67692e13fa282a51845f4f14": "112",
                            "67691971e689df0b1208de63": 200,
                            "66a1ead8a7d8bff7bb2f982a": [
                                "66a1e2e9e9e6674ea80d71f7",
                                "66a1e2e9ed6de57065b6cede",
                                "66a1e2e9a3948b3bdc7a5d62"
                            ],
                            "676919715e36fed325f2f048": 1712385780000
                        ],
                        "_id": "676919712bdb40e9d61b59a6"
                    ],
                    [
                        "cells": [
                            "6769197102fe4635130814eb": "",
                            "66a1ead8a7d8bff7bb2f982a": [],
                            "676919715e36fed325f2f048": "Date",
                            "67691971e689df0b1208de63": 2.1110000000000002
                        ],
                        "deleted": 0,
                        "_id": "67692d899b1de7220aebc897"
                    ],
                    [
                        "_id": "67692d8a3fddfae28c005d61",
                        "deleted": 0,
                        "cells": [
                            "6769197102fe4635130814eb": "",
                            "67692e13fa282a51845f4f14": "Block Field",
                            "67691971e689df0b1208de63": 102
                        ]
                    ],
                    [
                        "deleted": 0,
                        "cells": [
                            "67691971e689df0b1208de63": 32,
                            "6769197102fe4635130814eb": ""
                        ],
                        "_id": "67692df9dd6fb28904da322a"
                    ],
                    [
                        "_id": "68b160684351e35f9ee7d874",
                        "cells": [
                            "676137715cb7a772624dd5ab": "Default value",
                            "67692e13fa282a51845f4f14": "Block Column Value",
                            "66a1ead8a7d8bff7bb2f982a": ["66a1e2e9e9e6674ea80d71f7"],
                            "67691971e689df0b1208de63": 12345,
                            "676919715e36fed325f2f040": 1712255400000,
                            "676919715e36fed325f2f048": 1712255400000
                        ]
                    ]
                ]
            ],
            "target": "field.update"
        ]
        let change = Change(dictionary: changeDict)
        documentEditor.change(changes: [change])
        
        let updatedNumberOfRows = viewModel.tableDataModel.valueToValueElements?.count
        let updatedNumberOFRowsFromDocumentEditor = documentEditor.field(fieldID: "685750f0489567f18eb8a9ec")?.valueToValueElements?.count
        XCTAssertEqual(updatedNumberOfRows, 4, "Rows should be updated")
        XCTAssertEqual(updatedNumberOFRowsFromDocumentEditor, 4, "Rows should be updated")
    }
    
    func testApplyRowEditChanges_InvalidRowID_LogsError() {
        // Given
        let document = createTestDocument()
        let documentEditor = DocumentEditor(document: document, validateSchema: false)
        let viewModel = createTableViewModel(documentEditor: documentEditor)
        
        let changeDict1: [String: Any] = [
            "_id": "685750eff3216b45ffe73c80",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "pageId": "685750efeb612f4fac5819dd",
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "createdOn": 1756477790.7847528,
            "v": 1,
            "sdk": "swift",
            "fileId": "685750ef698da1ab427761ba",
            "target": "field.value.rowUpdate",
            "change": [
                "rowId": "684c3fedfed2b76677110b19",
                "row": [
                    "_id": "684c3fedfed2b76677110b19",
                    "cells": [
                        "684c3fedce82027a49234dd3": "Update"
                    ]
                ]
            ],
            "fieldId": "685750f0489567f18eb8a9ec"
        ]
        
        let changeDict2: [String: Any] = [
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "v": 1,
            "change": [
                "rowId": "68575b4059f586b81549fc07",
                "row": [
                    "_id": "68575b4059f586b81549fc07",
                    "cells": [
                        "684c3fedce82027a49234dd3": "Update"
                    ]
                ]
            ],
            "fieldId": "685750f0489567f18eb8a9ec",
            "createdOn": 1756477790.7847719,
            "target": "field.value.rowUpdate",
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "sdk": "swift",
            "fileId": "685750ef698da1ab427761ba",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "_id": "685750eff3216b45ffe73c80",
            "pageId": "685750efeb612f4fac5819dd"
        ]
        
        let changeDict3: [String: Any] = [
            "sdk": "swift",
            "pageId": "685750efeb612f4fac5819dd",
            "_id": "685750eff3216b45ffe73c80",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "target": "field.value.rowUpdate",
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "change": [
                "rowId": "68575b41d49ad2d821193a3d",
                "row": [
                    "_id": "68575b41d49ad2d821193a3d",
                    "cells": [
                        "684c3fedce82027a49234dd3": "Update"
                    ]
                ]
            ],
            "fileId": "685750ef698da1ab427761ba",
            "v": 1,
            "fieldId": "685750f0489567f18eb8a9ec",
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "createdOn": 1756477790.784775
        ]
        
        let changeDict4: [String: Any] = [
            "fieldIdentifier": "field_6857510f0b31d28d169b83d8",
            "createdOn": 1756477790.7847772,
            "pageId": "685750efeb612f4fac5819dd",
            "_id": "685750eff3216b45ffe73c80",
            "v": 1,
            "target": "field.value.rowUpdate",
            "sdk": "swift",
            "fieldPositionId": "6857510f4313cfbfb43c516c",
            "change": [
                "rowId": "68599845cb06457892ce27b4",
                "row": [
                    "cells": [
                        "684c3fedce82027a49234dd3": "Update"
                    ],
                    "_id": "68599845cb06457892ce27b4"
                ]
            ],
            "fieldId": "685750f0489567f18eb8a9ec",
            "identifier": "doc_685750eff3216b45ffe73c80",
            "fileId": "685750ef698da1ab427761ba"
        ]
        
        

        
        let change1 = Change(dictionary: changeDict1)
        let change2 = Change(dictionary: changeDict2)
        let change3 = Change(dictionary: changeDict3)
        let change4 = Change(dictionary: changeDict4)
        documentEditor.change(changes: [change1, change2, change3, change4])
        
        let updatedNumberOfRows = viewModel.tableDataModel.valueToValueElements?.count
        let updatedNumberOFRowsFromDocumentEditor = documentEditor.field(fieldID: "685750f0489567f18eb8a9ec")?.valueToValueElements
        XCTAssertEqual(updatedNumberOfRows, 4, "Rows should be updated")
    }
}
