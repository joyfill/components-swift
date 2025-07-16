import SwiftUI
import Joyfill
import JSONSchema
import JoyfillModel
import Foundation

struct SchemaValidationExampleView: View {
    @State private var documentEditor: DocumentEditor
    @State private var validationMessage: String = "Loading..."
    @State private var validationDetails: String = ""
    @State private var jsonString: String = ""
    @State private var jsonErrorMessage: String? = nil
    @State private var useCustomJSON: Bool = false
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
        
        // Initialize with the sample document JSON
        if let jsonData = try? JSONSerialization.data(withJSONObject: document.dictionary, options: .prettyPrinted),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            self.jsonString = jsonStr
        }
    }

    public var body: some View {
        NavigationView {
            VStack {
                // Toggle between sample and custom JSON
                Picker("Document Source", selection: $useCustomJSON) {
                    Text("Sample Document").tag(false)
                    Text("Custom JSON").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if useCustomJSON {
                    // JSON Input Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("JSON Input")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Enter your JoyDoc JSON data below")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let jsonErrorMessage = jsonErrorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(jsonErrorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // JSON TextEditor
                    VStack(spacing: 0) {
                        ZStack(alignment: .trailing) {
                            TextEditor(text: $jsonString)
                                .font(.system(.caption, design: .monospaced))
                                .frame(height: 120)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.05))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                                )
                                .onChange(of: jsonString) { _ in
                                    validateAndTestJSON()
                                }
                            
                            if !jsonString.isEmpty {
                                Button(action: {
                                    jsonString = ""
                                    jsonErrorMessage = nil
                                    resetToSampleDocument()
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.blue)
                                        .background(Circle().fill(.white))
                                        .imageScale(.medium)
                                        .padding(12)
                                }
                            }
                        }
                        
                        if !jsonString.isEmpty {
                            Text("JSON length: \(jsonString.count)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Validate JSON Button
                    Button(action: {
                        validateAndTestJSON()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.shield")
                            Text("Validate Schema")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                        .background(
                            jsonString.isEmpty || jsonErrorMessage != nil
                            ? Color.gray.opacity(0.3)
                            : Color.blue
                        )
                        .cornerRadius(12)
                    }
                    .disabled(jsonString.isEmpty || jsonErrorMessage != nil)
                    .padding(.horizontal)
                }
                
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
                        .frame(maxHeight: useCustomJSON ? 100 : 150)
                    }
                }
                .padding()
                
                if !useCustomJSON || (jsonErrorMessage == nil && !jsonString.isEmpty) {
                    Form(documentEditor: documentEditor)
                }
                
                Spacer()
            }
        }
        .onChange(of: useCustomJSON) { newValue in
            if !newValue {
                resetToSampleDocument()
            }
        }
    }
    
    private func validateAndTestJSON() {
        guard !jsonString.isEmpty else {
            jsonErrorMessage = "Please enter a JSON object"
            return
        }
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            jsonErrorMessage = "Invalid JSON encoding"
            return
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any]
            guard let jsonDict = jsonObject else {
                jsonErrorMessage = "JSON must be an object"
                return
            }
            
            jsonErrorMessage = nil
            
            // Create JoyDoc from the JSON and test schema validation
            let customDocument = JoyDoc(dictionary: jsonDict)
            let schemaManager = JoyfillSchemaManager()
            
            if let error = schemaManager.validateSchema(document: customDocument) {
                validationMessage = "❌ Schema Error: \(error.code) - \(error.message)"
                validationDetails = formatValidationErrors(error: error)
            } else {
                validationMessage = "✅ Schema validation passed!"
                validationDetails = "Document conforms to schema v\(customDocument.version ?? "undefined")"
            }
            
            // Update the DocumentEditor with the new document
            self.documentEditor = DocumentEditor(document: customDocument, events: changeManagerWraper.changeManager)
            
        } catch {
            jsonErrorMessage = "Invalid JSON format: \(error.localizedDescription)"
        }
    }
    
    private func resetToSampleDocument() {
        let document = sampleJSONDocument(fileName: "ErrorHandling")
        
        // Reset validation with sample document
        let schemaManager = JoyfillSchemaManager()
        if let error = schemaManager.validateSchema(document: document) {
            validationMessage = "❌ Schema Error: \(error.code) - \(error.message)"
            validationDetails = formatValidationErrors(error: error)
        } else {
            validationMessage = "✅ Schema validation passed!"
            validationDetails = "Document conforms to schema v\(document.version ?? "undefined")"
        }
        
        self.documentEditor = DocumentEditor(document: document, events: changeManagerWraper.changeManager)
        
        // Reset JSON string to sample document
        if let jsonData = try? JSONSerialization.data(withJSONObject: document.dictionary, options: .prettyPrinted),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            self.jsonString = jsonStr
        }
        
        jsonErrorMessage = nil
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
