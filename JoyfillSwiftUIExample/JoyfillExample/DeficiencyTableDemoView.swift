//
//  DeficiencyTableDemoView.swift
//  JoyfillExample
//
//  Created by Vivek on 11/07/25.
//

import Foundation
import JoyfillModel
import Joyfill
import SwiftUI

var deficiencyDemoDocumentEditor: DocumentEditor!

struct DeficiencyTableDemoView: View, FormChangeEvent {
    let imagePicker = ImagePicker()
    
    init() {
        let document = sampleJSONDocument(fileName: "hint_and_deficiency_demo")
        deficiencyDemoDocumentEditor = DocumentEditor(document: document, events: self, isPageDuplicateEnabled: true, validateSchema: false)
    }
    
    var body: some View {
        NavigationView {
            Form(documentEditor: deficiencyDemoDocumentEditor)
                .tint(.red)
        }
    }
}
extension DeficiencyTableDemoView {
    func onChange(changes: [Change], document: JoyfillModel.JoyDoc) {
        print("onChange documentID:", document.id)
        deficiencyDemoDocumentEditor.prepopulateDataFromHintsTableFor(document: document, documentEditor: deficiencyDemoDocumentEditor, changeEvent: changes.first!)
    }
    
    func onFocus(event: FieldIdentifier) { }
    func onBlur(event: FieldIdentifier) { }
    func onCapture(event: CaptureEvent) { }
    func onUpload(event: UploadEvent) { }
    func onError(error: Joyfill.JoyfillError) { }
}

extension DocumentEditor {
    // MARK: - Helper Methods
    func prepopulateDataFromHintsTableFor(document: JoyDoc, documentEditor: DocumentEditor, changeEvent: Joyfill.Change) {
        guard let changedRowID = (changeEvent.dictionary["change"] as? [String: Any?])?["rowId"] as? String else {
            return
        }
        guard let updatedCells = prepopulateDataFromHintsTableFor(document: document, changeEvent: changeEvent, documentEditor: documentEditor) else {
            return
        }

        let newChange = createRowUpdateChange(from: changeEvent, document: document, rowID: changedRowID, updatedCells: updatedCells)
        documentEditor.change(changes: [newChange])
    }

    func prepopulateDataFromHintsTableFor(document: JoyDoc, changeEvent: Joyfill.Change, documentEditor: DocumentEditor) -> [String: Any]? {
        guard let fieldID = changeEvent.fieldId else {
            return nil
        }

        guard let matchField = documentEditor.field(fieldID: fieldID) else {
            return nil
        }

        let hintTableID = "_hintTable"

        guard let hintsTableIdentifier = matchField.metadata?.dictionary[hintTableID] as? String else {
            return nil
        }

        guard let hintsTableField = document.fields.first(where: { $0.identifier == hintsTableIdentifier}) else {
            return nil
        }

        let kDictKeyChange = "change"
        let kDictKeyRow = "row"
        let kDictKeyCells = "cells"

        guard var changedCells = ((changeEvent.dictionary[kDictKeyChange] as? [String: Any?])?[kDictKeyRow] as? [String: Any?])?[kDictKeyCells] as? [String: Any?] else {
            return nil
        }

        changedCells = mapOptionIDsToValues(field: matchField, changedCells: changedCells)

        guard let sourceRowCells: [ValueElement] = hintsTableField.resolvedValue?.valueElements else {
            return nil
        }

        let existingColumnsIDs = matchField.tableColumns?.compactMap({$0.id}) ?? []

        let changedCellIDs = changedCells.compactMap({$0.key})

        let changedCellsValues: [String] = changedCells.compactMap { $0.value as? String }

        var hintsRows: [ValueElement] = []
        for cellValue in changedCellsValues {
            for item in sourceRowCells {
                for (key, value) in item.cells! {
                    if cellValue == value.text {
                        hintsRows.append(item)
                    }
                }
            }
        }
        var updatedCells: [String: Any] = [:]

        for row in hintsRows {
            for (key, _) in row.cells ?? [:] { // 100 cells, original : 6.
                if let hintsTableColumn = hintsTableField.tableColumns?.first{ $0.id == key},
                let matchFieldColumn = matchField.tableColumns?.first { $0.title == hintsTableColumn.title } {
                    if let cell = row.cells?[hintsTableColumn.id!] {
                        switch matchFieldColumn.type {
                        case .dropdown:
                            let rawValue = cell.text as? String
                            if let optionID = matchFieldColumn.options?.first(where: { $0.value == rawValue })?.id {
                                updatedCells[matchFieldColumn.id!] = optionID
                            }

                        case .multiSelect:
                            let rawValue = cell.text as? String
                            if let optionID = matchFieldColumn.options?.first(where: { $0.value == rawValue })?.id {
                                updatedCells[matchFieldColumn.id!] = optionID
                            }
                        default:
                            updatedCells[matchFieldColumn.id!] = cell.text
                        }
                    }
                }
            }
        }
        return updatedCells
    }

    func mapOptionIDsToValues(field: JoyDocField, changedCells: [String: Any?]) -> [String: Any?] {
        var changedCells = changedCells
        
        if field.fieldType == .collection {
            
        } else if field.fieldType == .table {
            if let columns = field.tableColumns {
                for column in columns {
                    guard let columnId = column.id else { continue }
                    // Handle dropdown/multiselect option resolution
                    if let cellValue = changedCells[columnId] {
                        switch column.type {
                        case .dropdown:
                            let rawValue = cellValue as? String
                            if let optionValue = column.options?.first(where: { $0.id == rawValue })?.value {
                                changedCells[columnId] = optionValue
                            }
                        case .multiSelect:
                            let rawArray = cellValue as? Array<String>
                            let resolvedOptions = rawArray?.compactMap { rawId in
                                return column.options?.first(where: { $0.id == rawId })?.value
                            }
                            changedCells[columnId] = resolvedOptions
                        default:
                            break
                        }
                    }
                }
            }
        }
        return changedCells
        
    }

    func mapOptionValuesToOptionID(field: JoyDocField, changedCells: [String: Any?]) -> [String: Any?] {
        var changedCells = changedCells
        if let columns = field.tableColumns {
            for column in columns {
                guard let columnId = column.id else { continue }
                if let value = changedCells[columnId] {
                    // Handle dropdown/multiselect option resolution
                    if let cellValue = changedCells[columnId] {
                        switch column.type {
                        case .dropdown:
                            let rawValue = cellValue as? String
                            if let optionValue = column.options?.first(where: { $0.id == rawValue })?.value {
                                changedCells[columnId] = optionValue
                            }
                        case .multiSelect:
                            let rawArray = cellValue as? Array<String>
                            let resolvedOptions = rawArray?.compactMap { rawId in
                                return column.options?.first(where: { $0.id == rawId })?.value
                            }
                            changedCells[columnId] = resolvedOptions
                        default:
                            break
                        }
                    }
                }
            }
        }
        return changedCells
    }

    func createRowUpdateChange(
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

}
