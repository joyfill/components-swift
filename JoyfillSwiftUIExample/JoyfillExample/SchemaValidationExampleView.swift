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
            if validate() {
                Form(documentEditor: documentEditor)
            }
        }
    }

    // MARK: - Validate Document
    func validate() -> Bool {
        do {
            let result = documentEditor.validateSchema(document: documentEditor.document)
            if result.error == nil {
                print("🔸 JSON is valid! 🌍")
                return true
            } else {
                for error in result.error ?? [] {
                    let instanceLoc = error.instanceLocation.path
                    let keywordLoc = error.keywordLocation.path
                    print("🔸 \(error.description)\n📍 Instance: \(instanceLoc)\n🧩 Keyword: \(keywordLoc)\n🌍")
                }
            }
        }
        return false
    }
    
    func onChange(changes: [JoyfillModel.Change], document: JoyfillModel.JoyDoc) {}
    func onFocus(event: JoyfillModel.FieldIdentifier) {}
    func onBlur(event: JoyfillModel.FieldIdentifier) {}
    func onUpload(event: JoyfillModel.UploadEvent) {}
    func onCapture(event: JoyfillModel.CaptureEvent) {}
}
