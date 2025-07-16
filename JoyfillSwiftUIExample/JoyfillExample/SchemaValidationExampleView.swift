import SwiftUI
import Joyfill
import JSONSchema
import JoyfillModel
import Foundation

struct SchemaValidationExampleView: View {
    @State private var documentEditor: DocumentEditor
    @State private var validationMessage: String = "Loading..."
    @State private var validationDetails: String = ""
    let changeManagerWraper = ChangeManagerWrapper()

    init() {
        let document = sampleJSONDocument(fileName: "ErrorHandling")
        
        // Test the new schema validation functionality first
        let schemaManager = JoyfillSchemaManager()
        if let error = schemaManager.validateSchema(document: document) {
            validationMessage = "❌ Schema Error: \(error.code) - \(error.message)"
            validationDetails = formatValidationErrors(error: error)
        } else {
            validationMessage = "✅ Schema validation passed!"
            validationDetails = "Document conforms to schema v\(document.version ?? "undefined")"
        }
        
        // Use the same document for DocumentEditor (even if it has validation errors)
        // The DocumentEditor will handle the errors gracefully
        self.documentEditor = DocumentEditor(document: document, events: changeManagerWraper.changeManager)
    }

    public var body: some View {
        NavigationView {
            VStack {
                // Display validation status
                VStack(alignment: .leading, spacing: 8) {
                    Text(validationMessage)
                        .font(.headline)
                        .padding()
                        .background(validationMessage.contains("❌") ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                        .cornerRadius(8)
                    
                    if !validationDetails.isEmpty {
                        ScrollView {
                            Text(validationDetails)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                        .frame(maxHeight: 150)
                    }
                }
                .padding()
                
                Form(documentEditor: documentEditor)
            }
        }
    }
}

fileprivate func formatValidationErrors(error: SchemaValidationError) -> String {
    var details = "Schema Version: \(error.details.schemaVersion)\nSDK Version: \(error.details.sdkVersion)\n\n"

    if let validationErrors = error.error {
        details += "Validation Errors (\(validationErrors.count)):\n"
        for (index, validationError) in validationErrors.enumerated() {
            details += "\(index + 1). \(validationError.description)\n"
        }
    } else {
        details += "No specific validation error details available."
    }

    return details
}
