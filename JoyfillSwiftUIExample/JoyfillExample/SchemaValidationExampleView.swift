import SwiftUI
import Joyfill
import JSONSchema
import JoyfillModel
import Foundation

struct SchemaValidationExampleView: View {
    @State private var documentEditor: DocumentEditor
    @State private var validationMessage: String = "Loading..."
    let changeManagerWraper = ChangeManagerWrapper()

    init() {
        let document = sampleJSONDocument(fileName: "ErrorHandling")
        self.documentEditor = DocumentEditor(document: JoyDoc(), events: changeManagerWraper.changeManager)

        // Test the new schema validation functionality
        let schemaManager = JoyfillSchemaManager()
        if let error = schemaManager.validateSchema(document: document) {
            validationMessage = "Validation failed: \(error.code) - \(error.message)"
        } else {
            validationMessage = "✅ Schema validation passed!"
        }
    }

    public var body: some View {
        NavigationView {
            VStack {
                // Display validation status
                Text(validationMessage)
                    .padding()
                    .background(validationMessage.contains("failed") ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                    .cornerRadius(8)
                    .padding()
                
                Form(documentEditor: documentEditor)
            }
        }
    }

}
