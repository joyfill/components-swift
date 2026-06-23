//
//  DropdownToCollection.swift
//  JoyfillExample
//
//  Created by Sumit's Mac on 22/06/26.
//

import Foundation
import JoyfillModel
import Joyfill
import SwiftUI

var dropdownDemoDocumentEditor: DocumentEditor!

struct DropdownCollectionDemoView: View, FormChangeEvent {
    var documentEditor: DocumentEditor { dropdownDemoDocumentEditor }

    // Page 1 collection + its dropdown column / "High" option
    private let page1CollectionFieldID = "6a3a86c7eb7c6217ebb41636"
    private let dropdownColumnID = "6813008e36be88d98ed5a90a"
    private let highOptionID = "6813008e634fdf79fe013b42"

    // Page 2 collection that receives a new row
    private let page2CollectionFieldID = "6a3a86b5ef84e04b356ea1b6"

    init() {
        let document = sampleJSONDocument(fileName: "Dropdown-Collection")
        dropdownDemoDocumentEditor = DocumentEditor(document: document, events: self, isPageDuplicateEnabled: true, validateSchema: false, license: licenseKey)
    }

    var body: some View {
        NavigationView {
            Form(documentEditor: documentEditor)
                .tint(.red)
        }
    }
}

extension DropdownCollectionDemoView {
    func onChange(changes: [Change], document: JoyfillModel.JoyDoc) {
        for change in changes where selectedHighInPage1Dropdown(change) {
            documentEditor.change(changes: [makeAddRowChange()])
        }
    }

    func onFocus(event: Event) { }
    func onBlur(event: Event) { }
    func onCapture(event: CaptureEvent) { }
    func onUpload(event: UploadEvent) { }
    func onError(error: Joyfill.JoyfillError) { }

    private func selectedHighInPage1Dropdown(_ change: Change) -> Bool {
        guard change.target == "field.value.rowUpdate",
              change.fieldId == page1CollectionFieldID,
              let row = change.change?["row"] as? [String: Any],
              let cells = row["cells"] as? [String: Any],
              let selectedOption = cells[dropdownColumnID] as? String else {
            return false
        }
        return selectedOption == highOptionID
    }

    private func makeAddRowChange() -> Change {
        let fieldIdentifier = documentEditor.getFieldIdentifier(for: page2CollectionFieldID)
        let rowID = UUID().uuidString
        let rowCount = documentEditor.field(fieldID: page2CollectionFieldID)?.valueToValueElements?.count ?? 0

        // Root-level collection row: empty schemaId / parentPath insert at the end.
        let payload: [String: Any] = [
            "rowId": rowID,
            "schemaId": "",
            "parentPath": "",
            "targetRowIndex": rowCount,
            "row": [
                "_id": rowID,
                "cells": [String: Any](),
                "children": [String: Any]()
            ]
        ]

        return Change(
            v: 1,
            sdk: "swift",
            target: "field.value.rowCreate",
            _id: documentEditor.documentID ?? "",
            identifier: documentEditor.documentIdentifier,
            fileId: fieldIdentifier.fileID ?? "",
            pageId: fieldIdentifier.pageID ?? "",
            fieldId: page2CollectionFieldID,
            fieldIdentifier: fieldIdentifier.fieldIdentifier,
            fieldPositionId: fieldIdentifier.fieldPositionId ?? "",
            change: payload,
            createdOn: Date().timeIntervalSince1970
        )
    }
}
