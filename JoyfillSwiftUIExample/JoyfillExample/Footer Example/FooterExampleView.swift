//
//  FooterExampleView.swift
//  JoyfillExample
//

import SwiftUI
import Joyfill
import JoyfillModel

struct FooterExampleView: View {
    let footerController: SampleFormFooterController
    let documentEditor: DocumentEditor
    @State private var showFooter = true

    init() {
        let doc = Self.loadDoc(named: "footer-form")
        let controller = SampleFormFooterController()
        let editor = DocumentEditor(
            document: doc,
            config: DocumentEditorConfig(
                mode: .fill,
                events: controller,
                license: licenseKey,
                page: PageConfig(navigation: true, currentPageID: nil)
            )
        )
        editor.rowDeleteConfirmation = RowDeleteConfirmationConfig(
            isEnabled: true,
            description: "You really want to delete this row?",
            bulkDescription: "You really want to delete {count} rows?"
        )
        controller.documentEditor = editor
        self.footerController = controller
        self.documentEditor = editor
    }

    var body: some View {
        Form(documentEditor: documentEditor)
            .formFooter {
                if showFooter {
                    SampleFormFooterBar(controller: footerController)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(showFooter ? "Hide Footer" : "Show Footer") {
                        showFooter.toggle()
                    }
                }
            }
    }
}

private extension FooterExampleView {
    static func loadDoc(named name: String) -> JoyDoc {
        let url = Bundle.main.url(forResource: name, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dict = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        return JoyDoc(dictionary: dict)
    }
}

// MARK: - Row Delete Confirmation Demo

/// Interactive playground for `RowDeleteConfirmationConfig`: tune every field live
/// (single + bulk, with the `{count}` token) and test it against the table/collection
/// in `footer-form`. Open **Settings**, then select one or more rows and delete.
struct RowDeleteConfirmationDemoView: View {
    let documentEditor: DocumentEditor
    @State private var showSettings = false

    // Gate controls — blank text fields fall back to the SDK defaults.
    @State private var isEnabled = true
    @State private var title = ""
    @State private var descriptionText = ""
    @State private var submitText = ""
    @State private var cancelText = ""
    @State private var bulkTitle = ""
    @State private var bulkDescription = "Delete {count} rows?"
    @State private var bulkSubmitText = ""

    init() {
        let doc = FooterExampleView.loadDoc(named: "footer-form")
        self.documentEditor = DocumentEditor(
            document: doc,
            config: DocumentEditorConfig(mode: .fill, license: licenseKey)
        )
    }

    /// Nil-out blanks so the SDK uses its own defaults for untouched fields.
    private var currentConfig: RowDeleteConfirmationConfig {
        func nonEmpty(_ s: String) -> String? { s.isEmpty ? nil : s }
        return RowDeleteConfirmationConfig(
            isEnabled: isEnabled,
            title: nonEmpty(title),
            description: nonEmpty(descriptionText),
            submitText: nonEmpty(submitText),
            cancelText: nonEmpty(cancelText),
            bulkTitle: nonEmpty(bulkTitle),
            bulkDescription: nonEmpty(bulkDescription),
            bulkSubmitText: nonEmpty(bulkSubmitText)
        )
    }

    var body: some View {
        Form(documentEditor: documentEditor)
            .onAppear { documentEditor.rowDeleteConfirmation = currentConfig }
            .onChange(of: currentConfig) { documentEditor.rowDeleteConfirmation = $0 }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Settings") { showSettings = true }
                }
            }
            .sheet(isPresented: $showSettings) {
                NavigationView {
                    SwiftUI.Form {
                        Section {
                            Toggle("Enabled", isOn: $isEnabled)
                        } footer: {
                            Text("Select one row for the single prompt, or several for the bulk prompt. Blank fields use SDK defaults. Use {count} for the selected row count.")
                        }
                        Section("Single row") {
                            labeledField("Title", $title, placeholder: RowDeleteConfirmationConfig.Defaults.title)
                            labeledField("Description", $descriptionText, placeholder: RowDeleteConfirmationConfig.Defaults.description)
                            labeledField("Submit", $submitText, placeholder: RowDeleteConfirmationConfig.Defaults.submitText)
                            labeledField("Cancel", $cancelText, placeholder: RowDeleteConfirmationConfig.Defaults.cancelText)
                        }
                        Section("Bulk (multiple rows)") {
                            labeledField("Bulk Title", $bulkTitle, placeholder: RowDeleteConfirmationConfig.Defaults.bulkTitle)
                            labeledField("Bulk Description", $bulkDescription, placeholder: RowDeleteConfirmationConfig.Defaults.bulkDescription)
                            labeledField("Bulk Submit", $bulkSubmitText, placeholder: RowDeleteConfirmationConfig.Defaults.bulkSubmitText)
                        }
                    }
                    .navigationTitle("Delete Confirmation")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showSettings = false }
                        }
                    }
                }
            }
    }

    private func labeledField(_ label: String, _ text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            TextField(placeholder, text: text)
        }
    }
}
