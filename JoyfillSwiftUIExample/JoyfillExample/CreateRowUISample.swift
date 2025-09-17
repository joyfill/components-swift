//
//  CreateRowUISample.swift
//  JoyfillExample
//
//  Created by Vivek on 17/09/25.
//

import Foundation
import JoyfillModel
import Joyfill
import SwiftUI

struct CreateRowUISample: View, FormChangeEvent {
    
    init() {
        let document = sampleJSONDocument(fileName: "FieldTemplate_TableCollection_Poplated")
        documentEditor = DocumentEditor(document: document, events: self, validateSchema: false, license: licenseKey)
    }
    
    var body: some View {
        VStack {
            NavigationView {
                Form(documentEditor: documentEditor)
                    .tint(.red)
            }
            
            Button("Add Nested Row") {
                let changes = [createRow(documentEditor: documentEditor)]
                
                documentEditor.change(changes: changes)
            }
        }
    }

    func onChange(changes: [Change], document: JoyfillModel.JoyDoc) { }
    func onFocus(event: FieldIdentifier) { }
    func onBlur(event:  FieldIdentifier) { }
    func onCapture(event: CaptureEvent) { }
    func onUpload(event: UploadEvent) { }
    func onError(error: Joyfill.JoyfillError) { }
   
    func createRow(documentEditor: DocumentEditor) -> Change {
        let fieldId = "6857510fbfed1553e168161b"
        let fieldIdentifier = documentEditor.getFieldIdentifier(for: fieldId)
        let field = documentEditor.field(fieldID: fieldId)
        
        var newRow = ValueElement(id: UUID().uuidString)
        newRow.cells = [:]
        newRow.childrens = [:]
        let schemas = field?.schema ?? [:]
        
        let rootSchemaKey = schemas.first(where: { $0.value.root == true })?.key ?? ""
        let targetSchemaID = schemas[rootSchemaKey]?.children?.first ?? "" // Add your target schema ID here
        
        let existingRows = field?.valueToValueElements ?? []
        let existingRowsInTargetSchema = existingRows.first?.childrens?[targetSchemaID]?.valueToValueElements ?? []
        let parentRowId = existingRows.first?.id ?? ""
        let parentPath = documentEditor.computeParentPath(targetParentId: parentRowId, nestedKey: targetSchemaID, in: [rootSchemaKey : existingRows]) ?? ""
        
        let newRowChange = addNestedRowChanges(newRow: newRow, targetRowIndex: existingRowsInTargetSchema.count, parentPath: parentPath, schemaId: targetSchemaID)
        
        return Change(v: 1,
                      sdk: "swift",
                      target: "field.value.rowCreate",
                      _id: documentEditor.documentID ?? "",
                      identifier: documentEditor.documentIdentifier,
                      fileId: fieldIdentifier.fileID ?? "",
                      pageId: fieldIdentifier.pageID ?? "",
                      fieldId: fieldId,
                      fieldIdentifier: field?.identifier ?? "",
                      fieldPositionId: fieldIdentifier.fieldPositionId ?? "",
                      change: newRowChange,
                      createdOn: Date().timeIntervalSince1970
        )
    }
    
    private func addNestedRowChanges(newRow: ValueElement, targetRowIndex: Int, parentPath: String, schemaId: String) -> [String: Any] {
        var newRowChange: [String: Any] = ["row": newRow.anyDictionary]
        newRowChange["parentPath"] = parentPath
        newRowChange["schemaId"] = schemaId // The ID of the associated schema.
        newRowChange["targetRowIndex"] = targetRowIndex // New row index
        return newRowChange
    }
}
