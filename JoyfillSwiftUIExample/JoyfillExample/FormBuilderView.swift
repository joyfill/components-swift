import SwiftUI
import JoyfillModel
import Joyfill
import JoyfillFormulas

struct FormBuilderView: View {
    @State private var fields: [BuilderField] = []
    @State private var formulas: [BuilderFormula] = []
    @State private var showingPreview = false
    @State private var showingAddField = false
    @State private var showingAddFormula = false
    @State private var builtDocument: JoyDoc?
    @State private var documentEditor: DocumentEditor?
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section("Formulas") {
                        ForEach(formulas) { formula in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(formula.identifier)
                                        .font(.headline)
                                    Text(formula.formula)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                Button("Delete") {
                                    deleteFormula(formula)
                                }
                                .foregroundColor(.red)
                                .font(.caption)
                            }
                            .padding(.vertical, 2)
                        }
                        
                        Button("Add Formula") {
                            showingAddFormula = true
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Section("Fields") {
                        ForEach(fields) { field in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(field.label)
                                        .font(.headline)
                                    HStack {
                                        Text(field.fieldType.rawValue)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(4)
                                        
                                        Text("ID: \(field.identifier)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        if let formulaRef = field.formulaRef {
                                            Text("Formula: \(formulaRef)")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                Button("Delete") {
                                    deleteField(field)
                                }
                                .foregroundColor(.red)
                                .font(.caption)
                            }
                            .padding(.vertical, 2)
                        }
                        
                        Button("Add Field") {
                            showingAddField = true
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                HStack {
                    Button("Clear All") {
                        fields.removeAll()
                        formulas.removeAll()
                    }
                    .foregroundColor(.red)
                    
                    Spacer()
                    
                    Button("Test Form") {
                        buildAndPreviewForm()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(fields.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(8)
                    .disabled(fields.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Form Builder")
            .sheet(isPresented: $showingAddField) {
                AddFieldView { field in
                    fields.append(field)
                }
            }
            .sheet(isPresented: $showingAddFormula) {
                AddFormulaView { formula in
                    formulas.append(formula)
                }
            }
            .sheet(isPresented: $showingPreview) {
                if let documentEditor = documentEditor {
                    NavigationView {
                        Form(documentEditor: documentEditor)
                            .navigationTitle("Form Preview")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarItems(trailing: Button("Done") {
                                showingPreview = false
                            })
                    }
                }
            }
            .onAppear {
                loadSampleData()
            }
        }
    }
    
    private func deleteField(_ field: BuilderField) {
        fields.removeAll { $0.id == field.id }
    }
    
    private func deleteFormula(_ formula: BuilderFormula) {
        formulas.removeAll { $0.id == formula.id }
        // Also remove formula references from fields
        for index in fields.indices {
            if fields[index].formulaRef == formula.identifier {
                fields[index].formulaRef = nil
            }
        }
    }
    
    private func buildAndPreviewForm() {
        var document = JoyDoc.addDocument()
        
        // Add all formulas first
        for formula in formulas {
            document = document.addFormula(id: formula.identifier, formula: formula.formula)
        }
        
        // Add all fields
        for field in fields {
            switch field.fieldType {
            case .text:
                if let formulaRef = field.formulaRef {
                    document = document.addTextField(
                        identifier: field.identifier,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey,
                        label: field.label
                    )
                } else {
                    document = document.addTextField(
                        identifier: field.identifier,
                        value: field.value,
                        label: field.label
                    )
                }
                
            case .number:
                if let formulaRef = field.formulaRef {
                    document = document.addNumberField(
                        identifier: field.identifier,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey,
                        label: field.label
                    )
                } else {
                    let numberValue = Double(field.value) ?? 0
                    document = document.addNumberField(
                        identifier: field.identifier,
                        value: numberValue,
                        label: field.label
                    )
                }
                
            case .checkbox:
                if let formulaRef = field.formulaRef {
                    document = document.addCheckboxField(
                        identifier: field.identifier,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey,
                        label: field.label
                    )
                } else {
                    let boolValue = field.value.lowercased() == "true"
                    document = document.addCheckboxField(
                        identifier: field.identifier,
                        value: boolValue,
                        label: field.label
                    )
                }
                
            case .date:
                if let formulaRef = field.formulaRef {
                    document = document.addDateField(
                        identifier: field.identifier,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey,
                        label: field.label
                    )
                } else {
                    document = document.addDateField(
                        identifier: field.identifier,
                        value: Date(),
                        label: field.label
                    )
                }
                
            case .option:
                let options = field.value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                if let formulaRef = field.formulaRef {
                    document = document.addOptionField(
                        identifier: field.identifier,
                        formulaRef: formulaRef,
                        formulaKey: field.formulaKey,
                        options: options,
                        label: field.label
                    )
                } else {
                    document = document.addOptionField(
                        identifier: field.identifier,
                        value: [options.first ?? ""],
                        options: options,
                        label: field.label
                    )
                }
            }
        }
        
        builtDocument = document
        documentEditor = DocumentEditor(document: document)
        showingPreview = true
    }
    
    private func loadSampleData() {
        // Load a sample form to demonstrate
        formulas = [
            BuilderFormula(identifier: "calc1", formula: "{num1} + {num2}"),
            BuilderFormula(identifier: "validation1", formula: "if({num1} > 10, \"Valid\", \"Too small\")")
        ]
        
        fields = [
            BuilderField(identifier: "num1", label: "First Number", fieldType: .number, value: "5"),
            BuilderField(identifier: "num2", label: "Second Number", fieldType: .number, value: "15"),
            BuilderField(identifier: "result", label: "Sum Result", fieldType: .number, formulaRef: "calc1"),
            BuilderField(identifier: "status", label: "Validation Status", fieldType: .text, formulaRef: "validation1")
        ]
    }
}

struct BuilderField: Identifiable {
    let id = UUID()
    var identifier: String
    var label: String
    var fieldType: FieldType
    var value: String = ""
    var formulaRef: String? = nil
    var formulaKey: String = "value"
}

struct BuilderFormula: Identifiable {
    let id = UUID()
    var identifier: String
    var formula: String
}

enum FieldType: String, CaseIterable {
    case text = "Text"
    case number = "Number"
    case checkbox = "Checkbox"
    case option = "Option"
    case date = "Date"
}

struct AddFieldView: View {
    @Environment(\.dismiss) var dismiss
    @State private var identifier = ""
    @State private var label = ""
    @State private var fieldType: FieldType = .text
    @State private var value = ""
    @State private var formulaRef = ""
    @State private var useFormula = false
    @State private var formulaKey = "value"
    
    let onAdd: (BuilderField) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Field Details") {
                    TextField("Identifier", text: $identifier)
                        .autocapitalization(.none)
                    TextField("Label", text: $label)
                    
                    Picker("Field Type", selection: $fieldType) {
                        ForEach(FieldType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section("Value or Formula") {
                    Toggle("Use Formula", isOn: $useFormula)
                    
                    if useFormula {
                        TextField("Formula Reference ID", text: $formulaRef)
                            .autocapitalization(.none)
                        TextField("Formula Key", text: $formulaKey)
                            .autocapitalization(.none)
                    } else {
                        switch fieldType {
                        case .text:
                            TextField("Default Value", text: $value)
                        case .number:
                            TextField("Default Value (number)", text: $value)
                                .keyboardType(.numberPad)
                        case .checkbox:
                            Picker("Default Value", selection: $value) {
                                Text("False").tag("false")
                                Text("True").tag("true")
                            }
                        case .option:
                            TextField("Options (comma separated)", text: $value)
                            Text("Example: apple,banana,cherry")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        case .date:
                            Text("Default: Current Date")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Add Field")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Add") {
                    let field = BuilderField(
                        identifier: identifier,
                        label: label,
                        fieldType: fieldType,
                        value: value,
                        formulaRef: useFormula ? formulaRef : nil,
                        formulaKey: formulaKey
                    )
                    onAdd(field)
                    dismiss()
                }
                .disabled(identifier.isEmpty || label.isEmpty)
            )
        }
    }
}

struct AddFormulaView: View {
    @Environment(\.dismiss) var dismiss
    @State private var identifier = ""
    @State private var formula = ""
    @State private var selectedTemplate = FormulaTemplate.custom
    
    let onAdd: (BuilderFormula) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Formula Details") {
                    TextField("Formula ID", text: $identifier)
                        .autocapitalization(.none)
                    
                    Picker("Template", selection: $selectedTemplate) {
                        ForEach(FormulaTemplate.allCases, id: \.self) { template in
                            Text(template.displayName).tag(template)
                        }
                    }
                    .onChange(of: selectedTemplate) { newValue in
                        formula = newValue.formulaText
                    }
                }
                
                Section("Formula") {
                    if #available(iOS 16.0, *) {
                        TextField("Formula", text: $formula, axis: .vertical)
                            .lineLimit(3...6)
                            .autocapitalization(.none)
                            .font(.system(.body, design: .monospaced))
                    } else {
                        // Fallback on earlier versions
                    }
                    
                    Text("Examples:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("• {field1} + {field2}")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("• if({num1} > 10, \"Valid\", \"Invalid\")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("• concat({firstName}, \" \", {lastName})")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Add Formula")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Add") {
                    let newFormula = BuilderFormula(
                        identifier: identifier,
                        formula: formula
                    )
                    onAdd(newFormula)
                    dismiss()
                }
                .disabled(identifier.isEmpty || formula.isEmpty)
            )
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
        case .addition: return "{field1} + {field2}"
        case .conditional: return "if({condition}, \"True\", \"False\")"
        case .concatenation: return "concat({field1}, \" \", {field2})"
        case .validation: return "if({value} > 0, \"Valid\", \"Invalid\")"
        case .arrayOperation: return "sum({arrayField})"
        case .dateCalculation: return "dateAdd({dateField}, 7, \"days\")"
        case .stringManipulation: return "upper({textField})"
        }
    }
}

#Preview {
    FormBuilderView()
} 
