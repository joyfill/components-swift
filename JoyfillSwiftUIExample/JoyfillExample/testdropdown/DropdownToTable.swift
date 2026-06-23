//
//  dropdowntotable.swift
//  JoyfillExample
//
//  Created by Sumit's Mac on 22/06/26.
//

import Foundation
import JoyfillModel
import Joyfill
import SwiftUI

var dropdownDemoDocumentEditor: DocumentEditor!

struct DropdownTableDemoView: View, FormChangeEvent {
    var documentEditor: DocumentEditor { dropdownDemoDocumentEditor }

    // Page 1 table + its dropdown column / "Yes" option
    private let page1TableFieldID = "69d3455047872828fd96de60"
    private let dropdownColumnID = "69d337ccd10629a7701dc731"
    private let yesOptionID = "69d337ccc122c9b7539df9e1"

    // Page 2 table that receives a new row
    private let page2TableFieldID = "6a38d632d3267f61016a9a55"

    init() { 
        let document = sampleJSONDocument(fileName: "Dropdown-Table")
        dropdownDemoDocumentEditor = DocumentEditor(document: document, events: self, isPageDuplicateEnabled: true, validateSchema: false, license: licenseKey)
    }

    var body: some View {
        NavigationView {
            Form(documentEditor: documentEditor)
                .tint(.red)
        }
    }
}

extension DropdownTableDemoView {
    func onChange(changes: [Change], document: JoyfillModel.JoyDoc) {
        for change in changes where selectedYesInPage1Dropdown(change) {
            documentEditor.change(changes: [makeAddRowChange()])
        }
    }

    func onFocus(event: Event) { }
    func onBlur(event: Event) { }
    func onCapture(event: CaptureEvent) { }
    func onUpload(event: UploadEvent) { }
    func onError(error: Joyfill.JoyfillError) { }

    private func selectedYesInPage1Dropdown(_ change: Change) -> Bool {
        guard change.target == "field.value.rowUpdate",
              change.fieldId == page1TableFieldID,
              let row = change.change?["row"] as? [String: Any],
              let cells = row["cells"] as? [String: Any],
              let selectedOption = cells[dropdownColumnID] as? String else {
            return false
        }
        return selectedOption == yesOptionID
    }

    private func makeAddRowChange() -> Change {
        let fieldIdentifier = documentEditor.getFieldIdentifier(for: page2TableFieldID)
        let rowID = UUID().uuidString

        let payload: [String: Any] = [
            "rowId": rowID,
            "schemaId": "",
            "parentPath": "",
            "row": [
                "_id": rowID,
                "cells": [String: Any]()
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
            fieldId: page2TableFieldID,
            fieldIdentifier: fieldIdentifier.fieldIdentifier,
            fieldPositionId: fieldIdentifier.fieldPositionId ?? "",
            change: payload,
            createdOn: Date().timeIntervalSince1970
        )
    }
}
