//
//  ManipulateDataOnChangeView.swift
//  JoyfillExample
//
//  Created by Vivek on 11/07/25.
//

import Foundation
import JoyfillModel
import Joyfill
import SwiftUI

var manipulateDocumentEditor: DocumentEditor!

struct ManipulateDataOnChangeView: View, FormChangeEvent {
    let imagePicker = ImagePicker()
    init() {
        //
        let document = sampleJSONDocument(fileName: "hint_and_deficiency_demo")

        manipulateDocumentEditor = DocumentEditor(document: document, events: self, isPageDuplicateEnabled: true)

    }
    
    var body: some View {
        HStack {
            NavigationView {
                Form(documentEditor: manipulateDocumentEditor)
                    .tint(.red)
            }
        }
    }

    func onChange(changes: [JoyfillModel.Change], document: JoyfillModel.JoyDoc) {
        print("onChange documentID:", document.id)
        let extraChanges = appendHintChanges(changes: changes, document: document)
        manipulateDocumentEditor.change(changes: extraChanges)
    }

    func appendHintChanges(changes: [JoyfillModel.Change], document: JoyfillModel.JoyDoc) -> [JoyfillModel.Change] {
        var extraChanges: [JoyfillModel.Change] = []

        let alarmDevicesFieldID = "67fa8e2a64d97bb156b088db"
        let hintsFieldID = "67fa934a0d0062e14617252f"
        let deviceTypeColumnID = "67fa8e20c0bf00d7dcb01486"
        let visualHintColumnID = "67fa9262c014f71619c540bf"
        let functionalHintColumnID = "67fa9277716cd4bd455398b9"

        for change in changes {
            guard
                change.target == "field.value.rowUpdate",
                change.fieldId == alarmDevicesFieldID,
                let changedFieldRowID = change.change?["rowId"] as? String,
                let rowDict = change.change?["row"] as? [String: Any],
                let cells = rowDict["cells"] as? [String: Any],
                let selectedOptionID = cells[deviceTypeColumnID] as? String,
                let hintsField = manipulateDocumentEditor.field(fieldID: hintsFieldID),
                let hintRows = hintsField.valueToValueElements
            else {
                continue
            }

            guard let matchingHintRow = hintRows.first(where: {
                $0.cells?[deviceTypeColumnID]?.text == selectedOptionID
            }) else { continue }

            var updatedCells: [String: Any] = [:]

            if let newCellValue = matchingHintRow.cells?[visualHintColumnID]?.dictionary {
                updatedCells[visualHintColumnID] = newCellValue
            }
            if let newCellValue = matchingHintRow.cells?[functionalHintColumnID]?.dictionary {
                updatedCells[functionalHintColumnID] = newCellValue
            }
            if let newCellValue = matchingHintRow.cells?[deviceTypeColumnID]?.dictionary {
                updatedCells[deviceTypeColumnID] = newCellValue
            }

            guard !updatedCells.isEmpty else { continue }

            let payload: [String: Any] = [
//                "parentPath": change.change?["parentPath"] ?? "",
//                "schemaId": change.change?["schemaId"] ?? "",
                "rowId": changedFieldRowID,
                "row": [
                    "_id": changedFieldRowID,
                    "cells": updatedCells
                ]
            ]

            let hintChange = JoyfillModel.Change(
                v: 1,
                sdk: "swift",
                target: "field.value.rowUpdate",
                _id: document.id ?? "",
                identifier: document.identifier ?? "",
                fileId: change.fileId ?? "",
                pageId: change.pageId ?? "",
                fieldId: change.fieldId ?? "",
                fieldIdentifier: change.fieldIdentifier,
                fieldPositionId: change.fieldPositionId ?? "",
                change: payload,
                createdOn: Date().timeIntervalSince1970
            )

            extraChanges.append(hintChange)
        }

        return extraChanges
    }

    func onFocus(event: JoyfillModel.FieldIdentifier) { }
    func onBlur(event: JoyfillModel.FieldIdentifier) { }
    func onCapture(event: JoyfillModel.CaptureEvent) { }
    func onUpload(event: JoyfillModel.UploadEvent) {
        event.uploadHandler(["https://app.joyfill.io/static/img/joyfill_logo_w.png"])
    }
}
