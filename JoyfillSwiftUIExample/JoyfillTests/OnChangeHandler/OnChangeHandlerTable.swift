//
//  OnChangeHandlerTable.swift
//  JoyfillExample
//
//  Created by Vivek on 28/07/25.
//

import XCTest
import Foundation
import SwiftUI
import JoyfillModel
import Joyfill

final class OnChangeHandlerTableTests: XCTestCase {
    func documentEditor(document: JoyDoc) -> DocumentEditor {
        DocumentEditor(document: document, validateSchema: false)
    }
    
    func getTableRowUpdateChange(changeDictionary: [String: Any] = [:]) -> Change {
        
        return Change(v: 1,
                      sdk: "swift",
                      target: "field.value.rowUpdate",
                      _id: "document_Id",
                      identifier: "",
                      fileId: "6629fab3c0ba3fb775b4a55c",
                      pageId: "6629fab320fca7c8107a6cf6",
                      fieldId: "67612793c4e6a5e6a05e64a3",
                      fieldIdentifier: "field_676127963e76996d780e6c51",
                      fieldPositionId: "6629fbc736d179b9014abae0",
                      change: changeDictionary,
                      createdOn: 1753676985.639533)
    }
    
    func testChangeCellForTable() throws {
        let document = JoyDoc(dictionary: ["_id" : "document_Id"])
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        
        
        let documentEditor = documentEditor(document: document)
        let chnageDictionary: [String: Any] = [
            "rowId": "676127938056dcd158942bad",
            "row": [
                "_id": "676127938056dcd158942bad",
                "cells": [
                    "676127938fb7c5fd4321a2f4": "hello ji"
                ]
            ]
        ]
        let change = getTableRowUpdateChange(changeDictionary: chnageDictionary)
        documentEditor.change(changes: [change])
        let field = documentEditor.field(fieldID: "67612793c4e6a5e6a05e64a3")
        XCTAssertEqual(field?.valueToValueElements?[0].cells?["676127938fb7c5fd4321a2f4"] as? String, "hello ji")
    }
}
