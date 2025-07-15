import SwiftUI
import Joyfill
import JSONSchema
import JoyfillModel
import Foundation

struct SchemaValidationExampleView: View, FormChangeEvent {
    init() {
        validate()
    }
    
    
    public var body: some View {
        NavigationView {
            Text("sadas")
        }
    }

    // MARK: - Validate Document
        func validate() {
            do {
                let result = try JSONSchema.validate(sampleJSONDocument(fileName: "ErrorHandling").dictionary, schema: sampleJSONDocument(fileName: "joyfill-schema 2").dictionary)
                if result.valid {
                    print("🔸 JSON is valid! 🌍")
                    return
                } else {
                    for error in result.errors ?? [] {
                        let instanceLoc = error.instanceLocation.path
                        let keywordLoc = error.keywordLocation.path
                        print("🔸 \(error.description)\n📍 Instance: \(instanceLoc)\n🧩 Keyword: \(keywordLoc)\n🌍")
                    }
                }
            } catch {
                 print("Validation failure: \(error.localizedDescription)")
            }
        }
}

extension SchemaValidationExampleView {
    func onChange(changes: [JoyfillModel.Change], document: JoyfillModel.JoyDoc) {}
    func onFocus(event: JoyfillModel.FieldIdentifier) { }
    func onBlur(event: JoyfillModel.FieldIdentifier) {}
    func onUpload(event: JoyfillModel.UploadEvent) {}
    func onCapture(event: JoyfillModel.CaptureEvent) {}
}
