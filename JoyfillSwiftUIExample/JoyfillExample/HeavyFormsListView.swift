//
//  HeavyFormsListView.swift
//  JoyfillExample
//
//  A simple gallery of heavy sample JoyDoc JSONs. Each row opens the
//  corresponding form. Tap a row -> the JSON is loaded and rendered with
//  `Form(documentEditor:)`, exactly like the other example screens.
//

import SwiftUI
import Joyfill
import JoyfillModel

/// Describes one heavy JoyDoc JSON that ships inside the example app bundle.
struct HeavyFormSample: Identifiable {
    let id = UUID()
    /// Bundle resource name (without the `.json` extension).
    let fileName: String
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

struct HeavyFormsListView: View {
    // All of these files are already bundled in the JoyfillExample app target.
    private let samples: [HeavyFormSample] = [
        .init(fileName: "10kRowsCollection",
              title: "10k Rows Collection",
              subtitle: "~10 MB · collection stress test",
              icon: "square.grid.3x3.fill", color: .green),
        .init(fileName: "3000-fields",
              title: "3000 Fields",
              subtitle: "~4 MB · very large field set",
              icon: "square.stack.3d.up.fill", color: .purple),
        .init(fileName: "testrow",
              title: "Test Rows",
              subtitle: "~700 KB · large table rows",
              icon: "tablecells.fill", color: .orange),
        .init(fileName: "Navigation",
              title: "Navigation",
              subtitle: "~130 KB · multi-page navigation",
              icon: "location.circle.fill", color: .indigo),
        .init(fileName: "OnChangeHandler",
              title: "On Change Handler",
              subtitle: "~130 KB · change-event heavy form",
              icon: "arrow.triangle.2.circlepath", color: .teal),
        .init(fileName: "Joydocjson",
              title: "Joy Doc",
              subtitle: "~110 KB · mixed field document",
              icon: "doc.text.fill", color: .blue),
        .init(fileName: "CollectionFilter",
              title: "Collection Filter",
              subtitle: "~60 KB · collection with filters",
              icon: "line.3.horizontal.decrease.circle.fill", color: .pink),
        .init(fileName: "ErrorHandling",
              title: "Error Handling",
              subtitle: "~55 KB · validation / error states",
              icon: "exclamationmark.triangle.fill", color: .red),
        .init(fileName: "ChangerHandlerUnit",
              title: "Change Handler Unit",
              subtitle: "~40 KB · change handler sample",
              icon: "slider.horizontal.3", color: .cyan),
        .init(fileName: "FieldTemplate_TableCollection_Poplated",
              title: "Table & Collection Populated",
              subtitle: "~30 KB · populated table + collection",
              icon: "tablecells.badge.ellipsis", color: .mint)
    ]

    var body: some View {
        List(samples) { sample in
            NavigationLink(destination: HeavyFormDetailView(sample: sample)) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(sample.color.opacity(0.12))
                            .frame(width: 44, height: 44)
                        Image(systemName: sample.icon)
                            .font(.system(size: 20))
                            .foregroundColor(sample.color)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(sample.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(sample.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .navigationTitle("Heavy Forms")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Loads the selected JSON into a `DocumentEditor` and renders the form.
struct HeavyFormDetailView: View, FormChangeEvent {
    let sample: HeavyFormSample
    private let imagePicker = ImagePicker()

    @State private var documentEditor: DocumentEditor?
    @State private var isLoading: Bool = true

    var body: some View {
        Group {
            if let documentEditor = documentEditor, !isLoading {
                Form(documentEditor: documentEditor)
            } else {
                ProgressView("Loading \(sample.title)…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(sample.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadDocumentIfNeeded)
    }

    private func loadDocumentIfNeeded() {
        guard documentEditor == nil else { return }
        isLoading = true
        // Build the document and editor off the main thread so the heavy JSON
        // parse doesn't hitch the UI during the push animation.
        DispatchQueue.global(qos: .userInitiated).async {
            let document = sampleJSONDocument(fileName: sample.fileName)
            let editor = DocumentEditor(
                document: document,
                config: DocumentEditorConfig(
                    events: self,
                    license: licenseKey,
                    validateSchema: false,
                    page: PageConfig(enableDuplicates: true, enableDeletes: true),
                    display: DisplayConfig(singleClickRowEdit: true)
                )
            )
            DispatchQueue.main.async {
                self.documentEditor = editor
                self.isLoading = false
            }
        }
    }

    // MARK: - FormChangeEvent
    func onChange(changes: [Change], document: JoyDoc) { }
    func onFocus(event: Event) { }
    func onBlur(event: Event) { }
    func onCapture(event: CaptureEvent) { }

    func onUpload(event: UploadEvent) {
        imagePicker.showPickerOptions { urls in
            guard let imageURL = urls.first else { return }
            event.uploadHandler([imageURL])
        }
    }

    func onError(error: JoyfillError) { }
}
