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
    @State private var showingEditField = false
    @State private var showingEditFormula = false
    @State private var editingField: BuilderField?
    @State private var editingFormula: BuilderFormula?
    @State private var builtDocument: JoyDoc?
    @State private var documentEditor: DocumentEditor?
    @State private var selectedTemplate: FormTemplate = .mathFormulas
    
    var body: some View {
        NavigationView {
            VStack {
                // Template Picker Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("📋 Load Template")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Picker("Select Template", selection: $selectedTemplate) {
                        ForEach(FormTemplate.allCases, id: \.self) { template in
                            Text(template.displayName).tag(template)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                    .onChange(of: selectedTemplate) { newValue in
                        if newValue != .custom {
                            loadTemplate(newValue)
                        }
                    }
                    
                    if selectedTemplate != .custom {
                        Text(selectedTemplate.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.bottom, 4)
                    }
                    
                    Divider()
                        .padding(.horizontal)
                }
                
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
                                
                                Text("✏️")
                                    .font(.caption)
                                    .foregroundColor(.blue.opacity(0.7))
                                
                                Button("Edit") {
                                    editingFormula = formula
                                    showingEditFormula = true
                                }
                                .foregroundColor(.blue)
                                .font(.caption)
                                
                                Button("Delete") {
                                    deleteFormula(formula)
                                }
                                .foregroundColor(.red)
                                .font(.caption)
                            }
                            .padding(.vertical, 2)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingFormula = formula
                                showingEditFormula = true
                            }
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
                                
                                Text("✏️")
                                    .font(.caption)
                                    .foregroundColor(.blue.opacity(0.7))
                                
                                Button("Edit") {
                                    editingField = field
                                    showingEditField = true
                                }
                                .foregroundColor(.blue)
                                
                                Button("Delete") {
                                    deleteField(field)
                                }
                                .foregroundColor(.red)
                                .font(.caption)
                            }
                            .padding(.vertical, 2)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingField = field
                                showingEditField = true
                            }
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
                AddFieldView(editingField: nil) { field in
                    fields.append(field)
                }
            }
            .sheet(isPresented: $showingAddFormula) {
                AddFormulaView(editingFormula: nil) { formula in
                    formulas.append(formula)
                }
            }
            .sheet(isPresented: $showingEditField) {
                if let editingField = editingField {
                    AddFieldView(editingField: editingField) { updatedField in
                        if let index = fields.firstIndex(where: { $0.id == editingField.id }) {
                            let oldIdentifier = editingField.identifier
                            let newIdentifier = updatedField.identifier
                            
                            // Update the field
                            fields[index] = updatedField
                            
                            // If identifier changed, update any formulas that reference it
                            if oldIdentifier != newIdentifier {
                                for formulaIndex in formulas.indices {
                                    let oldFormula = formulas[formulaIndex].formula
                                    let updatedFormula = oldFormula.replacingOccurrences(of: "{\(oldIdentifier)}", with: "{\(newIdentifier)}")
                                    if updatedFormula != oldFormula {
                                        formulas[formulaIndex].formula = updatedFormula
                                    }
                                }
                            }
                        }
                        self.editingField = nil
                    }
                }
            }
            .sheet(isPresented: $showingEditFormula) {
                if let editingFormula = editingFormula {
                    AddFormulaView(editingFormula: editingFormula) { updatedFormula in
                        if let index = formulas.firstIndex(where: { $0.id == editingFormula.id }) {
                            let oldIdentifier = editingFormula.identifier
                            let newIdentifier = updatedFormula.identifier
                            
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
                        self.editingFormula = nil
                    }
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
                loadTemplate(.mathFormulas) // Load basic math template by default
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
    
    private func loadTemplate(_ template: FormTemplate) {
        // Clear existing data
        fields.removeAll()
        formulas.removeAll()
        
        switch template {
        case .custom:
            // Keep current data as is
            break
            
        case .mathFormulas:
            // Math formulas template
            formulas = [
                BuilderFormula(identifier: "addition", formula: "{num1} + {num2}"),
                BuilderFormula(identifier: "multiplication", formula: "{num1} * {num2}"),
                BuilderFormula(identifier: "power", formula: "pow({base}, {exponent})"),
                BuilderFormula(identifier: "squareRoot", formula: "sqrt({number})"),
                BuilderFormula(identifier: "rounding", formula: "round({decimal}, {places})"),
                BuilderFormula(identifier: "percentage", formula: "({score} / {total}) * 100"),
                BuilderFormula(identifier: "average", formula: "({num1} + {num2} + {num3}) / 3")
            ]
            
            // Input fields
            let inputFields = [
                BuilderField(identifier: "num1", label: "First Number", fieldType: .number, value: "10"),
                BuilderField(identifier: "num2", label: "Second Number", fieldType: .number, value: "5"),
                BuilderField(identifier: "num3", label: "Third Number", fieldType: .number, value: "15"),
                BuilderField(identifier: "base", label: "Base", fieldType: .number, value: "2"),
                BuilderField(identifier: "exponent", label: "Exponent", fieldType: .number, value: "3"),
                BuilderField(identifier: "number", label: "Square Root Input", fieldType: .number, value: "16"),
                BuilderField(identifier: "decimal", label: "Decimal Number", fieldType: .number, value: "3.14159"),
                BuilderField(identifier: "places", label: "Decimal Places", fieldType: .number, value: "2"),
                BuilderField(identifier: "score", label: "Score", fieldType: .number, value: "85"),
                BuilderField(identifier: "total", label: "Total", fieldType: .number, value: "100")
            ]
            
            // Result fields
            let resultFields = [
                BuilderField(identifier: "sum", label: "Sum Result", fieldType: .number, formulaRef: "addition"),
                BuilderField(identifier: "product", label: "Product Result", fieldType: .number, formulaRef: "multiplication"),
                BuilderField(identifier: "powerResult", label: "Power Result", fieldType: .number, formulaRef: "power"),
                BuilderField(identifier: "sqrtResult", label: "Square Root", fieldType: .number, formulaRef: "squareRoot"),
                BuilderField(identifier: "roundResult", label: "Rounded Value", fieldType: .number, formulaRef: "rounding"),
                BuilderField(identifier: "percentResult", label: "Percentage", fieldType: .number, formulaRef: "percentage"),
                BuilderField(identifier: "avgResult", label: "Average", fieldType: .number, formulaRef: "average")
            ]
            
            fields = inputFields + resultFields
            
        case .stringFormulas:
            // String manipulation template
            formulas = [
                BuilderFormula(identifier: "fullName", formula: "concat({firstName}, \" \", {lastName})"),
                BuilderFormula(identifier: "upperCase", formula: "upper({text})"),
                BuilderFormula(identifier: "lowerCase", formula: "lower({text})"),
                BuilderFormula(identifier: "textLength", formula: "length({text})"),
                BuilderFormula(identifier: "containsCheck", formula: "contains({text}, {searchTerm})"),
                BuilderFormula(identifier: "emailValidation", formula: "if(and(contains({email}, \"@\"), contains({email}, \".\")), \"Valid\", \"Invalid\")"),
                BuilderFormula(identifier: "greeting", formula: "concat(\"Hello, \", {firstName}, \"! You have \", length({text}), \" characters.\")")
            ]
            
            fields = [
                BuilderField(identifier: "firstName", label: "First Name", fieldType: .text, value: "John"),
                BuilderField(identifier: "lastName", label: "Last Name", fieldType: .text, value: "Doe"),
                BuilderField(identifier: "text", label: "Sample Text", fieldType: .text, value: "Hello World"),
                BuilderField(identifier: "searchTerm", label: "Search Term", fieldType: .text, value: "Hello"),
                BuilderField(identifier: "email", label: "Email", fieldType: .text, value: "john@example.com"),
                BuilderField(identifier: "fullNameResult", label: "Full Name", fieldType: .text, formulaRef: "fullName"),
                BuilderField(identifier: "upperResult", label: "Uppercase", fieldType: .text, formulaRef: "upperCase"),
                BuilderField(identifier: "lowerResult", label: "Lowercase", fieldType: .text, formulaRef: "lowerCase"),
                BuilderField(identifier: "lengthResult", label: "Text Length", fieldType: .number, formulaRef: "textLength"),
                BuilderField(identifier: "containsResult", label: "Contains Check", fieldType: .text, formulaRef: "containsCheck"),
                BuilderField(identifier: "emailResult", label: "Email Valid", fieldType: .text, formulaRef: "emailValidation"),
                BuilderField(identifier: "greetingResult", label: "Greeting Message", fieldType: .text, formulaRef: "greeting")
            ]
            
        case .arrayFormulas:
            // Array operations template
            formulas = [
                BuilderFormula(identifier: "arraySum", formula: "sum({numbers})"),
                BuilderFormula(identifier: "arrayLength", formula: "length({fruits})"),
                BuilderFormula(identifier: "arrayMap", formula: "map({numbers}, (item) → item * 2)"),
                BuilderFormula(identifier: "arrayFilter", formula: "filter({numbers}, (item) → item > 5)"),
                BuilderFormula(identifier: "arrayFind", formula: "find({fruits}, (item) → contains(item, \"a\"))"),
                BuilderFormula(identifier: "arrayEvery", formula: "every({numbers}, (item) → item > 0)"),
                BuilderFormula(identifier: "arraySome", formula: "some({fruits}, (item) → contains(item, \"e\"))"),
                BuilderFormula(identifier: "arrayConcat", formula: "concat(\"Selected: \", {fruits})")
            ]
            
            fields = [
                BuilderField(identifier: "numbers", label: "Numbers Array", fieldType: .text, value: "[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]"),
                BuilderField(identifier: "fruits", label: "Fruits", fieldType: .option, value: "apple,banana,cherry,date,elderberry"),
                BuilderField(identifier: "sumResult", label: "Array Sum", fieldType: .number, formulaRef: "arraySum"),
                BuilderField(identifier: "lengthResult", label: "Array Length", fieldType: .number, formulaRef: "arrayLength"),
                BuilderField(identifier: "mapResult", label: "Doubled Numbers", fieldType: .text, formulaRef: "arrayMap"),
                BuilderField(identifier: "filterResult", label: "Numbers > 5", fieldType: .text, formulaRef: "arrayFilter"),
                BuilderField(identifier: "findResult", label: "First with 'a'", fieldType: .text, formulaRef: "arrayFind"),
                BuilderField(identifier: "everyResult", label: "All Positive", fieldType: .checkbox, formulaRef: "arrayEvery"),
                BuilderField(identifier: "someResult", label: "Some have 'e'", fieldType: .checkbox, formulaRef: "arraySome"),
                BuilderField(identifier: "concatResult", label: "Concatenated", fieldType: .text, formulaRef: "arrayConcat")
            ]
            
        case .logicalFormulas:
            // Logical operations template
            formulas = [
                BuilderFormula(identifier: "simpleIf", formula: "if({age} >= 18, \"Adult\", \"Minor\")"),
                BuilderFormula(identifier: "nestedIf", formula: "if({score} >= 90, \"A\", if({score} >= 80, \"B\", if({score} >= 70, \"C\", \"F\")))"),
                BuilderFormula(identifier: "andLogic", formula: "and({isActive}, {hasPermission})"),
                BuilderFormula(identifier: "orLogic", formula: "or({isVip}, {isPremium})"),
                BuilderFormula(identifier: "notLogic", formula: "not({isBlocked})"),
                BuilderFormula(identifier: "complexLogic", formula: "if(and({age} >= 18, or({hasLicense}, {hasPermit})), \"Can Drive\", \"Cannot Drive\")"),
                BuilderFormula(identifier: "emptyCheck", formula: "if(empty({optionalText}), \"No value provided\", {optionalText})")
            ]
            
            // Input fields
            let inputFields = [
                BuilderField(identifier: "age", label: "Age", fieldType: .number, value: "25"),
                BuilderField(identifier: "score", label: "Test Score", fieldType: .number, value: "85"),
                BuilderField(identifier: "isActive", label: "Is Active", fieldType: .checkbox, value: "true"),
                BuilderField(identifier: "hasPermission", label: "Has Permission", fieldType: .checkbox, value: "true"),
                BuilderField(identifier: "isVip", label: "Is VIP", fieldType: .checkbox, value: "false"),
                BuilderField(identifier: "isPremium", label: "Is Premium", fieldType: .checkbox, value: "true"),
                BuilderField(identifier: "isBlocked", label: "Is Blocked", fieldType: .checkbox, value: "false"),
                BuilderField(identifier: "hasLicense", label: "Has License", fieldType: .checkbox, value: "true"),
                BuilderField(identifier: "hasPermit", label: "Has Permit", fieldType: .checkbox, value: "false"),
                BuilderField(identifier: "optionalText", label: "Optional Text", fieldType: .text, value: "")
            ]
            
            // Result fields
            let resultFields = [
                BuilderField(identifier: "ageCategory", label: "Age Category", fieldType: .text, formulaRef: "simpleIf"),
                BuilderField(identifier: "grade", label: "Letter Grade", fieldType: .text, formulaRef: "nestedIf"),
                BuilderField(identifier: "accessGranted", label: "Access Granted", fieldType: .checkbox, formulaRef: "andLogic"),
                BuilderField(identifier: "specialMember", label: "Special Member", fieldType: .checkbox, formulaRef: "orLogic"),
                BuilderField(identifier: "canAccess", label: "Can Access", fieldType: .checkbox, formulaRef: "notLogic"),
                BuilderField(identifier: "drivingStatus", label: "Driving Status", fieldType: .text, formulaRef: "complexLogic"),
                BuilderField(identifier: "textStatus", label: "Text Status", fieldType: .text, formulaRef: "emptyCheck")
            ]
            
            fields = inputFields + resultFields
            
        case .referenceResolution:
            // Advanced reference resolution template
            formulas = [
                BuilderFormula(identifier: "arrayIndex", formula: "{fruits[{selectedIndex}]}"),
                BuilderFormula(identifier: "dynamicIndex", formula: "{matrix[{row}][{col}]}"),
                BuilderFormula(identifier: "objectProperty", formula: "{user.name}"),
                BuilderFormula(identifier: "nestedProperty", formula: "{user.address.city}"),
                BuilderFormula(identifier: "selfReference", formula: "self * 2"),
                BuilderFormula(identifier: "currentReference", formula: "current + 10"),
                BuilderFormula(identifier: "dynamicSum", formula: "{numbers[0]} + {numbers[1]} + {numbers[2]}"),
                BuilderFormula(identifier: "conditionalRef", formula: "if({useFirst}, {fruits[0]}, {fruits[1]})")
            ]
            
            // Input fields
            let inputFields = [
                BuilderField(identifier: "fruits", label: "Fruits Array", fieldType: .text, value: "[\"apple\", \"banana\", \"cherry\", \"date\"]"),
                BuilderField(identifier: "selectedIndex", label: "Selected Index", fieldType: .number, value: "2"),
                BuilderField(identifier: "matrix", label: "Matrix", fieldType: .text, value: "[[1, 2, 3], [4, 5, 6], [7, 8, 9]]"),
                BuilderField(identifier: "row", label: "Row Index", fieldType: .number, value: "1"),
                BuilderField(identifier: "col", label: "Column Index", fieldType: .number, value: "2"),
                BuilderField(identifier: "user", label: "User Object", fieldType: .text, value: "{\"name\": \"John\", \"address\": {\"city\": \"NYC\"}}"),
                BuilderField(identifier: "selfValue", label: "Self Value", fieldType: .number, value: "25"),
                BuilderField(identifier: "currentValue", label: "Current Value", fieldType: .number, value: "15"),
                BuilderField(identifier: "numbers", label: "Numbers", fieldType: .text, value: "[10, 20, 30]"),
                BuilderField(identifier: "useFirst", label: "Use First", fieldType: .checkbox, value: "true")
            ]
            
            // Result fields
            let resultFields = [
                BuilderField(identifier: "selectedFruit", label: "Selected Fruit", fieldType: .text, formulaRef: "arrayIndex"),
                BuilderField(identifier: "matrixValue", label: "Matrix Value", fieldType: .number, formulaRef: "dynamicIndex"),
                BuilderField(identifier: "userName", label: "User Name", fieldType: .text, formulaRef: "objectProperty"),
                BuilderField(identifier: "userCity", label: "User City", fieldType: .text, formulaRef: "nestedProperty"),
                BuilderField(identifier: "selfResult", label: "Self * 2", fieldType: .number, formulaRef: "selfReference"),
                BuilderField(identifier: "currentResult", label: "Current + 10", fieldType: .number, formulaRef: "currentReference"),
                BuilderField(identifier: "numbersSum", label: "Numbers Sum", fieldType: .number, formulaRef: "dynamicSum"),
                BuilderField(identifier: "conditionalResult", label: "Conditional Fruit", fieldType: .text, formulaRef: "conditionalRef")
            ]
            
            fields = inputFields + resultFields
            
        case .dateFormulas:
            // Date manipulation template  
            formulas = [
                BuilderFormula(identifier: "currentDate", formula: "now()"),
                BuilderFormula(identifier: "dateYear", formula: "year({birthDate})"),
                BuilderFormula(identifier: "dateMonth", formula: "month({birthDate})"),
                BuilderFormula(identifier: "dateDay", formula: "day({birthDate})"),
                BuilderFormula(identifier: "addDays", formula: "dateAdd({startDate}, {days}, \"days\")"),
                BuilderFormula(identifier: "addWeeks", formula: "dateAdd({startDate}, {weeks}, \"weeks\")"),
                BuilderFormula(identifier: "subtractDays", formula: "dateSubtract({endDate}, {days}, \"days\")"),
                BuilderFormula(identifier: "ageCalculation", formula: "round((now() - {birthDate}) / (365.25 * 24 * 60 * 60 * 1000))")
            ]
            
            let currentTime = Date().timeIntervalSince1970 * 1000
            let yearsAgo25 = -25 * 365.25 * 24 * 60 * 60
            let birthTime = Date().addingTimeInterval(yearsAgo25).timeIntervalSince1970 * 1000
            let daysToMilliseconds = 30 * 24 * 60 * 60 * 1000
            let endTime = currentTime + Double(daysToMilliseconds)
            
            fields = [
                BuilderField(identifier: "birthDate", label: "Birth Date", fieldType: .number, value: String(birthTime)),
                BuilderField(identifier: "startDate", label: "Start Date", fieldType: .number, value: String(currentTime)),
                BuilderField(identifier: "endDate", label: "End Date", fieldType: .number, value: String(endTime)),
                BuilderField(identifier: "days", label: "Days to Add", fieldType: .number, value: "7"),
                BuilderField(identifier: "weeks", label: "Weeks to Add", fieldType: .number, value: "2"),
                BuilderField(identifier: "currentDateResult", label: "Current Date", fieldType: .date, formulaRef: "currentDate"),
                BuilderField(identifier: "yearResult", label: "Birth Year", fieldType: .number, formulaRef: "dateYear"),
                BuilderField(identifier: "monthResult", label: "Birth Month", fieldType: .number, formulaRef: "dateMonth"),
                BuilderField(identifier: "dayResult", label: "Birth Day", fieldType: .number, formulaRef: "dateDay"),
                BuilderField(identifier: "addDaysResult", label: "Date + Days", fieldType: .date, formulaRef: "addDays"),
                BuilderField(identifier: "addWeeksResult", label: "Date + Weeks", fieldType: .date, formulaRef: "addWeeks"),
                BuilderField(identifier: "subtractResult", label: "Date - Days", fieldType: .date, formulaRef: "subtractDays"),
                BuilderField(identifier: "ageResult", label: "Calculated Age", fieldType: .number, formulaRef: "ageCalculation")
            ]
            
        case .conversionFormulas:
            // Type conversion template
            formulas = [
                BuilderFormula(identifier: "stringToNumber", formula: "toNumber({stringValue})"),
                BuilderFormula(identifier: "numberCalculation", formula: "toNumber({stringNum1}) + toNumber({stringNum2})"),
                BuilderFormula(identifier: "decimalConversion", formula: "toNumber({decimalString})"),
                BuilderFormula(identifier: "negativeConversion", formula: "toNumber({negativeString})"),
                BuilderFormula(identifier: "percentageCalc", formula: "(toNumber({numerator}) / toNumber({denominator})) * 100"),
                BuilderFormula(identifier: "roundedConversion", formula: "round(toNumber({floatString}), 2)"),
                BuilderFormula(identifier: "validationCheck", formula: "if(toNumber({inputValue}) > 0, \"Valid Number\", \"Invalid or Zero\")")
            ]
            
            fields = [
                BuilderField(identifier: "stringValue", label: "String Number", fieldType: .text, value: "42"),
                BuilderField(identifier: "stringNum1", label: "String Number 1", fieldType: .text, value: "10"),
                BuilderField(identifier: "stringNum2", label: "String Number 2", fieldType: .text, value: "25"),
                BuilderField(identifier: "decimalString", label: "Decimal String", fieldType: .text, value: "3.14159"),
                BuilderField(identifier: "negativeString", label: "Negative String", fieldType: .text, value: "-25"),
                BuilderField(identifier: "numerator", label: "Numerator", fieldType: .text, value: "75"),
                BuilderField(identifier: "denominator", label: "Denominator", fieldType: .text, value: "100"),
                BuilderField(identifier: "floatString", label: "Float String", fieldType: .text, value: "12.3456789"),
                BuilderField(identifier: "inputValue", label: "Input Value", fieldType: .text, value: "123"),
                BuilderField(identifier: "numberResult", label: "Converted Number", fieldType: .number, formulaRef: "stringToNumber"),
                BuilderField(identifier: "calculationResult", label: "Sum Result", fieldType: .number, formulaRef: "numberCalculation"),
                BuilderField(identifier: "decimalResult", label: "Decimal Result", fieldType: .number, formulaRef: "decimalConversion"),
                BuilderField(identifier: "negativeResult", label: "Negative Result", fieldType: .number, formulaRef: "negativeConversion"),
                BuilderField(identifier: "percentageResult", label: "Percentage", fieldType: .number, formulaRef: "percentageCalc"),
                BuilderField(identifier: "roundedResult", label: "Rounded Result", fieldType: .number, formulaRef: "roundedConversion"),
                BuilderField(identifier: "validationResult", label: "Validation Result", fieldType: .text, formulaRef: "validationCheck")
            ]
        }
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

enum FormTemplate: CaseIterable {
    case custom
    case mathFormulas
    case stringFormulas
    case arrayFormulas
    case logicalFormulas
    case referenceResolution
    case dateFormulas
    case conversionFormulas
    
    var displayName: String {
        switch self {
        case .custom: return "🔧 Custom"
        case .mathFormulas: return "🧮 Math Formulas"
        case .stringFormulas: return "📝 String Formulas"
        case .arrayFormulas: return "📊 Array Formulas"
        case .logicalFormulas: return "🔀 Logical Formulas"
        case .referenceResolution: return "🔗 Advanced References"
        case .dateFormulas: return "📅 Date Formulas"
        case .conversionFormulas: return "🔄 Type Conversion"
        }
    }
    
    var description: String {
        switch self {
        case .custom: return "Start from scratch or keep current form"
        case .mathFormulas: return "Basic math operations, calculations, and functions"
        case .stringFormulas: return "Text manipulation, concatenation, and validation"
        case .arrayFormulas: return "Array operations with lambda functions"
        case .logicalFormulas: return "Conditional logic, boolean operations"
        case .referenceResolution: return "Dynamic references, object properties, array indexing"
        case .dateFormulas: return "Date calculations and manipulations"
        case .conversionFormulas: return "Type conversions and data transformations"
        }
    }
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
    
    let editingField: BuilderField?
    let onAdd: (BuilderField) -> Void
    
    init(editingField: BuilderField? = nil, onAdd: @escaping (BuilderField) -> Void) {
        self.editingField = editingField
        self.onAdd = onAdd
        
        if let field = editingField {
            _identifier = State(initialValue: field.identifier)
            _label = State(initialValue: field.label)
            _fieldType = State(initialValue: field.fieldType)
            _value = State(initialValue: field.value)
            _formulaRef = State(initialValue: field.formulaRef ?? "")
            _useFormula = State(initialValue: field.formulaRef != nil)
            _formulaKey = State(initialValue: field.formulaKey)
        }
    }
    
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
            .navigationTitle(editingField == nil ? "Add Field" : "Edit Field")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button(editingField == nil ? "Add" : "Save") {
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
    
    let editingFormula: BuilderFormula?
    let onAdd: (BuilderFormula) -> Void
    
    init(editingFormula: BuilderFormula? = nil, onAdd: @escaping (BuilderFormula) -> Void) {
        self.editingFormula = editingFormula
        self.onAdd = onAdd
        
        if let formula = editingFormula {
            _identifier = State(initialValue: formula.identifier)
            _formula = State(initialValue: formula.formula)
            _selectedTemplate = State(initialValue: .custom)
        }
    }
    
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
                        TextField("Formula", text: $formula)
                            .autocapitalization(.none)
                            .font(.system(.body, design: .monospaced))
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
            .navigationTitle(editingFormula == nil ? "Add Formula" : "Edit Formula")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button(editingFormula == nil ? "Add" : "Save") {
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
