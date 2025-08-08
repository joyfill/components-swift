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
    func onError(error: Joyfill.JoyfillError) {

    }
    
    let imagePicker = ImagePicker()
    init() {
        //
        let document = sampleJSONDocument(fileName: "hint_and_deficiency_demo")

        manipulateDocumentEditor = DocumentEditor(document: document, events: self, isPageDuplicateEnabled: true, validateSchema: false)

    }
    
    var body: some View {
        HStack {
            NavigationView {
                Form(documentEditor: manipulateDocumentEditor)
                    .tint(.red)
            }
        }
    }

    func onChange(changes: [Change], document: JoyfillModel.JoyDoc) {
        print("onChange documentID:", document.id)
        let extraChanges = appendHintChanges(changes: changes, document: document)
        manipulateDocumentEditor.change(changes: extraChanges)
    }

    func appendHintChanges(changes: [Change], document: JoyfillModel.JoyDoc) -> [Change] {
        var additionalChanges: [Change] = []

        let sourceTableFieldID = "67fa8e2a64d97bb156b088db"
        let hintLookupTableFieldID = "67fa934a0d0062e14617252f"
        let deviceTypeColumn = "67fa8e20c0bf00d7dcb01486"
        let visualHintColumn = "67fa9262c014f71619c540bf"
        let functionalHintColumn = "67fa9277716cd4bd455398b9"

        for change in changes {
            guard let rowUpdate = extractRowUpdateInfo(from: change, sourceFieldID: sourceTableFieldID) else {
                continue
            }
            
            guard let selectedDeviceType = rowUpdate.updatedCells[deviceTypeColumn] as? String else {
                continue
            }
            
            guard let hintLookupTable = manipulateDocumentEditor.field(fieldID: hintLookupTableFieldID),
                  let lookupRows = hintLookupTable.valueToValueElements else {
                continue
            }

            guard let matchingHintRow = findMatchingHintRow(
                in: lookupRows,
                deviceTypeColumn: deviceTypeColumn,
                selectedDeviceType: selectedDeviceType
            ) else {
                continue
            }

            let cellsToUpdate = buildUpdatedCells(
                from: matchingHintRow,
                columns: [visualHintColumn, functionalHintColumn, deviceTypeColumn]
            )
            
            guard !cellsToUpdate.isEmpty else { continue }

            let hintUpdateChange = createRowUpdateChange(
                from: change,
                document: document,
                rowID: rowUpdate.rowID,
                updatedCells: cellsToUpdate
            )

            additionalChanges.append(hintUpdateChange)
        }

        return additionalChanges
    }
    
    // MARK: - Helper Methods
    
    private func extractRowUpdateInfo(from change: Change, sourceFieldID: String) -> (rowID: String, updatedCells: [String: Any])? {
        guard change.target == "field.value.rowUpdate",
              change.fieldId == sourceFieldID,
              let rowID = change.change?["rowId"] as? String,
              let rowData = change.change?["row"] as? [String: Any],
              let updatedCells = rowData["cells"] as? [String: Any] else {
            return nil
        }
        
        return (rowID: rowID, updatedCells: updatedCells)
    }
    
    private func findMatchingHintRow(
        in lookupRows: [ValueElement],
        deviceTypeColumn: String,
        selectedDeviceType: String
    ) -> ValueElement? {
        return lookupRows.first { row in
            row.cells?[deviceTypeColumn]?.text == selectedDeviceType
        }
    }
    
    private func buildUpdatedCells(from hintRow: ValueElement, columns: [String]) -> [String: Any] {
        var updatedCells: [String: Any] = [:]
        
        for columnID in columns {
            if let cellValue = hintRow.cells?[columnID]?.dictionary {
                updatedCells[columnID] = cellValue
            }
        }
        
        return updatedCells
    }
    
    private func createRowUpdateChange(
        from originalChange: Change,
        document: JoyfillModel.JoyDoc,
        rowID: String,
        updatedCells: [String: Any]
    ) -> Change {
        let payload: [String: Any] = [
            "rowId": rowID,
            "row": [
                "_id": rowID,
                "cells": updatedCells
            ]
        ]

        return Change(
            v: 1,
            sdk: "swift",
            target: "field.value.rowUpdate",
            _id: document.id ?? "",
            identifier: document.identifier ?? "",
            fileId: originalChange.fileId ?? "",
            pageId: originalChange.pageId ?? "",
            fieldId: originalChange.fieldId ?? "",
            fieldIdentifier: originalChange.fieldIdentifier,
            fieldPositionId: originalChange.fieldPositionId ?? "",
            change: payload,
            createdOn: Date().timeIntervalSince1970
        )
    }

    func onFocus(event: FieldIdentifier) { }
    func onBlur(event: FieldIdentifier) { }
    func onCapture(event: CaptureEvent) { }
    func onUpload(event: UploadEvent) {
        event.uploadHandler(["https://app.joyfill.io/static/img/joyfill_logo_w.png"])
    }
}
