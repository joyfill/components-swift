//
//  SaveButtonView.swift
//  JoyfillExample
//

import SwiftUI
import Joyfill
import JoyfillModel
import JoyfillAPIService

struct SaveButtonView: View {
    let changeManager: ChangeManager
    let documentEditor: DocumentEditor

    let showBothButtons: Bool
    @State private var copyButtonLabel = "Copy JSON"

    var body: some View {
        VStack {
            if showBothButtons {
                HStack(spacing: 20) {
                    saveButton
                    copyJsonButton
                }
            } else {
                copyJsonButton
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var saveButton: some View {
        Button(action: {
            changeManager.saveJoyDoc(document: documentEditor.document)
            let result = documentEditor.validate()
            print("Document status:", result.status)
            for fieldResult in result.fieldValidities {
                print("Field status:", fieldResult.field.id ?? "No field id", ":", fieldResult.status)
            }
        }) {
            Label("Save", systemImage: "tray.and.arrow.down")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(16)
        }
    }

    private var copyJsonButton: some View {
        Button(action: {
            if let jsonData = try? JSONSerialization.data(withJSONObject: documentEditor.document.dictionary, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                UIPasteboard.general.string = jsonString
                copyButtonLabel = "Copied!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    copyButtonLabel = "Copy JSON"
                }
            }
        }) {
            Label(copyButtonLabel, systemImage: copyButtonLabel == "Copied!" ? "checkmark.circle.fill" : "doc.on.doc")
                .frame(maxWidth: .infinity)
                .padding()
                .background(copyButtonLabel == "Copied!" ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                .foregroundColor(copyButtonLabel == "Copied!" ? .green : .primary)
                .cornerRadius(16)
        }
    }
}
