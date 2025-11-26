//
//  FormulaFunctionTestsView.swift
//  JoyfillExample
//
//  View for testing individual formula functions like if(), sum(), etc.
//

import SwiftUI
import Joyfill
import JoyfillModel

struct FormulaFunctionTestsView: View {
    // List of formula function JSON files (add more as they are created)
    let formulaFunctions: [(name: String, fileName: String, description: String)] = [
        // Logical
        ("if()", "FormulaTemplate_IfFunction", "Conditional logic: if(condition, true_value, false_value)"),
        ("and()", "FormulaTemplate_AndFunction", "Logical AND: and(condition1, condition2, ...) - all must be true"),
        ("or()", "FormulaTemplate_OrFunction", "Logical OR: or(condition1, condition2, ...) - any must be true"),
        ("not()", "FormulaTemplate_NotFunction", "Logical NOT: not(condition) - negates boolean value"),
        // String
        ("empty()", "FormulaTemplate_EmptyFunction", "Check if value is empty: empty(value) - strings, arrays, fields"),
        ("contains()", "FormulaTemplate_ContainsFunction", "String search: contains(text, search) - case insensitive"),
        ("concat()", "FormulaTemplate_ConcatFunction", "Concatenate: concat(a, b, ...) - joins strings/arrays"),
        ("lower()", "FormulaTemplate_LowerFunction", "Lowercase: lower(text) - converts text to lowercase"),
        ("upper()", "FormulaTemplate_UpperFunction", "Uppercase: upper(text) - converts text to uppercase"),
        ("length()", "FormulaTemplate_LengthFunction", "Length: length(value) - string length or array count"),
        ("toNumber()", "FormulaTemplate_ToNumberFunction", "Convert: toNumber(value) - converts string to number"),
        // Math
        ("sum()", "FormulaTemplate_SumFunction", "Sum: sum(a, b, ...) - adds numbers or array elements"),
        ("max()", "FormulaTemplate_MaxFunction", "Maximum: max(a, b, ...) - returns largest value"),
        ("round()", "FormulaTemplate_RoundFunction", "Round: round(value, places) - rounds to decimal places"),
        ("ceil()", "FormulaTemplate_CeilFunction", "Ceiling: ceil(value) - rounds up to nearest integer"),
        ("floor()", "FormulaTemplate_FloorFunction", "Floor: floor(value) - rounds down to nearest integer"),
        ("sqrt()", "FormulaTemplate_SqrtFunction", "Square root: sqrt(value) - returns square root"),
        ("pow()", "FormulaTemplate_PowFunction", "Power: pow(base, exponent) - raises base to power"),
        ("mod()", "FormulaTemplate_ModFunction", "Modulo: mod(a, b) - returns remainder of division"),
        // Date
        ("date()", "FormulaTemplate_DateFunction", "Date: date(year, month, day) - creates a date"),
        ("day()", "FormulaTemplate_DayFunction", "Day: day(date) - extracts day from date"),
        ("month()", "FormulaTemplate_MonthFunction", "Month: month(date) - extracts month from date"),
        ("year()", "FormulaTemplate_YearFunction", "Year: year(date) - extracts year from date"),
        ("now()", "FormulaTemplate_NowFunction", "Now: now() - returns current date/time"),
        ("dateAdd()", "FormulaTemplate_DateAddFunction", "Add: dateAdd(date, amount, unit) - adds to date"),
        ("dateSubtract()", "FormulaTemplate_DateSubtractFunction", "Subtract: dateSubtract(date, amount, unit)"),
        // Array
        ("map()", "FormulaTemplate_MapFunction", "Map: map(array, fn) - transforms each element"),
        ("filter()", "FormulaTemplate_FilterFunction", "Filter: filter(array, fn) - filters elements"),
        ("find()", "FormulaTemplate_FindFunction", "Find: find(array, fn) - finds first matching element"),
        ("reduce()", "FormulaTemplate_ReduceFunction", "Reduce: reduce(array, fn, initial) - reduces to value"),
        ("flat()", "FormulaTemplate_FlatFunction", "Flat: flat(array) - flattens nested arrays"),
        ("flatMap()", "FormulaTemplate_FlatMapFunction", "FlatMap: flatMap(array, fn) - map then flatten"),
        ("every()", "FormulaTemplate_EveryFunction", "Every: every(array, fn) - all elements match"),
        ("some()", "FormulaTemplate_SomeFunction", "Some: some(array, fn) - any element matches"),
        ("countIf()", "FormulaTemplate_CountIfFunction", "CountIf: countIf(array, fn) - counts matching"),
    ]
    
    @State private var selectedFunction: String? = nil
    @State private var showForm: Bool = false
    @State private var documentEditor: DocumentEditor? = nil
    @State private var loadError: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Formula Function Tests")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Select a formula function to test its behavior")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            if formulaFunctions.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "function")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("No Formula Functions Available")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Add JSON files to test formula functions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // List of formula functions
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(formulaFunctions, id: \.fileName) { function in
                            FormulaFunctionCard(
                                name: function.name,
                                description: function.description,
                                isSelected: selectedFunction == function.fileName
                            ) {
                                selectedFunction = function.fileName
                                loadFormula(fileName: function.fileName)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            
            // Error message
            if let error = loadError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            
            // Navigation to form view
            NavigationLink(
                destination: FormulaFunctionFormView(documentEditor: documentEditor),
                isActive: $showForm
            ) {
                EmptyView()
            }
        }
        .navigationTitle("Formula Functions")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func loadFormula(fileName: String) {
        loadError = nil
        
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            loadError = "Could not find \(fileName).json in bundle"
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let dict = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]
            let document = JoyDoc(dictionary: dict)
            
            documentEditor = DocumentEditor(
                document: document,
                mode: .fill,
                events: nil,
                pageID: "",
                navigation: true,
                isPageDuplicateEnabled: false,
                validateSchema: false
            )
            
            showForm = true
        } catch {
            loadError = "Error loading JSON: \(error.localizedDescription)"
        }
    }
}

struct FormulaFunctionCard: View {
    let name: String
    let description: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.indigo.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "f.cursive")
                        .font(.system(size: 24))
                        .foregroundColor(.indigo)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Arrow indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.indigo : Color.gray.opacity(0.15),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FormulaFunctionFormView: View {
    let documentEditor: DocumentEditor?
    
    var body: some View {
        if let editor = documentEditor {
            VStack {
                Form(documentEditor: editor)
            }
            .navigationTitle(editor.document.name ?? "Formula Test")
            .navigationBarTitleDisplayMode(.inline)
        } else {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("No document loaded")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    NavigationView {
        FormulaFunctionTestsView()
    }
}

