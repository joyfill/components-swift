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
    func onChange(changes: [Change], document: JoyfillModel.JoyDoc) {}
    func onFocus(event: FieldIdentifier) {}
    func onBlur(event: FieldIdentifier) {}
    func onUpload(event: UploadEvent) {}
    func onCapture(event: CaptureEvent) {}
    func onError(error: Joyfill.JoyfillError) {}
}
