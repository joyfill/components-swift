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
        prepopulateDataFromHintsTableFor(document: document, documentEditor: deficiencyDemoDocumentEditor, changeEvent: changes.first!)
    }
    
    func onFocus(event: FieldIdentifier) { }
    func onBlur(event: FieldIdentifier) { }
    func onCapture(event: CaptureEvent) { }
    func onUpload(event: UploadEvent) { }
    func onError(error: Joyfill.JoyfillError) { }

    func mapOptionIDsToValuesCollection(field: JoyDocField, changeObject: [String: Any]) -> [String: Any] {
        var changedRow = changeObject["row"] as! [String: Any]
        var changedCells = changedRow["cells"] as! [String: Any]
        
        let schemaKey = changeObject["schemaId"] as! String
        let schema = field.schema?[schemaKey]
        if let columns = schema?.tableColumns {
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
        return changedCells
    }
    
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

    // swiftlint:disable:next cyclomatic_complexity
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
        
        guard let changeObject = changeEvent.change as? [String: Any] else {
            return nil
        }

        changedCells = mapOptionIDsToValues(field: matchField, changeObject: changeObject)

        guard let sourceRowCells: [ValueElement] = hintsTableField.resolvedValue?.valueElements else {
            return nil
        }

        let changedCellsValues: [String] = changedCells.compactMap { $0.value as? String }

        var hintsRows: [ValueElement] = []
        for cellValue in changedCellsValues {
            for item in sourceRowCells {
                for (_, value) in item.cells ?? [:] {
                    if cellValue == value.text {
                        hintsRows.append(item)
                    }
                }
            }
        }
        var updatedCells: [String: Any] = [:]

        for row in hintsRows {
            for cell in row.cells ?? [:] {
                let rowID = cell.key
                if let hintsTableColumn = hintsTableField.tableColumns?.first(where: { $0.id == rowID}),
                   let matchFieldColumn = matchedColumn(matchField: matchField, comparingTitle: hintsTableColumn.title, changeObject: changeObject) {
                    if let cell = row.cells?[hintsTableColumn.id!] {
                        guard let rawValue = cell.text, !changedCellsValues.contains(rawValue) else { // exclude the modified cell by user in UI
                            continue
                        }
                        
                        guard let columnID = matchFieldColumn.id else {
                            continue
                        }
                        switch matchFieldColumn.type {
                        case .dropdown:
                            let rawValue = cell.text
                            if let optionID = matchFieldColumn.options?.first(where: { $0.value == rawValue })?.id {
                                updatedCells[columnID] = optionID
                            }
                        case .multiSelect:
                            let rawValues = cell.multiSelector
                            var ansArray: [String] = []
                            for rawValue in rawValues ?? [] {
                                if let optionID = matchFieldColumn.options?.first(where: { $0.value == rawValue })?.id {
                                    ansArray.append(optionID)
                                }
                            }
                            updatedCells[columnID] = ansArray
                        default:
                            updatedCells[columnID] = cell.dictionary
                        }
                    }
                }
            }
        }
        return updatedCells
    }
    
    func matchedColumn(matchField: JoyDocField, comparingTitle: String, changeObject: [String: Any?]) -> FieldTableColumn? {
        if matchField.fieldType == .collection {
            let schemaKey = changeObject["schemaId"] as! String
            
            return matchField.schema?[schemaKey]?.tableColumns?.first(where: { $0.title == comparingTitle })
        }
        if matchField.fieldType == .table {
            return matchField.tableColumns?.first(where: { $0.title == comparingTitle })
        }
        return nil
    }

    func mapOptionIDsToValues(field: JoyDocField, changeObject: [String: Any?]) -> [String: Any?] {
        var changedRow = changeObject["row"] as! [String: Any]
        var changedCells = changedRow["cells"] as! [String: Any]
        
        if field.fieldType == .collection {
            return mapOptionIDsToValuesCollection(field: field, changeObject: changeObject)
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

    func createRowUpdateChange(
        from originalChange: Change,
        document: JoyfillModel.JoyDoc,
        rowID: String,
        updatedCells: [String: Any]
    ) -> Change {
        let payload: [String: Any] = [
            "rowId": rowID,
            "schemaId": originalChange.change?["schemaId"] as? String ?? "",
            "parentPath": originalChange.change?["parentPath"] as? String ?? "",
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
