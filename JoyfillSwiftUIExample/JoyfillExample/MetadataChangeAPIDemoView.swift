//
//  MetadataChangeAPIDemoView.swift
//  JoyfillExample
//
//  Covers:
//  • Field-level metadata — access/update via Change API (field.update).
//  • Row-level metadata — table and collection rows (field.value.rowUpdate).
//  • Updates when you edit in the form (onChange) or by calling editor.change().
//

import Foundation
import JoyfillModel
import Joyfill
import SwiftUI

struct MetadataChangeAPIDemoView: View, FormChangeEvent {

    @StateObject private var documentEditor: DocumentEditor
    @State private var copyButtonLabel = "Copy JSON"
    @State private var hintText = "Edit a field or row → we add metadata in onChange. Copy JSON to see field/row metadata."

    init() {
        let document = sampleJSONDocument(fileName: "ChangerHandlerUnit")
        _documentEditor = StateObject(wrappedValue: DocumentEditor(
            document: document,
            events: nil,
            validateSchema: false,
            license: licenseKey
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            Form(documentEditor: documentEditor)
                .tint(.blue)
        }
        .navigationTitle("Metadata + Change API")
        .onAppear { documentEditor.events = self }
    }

    private var toolbar: some View {
        VStack(spacing: 12) {
            Text(hintText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: copyDocumentJSON) {
                HStack(spacing: 6) {
                    Image(systemName: "doc.on.doc")
                    Text(copyButtonLabel)
                }
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.accentColor.opacity(0.15))
                .foregroundColor(.accentColor)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .disabled(copyButtonLabel == "Copied!")
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    private func copyDocumentJSON() {
        let dict = documentEditor.document.dictionary
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
              let json = String(data: data, encoding: .utf8) else { return }
        UIPasteboard.general.string = json
        copyButtonLabel = "Copied!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copyButtonLabel = "Copy JSON"
        }
    }

    // MARK: - FormChangeEvent: add metadata when user changes something

    func onChange(changes: [Change], document: JoyDoc) {
        for change in changes {
            // Only add metadata to user changes (no metadata yet) so we don’t loop
            if change.change?["metadata"] != nil { continue }

            switch change.target {
            case "field.update":
                addFieldMetadata(change: change)
            case "field.value.rowUpdate":
                addRowMetadata(change: change)
            default:
                break
            }
        }
    }

    /// Send the same changelog payload as received, but with metadata added. Keeps value/cells intact.
    private func addFieldMetadata(change: Change) {
        guard let fieldId = change.fieldId,
              let field = documentEditor.field(fieldID: fieldId),
              change.change?["metadata"] == nil else { return }

        let meta: [String: Any] = [
            "lastModified": ISO8601DateFormatter().string(from: Date()),
            "source": "metadata-demo"
        ]
        // Copy full payload so we keep value (and don’t clear the field)
        var payload: [String: Any] = [:]
        (change.change ?? [:]).forEach { payload[$0.key] = $0.value }
        payload["metadata"] = meta

        let c = Change(
            v: 1,
            sdk: "swift",
            target: "field.update",
            _id: documentEditor.documentID ?? "",
            identifier: documentEditor.documentIdentifier,
            fileId: change.fileId ?? "",
            pageId: change.pageId ?? "",
            fieldId: fieldId,
            fieldIdentifier: field.identifier,
            fieldPositionId: change.fieldPositionId ?? "",
            change: payload,
            createdOn: Date().timeIntervalSince1970
        )
        documentEditor.change(changes: [c])
    }

    /// Send the same changelog payload as received, but with metadata on the row. Keeps all cells intact.
    private func addRowMetadata(change: Change) {
        guard let fieldId = change.fieldId,
              let field = documentEditor.field(fieldID: fieldId),
              let rowDict = change.change?["row"] as? [String: Any],
              rowDict["metadata"] == nil else { return }

        let meta: [String: Any] = [
            "lastModified": ISO8601DateFormatter().string(from: Date()),
            "source": "metadata-demo"
        ]
        // Copy full change payload so we keep rowId, schemaId, parentPath, etc.
        var payload: [String: Any] = [:]
        (change.change ?? [:]).forEach { payload[$0.key] = $0.value }
        // Copy row and add metadata so we keep all cells
        var rowCopy: [String: Any] = [:]
        rowDict.forEach { rowCopy[$0.key] = $0.value }
        rowCopy["metadata"] = meta
        payload["row"] = rowCopy

        let c = Change(
            v: 1,
            sdk: "swift",
            target: "field.value.rowUpdate",
            _id: documentEditor.documentID ?? "",
            identifier: documentEditor.documentIdentifier,
            fileId: change.fileId ?? "",
            pageId: change.pageId ?? "",
            fieldId: fieldId,
            fieldIdentifier: field.identifier,
            fieldPositionId: change.fieldPositionId ?? "",
            change: payload,
            createdOn: Date().timeIntervalSince1970
        )
        documentEditor.change(changes: [c])
    }

    func onFocus(event: Event) { }
    func onBlur(event: Event) { }
    func onUpload(event: UploadEvent) { }
    func onCapture(event: CaptureEvent) { }
    func onError(error: Joyfill.JoyfillError) { }
}
