import SwiftUI
import Joyfill
import JSONSchema
import JoyfillModel
import Foundation

struct SchemaValidationExampleView: View, FormChangeEvent {
    func onChange(changes: [JoyfillModel.Change], document: JoyfillModel.JoyDoc) {
        
    }
    
    func onFocus(event: JoyfillModel.FieldIdentifier) {
        
    }
    
    func onBlur(event: JoyfillModel.FieldIdentifier) {
        
    }
    
    func onUpload(event: JoyfillModel.UploadEvent) {
        
    }
    
    func onCapture(event: JoyfillModel.CaptureEvent) {
        
    }
    
    
    init() {
        var document = sampleJSONDocument(fileName: "ErrorHandling")
        documentEditor = DocumentEditor(document: document, events: self)
        validateJSON()
    }
    
    
    public var body: some View {
        NavigationView {
            Form(documentEditor: documentEditor)
        }
    }
    
    func validateJSON() -> [ValidationResult] {
        // Load schema from bundled JSON file named "joyfill-schema.json"
        // Reminder: Make sure "joyfill-schema.json" is included in your app target's bundle resources.
        guard let schemaURL = Bundle.main.url(forResource: "joyfill-schema 2", withExtension: "json"),
              let schemaData = try? Data(contentsOf: schemaURL),
              let schema = try? JSONSerialization.jsonObject(with: schemaData) as? [String: Any] else {
            print("❌ Failed to load or parse schema file 'joyfill-schema.json'")
            return []
        }
        
        do {
            let result = try JSONSchema.validate(documentEditor.document.dictionary, schema: schema)
            if let errors = result.errors, !errors.isEmpty {
                print("❌ JSON is invalid:")
                var validationResult: [ValidationResult] = []
                errors.forEach { error in
                    // Print full error via reflection
                    print(" • Full ValidationError object: \(error)")
                    let mirror = Mirror(reflecting: error)
                    for child in mirror.children {
                        let label = child.label ?? "unknown"
                        print("    \(label): \(child.value)")
                    }
                    print(error.keywordLocation)
                    
                    validationResult.append(.failure(code: "ERROR_SCHEMA_VALIDATION",
                                                     message: error.description,
                                                     error: "\(error.keywordLocation)",
                                                     details: ["schemaVersion" : "",
                                                               "sdkVersion": ""
                                                              ]))
                }
                return validationResult
            } else {
                print("✅ JSON is valid!")
                var result: ValidationResult  = .success
                return [result]
            }
        } catch {
            print("Schema validation failed:", error)
            return []
        }
    }
}


enum ValidationResult {
    case success
    case failure(code: String, message: String, error: String, details: [String: String])
}
