//
//  FailureCaptureDemoView.swift
//  JoyfillExample
//
//  Created by Vivek on 16/01/26.
//

import Foundation
import JoyfillModel
import Joyfill
import SwiftUI

var failureCaptureDocumentEditor: DocumentEditor!

struct FailureCaptureDemoView: View {
    @State private var showDialog = false
    @State private var dialogInput = ""
    @State private var pendingChange: Change?
    
    init() {
        let document = sampleJSONDocument(fileName: "testDoc")
        let eventHandler = FailureCaptureEventHandler()
        failureCaptureDocumentEditor = DocumentEditor(document: document, events: eventHandler, isPageDuplicateEnabled: false, validateSchema: false, license: licenseKey)
    }
    
    var body: some View {
        NavigationView {
            Form(documentEditor: failureCaptureDocumentEditor)
                .tint(.red)
        }
        .onReceive(NotificationCenter.default.publisher(for: .showFailureAlert)) { notification in
            if let change = notification.object as? Change {
                pendingChange = change
                showDialog = true
            }
        }
        .alert("Capture Deficiency", isPresented: $showDialog) {
            TextField("Enter deficiency details", text: $dialogInput)
            Button("Cancel", role: .cancel) {
                dialogInput = ""
                pendingChange = nil
            }
            Button("Confirm") {
                if !dialogInput.isEmpty {
                    addDeficiencyToSummaryTable(input: dialogInput)
                }
                dialogInput = ""
                pendingChange = nil
            }
        } message: {
            Text("A failure option was selected. Please provide details for the deficiency summary.")
        }
    }
}

class FailureCaptureEventHandler: FormChangeEvent {
    func onChange(changes: [Change], document: JoyfillModel.JoyDoc) {
        for change in changes {
            if isFailureOptionSelected(change: change, document: document) {
                NotificationCenter.default.post(name: .showFailureAlert, object: change)
                break
            }
        }
    }
    
    func onFocus(event: FieldIdentifier) { }
    func onBlur(event: FieldIdentifier) { }
    func onCapture(event: CaptureEvent) { }
    func onUpload(event: UploadEvent) { }
    func onError(error: Joyfill.JoyfillError) { }
}

extension Notification.Name {
    static let showFailureAlert = Notification.Name("showFailureAlert")
}

// MARK: - Detection Logic
extension FailureCaptureEventHandler {
    
    /// Check if the change represents a failure option selection
    func isFailureOptionSelected(change: Change, document: JoyDoc) -> Bool {
        guard let fieldId = change.fieldId else {
            print("❌ No fieldId in change")
            return false
        }
        
        // Get the field from the document
        guard let field = document.fields.first(where: { $0.id == fieldId }) else {
            print("❌ Field not found: \(fieldId)")
            return false
        }
        
        print("🔍 Checking field: \(field.title ?? "nil"), type: \(field.fieldType)")
        
        // Handle different field types
        switch field.fieldType {
        case .dropdown:
            return checkDropdownFieldForFailure(change: change, field: field)
            
        case .table:
            return checkTableFieldForFailure(change: change, field: field)
            
        case .collection:
            return checkCollectionFieldForFailure(change: change, field: field)
            
        default:
            return false
        }
    }
    
    /// Check if a dropdown field has a failure option selected
    private func checkDropdownFieldForFailure(change: Change, field: JoyDocField) -> Bool {
        // Try to extract the selected option ID from different formats
        var selectedOptionId: String?
        
        // Format 1: Array with single string element (e.g., ["option_id"])
        if let valueArray = change.change?["value"] as? [Any],
           let firstValue = valueArray.first as? String {
            selectedOptionId = firstValue
        }
        // Format 2: Direct string (e.g., "option_id")
        else if let valueString = change.change?["value"] as? String {
            selectedOptionId = valueString
        }
        
        guard let optionId = selectedOptionId else {
            print("❌ No value in dropdown change, change: \(change.change ?? [:])")
            return false
        }
        
        print("🔍 Dropdown selected option ID: \(optionId)")
        
        // Check if the selected option has failure metadata
        if let options = field.options {
            for option in options {
                if option.id == optionId {
                    print("🔍 Found option: \(option.value ?? "nil")")
                    if let metadata = option.dictionary["metadata"] as? [String: Any],
                       let isFailure = metadata["failure"] as? Bool,
                       isFailure == true {
                        print("✅ Failure metadata found!")
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    /// Check if a table field has a failure option selected in any dropdown column
    private func checkTableFieldForFailure(change: Change, field: JoyDocField) -> Bool {
        // Check for rowUpdate target
        guard change.target == "field.value.rowUpdate" else {
            return false
        }
        
        guard let rowData = change.change?["row"] as? [String: Any],
              let cells = rowData["cells"] as? [String: Any] else {
            print("❌ No row data in table change")
            return false
        }
        
        print("🔍 Table row update with \(cells.count) cells")
        
        // Check each cell to see if it's a dropdown with failure metadata
        guard let tableColumns = field.tableColumns else {
            return false
        }
        
        for (columnId, cellValue) in cells {
            // Find the column definition
            guard let column = tableColumns.first(where: { $0.id == columnId }),
                  column.type == .dropdown else {
                continue
            }
            
            print("🔍 Checking dropdown column: \(column.title ?? "nil")")
            
            // Extract the selected option ID from cell value
            var selectedOptionId: String?
            if let cellDict = cellValue as? [String: Any],
               let text = cellDict["text"] as? String {
                selectedOptionId = text
            } else if let text = cellValue as? String {
                selectedOptionId = text
            }
            
            guard let optionId = selectedOptionId else {
                continue
            }
            
            print("🔍 Column selected option ID: \(optionId)")
            
            // Check if this option has failure metadata
            if let options = column.options {
                for option in options {
                    if option.id == optionId {
                        print("🔍 Found option: \(option.value ?? "nil")")
                        if let metadata = option.dictionary["metadata"] as? [String: Any],
                           let isFailure = metadata["failure"] as? Bool,
                           isFailure == true {
                            print("✅ Failure metadata found in table column!")
                            return true
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    /// Check if a collection field has a failure option selected in any dropdown column
    private func checkCollectionFieldForFailure(change: Change, field: JoyDocField) -> Bool {
        // Check for rowUpdate target
        guard change.target == "field.value.rowUpdate" else {
            return false
        }
        
        guard let rowData = change.change?["row"] as? [String: Any],
              let cells = rowData["cells"] as? [String: Any] else {
            print("❌ No row data in collection change")
            return false
        }
        
        print("🔍 Collection row update with \(cells.count) cells")
        
        // Get the schema columns
        guard let schema = field.schema,
              let collectionSchema = schema["collectionSchemaId"],
              let tableColumns = collectionSchema.tableColumns else {
            return false
        }
        
        for (columnId, cellValue) in cells {
            // Find the column definition
            guard let column = tableColumns.first(where: { $0.id == columnId }),
                  column.type == .dropdown else {
                continue
            }
            
            print("🔍 Checking dropdown column: \(column.title ?? "nil")")
            
            // Extract the selected option ID from cell value
            var selectedOptionId: String?
            if let cellDict = cellValue as? [String: Any],
               let text = cellDict["text"] as? String {
                selectedOptionId = text
            } else if let text = cellValue as? String {
                selectedOptionId = text
            }
            
            guard let optionId = selectedOptionId else {
                continue
            }
            
            print("🔍 Column selected option ID: \(optionId)")
            
            // Check if this option has failure metadata
            if let options = column.options {
                for option in options {
                    if option.id == optionId {
                        print("🔍 Found option: \(option.value ?? "nil")")
                        if let metadata = option.dictionary["metadata"] as? [String: Any],
                           let isFailure = metadata["failure"] as? Bool,
                           isFailure == true {
                            print("✅ Failure metadata found in collection column!")
                            return true
                        }
                    }
                }
            }
        }
        
        return false
    }
}

// MARK: - View Helper Methods
extension FailureCaptureDemoView {
    /// Add a new row to the Deficiencies Summary table with the user's input
    private func addDeficiencyToSummaryTable(input: String) {
        print("📝 Adding deficiency to summary table: \(input)")
        
        guard let document = failureCaptureDocumentEditor?.document else {
            print("❌ No document available")
            return
        }
        
        // Find the Deficiencies Summary table
        guard let summaryTable = document.fields.first(where: { $0.title == "Deficiencies Summary" }),
              let tableColumns = summaryTable.tableColumns,
              let textColumn = tableColumns.first(where: { $0.type == .text }),
              let columnId = textColumn.id,
              let tableFieldId = summaryTable.id else {
            print("❌ Could not find Deficiencies Summary table or text column")
            return
        }
        
        print("✅ Found summary table: \(summaryTable.identifier ?? "nil")")
        print("✅ Found text column: \(textColumn.title ?? "nil") with ID: \(columnId)")
        
        // Create cell values for the new row
        let cellValues: [String: Any] = [
            columnId: "\(input)"
        ]
        
        // Generate unique ID for the new row
        let rowId = generateObjectId()
        
        // Create the Change event for row creation
        guard let pendingChange = pendingChange else {
            print("❌ No pending change available")
            return
        }
        
        let createRowChange = createRowCreateChange(
            from: pendingChange,
            document: document,
            targetFieldID: summaryTable.identifier ?? "",
            rowID: rowId,
            cellValues: cellValues
        )
        
        // Apply the change
        failureCaptureDocumentEditor.change(changes: [createRowChange])
        
        print("✅ Successfully added row to Deficiencies Summary table")
    }
    
    /// Create a Change event for row creation
    private func createRowCreateChange(
        from originalChange: Change,
        document: JoyDoc,
        targetFieldID: String,
        rowID: String,
        cellValues: [String: Any]
    ) -> Change {
        let newRow: [String: Any] = [
            "_id": rowID,
            "cells": cellValues
        ]
        
        let payload: [String: Any] = [
            "rowId": rowID,
            "row": newRow
        ]
        
        guard let targetField = document.fields.first(where: { $0.identifier == targetFieldID }),
              let actualFieldId = targetField.id else {
            print("❌ Cannot find field with identifier: \(targetFieldID)")
            fatalError("Field not found: \(targetFieldID)")
        }
        
        return Change(
            v: 1,
            sdk: "swift",
            target: "field.value.rowCreate",
            _id: document.id ?? "",
            identifier: document.identifier ?? "",
            fileId: originalChange.fileId ?? "",
            pageId: originalChange.pageId ?? "",
            fieldId: actualFieldId,
            fieldIdentifier: targetFieldID,
            fieldPositionId: originalChange.fieldPositionId ?? "",
            change: payload,
            createdOn: Date().timeIntervalSince1970
        )
    }
}

