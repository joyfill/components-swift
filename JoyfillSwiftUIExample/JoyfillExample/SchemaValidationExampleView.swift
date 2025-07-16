import SwiftUI
import Joyfill
import JSONSchema
import JoyfillModel
import Foundation

struct SchemaValidationExampleView: View, FormChangeEvent {
    init() {
        let document = sampleJSONDocument(fileName: "ErrorHandling")
        documentEditor = DocumentEditor(document: document, events: self)
    }

    public var body: some View {
        NavigationView {
            Form(documentEditor: documentEditor)
        }
    }

    // MARK: - Validate Document
    func onChange(changes: [JoyfillModel.Change], document: JoyfillModel.JoyDoc) {}
    func onFocus(event: JoyfillModel.FieldIdentifier) {}
    func onBlur(event: JoyfillModel.FieldIdentifier) {}
    func onUpload(event: JoyfillModel.UploadEvent) {}
    func onCapture(event: JoyfillModel.CaptureEvent) {}
}
