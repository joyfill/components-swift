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
            guard let schemaURL = Bundle.main.url(forResource: "joyfill-schema 2", withExtension: "json"),
                  let schemaData = try? Data(contentsOf: schemaURL),
                  let schema = try? JSONSerialization.jsonObject(with: schemaData) as? [String: Any] else {
                print("❌ Failed to load or parse schema file 'joyfill-schema.json'")
                return
            }
            do {
                let result = try JSONSchema.validate(sampleJSONDocument(fileName: "Joydocjson").dictionary, schema: schema)
                if result.valid {
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
