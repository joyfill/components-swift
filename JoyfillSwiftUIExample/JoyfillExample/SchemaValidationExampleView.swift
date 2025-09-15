import SwiftUI
import Joyfill
import JSONSchema
import JoyfillModel
import Foundation

struct SchemaValidationExampleView: View {
    @State private var documentEditor: DocumentEditor
    @State private var validationMessage: String = ""
    @State private var validationDetails: String = ""
    @State private var jsonString: String = ""
    @State private var jsonSchema: String = ""
    @State private var jsonErrorMessage: String? = nil
    @State private var useCustomJSON: Bool = false
    @State private var showForm: Bool = false
    @State private var selectedExample = "ErrorHandling"
    let changeManagerWraper = ChangeManagerWrapper()

    init() {
        let document = sampleJSONDocument(fileName: "ErrorHandling")
        self.documentEditor = DocumentEditor(document: document, events: changeManagerWraper.changeManager, license: licenseKey)
        
        // Initialize with the sample document JSON
        if let jsonData = try? JSONSerialization.data(withJSONObject: document.dictionary, options: .prettyPrinted),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            self.jsonString = jsonStr
        }
    }

    public var body: some View {
        NavigationView {
            ScrollView {
            VStack(spacing: 16) {
                // Toggle between sample and custom JSON
                Picker("Document Source", selection: $useCustomJSON) {
                    Text("Sample Document").tag(false)
                    Text("Custom JSON").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if useCustomJSON {
                    // JSON Input Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("JSON Input")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let jsonErrorMessage = jsonErrorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(jsonErrorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // JSON TextEditor
                        ZStack(alignment: .topTrailing) {
                            TextEditor(text: $jsonString)
                                .font(.system(.caption, design: .monospaced))
                                .frame(height: 120)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.05))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                                )
                                .onChange(of: jsonString) { _ in
                                    validateJSONSyntax()
                                }
                            
                            if !jsonString.isEmpty {
                                Button(action: {
                                    jsonString = ""
                                    jsonErrorMessage = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.blue)
                                        .background(Circle().fill(.white))
                                        .imageScale(.medium)
                                        .padding(8)
                                }
                            }
                        }
                        Text("JSONSchema Input")
                            .font(.headline)
                            .foregroundColor(.primary)
                        // JSON TextEditor
                        ZStack(alignment: .topTrailing) {
                            TextEditor(text: $jsonSchema)
                                .font(.system(.caption, design: .monospaced))
                                .frame(height: 120)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.05))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                                )
                            
                            if !jsonSchema.isEmpty {
                                Button(action: {
                                    jsonSchema = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.blue)
                                        .background(Circle().fill(.white))
                                        .imageScale(.medium)
                                        .padding(8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                if !useCustomJSON {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select JSON Sample")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Picker("Select JSON File", selection: $selectedExample) {
                        Section("All Fields Desktop And Mobile Templates") {
                            ForEach(allFieldsDesktopAndMobileTemplates, id: \.self) { fileName in
                                Text(fileName)
                                    .tag(fileName)
                            }
                        }
                        
                        Section("Conditional Logic Templates") {
                            ForEach(conditionalLogicTemplateFiles, id: \.self) { fileName in
                                Text(fileName).tag(fileName)
                            }
                        }

                        Section("Default Empty Templates") {
                            ForEach(defaultEmptyTemplateFiles, id: \.self) { fileName in
                                Text(fileName).tag(fileName)
                            }
                        }

                        Section("File Settings Templates") {
                            ForEach(fileSettingsTemplateFiles, id: \.self) { fileName in
                                Text(fileName).tag(fileName)
                            }
                        }

                        Section("Great Wall of QA Templates") {
                            ForEach(greatWallOfQATemplateFiles, id: \.self) { fileName in
                                Text(fileName).tag(fileName)
                            }
                        }

                        Section("Metadata Templates") {
                            ForEach(metadataTemplateFiles, id: \.self) { fileName in
                                Text(fileName).tag(fileName)
                            }
                        }

                        Section("Page Settings Templates") {
                            ForEach(pageSettingsTemplateFiles, id: \.self) { fileName in
                                Text(fileName).tag(fileName)
                            }
                        }
                        
                        Section("Optional Properties Removed Templates") {
                            ForEach(optionalPropertiesRemovedTemplateFiles, id: \.self) { fileName in
                                Text(fileName)
                                    .tag(fileName)
                            }
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                }
                }
                
                // Action Buttons
                HStack(spacing: 12) {
                    // Validate Schema Button
                    Button(action: {
                        validateSchema()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.shield")
                            Text("Validate Schema")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                        .background(
                            (useCustomJSON && ( jsonString.isEmpty || jsonErrorMessage != nil))
                            ? Color.gray.opacity(0.3)
                            : Color.blue
                        )
                        .cornerRadius(8)
                    }
                    .disabled(useCustomJSON && ( jsonString.isEmpty || jsonErrorMessage != nil))
                    
                    // Show Form Button
                    Button(action: {
                        showForm = true
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("Show Form")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                        .background(
                            (useCustomJSON && ( jsonString.isEmpty || jsonErrorMessage != nil))
                            ? Color.gray.opacity(0.3)
                            : Color.green
                        )
                        .cornerRadius(8)
                    }
                    .disabled(useCustomJSON && ( jsonString.isEmpty || jsonErrorMessage != nil))
                }
                .padding(.horizontal)
                
                // Validation Results
                if !validationMessage.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(validationMessage)
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(validationMessage.contains("❌") ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                            .cornerRadius(8)
                        
                        if !validationDetails.isEmpty {
                            ScrollView {
                                Text(validationDetails)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(maxHeight: 100)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            }
            .modifier(KeyboardDismissModifier())
            .navigationTitle("Schema Validation")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showForm) {
            NavigationView {
                Form(documentEditor: getCurrentDocumentEditor())
                    .navigationTitle("Document Form")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showForm = false
                            }
                        }
                    }
            }
        }
        .onChange(of: useCustomJSON) { newValue in
            if !newValue {
                resetToSampleDocument()
            }
        }
    }
    
    private let allFieldsDesktopAndMobileTemplates = [
        "ErrorHandling",
        "blockField",
        "chartField",
        "collectionField",
        "dateField",
        "dropdownField",
        "fileField",
        "imageField",
        "multilineTextField",
        "multiSelectField",
        "numberField",
        "signatureField",
        "tableField",
        "textField"
    ]
    
    private let conditionalLogicTemplateFiles = [
        "conditionalLogicTemplate"
    ]

    private let defaultEmptyTemplateFiles = [
        "defaultEmptyTemplate"
    ]

    private let fileSettingsTemplateFiles = [
        "fileSettingsTemplate"
    ]

    private let greatWallOfQATemplateFiles = [
        "greatWallOfQATemplate"
    ]

    private let metadataTemplateFiles = [
        "metadataTemplate"
    ]

    private let pageSettingsTemplateFiles = [
        "PageSettingsTemplate"
    ]
    
    private let optionalPropertiesRemovedTemplateFiles = [
        "baseChartTemplateValidation",
        "baseCollectionTemplateValidation",
        "baseDropdownTemplateValidation",
        "baseImageTemplateValidation",
        "baseInputGroupTemplateValidation",
        "baseMultilineTemplateValidation",
        "baseMultiselectTemplateValidation",
        "BaseNumberTemplateValidation",
        "baseSignatureTemplateValidation",
        "baseTableCollectionTemplateValidation",
        "baseTableTemplateValidation",
        "baseTableTemplate 2Validation",
        "chartFieldValidation",
        "collectionInputGroupFieldValidation",
        "collectionTableFieldValidation",
        "dateFieldValidation",
        "dropdownFieldValidation",
        "imageAndFileFieldValidation",
        "inputGroupFieldValidation",
        "multilineTextFieldValidation",
        "multiSelectFieldValidation",
        "numberFieldValidation",
        "signatureFieldValidation",
        "tableFieldValidation",
        "textFieldValidation"
    ]
    
    private var allFiles: [String] {
        allFieldsDesktopAndMobileTemplates + conditionalLogicTemplateFiles + defaultEmptyTemplateFiles + fileSettingsTemplateFiles + greatWallOfQATemplateFiles + metadataTemplateFiles + pageSettingsTemplateFiles + optionalPropertiesRemovedTemplateFiles
    }
    
    private func validateJSONSyntax() {
        guard !jsonString.isEmpty else {
            jsonErrorMessage = nil
            return
        }
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            jsonErrorMessage = "Invalid JSON encoding"
            return
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any]
            guard jsonObject != nil else {
                jsonErrorMessage = "JSON must be an object"
                return
            }
            jsonErrorMessage = nil
        } catch {
            jsonErrorMessage = "Invalid JSON format: \(error.localizedDescription)"
        }
    }
    
    private func validateSchema() {
        let document = getCurrentDocument()
        setCurrentJSONSchema()
        let schemaManager = JoyfillSchemaManager()
        if let error = schemaManager.validateSchema(document: document) {
            validationMessage = "❌ Schema validation failed"
            validationDetails = formatValidationErrors(error: error)
        } else {
            validationMessage = "✅ Schema validation passed!"
            validationDetails = "Document conforms to schema v\(document.version ?? "undefined")"
        }
    }
    
    private func getCurrentDocument() -> JoyDoc {
        if useCustomJSON {
            guard let jsonData = jsonString.data(using: .utf8),
                  let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any] else {
                return sampleJSONDocument(fileName: "ErrorHandling")
            }
            return JoyDoc(dictionary: jsonDict)
        } else {
            return sampleJSONDocument(fileName: selectedExample)
        }
    }
    
    private func setCurrentJSONSchema() {
        if useCustomJSON {
            if jsonSchema.isEmpty {
                resetJoyfillSchemaToDefault()
            } else {
                setCustomSchema(jsonSchema)
            }
        } else {
            resetJoyfillSchemaToDefault()
        }
    }
    
    private func getCurrentDocumentEditor() -> DocumentEditor {
        let document = getCurrentDocument()
        return DocumentEditor(document: document, events: changeManagerWraper.changeManager, license: licenseKey)
    }
    
    private func resetToSampleDocument() {
        let document = sampleJSONDocument(fileName: "ErrorHandling")
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: document.dictionary, options: .prettyPrinted),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            self.jsonString = jsonStr
        }
        
        jsonErrorMessage = nil
        validationMessage = ""
        validationDetails = ""
    }
}

fileprivate func formatValidationErrors(error: SchemaValidationError) -> String {
    var details = "Schema Version: \(error.details.schemaVersion)\nSDK Version: \(error.details.sdkVersion)\n\n Message: \(error.message)\n\n"
    
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
