import SwiftUI
import JoyfillAPIService
import JoyfillModel
import Joyfill
import JoyfillFormulas
import UIKit

struct FormBuilderView: View {
    @State private var fields: [BuilderField] = []
    @State private var formulas: [BuilderFormula] = []
    @State private var tableColumns: [FieldTableColumn] = []
    @State private var showingAddField = false
    @State private var showingAddFormula = false
    @State private var editingField: BuilderField? = nil
    @State private var editingFormula: BuilderFormula? = nil
    @State private var builtDocument: JoyDoc?
    @State private var documentEditor: DocumentEditor?
    @State private var selectedTemplate: FormTemplate = .allFieldTypes
    @State private var isFormulasExpanded = true
    @State private var isFieldsExpanded = true
    @State private var isTemplateExpanded = false
    @State private var showingPasteAlert = false
    @State private var pasteAlertMessage = ""
    let imagePicker = ImagePicker()
    let changeManager: ChangeManager

    init(fields: [BuilderField] = [], formulas: [BuilderFormula] = [], tableColumns: [FieldTableColumn] = [], showingAddField: Bool = false, showingAddFormula: Bool = false, editingField: BuilderField? = nil, editingFormula: BuilderFormula? = nil, builtDocument: JoyDoc? = nil, documentEditor: DocumentEditor? = nil, selectedTemplate: FormTemplate = .allFieldTypes, isFormulasExpanded: Bool = true, isFieldsExpanded: Bool = true, isTemplateExpanded: Bool = false) {
        self.fields = fields
        self.formulas = formulas
        self.tableColumns = tableColumns
        self.showingAddField = showingAddField
        self.showingAddFormula = showingAddFormula
        self.editingField = editingField
        self.editingFormula = editingFormula
        self.builtDocument = builtDocument
        self.documentEditor = documentEditor
        self.selectedTemplate = selectedTemplate
        self.isFormulasExpanded = isFormulasExpanded
        self.isFieldsExpanded = isFieldsExpanded
        self.isTemplateExpanded = isTemplateExpanded
        self.changeManager = ChangeManager(showImagePicker: imagePicker.showPickerOptions, showScan: {_ in })
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Main scrollable content
                ScrollView {
                    VStack(spacing: 20) {
                        // Template Picker Section (Collapsible)
                        VStack(alignment: .leading, spacing: 16) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isTemplateExpanded.toggle()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                    
                                    Text("Load Template")
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: isTemplateExpanded ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .padding(.horizontal, 20)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if isTemplateExpanded {
                                VStack(alignment: .leading, spacing: 12) {
                                    Menu {
                                        ForEach(FormTemplate.allCases, id: \.self) { template in
                                            Button(action: {
                                                selectedTemplate = template
                                                if template != .custom {
                                                    loadTemplate(template)
                                                }
                                            }) {
                                                Label(template.displayName, systemImage: template.systemImage)
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: selectedTemplate.systemImage)
                                                .foregroundColor(.blue)
                                            Text(selectedTemplate.displayName)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.secondary)
                                                .font(.caption)
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    if selectedTemplate != .custom {
                                        Text(selectedTemplate.description)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 16)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        
                        // Formulas Section (Collapsible)
                        VStack(alignment: .leading, spacing: 16) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isFormulasExpanded.toggle()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "function")
                                        .foregroundColor(.purple)
                                        .font(.title2)
                                    
                                    Text("Formulas")
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                    
                                    Text("(\(formulas.count))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: isFormulasExpanded ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Button(action: { showingAddFormula = true }) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title2)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.horizontal, 20)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if isFormulasExpanded {
                                if formulas.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "function")
                                            .font(.system(size: 32))
                                            .foregroundColor(.secondary)
                                        
                                        Text("No Formulas Yet")
                                            .foregroundColor(.secondary)
                                        
                                        Text("Add your first formula to get started")
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                            .font(.subheadline)
                                    }
                                    .padding(.vertical, 24)
                                    .frame(maxWidth: .infinity)
                                } else {
                                    VStack(alignment: .leading, spacing: 8) {
                                        List {
                                            ForEach(formulas) { formula in
                                                FormulaCardView(formula: formula)
                                                    .listRowBackground(Color(.systemBackground))
                                                    .listRowSeparator(.hidden)
                                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                                    .onTapGesture {
                                                        editingFormula = formula
                                                    }
                                            }
                                            .onDelete(perform: deleteFormulaAtIndex)
                                        }
                                        .listStyle(.plain)
                                        .frame(height: CGFloat(min(formulas.count * 120, 400)))
                                        .background(Color(.systemGroupedBackground))
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 16)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        
                        // Fields Section (Collapsible)
                        VStack(alignment: .leading, spacing: 16) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isFieldsExpanded.toggle()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.3.group.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                    
                                    Text("Fields")
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                    
                                    Text("(\(fields.count))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: isFieldsExpanded ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Button(action: { showingAddField = true }) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title2)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.horizontal, 20)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if isFieldsExpanded {
                                if fields.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "rectangle.3.group")
                                            .font(.system(size: 32))
                                            .foregroundColor(.secondary)
                                        
                                        Text("No Fields Yet")
                                            .foregroundColor(.secondary)
                                        
                                        Text("Add your first field to get started")
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.secondary)
                                            .font(.subheadline)
                                    }
                                    .padding(.vertical, 24)
                                    .frame(maxWidth: .infinity)
                                } else {
                                    VStack(alignment: .leading, spacing: 8) {
                                        List {
                                            ForEach(fields) { field in
                                                FieldCardView(field: field)
                                                    .listRowBackground(Color(.systemBackground))
                                                    .listRowSeparator(.hidden)
                                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                                    .onTapGesture {
                                                        editingField = field
                                                    }
                                            }
                                            .onDelete(perform: deleteFieldAtIndex)
                                            .onMove(perform: moveField)
                                        }
                                        .listStyle(.plain)
                                        .frame(height: CGFloat(min(fields.count * 120, 400)))
                                        .background(Color(.systemGroupedBackground))
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 16)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 16)
                    }
                }
                
                // Fixed Bottom Action Buttons
                VStack(spacing: 0) {
                    Divider()
                        .background(Color(.systemGray4))
                    
                    HStack(spacing: 20) {
                        // Clear All Button
                        Button(action: {
                            withAnimation {
                                fields.removeAll()
                                formulas.removeAll()
                            }
                        }) {
                            VStack(spacing: 6) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 48, height: 48)
                                    .background(fields.isEmpty && formulas.isEmpty ? Color.gray : Color.red)
                                    .clipShape(Circle())
                                
                                Text("Clear All")
                                    .font(.caption2)
                                    .foregroundColor(fields.isEmpty && formulas.isEmpty ? .secondary : .red)
                            }
                        }
                        .disabled(fields.isEmpty && formulas.isEmpty)
                        
                        // Copy JSON Button
                        Button(action: {
                            copyJSONToClipboard()
                        }) {
                            VStack(spacing: 6) {
                                Image(systemName: "doc.on.doc.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 48, height: 48)
                                    .background(fields.isEmpty ? Color.gray : Color.purple)
                                    .clipShape(Circle())
                                
                                Text("Copy JSON")
                                    .font(.caption2)
                                    .foregroundColor(fields.isEmpty ? .secondary : .purple)
                            }
                        }
                        .disabled(fields.isEmpty)
                        
                        // Paste JSON Button
                        Button(action: {
                            pasteAndLoadJSON()
                        }) {
                            VStack(spacing: 6) {
                                Image(systemName: "doc.on.clipboard.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 48, height: 48)
                                    .background(Color.orange)
                                    .clipShape(Circle())
                                
                                Text("Paste JSON")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }

                        Spacer()
                        
                        // Test Form Button
                        NavigationLink(destination: {
                            if let documentEditor = documentEditor {
                                Form(documentEditor: documentEditor)
                                    .navigationBarTitleDisplayMode(.inline)
                            } else {
                                Text("Please build the form first")
                                    .foregroundColor(.secondary)
                            }
                        }) {
                            VStack(spacing: 6) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 48, height: 48)
                                    .background(fields.isEmpty ? Color.gray : Color.blue)
                                    .clipShape(Circle())
                                
                                Text("Test Form")
                                    .font(.caption2)
                                    .foregroundColor(fields.isEmpty ? .secondary : .blue)
                            }
                        }
                        .disabled(fields.isEmpty)
                        .simultaneousGesture(TapGesture().onEnded {
                            if !fields.isEmpty {
                                buildAndPreviewForm()
                            }
                        })
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddField) {
                AddFieldView(editingField: nil, formulas: formulas) { field in
                    fields.append(field)
                }
            }
            .sheet(isPresented: $showingAddFormula) {
                AddFormulaView(editingFormula: nil) { formula in
                    formulas.append(formula)
                }
            }
            .sheet(item: $editingField) { field in
                AddFieldView(editingField: field, formulas: formulas) { updatedField in
                    if let index = fields.firstIndex(where: { $0.id == field.id }) {
                        let oldIdentifier = field.id
                        let newIdentifier = updatedField.id

                        // Update the field
                        fields[index] = updatedField
                        
                        // If identifier changed, update any formulas that reference it
                        if oldIdentifier != newIdentifier {
                            for formulaIndex in formulas.indices {
                                let oldFormula = formulas[formulaIndex].formula
                                // Use regex with word boundaries to replace only complete identifiers
                                let pattern = "\\b\(NSRegularExpression.escapedPattern(for: oldIdentifier))\\b"
                                let updatedFormula = oldFormula.replacingOccurrences(
                                    of: pattern,
                                    with: newIdentifier,
                                    options: .regularExpression
                                )
                                if updatedFormula != oldFormula {
                                    formulas[formulaIndex].formula = updatedFormula
                                }
                            }
                        }
                    }
                    editingField = nil
                }
            }
            .sheet(item: $editingFormula) { formula in
                AddFormulaView(editingFormula: formula) { updatedFormula in
                    if let index = formulas.firstIndex(where: { $0.id == formula.id }) {
                        let oldIdentifier = formula.id
                        let newIdentifier = updatedFormula.id
                        
                        // Update the formula
                        formulas[index] = updatedFormula
                        
                        // If identifier changed, update any fields that reference it
                        if oldIdentifier != newIdentifier {
                            for fieldIndex in fields.indices {
                                if fields[fieldIndex].formulaRef == oldIdentifier {
                                    fields[fieldIndex].formulaRef = newIdentifier
                                }
                            }
                        }
                    }
                    editingFormula = nil
                }
            }
            .alert(isPresented: $showingPasteAlert) {
                Alert(title: Text("Paste JSON"), message: Text(pasteAlertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                loadTemplate(.allFieldTypes) // Load comprehensive field types template by default
            }
        }
    }
    
    private func pasteAndLoadJSON() {
        guard let jsonString = UIPasteboard.general.string else {
            pasteAlertMessage = "Clipboard does not contain a string."
            showingPasteAlert = true
            return
        }
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            pasteAlertMessage = "Failed to encode JSON string to data."
            showingPasteAlert = true
            return
        }
        
        do {
            if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                let joyDoc = JoyDoc(dictionary: jsonDict)
                load(from: joyDoc)
                pasteAlertMessage = "Successfully loaded form from JSON."
                showingPasteAlert = true
            }
        } catch {
            pasteAlertMessage = "Failed to parse JSON: \(error.localizedDescription)"
            showingPasteAlert = true
        }
    }
    
    private func load(from joyDoc: JoyDoc) {
        // Clear existing data
        fields.removeAll()
        formulas.removeAll()
        
        // Load formulas
        self.formulas = joyDoc.formulas.map {
            BuilderFormula(id: $0.id ?? "", formula: $0.expression ?? "")
        }
        
//        // Load fields
        self.fields = joyDoc.fields.map { docField -> BuilderField in
            let fieldType = docField.fieldType
            var formulaRef: String?
            var formulaKey: String = "value"
            
            if let appliedFormula = docField.formulas?.first {
                formulaRef = appliedFormula.formula
                formulaKey = appliedFormula.key ?? "value"
            }
            
            var field = BuilderField(
                id: docField.id ?? "",
                label: docField.title ?? "",
                fieldType: fieldType,
                value: docField.value?.text ?? "",
                formulaRef: formulaRef,
                formulaKey: formulaKey,
                tableColumns: docField.tableColumns ?? []
            )
            field.valueUnion = docField.value
            return field
        }
        
        // Switch to custom template view
        selectedTemplate = .custom
    }
    
    private func deleteField(_ field: BuilderField) {
        fields.removeAll { $0.id == field.id }
    }
    
    private func deleteFormula(_ formula: BuilderFormula) {
        formulas.removeAll { $0.id == formula.id }
        // Also remove formula references from fields
        for index in fields.indices {
            if fields[index].formulaRef == formula.id {
                fields[index].formulaRef = nil
            }
        }
    }
    
    private func deleteFieldAtIndex(at offsets: IndexSet) {
        fields.remove(atOffsets: offsets)
    }
    
    private func deleteFormulaAtIndex(at offsets: IndexSet) {
        let formulasToDelete = offsets.map { formulas[$0] }
        formulas.remove(atOffsets: offsets)
        
        // Remove formula references from fields
        for deletedFormula in formulasToDelete {
            for index in fields.indices {
                if fields[index].formulaRef == deletedFormula.id {
                    fields[index].formulaRef = nil
                }
            }
        }
    }
    
    private func moveField(from source: IndexSet, to destination: Int) {
        fields.move(fromOffsets: source, toOffset: destination)
    }
    
    private func buildAndPreviewForm() {
        var document = JoyDoc.addDocument()
        
        // Add all formulas first
        for formula in formulas {
            document = document.addFormula(id: formula.id, formula: formula.formula)
        }
        
        // Add all fields
        for field in fields {
            switch field.fieldType {
            case .text:
                if let formulaRef = field.formulaRef {
                    document = document.addTextField(
                        identifier: field.id,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey,
                        value: field.value,
                        label: field.label
                    )
                } else {
                    document = document.addTextField(
                        identifier: field.id,
                        value: field.value,
                        label: field.label
                    )
                }
                
            case .textarea:
                if let formulaRef = field.formulaRef {
                    document = document.addTextareaField(
                        identifier: field.id,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey
                    )
                } else {
                    document = document.addTextareaField(
                        identifier: field.id,
                        value: field.value
                    )
                }
                
            case .richText:
                if let formulaRef = field.formulaRef {
                    document = document.addRichTextField(
                        identifier: field.id,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey,
                        htmlContent: field.value
                    )
                } else {
                    document = document.addRichTextField(
                        identifier: field.id,
                        htmlContent: field.value
                    )
                }
                
            case .number:
                if let formulaRef = field.formulaRef {
                    document = document.addNumberField(
                        identifier: field.id,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey,
                        value: 0,
                        label: field.label
                    )
                } else {
                    let numberValue = Double(field.value) ?? 0
                    document = document.addNumberField(
                        identifier: field.id,
                        value: numberValue,
                        label: field.label
                    )
                }
                
            case .date:
                if let formulaRef = field.formulaRef {
                    document = document.addDateField(
                        identifier: field.id,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey,
                        label: field.label
                    )
                } else {
                    document = document.addDateField(
                        identifier: field.id,
                        value: Date(),
                        label: field.label
                    )
                }
                
            case .dropdown:
                if let formulaRef = field.formulaRef {
                    document = document.addOptionField(
                        identifier: field.id,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey,
                        options: field.options,
                        label: field.label
                    )
                } else {
                    document = document.addOptionField(
                        identifier: field.id,
                        options: field.options,
                        label: field.label
                    )
                }
                
            case .multiSelect:
                if field.needsOptions {
                    // Multi-select with options
                    let options = field.value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    if let formulaRef = field.formulaRef {
                        document = document.addOptionField(
                            identifier: field.id,
                            formulaRef: formulaRef,
                            formulaKey: field.formulaKey,
                            options: options,
                            multiselect: true,
                            label: field.label
                        )
                    } else {
                        document = document.addOptionField(
                            identifier: field.id,
                            value: [],
                            options: options,
                            multiselect: true,
                            label: field.label
                        )
                    }
                } else {
                    // Checkbox/boolean multi-select
                    if let formulaRef = field.formulaRef {
                        document = document.addCheckboxField(
                            identifier: field.id,
                            formulaRef: formulaRef,
                            formulaKey: field.formulaKey,
                            label: field.label
                        )
                    } else {
                        let boolValue = field.value.lowercased() == "true"
                        document = document.addCheckboxField(
                            identifier: field.id,
                            value: boolValue,
                            label: field.label
                        )
                    }
                }
                
            case .signature:
                if let formulaRef = field.formulaRef {
                    document = document.addSignatureField(
                        identifier: field.id,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey
                    )
                } else {
                    document = document.addSignatureField(
                        identifier: field.id,
                        signatureUrl: field.value
                    )
                }
                
            case .image:
                if let formulaRef = field.formulaRef {
                    document = document.addImageField(
                        identifier: field.id,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey,
                        allowMultiple: field.supportsMultiple
                    )
                } else {
                    document = document.addImageField(
                        identifier: field.id,
                        imageUrl: field.value,
                        allowMultiple: field.supportsMultiple
                    )
                }
                
            case .block:
                if let formulaRef = field.formulaRef {
                    document = document.addBlockField(
                        identifier: field.id,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey
                    )
                } else {
                    document = document.addBlockField(
                        identifier: field.id
                    )
                }
                
            case .chart:
                if let formulaRef = field.formulaRef {
                    document = document.addChartField(
                        identifier: field.id,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey
                    )
                } else {
                    // Create some sample points for chart
                    let samplePoints: [Point] = []
                    document = document.addChartField(
                        identifier: field.id,
                        points: samplePoints
                    )
                }
                
            case .table:
                if let formulaRef = field.formulaRef {
                    document = document.addTableField(
                        identifier: field.id,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey,
                        columns: field.tableColumns,
                        rows: field.valueUnion?.valueElements ?? []
                    )
                } else {
                    // Create sample table columns
                    document = document.addTableField(
                        identifier: field.id,
                        columns: field.tableColumns,
                        rows: field.valueUnion?.valueElements ?? []
                    )
                }
                
            case .collection:
                if let formulaRef = field.formulaRef {
                    document = document.addCollectionField(
                        identifier: field.id,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey
                    )
                } else {
                    // Create basic schema for collection
                    let basicSchema: [String: Schema] = [:]
                    document = document.addCollectionField(
                        identifier: field.id,
                        schema: basicSchema
                    )
                }
            
            default:
                // Handle other field types as text fields for now
                if let formulaRef = field.formulaRef {
                    document = document.addTextField(
                        identifier: field.id,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey,
                        label: field.label
                    )
                } else {
                    document = document.addTextField(
                        identifier: field.id,
                        value: field.value,
                        label: field.label
                    )
                }
            }
        }
        
        builtDocument = document
        documentEditor = DocumentEditor(document: document)
//        changeManager.documentEditor = documentEditor
    }
    
    private func loadTemplate(_ template: FormTemplate) {
        // Clear existing data
        fields.removeAll()
        formulas.removeAll()
        
        switch template {
        case .custom:
            // Keep current data as is
            break
            
        case .allFieldTypes:
            // Comprehensive showcase of all field types
            formulas = [
                BuilderFormula(id: "textFormula", formula: "upper(textInput)"),
                BuilderFormula(id: "numberFormula", formula: "number1 + number2"),
                BuilderFormula(id: "dateFormula", formula: "dateAdd(startDate, 7, \"days\")")
            ]
            
            fields = [
                // Basic Input Fields
                BuilderField(id: "textInput", label: "Text Field", fieldType: .text, value: "Sample text"),
                BuilderField(id: "textareaInput", label: "Text Area", fieldType: .textarea, value: "Multi-line\ntext content"),
                BuilderField(id: "richTextInput", label: "Rich Text", fieldType: .richText, value: "<p><strong>Rich</strong> <em>text</em> content</p>"),
                BuilderField(id: "numberInput", label: "Number Field", fieldType: .number, value: "42"),
                BuilderField(id: "dateInput", label: "Date Field", fieldType: .date, value: ""),

                // Selection Fields
                BuilderField(id: "dropdownInput", label: "Dropdown", fieldType: .dropdown, value: "Option 1,Option 2,Option 3"),
                BuilderField(id: "multiselectInput", label: "Multi Select", fieldType: .multiSelect, value: "Choice A,Choice B,Choice C"),

                // Media & Interaction Fields
                BuilderField(id: "imageInput", label: "Image Field", fieldType: .image, value: ""),
                BuilderField(id: "signatureInput", label: "Signature", fieldType: .signature, value: ""),

                // Display Fields
                BuilderField(id: "blockInput", label: "Block/Label", fieldType: .block, value: "This is a static label"),

                // Advanced Fields
                BuilderField(id: "chartInput", label: "Chart Field", fieldType: .chart, value: "Sample Chart"),
                BuilderField(id: "tableInput", label: "Table Field", fieldType: .table, value: ""),
                BuilderField(id: "collectionInput", label: "Collection", fieldType: .collection, value: ""),

                // Formula-driven Fields
                BuilderField(id: "textResult", label: "Text Formula Result", fieldType: .text, formulaRef: "textFormula"),
                BuilderField(id: "numberResult", label: "Number Formula Result", fieldType: .number, formulaRef: "numberFormula"),
                BuilderField(id: "dateResult", label: "Date Formula Result", fieldType: .date, formulaRef: "dateFormula"),

                // Supporting Fields for Formulas
                BuilderField(id: "number1", label: "First Number", fieldType: .number, value: "10"),
                BuilderField(id: "number2", label: "Second Number", fieldType: .number, value: "5"),
                BuilderField(id: "startDate", label: "Start Date", fieldType: .date, value: "")
            ]
            
        case .mathFormulas:
            // Math formulas template
            formulas = [
                BuilderFormula(id: "addition", formula: "num1 + num2"),
                BuilderFormula(id: "multiplication", formula: "num1 * num2"),
                BuilderFormula(id: "power", formula: "pow(base, exponent)"),
                BuilderFormula(id: "squareRoot", formula: "sqrt(number)"),
                BuilderFormula(id: "rounding", formula: "round(decimal, places)"),
                BuilderFormula(id: "percentage", formula: "(score / total) * 100"),
                BuilderFormula(id: "average", formula: "(num1 + num2 + num3) / 3")
            ]
            
            // Input fields
            let inputFields = [
                BuilderField(id: "num1", label: "First Number", fieldType: .number, value: "10"),
                BuilderField(id: "num2", label: "Second Number", fieldType: .number, value: "5"),
                BuilderField(id: "num3", label: "Third Number", fieldType: .number, value: "15"),
                BuilderField(id: "base", label: "Base", fieldType: .number, value: "2"),
                BuilderField(id: "exponent", label: "Exponent", fieldType: .number, value: "3"),
                BuilderField(id: "number", label: "Square Root Input", fieldType: .number, value: "16"),
                BuilderField(id: "decimal", label: "Decimal Number", fieldType: .number, value: "3.14159"),
                BuilderField(id: "places", label: "Decimal Places", fieldType: .number, value: "2"),
                BuilderField(id: "score", label: "Score", fieldType: .number, value: "85"),
                BuilderField(id: "total", label: "Total", fieldType: .number, value: "100")
            ]
            
            // Result fields
            let resultFields = [
                BuilderField(id: "sum", label: "Sum Result", fieldType: .number, formulaRef: "addition"),
                BuilderField(id: "product", label: "Product Result", fieldType: .number, formulaRef: "multiplication"),
                BuilderField(id: "powerResult", label: "Power Result", fieldType: .number, formulaRef: "power"),
                BuilderField(id: "sqrtResult", label: "Square Root", fieldType: .number, formulaRef: "squareRoot"),
                BuilderField(id: "roundResult", label: "Rounded Value", fieldType: .number, formulaRef: "rounding"),
                BuilderField(id: "percentResult", label: "Percentage", fieldType: .number, formulaRef: "percentage"),
                BuilderField(id: "avgResult", label: "Average", fieldType: .number, formulaRef: "average")
            ]
            
            fields = inputFields + resultFields
            
        case .stringFormulas:
            // String manipulation template
            formulas = [
                BuilderFormula(id: "fullName", formula: "concat(firstName, \" \", lastName)"),
                BuilderFormula(id: "upperCase", formula: "upper(text)"),
                BuilderFormula(id: "lowerCase", formula: "lower(text)"),
                BuilderFormula(id: "textLength", formula: "length(text)"),
                BuilderFormula(id: "containsCheck", formula: "contains(text, searchTerm)"),
                BuilderFormula(id: "emailValidation", formula: "if(and(contains(email, \"@\"), contains(email, \".\")), \"Valid\", \"Invalid\")"),
                BuilderFormula(id: "greeting", formula: "concat(\"Hello, \", firstName, \"! You have \", length(text), \" characters.\")")
            ]
            
            fields = [
                BuilderField(id: "firstName", label: "First Name", fieldType: .text, value: "John"),
                BuilderField(id: "lastName", label: "Last Name", fieldType: .text, value: "Doe"),
                BuilderField(id: "text", label: "Sample Text", fieldType: .text, value: "Hello World"),
                BuilderField(id: "searchTerm", label: "Search Term", fieldType: .text, value: "Hello"),
                BuilderField(id: "email", label: "Email", fieldType: .text, value: "john@example.com"),
                BuilderField(id: "fullNameResult", label: "Full Name", fieldType: .text, formulaRef: "fullName"),
                BuilderField(id: "upperResult", label: "Uppercase", fieldType: .text, formulaRef: "upperCase"),
                BuilderField(id: "lowerResult", label: "Lowercase", fieldType: .text, formulaRef: "lowerCase"),
                BuilderField(id: "lengthResult", label: "Text Length", fieldType: .number, formulaRef: "textLength"),
                BuilderField(id: "containsResult", label: "Contains Check", fieldType: .text, formulaRef: "containsCheck"),
                BuilderField(id: "emailResult", label: "Email Valid", fieldType: .text, formulaRef: "emailValidation"),
                BuilderField(id: "greetingResult", label: "Greeting Message", fieldType: .text, formulaRef: "greeting")
            ]
            
        case .arrayFormulas:
            // Array operations template
            formulas = [
                BuilderFormula(id: "arraySum", formula: "sum(numbers)"),
                BuilderFormula(id: "arrayLength", formula: "length(fruits)"),
                BuilderFormula(id: "arrayMap", formula: "map(numbers, (item) → item * 2)"),
                BuilderFormula(id: "arrayFilter", formula: "filter(numbers, (item) → item > 5)"),
                BuilderFormula(id: "arrayFind", formula: "find(fruits, (item) → contains(item, \"a\"))"),
                BuilderFormula(id: "arrayEvery", formula: "every(numbers, (item) → item > 0)"),
                BuilderFormula(id: "arraySome", formula: "some(fruits, (item) → contains(item, \"e\"))"),
                BuilderFormula(id: "arrayConcat", formula: "concat(\"Selected: \", fruits)")
            ]
            
            fields = [
                BuilderField(id: "numbers", label: "Numbers Array", fieldType: .text, value: "[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]"),
                BuilderField(id: "fruits", label: "Fruits", fieldType: .dropdown, options: ["apple" , "banana", "cherry", "date", "elderberry"]),
                BuilderField(id: "sumResult", label: "Array Sum", fieldType: .number, formulaRef: "arraySum"),
                BuilderField(id: "lengthResult", label: "Array Length", fieldType: .number, formulaRef: "arrayLength"),
                BuilderField(id: "mapResult", label: "Doubled Numbers", fieldType: .text, formulaRef: "arrayMap"),
                BuilderField(id: "filterResult", label: "Numbers > 5", fieldType: .text, formulaRef: "arrayFilter"),
                BuilderField(id: "findResult", label: "First with 'a'", fieldType: .text, formulaRef: "arrayFind"),
                BuilderField(id: "everyResult", label: "All Positive", fieldType: .multiSelect, formulaRef: "arrayEvery"),
                BuilderField(id: "someResult", label: "Some have 'e'", fieldType: .multiSelect, formulaRef: "arraySome"),
                BuilderField(id: "concatResult", label: "Concatenated", fieldType: .text, formulaRef: "arrayConcat")
            ]
            
        case .logicalFormulas:
            // Logical operations template
            formulas = [
                BuilderFormula(id: "simpleIf", formula: "if(age >= 18, \"Adult\", \"Minor\")"),
                BuilderFormula(id: "nestedIf", formula: "if(score >= 90, \"A\", if(score >= 80, \"B\", if(score >= 70, \"C\", \"F\")))"),
                BuilderFormula(id: "andLogic", formula: "and(isActive, hasPermission)"),
                BuilderFormula(id: "orLogic", formula: "or(isVip, isPremium)"),
                BuilderFormula(id: "notLogic", formula: "not(isBlocked)"),
                BuilderFormula(id: "complexLogic", formula: "if(and(age >= 18, or(hasLicense, hasPermit)), \"Can Drive\", \"Cannot Drive\")"),
                BuilderFormula(id: "emptyCheck", formula: "if(empty(optionalText), \"No value provided\", optionalText)")
            ]
            
            // Input fields
            let inputFields = [
                BuilderField(id: "age", label: "Age", fieldType: .number, value: "25"),
                BuilderField(id: "score", label: "Test Score", fieldType: .number, value: "85"),
                BuilderField(id: "isActive", label: "Is Active", fieldType: .multiSelect, value: "true"),
                BuilderField(id: "hasPermission", label: "Has Permission", fieldType: .multiSelect, value: "true"),
                BuilderField(id: "isVip", label: "Is VIP", fieldType: .multiSelect, value: "false"),
                BuilderField(id: "isPremium", label: "Is Premium", fieldType: .multiSelect, value: "true"),
                BuilderField(id: "isBlocked", label: "Is Blocked", fieldType: .multiSelect, value: "false"),
                BuilderField(id: "hasLicense", label: "Has License", fieldType: .multiSelect, value: "true"),
                BuilderField(id: "hasPermit", label: "Has Permit", fieldType: .multiSelect, value: "false"),
                BuilderField(id: "optionalText", label: "Optional Text", fieldType: .text, value: "")
            ]
            
            // Result fields
            let resultFields = [
                BuilderField(id: "ageCategory", label: "Age Category", fieldType: .text, formulaRef: "simpleIf"),
                BuilderField(id: "grade", label: "Letter Grade", fieldType: .text, formulaRef: "nestedIf"),
                BuilderField(id: "accessGranted", label: "Access Granted", fieldType: .multiSelect, formulaRef: "andLogic"),
                BuilderField(id: "specialMember", label: "Special Member", fieldType: .multiSelect, formulaRef: "orLogic"),
                BuilderField(id: "canAccess", label: "Can Access", fieldType: .multiSelect, formulaRef: "notLogic"),
                BuilderField(id: "drivingStatus", label: "Driving Status", fieldType: .text, formulaRef: "complexLogic"),
                BuilderField(id: "textStatus", label: "Text Status", fieldType: .text, formulaRef: "emptyCheck")
            ]
            
            fields = inputFields + resultFields
            
        case .referenceResolution:
            // Advanced reference resolution template
            formulas = [
                BuilderFormula(id: "arrayIndex", formula: "fruits[selectedIndex]"),
                BuilderFormula(id: "dynamicIndex", formula: "matrix[row][col]"),
                BuilderFormula(id: "objectProperty", formula: "user.name"),
                BuilderFormula(id: "nestedProperty", formula: "user.address.city"),
                BuilderFormula(id: "selfReference", formula: "self * 2"),
                BuilderFormula(id: "currentReference", formula: "current + 10"),
                BuilderFormula(id: "dynamicSum", formula: "numbers[0] + numbers[1] + numbers[2]"),
                BuilderFormula(id: "conditionalRef", formula: "if(useFirst, fruits[0], fruits[1])")
            ]
            
            // Input fields
            let inputFields = [
                BuilderField(id: "fruits", label: "Fruits Array", fieldType: .text, value: "[\"apple\", \"banana\", \"cherry\", \"date\"]"),
                BuilderField(id: "selectedIndex", label: "Selected Index", fieldType: .number, value: "2"),
                BuilderField(id: "matrix", label: "Matrix", fieldType: .text, value: "[[1, 2, 3], [4, 5, 6], [7, 8, 9]]"),
                BuilderField(id: "row", label: "Row Index", fieldType: .number, value: "1"),
                BuilderField(id: "col", label: "Column Index", fieldType: .number, value: "2"),
                BuilderField(id: "user", label: "User Object", fieldType: .text, value: "{\"name\": \"John\", \"address\": {\"city\": \"NYC\"}}"),
                BuilderField(id: "selfValue", label: "Self Value", fieldType: .number, value: "25"),
                BuilderField(id: "currentValue", label: "Current Value", fieldType: .number, value: "15"),
                BuilderField(id: "numbers", label: "Numbers", fieldType: .text, value: "[10, 20, 30]"),
                BuilderField(id: "useFirst", label: "Use First", fieldType: .multiSelect, value: "true")
            ]
            
            // Result fields
            let resultFields = [
                BuilderField(id: "selectedFruit", label: "Selected Fruit", fieldType: .text, formulaRef: "arrayIndex"),
                BuilderField(id: "matrixValue", label: "Matrix Value", fieldType: .number, formulaRef: "dynamicIndex"),
                BuilderField(id: "userName", label: "User Name", fieldType: .text, formulaRef: "objectProperty"),
                BuilderField(id: "userCity", label: "User City", fieldType: .text, formulaRef: "nestedProperty"),
                BuilderField(id: "selfResult", label: "Self * 2", fieldType: .number, formulaRef: "selfReference"),
                BuilderField(id: "currentResult", label: "Current + 10", fieldType: .number, formulaRef: "currentReference"),
                BuilderField(id: "numbersSum", label: "Numbers Sum", fieldType: .number, formulaRef: "dynamicSum"),
                BuilderField(id: "conditionalResult", label: "Conditional Fruit", fieldType: .text, formulaRef: "conditionalRef")
            ]
            
            fields = inputFields + resultFields
            
        case .dateFormulas:
            // Date manipulation template  
            formulas = [
                BuilderFormula(id: "currentDate", formula: "now()"),
                BuilderFormula(id: "dateYear", formula: "year(birthDate)"),
                BuilderFormula(id: "dateMonth", formula: "month(birthDate)"),
                BuilderFormula(id: "dateDay", formula: "day(birthDate)"),
                BuilderFormula(id: "addDays", formula: "dateAdd(startDate, days, \"days\")"),
                BuilderFormula(id: "addWeeks", formula: "dateAdd(startDate, weeks, \"weeks\")"),
                BuilderFormula(id: "subtractDays", formula: "dateSubtract(endDate, days, \"days\")"),
                BuilderFormula(id: "ageCalculation", formula: "round((now() - birthDate) / (365.25 * 24 * 60 * 60 * 1000))")
            ]
            
            let currentTime = Date().timeIntervalSince1970 * 1000
            let yearsAgo25 = -25 * 365.25 * 24 * 60 * 60
            let birthTime = Date().addingTimeInterval(yearsAgo25).timeIntervalSince1970 * 1000
            let daysToMilliseconds = 30 * 24 * 60 * 60 * 1000
            let endTime = currentTime + Double(daysToMilliseconds)
            
            fields = [
                BuilderField(id: "birthDate", label: "Birth Date", fieldType: .number, value: String(birthTime)),
                BuilderField(id: "startDate", label: "Start Date", fieldType: .number, value: String(currentTime)),
                BuilderField(id: "endDate", label: "End Date", fieldType: .number, value: String(endTime)),
                BuilderField(id: "days", label: "Days to Add", fieldType: .number, value: "7"),
                BuilderField(id: "weeks", label: "Weeks to Add", fieldType: .number, value: "2"),
                BuilderField(id: "currentDateResult", label: "Current Date", fieldType: .date, formulaRef: "currentDate"),
                BuilderField(id: "yearResult", label: "Birth Year", fieldType: .number, formulaRef: "dateYear"),
                BuilderField(id: "monthResult", label: "Birth Month", fieldType: .number, formulaRef: "dateMonth"),
                BuilderField(id: "dayResult", label: "Birth Day", fieldType: .number, formulaRef: "dateDay"),
                BuilderField(id: "addDaysResult", label: "Date + Days", fieldType: .date, formulaRef: "addDays"),
                BuilderField(id: "addWeeksResult", label: "Date + Weeks", fieldType: .date, formulaRef: "addWeeks"),
                BuilderField(id: "subtractResult", label: "Date - Days", fieldType: .date, formulaRef: "subtractDays"),
                BuilderField(id: "ageResult", label: "Calculated Age", fieldType: .number, formulaRef: "ageCalculation")
            ]
            
        case .conversionFormulas:
            // Type conversion template
            formulas = [
                BuilderFormula(id: "stringToNumber", formula: "toNumber(stringValue)"),
                BuilderFormula(id: "numberCalculation", formula: "toNumber(stringNum1) + toNumber(stringNum2)"),
                BuilderFormula(id: "decimalConversion", formula: "toNumber(decimalString)"),
                BuilderFormula(id: "negativeConversion", formula: "toNumber(negativeString)"),
                BuilderFormula(id: "percentageCalc", formula: "(toNumber(numerator) / toNumber(denominator)) * 100"),
                BuilderFormula(id: "roundedConversion", formula: "round(toNumber(floatString), 2)"),
                BuilderFormula(id: "validationCheck", formula: "if(toNumber(inputValue) > 0, \"Valid Number\", \"Invalid or Zero\")")
            ]
            
            fields = [
                BuilderField(id: "stringValue", label: "String Number", fieldType: .text, value: "42"),
                BuilderField(id: "stringNum1", label: "String Number 1", fieldType: .text, value: "10"),
                BuilderField(id: "stringNum2", label: "String Number 2", fieldType: .text, value: "25"),
                BuilderField(id: "decimalString", label: "Decimal String", fieldType: .text, value: "3.14159"),
                BuilderField(id: "negativeString", label: "Negative String", fieldType: .text, value: "-25"),
                BuilderField(id: "numerator", label: "Numerator", fieldType: .text, value: "75"),
                BuilderField(id: "denominator", label: "Denominator", fieldType: .text, value: "100"),
                BuilderField(id: "floatString", label: "Float String", fieldType: .text, value: "12.3456789"),
                BuilderField(id: "inputValue", label: "Input Value", fieldType: .text, value: "123"),
                BuilderField(id: "numberResult", label: "Converted Number", fieldType: .number, formulaRef: "stringToNumber"),
                BuilderField(id: "calculationResult", label: "Sum Result", fieldType: .number, formulaRef: "numberCalculation"),
                BuilderField(id: "decimalResult", label: "Decimal Result", fieldType: .number, formulaRef: "decimalConversion"),
                BuilderField(id: "negativeResult", label: "Negative Result", fieldType: .number, formulaRef: "negativeConversion"),
                BuilderField(id: "percentageResult", label: "Percentage", fieldType: .number, formulaRef: "percentageCalc"),
                BuilderField(id: "roundedResult", label: "Rounded Result", fieldType: .number, formulaRef: "roundedConversion"),
                BuilderField(id: "validationResult", label: "Validation Result", fieldType: .text, formulaRef: "validationCheck")
            ]
        case .table:
            // Use the standardized table cell resolution document
            let tableDocument = JoyDoc.createComprehensiveTableCellResolutionDocument1()
            
            // Extract formulas from the standardized document
            formulas = tableDocument.formulas.map {
                BuilderFormula(id: $0.id ?? "", formula: $0.expression ?? "")
            }
            
            // Extract fields from the standardized document
            fields = tableDocument.fields.compactMap { docField -> BuilderField? in
                guard let fieldId = docField.id, let fieldType = FieldTypes(rawValue: docField.type ?? "") else {
                    return nil
                }
                
                // Get the applied formula reference if it exists
                let formulaRef = docField.formulas?.first?.formula
                let formulaKey = docField.formulas?.first?.key ?? "value"
                
                // Convert value based on field type
                var valueString = ""
                switch docField.value {
                case .string(let s):
                    valueString = s
                case .double(let d):
                    valueString = String(d)
                case .bool(let b):
                    valueString = String(b)
                case .array(let a):
                    valueString = a.joined(separator: ", ")
                default:
                    valueString = ""
                }
                
                var fieldToBeReturned =  BuilderField(
                    id: fieldId,
                    label: docField.title ?? fieldId,
                    fieldType: fieldType,
                    value: valueString,
                    formulaRef: formulaRef,
                    formulaKey: formulaKey,
                    tableColumns: docField.tableColumns ?? []
                )
                fieldToBeReturned.valueUnion = docField.value
                return fieldToBeReturned
            }
        }
    }
    
    private func copyJSONToClipboard() {
        // Build the document structure similar to buildAndPreviewForm
        var document = JoyDoc.addDocument()
        
        // Add all formulas first
        for formula in formulas {
            document = document.addFormula(id: formula.id, formula: formula.formula)
        }
        
        // Add all fields (simplified version for JSON generation)
        for field in fields {
            switch field.fieldType {
            case .text:
                if let formulaRef = field.formulaRef {
                    document = document.addTextField(
                        identifier: field.id,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey,
                        label: field.label
                    )
                } else {
                    document = document.addTextField(
                        identifier: field.id,
                        value: field.value,
                        label: field.label
                    )
                }
            case .number:
                if let formulaRef = field.formulaRef {
                    document = document.addNumberField(
                        identifier: field.id,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey,
                        value: 0,
                        label: field.label
                    )
                } else {
                    let numberValue = Double(field.value) ?? 0
                    document = document.addNumberField(
                        identifier: field.id,
                        value: numberValue,
                        label: field.label
                    )
                }
            case .date:
                if let formulaRef = field.formulaRef {
                    document = document.addDateField(
                        identifier: field.id,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey,
                        label: field.label
                    )
                } else {
                    document = document.addDateField(
                        identifier: field.id,
                        value: Date(),
                        label: field.label
                    )
                }
            case .dropdown:
                if let formulaRef = field.formulaRef {
                    document = document.addOptionField(
                        identifier: field.id,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey,
                        options: field.options,
                        label: field.label
                    )
                } else {
                    document = document.addOptionField(
                        identifier: field.id,
                        options: field.options,
                        label: field.label
                    )
                }
            // Add other field types as needed
            default:
                // Default to text field for simplicity
                if let formulaRef = field.formulaRef {
                    document = document.addTextField(
                        identifier: field.id,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey,
                        label: field.label
                    )
                } else {
                    document = document.addTextField(
                        identifier: field.id,
                        value: field.value,
                        label: field.label
                    )
                }
            }
        }
        
        // Convert document to JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: document.dictionary, options: [.prettyPrinted, .sortedKeys])
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                // Copy to clipboard
                UIPasteboard.general.string = jsonString
                
                // Optional: Show user feedback (you could add a toast or alert here)
                print("JSON copied to clipboard!")
            }
        } catch {
            print("Error generating JSON: \(error)")
        }
    }
}

struct BuilderField: Identifiable {
    let id: String
    var label: String
    var fieldType: FieldTypes
    var valueUnion: ValueUnion?
    var options = [String]()
    var value: String {
        get {
            return valueUnion?.text ?? ""
        }

        set {
            valueUnion = .string(newValue)
        }
    }
    var formulaRef: String? = nil
    var formulaKey: String = "value"
    var tableColumns: [FieldTableColumn] = []
    
    var needsOptions: Bool {
        return fieldType == .dropdown || fieldType == .multiSelect
    }
    
    var supportsMultiple: Bool {
        return fieldType == .image || fieldType == .multiSelect
    }

    init(id: String = "", label: String = "", fieldType: FieldTypes, value: String = "", formulaRef: String? = nil, formulaKey: String = "", tableColumns: [FieldTableColumn] = [], options: [String] = [String]()) {
        self.id = id
        self.label = label
        self.fieldType = fieldType
        self.valueUnion = .string(value)
        self.formulaRef = formulaRef
        self.formulaKey = formulaKey
        self.tableColumns = tableColumns
        self.options = options
    }
}

struct BuilderFormula: Identifiable {
    var id: String
    var formula: String
}

// Extension to add UI properties to FieldTypes from JoyfillModel
extension FieldTypes: CaseIterable {
    public static var allCases: [FieldTypes] {
        return [.text, .textarea, .richText, .number, .date, .dropdown, .multiSelect, .signature, .image, .block, .chart, .table, .collection]
    }
    
    var displayName: String {
        switch self {
        case .text: return "Text"
        case .number: return "Number"
        case .date: return "Date"
        case .dropdown: return "Dropdown"
        case .multiSelect: return "Multi Select"
        case .textarea: return "Text Area"
        case .signature: return "Signature"
        case .block: return "Block/Label"
        case .chart: return "Chart"
        case .richText: return "Rich Text"
        case .table: return "Table"
        case .collection: return "Collection"
        case .image: return "Image"
        case .unknown: return "Unknown"
        }
    }
    
    var systemImage: String {
        switch self {
        case .text: return "textformat"
        case .number: return "number"
        case .date: return "calendar"
        case .dropdown: return "list.bullet"
        case .multiSelect: return "checkmark.square"
        case .textarea: return "text.alignleft"
        case .signature: return "signature"
        case .block: return "cube"
        case .chart: return "chart.bar"
        case .richText: return "textformat.abc"
        case .table: return "tablecells"
        case .collection: return "rectangle.3.group"
        case .image: return "photo"
        case .unknown: return "questionmark"
        }
    }
    
    var color: Color {
        switch self {
        case .text: return .blue
        case .number: return .green
        case .date: return .red
        case .dropdown: return .orange
        case .multiSelect: return .purple
        case .textarea: return .indigo
        case .signature: return .brown
        case .block: return .gray
        case .chart: return .pink
        case .richText: return .cyan
        case .table: return .mint
        case .collection: return .teal
        case .image: return .yellow
        case .unknown: return .secondary
        }
    }
    
    var description: String {
        switch self {
        case .text: return "Single line text input"
        case .number: return "Numeric input field"
        case .date: return "Date and time picker"
        case .dropdown: return "Single selection dropdown"
        case .multiSelect: return "Multiple selection options"
        case .textarea: return "Multi-line text input"
        case .signature: return "Digital signature capture"
        case .block: return "Static text or label"
        case .chart: return "Data visualization chart"
        case .richText: return "Formatted text editor"
        case .table: return "Data table with rows and columns"
        case .collection: return "Nested data collection"
        case .image: return "Image upload and display"
        case .unknown: return "Unknown field type"
        }
    }
    
    var needsOptions: Bool {
        return self == .dropdown || self == .multiSelect
    }
    
    var supportsMultiple: Bool {
        return self == .image || self == .multiSelect
    }
}

enum FormTemplate: CaseIterable {
    case custom
    case allFieldTypes
    case mathFormulas
    case stringFormulas
    case arrayFormulas
    case logicalFormulas
    case referenceResolution
    case dateFormulas
    case conversionFormulas
    case table

    var displayName: String {
        switch self {
        case .custom: return "🔧 Custom"
        case .allFieldTypes: return "📋 All Field Types"
        case .mathFormulas: return "🧮 Math Formulas"
        case .stringFormulas: return "📝 String Formulas"
        case .arrayFormulas: return "📊 Array Formulas"
        case .logicalFormulas: return "🔀 Logical Formulas"
        case .referenceResolution: return "🔗 Advanced References"
        case .dateFormulas: return "📅 Date Formulas"
        case .conversionFormulas: return "🔄 Type Conversion"
        case .table: return "📋 Table field"
        }
    }
    
    var systemImage: String {
        switch self {
        case .custom: return "doc.text.fill"
        case .allFieldTypes: return "square.grid.3x3"
        case .mathFormulas: return "function"
        case .stringFormulas: return "text.alignleft"
        case .arrayFormulas: return "rectangle.3.group.fill"
        case .logicalFormulas: return "brain.head.profile"
        case .referenceResolution: return "link"
        case .dateFormulas: return "calendar"
        case .conversionFormulas: return "arrow.left.arrow.right"
        case .table: return "square.grid.3x3"
        }
    }
    
    var description: String {
        switch self {
        case .custom: return "Start from scratch or keep current form"
        case .allFieldTypes: return "Showcase of all available field types"
        case .mathFormulas: return "Basic math operations, calculations, and functions"
        case .stringFormulas: return "Text manipulation, concatenation, and validation"
        case .arrayFormulas: return "Array operations with lambda functions"
        case .logicalFormulas: return "Conditional logic, boolean operations"
        case .referenceResolution: return "Dynamic references, object properties, array indexing"
        case .dateFormulas: return "Date calculations and manipulations"
        case .conversionFormulas: return "Type conversions and data transformations"
        case .table: return "Table referance resolution"
        }
    }
}

struct AddFieldView: View {
    @Environment(\.dismiss) var dismiss
    @State private var identifier = ""
    @State private var label = ""
    @State private var fieldType: FieldTypes = .text
    @State private var value = ""
    @State private var formulaRef = ""
    @State private var useFormula = false
    @State private var formulaKey = "value"
    @State private var tableColumns: [FieldTableColumn] = []
    @State private var showingAddColumn = false
    @State private var editingColumn: FieldTableColumn? = nil
    @State private var editingColumnIndex: Int? = nil
    @State private var showingEditColumn = false

    let editingField: BuilderField?
    let formulas: [BuilderFormula]
    let onAdd: (BuilderField) -> Void
    
    init(editingField: BuilderField? = nil, formulas: [BuilderFormula] = [], onAdd: @escaping (BuilderField) -> Void) {
        self.editingField = editingField
        self.formulas = formulas
        self.onAdd = onAdd
        
        if let field = editingField {
            _identifier = State(initialValue: field.id)
            _label = State(initialValue: field.label)
            _fieldType = State(initialValue: field.fieldType)
            _value = State(initialValue: field.value)
            _formulaRef = State(initialValue: field.formulaRef ?? "")
            _useFormula = State(initialValue: field.formulaRef != nil)
            _formulaKey = State(initialValue: field.formulaKey)
            _tableColumns = State(initialValue: field.tableColumns)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: fieldTypeIcon)
                                .foregroundColor(fieldTypeColor)
                                .font(.title2)
                                .frame(width: 32, height: 32)
                                .background(fieldTypeColor.opacity(0.15))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(editingField == nil ? "New Field" : "Edit Field")
                                
                                Text("Configure your form field")
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Field Details Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("Field Details")
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("_id")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                TextField("e.g., firstName (optional)", text: $identifier)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                
                                Text("Optional - Auto-generated from label if empty")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Label")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                TextField("e.g., First Name", text: $label)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Field Type")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Menu {
                                    ForEach(FieldTypes.allCases, id: \.self) { type in
                                        Button(action: { 
                                            fieldType = type
                                            // Reset value when changing field type
                                            if !useFormula {
                                                value = defaultValueForFieldType(type)
                                            }
                                        }) {
                                            VStack(alignment: .leading) {
                                                Label(type.displayName, systemImage: type.systemImage)
                                                Text(type.description)
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: fieldType.systemImage)
                                            .foregroundColor(fieldType.color)
                                        VStack(alignment: .leading) {
                                            Text(fieldType.displayName)
                                            Text(fieldType.description)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    
                    // Value Configuration Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: useFormula ? "link" : "pencil.line")
                                .foregroundColor(useFormula ? .green : .orange)
                            Text("Value Configuration")
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            HStack {
                                Toggle("Use Formula", isOn: $useFormula)
                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                            }
                            
                            if useFormula {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Formula Reference ID")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    Menu {
                                        if formulas.isEmpty {
                                            Button("No formulas available") { }
                                                .disabled(true)
                                        } else {
                                            ForEach(formulas, id: \.id) { formula in
                                                Button(action: { formulaRef = formula.id }) {
                                                    HStack {
                                                        Image(systemName: "function")
                                                            .foregroundColor(.purple)
                                                        Text(formula.id)
                                                        Spacer()
                                                        Text(formula.formula.count > 20 ? String(formula.formula.prefix(20)) + "..." : formula.formula)
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "function")
                                                .foregroundColor(formulaRef.isEmpty ? .secondary : .purple)
                                            Text(formulaRef.isEmpty ? "Select formula" : formulaRef)
                                                .foregroundColor(formulaRef.isEmpty ? .secondary : .primary)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.secondary)
                                                .font(.caption)
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                    }
                                    .disabled(formulas.isEmpty)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Formula Key")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    TextField("value", text: $formulaKey)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    
                    // Table Columns Section (for table fields)
                    if fieldType == .table {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "tablecells")
                                    .foregroundColor(.mint)
                                Text("Table Columns")
                                
                                Spacer()
                                
                                Button(action: { showingAddColumn = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title3)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            if tableColumns.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "tablecells")
                                        .font(.system(size: 32))
                                        .foregroundColor(.secondary)
                                    
                                    Text("No Columns Yet")
                                        .foregroundColor(.secondary)
                                    
                                    Text("Add columns to define your table structure")
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                }
                                .padding(.vertical, 24)
                                .frame(maxWidth: .infinity)
                            } else {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(Array(tableColumns.enumerated()), id: \.offset) { index, column in
                                        TableColumnCardView(column: column)
                                            .onTapGesture {
                                                editingColumn = column
                                                editingColumnIndex = index
                                                showingEditColumn = true
                                            }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 16)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 16)
                    }
                    
                    Spacer(minLength: 32)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editingField == nil ? "Add" : "Save") {
                        // Auto-generate identifier if empty
                        let finalIdentifier = identifier.isEmpty ? generateIdentifier(from: label) : identifier
                        
                        let field = BuilderField(
                            id: finalIdentifier,
                            label: label,
                            fieldType: fieldType,
                            value: value,
                            formulaRef: useFormula ? formulaRef : nil,
                            formulaKey: formulaKey,
                            tableColumns: tableColumns
                        )
                        onAdd(field)
                        dismiss()
                    }
                    .disabled(label.isEmpty)
                    .foregroundColor(label.isEmpty ? .gray : .blue)
                }
            }
            .sheet(isPresented: $showingAddColumn) {
                AddColumnView { column in
                    tableColumns.append(column)
                }
            }
            .sheet(isPresented: $showingEditColumn) {
                if let editingColumn = editingColumn {
                    AddColumnView(editingColumn: editingColumn) { updatedColumn in
                        if let index = tableColumns.firstIndex(where: { 
                            ($0.id == editingColumn.id) && ($0.title == editingColumn.title)
                        }) {
                            tableColumns[index] = updatedColumn
                        }
                        self.editingColumn = nil
                        showingEditColumn = false
                    }
                }
            }
        }
    }
    
    private var fieldTypeIcon: String {
        return fieldType.systemImage
    }
    
    private var fieldTypeColor: Color {
        return fieldType.color
    }
    
    private func defaultValueForFieldType(_ type: FieldTypes) -> String {
        switch type {
        case .text, .textarea, .richText:
            return ""
        case .number:
            return "0"
        case .multiSelect:
            return "false"
        case .dropdown:
            return ""
        case .date:
            return Date().formatted(date: .abbreviated, time: .omitted)
        default:
            return ""
        }
    }
    
    private func generateIdentifier(from label: String) -> String {
        // Convert label to camelCase identifier
        let words = label.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        
        guard !words.isEmpty else { return "field" }
        
        let camelCase = words.enumerated().map { index, word in
            if index == 0 {
                return word.lowercased()
            } else {
                return word.capitalized
            }
        }.joined()
        
        return camelCase.isEmpty ? "field" : camelCase
    }
}

struct AddFormulaView: View {
    @Environment(\.dismiss) var dismiss
    @State private var identifier = ""
    @State private var formula = ""
    @State private var selectedTemplate = FormulaTemplate.custom
    
    let editingFormula: BuilderFormula?
    let onAdd: (BuilderFormula) -> Void
    
    init(editingFormula: BuilderFormula? = nil, onAdd: @escaping (BuilderFormula) -> Void) {
        self.editingFormula = editingFormula
        self.onAdd = onAdd
        
        if let formula = editingFormula {
            _identifier = State(initialValue: formula.id)
            _formula = State(initialValue: formula.formula)
            _selectedTemplate = State(initialValue: .custom)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "function")
                                .foregroundColor(.purple)
                                .font(.title2)
                                .frame(width: 32, height: 32)
                                .background(Color.purple.opacity(0.15))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(editingFormula == nil ? "New Formula" : "Edit Formula")
                                
                                Text("Create powerful calculations")
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Formula Details Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("Formula Details")
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Formula ID")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                TextField("e.g., calculateTotal", text: $identifier)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Template")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Menu {
                                    ForEach(FormulaTemplate.allCases, id: \.self) { template in
                                        Button(action: {
                                            selectedTemplate = template
                                            formula = template.formulaText
                                        }) {
                                            Text(template.displayName)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "doc.text")
                                            .foregroundColor(.purple)
                                        Text(selectedTemplate.displayName)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    
                    // Formula Expression Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "curlybraces")
                                .foregroundColor(.green)
                            Text("Formula Expression")
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Expression")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                ZStack(alignment: .topLeading) {
                                    if #available(iOS 16.0, *) {
                                        TextField("Enter your formula", text: $formula, axis: .vertical)
                                            .lineLimit(3...6)
                                            .font(.system(.body, design: .monospaced))
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(12)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                    } else {
                                        TextEditor(text: $formula)
                                            .font(.system(.body, design: .monospaced))
                                            .frame(minHeight: 80)
                                            .padding(8)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            
                            // Examples Section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    Text("Examples")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    FormulaExampleView(
                                        title: "Field Reference",
                                        example: "field1 + field2",
                                        description: "Reference other fields"
                                    )
                                    
                                    FormulaExampleView(
                                        title: "Conditional Logic",
                                        example: "if(num1 > 10, \"Valid\", \"Invalid\")",
                                        description: "Add conditional statements"
                                    )
                                    
                                    FormulaExampleView(
                                        title: "String Concatenation",
                                        example: "concat(firstName, \" \", lastName)",
                                        description: "Combine text values"
                                    )
                                    
                                    FormulaExampleView(
                                        title: "Array Operations",
                                        example: "map(numbers, (item) → item * 2)",
                                        description: "Transform array data"
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    
                    Spacer(minLength: 32)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editingFormula == nil ? "Add" : "Save") {
                        let newFormula = BuilderFormula(
                            id: identifier,
                            formula: formula
                        )
                        onAdd(newFormula)
                        dismiss()
                    }
                    .disabled(identifier.isEmpty || formula.isEmpty)
                    .foregroundColor(identifier.isEmpty || formula.isEmpty ? .gray : .blue)
                }
            }
        }
    }
}

enum FormulaTemplate: CaseIterable {
    case custom
    case addition
    case conditional
    case concatenation
    case validation
    case arrayOperation
    case dateCalculation
    case stringManipulation
    
    var displayName: String {
        switch self {
        case .custom: return "Custom"
        case .addition: return "Addition"
        case .conditional: return "Conditional"
        case .concatenation: return "Concatenation"
        case .validation: return "Validation"
        case .arrayOperation: return "Array Operation"
        case .dateCalculation: return "Date Calculation"
        case .stringManipulation: return "String Manipulation"
        }
    }
    
    var formulaText: String {
        switch self {
        case .custom: return ""
        case .addition: return "field1 + field2"
        case .conditional: return "if(condition, \"True\", \"False\")"
        case .concatenation: return "concat(field1, \" \", field2)"
        case .validation: return "if(value > 0, \"Valid\", \"Invalid\")"
        case .arrayOperation: return "sum(arrayField)"
        case .dateCalculation: return "dateAdd(dateField, 7, \"days\")"
        case .stringManipulation: return "upper(textField)"
        }
    }
}

// MARK: - Card Views

struct FormulaCardView: View {
    let formula: BuilderFormula
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "function")
                    .foregroundColor(.purple)
                    .font(.title3)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(formula.id)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Formula")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Expression")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(formula.formula)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .contentShape(Rectangle())
    }
}

struct FieldCardView: View {
    let field: BuilderField
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                
                Image(systemName: fieldTypeIcon)
                    .foregroundColor(fieldTypeColor)
                    .font(.title3)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(field.label)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Text(field.fieldType.displayName)
                            .font(.caption)
                            .foregroundColor(fieldTypeColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(fieldTypeColor.opacity(0.15))
                            .cornerRadius(6)
                        
                        Text("ID: \(field.id)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // No buttons needed - entire cell is tappable
            }
            
            VStack(alignment: .leading, spacing: 8) {
                if let formulaRef = field.formulaRef {
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(.green)
                            .font(.caption)
                        
                        Text("Linked to formula: \(formulaRef)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                } else {
                    HStack {
                        Image(systemName: "pencil.line")
                            .foregroundColor(.orange)
                            .font(.caption)
                        
                        Text("Default value: \(field.value.isEmpty ? "None" : field.value)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .contentShape(Rectangle())
    }
    
    private var fieldTypeIcon: String {
        return field.fieldType.systemImage
    }
    
    private var fieldTypeColor: Color {
        return field.fieldType.color
    }
}

struct FormulaExampleView: View {
    let title: String
    let example: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                Text(example)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(6)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(8)
    }
}

#Preview {
    FormBuilderView()
} 

// MARK: - Table Configuration Views

struct TableColumnCardView: View {
    let column: FieldTableColumn

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: (column.type ?? .text).systemImage)
                    .foregroundColor((column.type ?? .text).color)
                    .font(.title3)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(column.title.isEmpty ? "Untitled Column" : column.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Text((column.type ?? .text).displayName)
                            .font(.caption)
                            .foregroundColor((column.type ?? .text).color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background((column.type ?? .text).color.opacity(0.15))
                            .cornerRadius(6)
                        
                        if column.required == true {
                            Text("Required")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
                
                Text("W: \(column.width ?? 150)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if (column.type ?? .text).needsOptions && !(column.options?.isEmpty ?? true) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Options")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(Array((column.options?.prefix(3) ?? []).enumerated()), id: \.offset) { index, option in
                                Text(option.value ?? "")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(4)
                            }
                            if (column.options?.count ?? 0) > 3 {
                                Text("+\((column.options?.count ?? 0) - 3)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

struct AddColumnView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var identifier = ""
    @State private var columnType: ColumnTypes = .text
    @State private var defaultValue = ""
    @State private var width: Int = 150
    @State private var required = false
    @State private var maxImageWidth: Double = 100
    @State private var maxImageHeight: Double = 60
    @State private var options: [Option] = []
    
    let editingColumn: FieldTableColumn?
    let onAdd: (FieldTableColumn) -> Void
    
    init(editingColumn: FieldTableColumn? = nil, onAdd: @escaping (FieldTableColumn) -> Void) {
        self.editingColumn = editingColumn
        self.onAdd = onAdd
        
        if let column = editingColumn {
            _title = State(initialValue: column.title)
            _identifier = State(initialValue: column.identifier ?? "")
            _columnType = State(initialValue: column.type ?? .text)
            _defaultValue = State(initialValue: "")
            _width = State(initialValue: column.width ?? 150)
            _required = State(initialValue: column.required ?? false)
            _options = State(initialValue: column.options ?? [])
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    AddColumnHeaderView(editingColumn: editingColumn)
                    AddColumnDetailsView(
                        title: $title,
                        columnType: $columnType,
                        width: $width,
                        required: $required
                    )
                    
                    if columnType.needsOptions {
                        AddColumnOptionsView(
                            columnType: columnType,
                            options: $options,
                            addOption: addOption
                        )
                    }
                    
                    if columnType == .image {
                        AddColumnImageSettingsView(
                            maxImageWidth: $maxImageWidth,
                            maxImageHeight: $maxImageHeight
                        )
                    }
                    
                    Spacer(minLength: 32)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editingColumn == nil ? "Add" : "Save") {
                        saveColumn()
                    }
                    .disabled(title.isEmpty)
                    .foregroundColor(title.isEmpty ? .gray : .blue)
                }
            }
        }
    }
    
    private func addOption() {
        var option = Option()
        option.id = UUID().uuidString
        options.append(option)
    }
    
    private func saveColumn() {
        let finalIdentifier = identifier.isEmpty ? generateColumnIdentifier(from: title) : identifier
        
        var column = FieldTableColumn()
        column.id = UUID().uuidString
        column.identifier = finalIdentifier
        column.title = title
        column.type = columnType
        column.options = columnType.needsOptions ? options.filter { !(($0.value ?? "").isEmpty) } : nil
        column.width = width
        column.required = required
        
        onAdd(column)
        dismiss()
    }
    
    private func generateColumnIdentifier(from title: String) -> String {
        let words = title.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        
        guard !words.isEmpty else { return "column" }
        
        let camelCase = words.enumerated().map { index, word in
            if index == 0 {
                return word.lowercased()
            } else {
                return word.capitalized
            }
        }.joined()
        
        return camelCase.isEmpty ? "column" : camelCase
    }
}

// MARK: - AddColumn Subviews

struct AddColumnHeaderView: View {
    let editingColumn: JoyfillModel.FieldTableColumn?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "tablecells.fill")
                    .foregroundColor(.mint)
                    .font(.title2)
                    .frame(width: 32, height: 32)
                    .background(Color.mint.opacity(0.15))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(editingColumn == nil ? "New Column" : "Edit Column")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Configure table column")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}

struct AddColumnDetailsView: View {
    @Binding var title: String
    @Binding var columnType: ColumnTypes
    @Binding var width: Int
    @Binding var required: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Column Details")
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    TextField("e.g., Product Name", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Column Type")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Menu {
                        ForEach(ColumnTypes.tableColumnTypes, id: \.self) { type in
                            Button(action: {
                                columnType = type
                            }) {
                                Label(type.displayName, systemImage: type.systemImage)
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: columnType.systemImage)
                                .foregroundColor(columnType.color)
                            Text(columnType.displayName)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Width")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Slider(value: Binding(
                                get: { Double(width) },
                                set: { width = Int($0) }
                            ), in: 100...400, step: 10) {
                                Text("Width")
                            }
                            Text("\(width)px")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 40)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Required")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Toggle("", isOn: $required)
                            .toggleStyle(SwitchToggleStyle(tint: .red))
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
}

struct AddColumnOptionsView: View {
    let columnType: ColumnTypes
    @Binding var options: [Option]
    let addOption: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(.orange)
                Text("Options")
                
                Spacer()
                
                Button(action: addOption) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            .padding(.horizontal, 20)
            
            if options.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                    
                    Text("No Options Yet")
                        .foregroundColor(.secondary)
                    
                    Text("Add options for this column")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(options.indices, id: \.self) { index in
                        HStack {
                            TextField("Option \(index + 1)", text: Binding(
                                get: { options[index].value ?? "" },
                                set: { options[index].value = $0 }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: {
                                options.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
}

struct AddColumnImageSettingsView: View {
    @Binding var maxImageWidth: Double
    @Binding var maxImageHeight: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "photo")
                    .foregroundColor(.indigo)
                Text("Image Settings")
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Max Width: \(Int(maxImageWidth))px")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Slider(value: $maxImageWidth, in: 50...300, step: 10)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Max Height: \(Int(maxImageHeight))px")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Slider(value: $maxImageHeight, in: 50...200, step: 10)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
}

// Supported column types (all except table and unknown)
extension ColumnTypes {
    static var tableColumnTypes: [ColumnTypes] {
        return allCases.filter { $0 != .table && $0 != .unknown }
    }
}

// Extension to add UI properties to ColumnTypes from JoyfillModel
extension ColumnTypes: CaseIterable {
    public static var allCases: [ColumnTypes] {
        return [.text, .dropdown, .image, .block, .date, .number, .multiSelect, .progress, .barcode, .signature]
    }
    
    var displayName: String {
        switch self {
        case .text: return "Text"
        case .dropdown: return "Dropdown"
        case .image: return "Image"
        case .block: return "Block/Label"
        case .date: return "Date"
        case .number: return "Number"
        case .multiSelect: return "Multi Select"
        case .progress: return "Progress"
        case .barcode: return "Barcode"
        case .table: return "Table"
        case .signature: return "Signature"
        case .unknown: return "Unknown"
        }
    }
    
    var systemImage: String {
        switch self {
        case .text: return "textformat"
        case .dropdown: return "list.bullet"
        case .image: return "photo"
        case .block: return "cube"
        case .date: return "calendar"
        case .number: return "number"
        case .multiSelect: return "checkmark.square"
        case .progress: return "chart.bar.fill"
        case .barcode: return "barcode"
        case .table: return "tablecells"
        case .signature: return "signature"
        case .unknown: return "questionmark"
        }
    }
    
    var color: Color {
        switch self {
        case .text: return .blue
        case .dropdown: return .orange
        case .image: return .yellow
        case .block: return .gray
        case .date: return .red
        case .number: return .green
        case .multiSelect: return .purple
        case .progress: return .pink
        case .barcode: return .brown
        case .table: return .mint
        case .signature: return .indigo
        case .unknown: return .secondary
        }
    }
    
    var description: String {
        switch self {
        case .text: return "Single line text input"
        case .dropdown: return "Single selection dropdown"
        case .image: return "Image upload and display"
        case .block: return "Static text or label"
        case .date: return "Date and time picker"
        case .number: return "Numeric input field"
        case .multiSelect: return "Multiple selection options"
        case .progress: return "Progress indicator"
        case .barcode: return "Barcode scanner/display"
        case .table: return "Nested table (not supported in columns)"
        case .signature: return "Digital signature capture"
        case .unknown: return "Unknown column type"
        }
    }
    
    var needsOptions: Bool {
        return self == .dropdown || self == .multiSelect
    }
}

extension Option {
    init(_ option: String) {
        self.init()
        value = option
        id = UUID().uuidString
    }
}
