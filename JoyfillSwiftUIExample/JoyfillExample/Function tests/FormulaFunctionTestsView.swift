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
    // List of formula function JSON files - uses simple names from "All Functions" folder
    let formulaFunctions: [(name: String, fileName: String, description: String)] = [
        // Logical
        ("if()", "if", "Conditional logic: if(condition, true_value, false_value)"),
        ("and()", "and", "Logical AND: and(condition1, condition2, ...) - all must be true"),
        ("or()", "or", "Logical OR: or(condition1, condition2, ...) - any must be true"),
        ("not()", "not", "Logical NOT: not(condition) - negates boolean value"),
        // String
        ("empty()", "empty", "Check if value is empty: empty(value) - strings, arrays, fields"),
        ("contains()", "contains", "String search: contains(text, search) - case insensitive"),
        ("concat()", "concat", "Concatenate: concat(a, b, ...) - joins strings/arrays"),
        ("lower()", "lower", "Lowercase: lower(text) - converts text to lowercase"),
        ("upper()", "upper", "Uppercase: upper(text) - converts text to uppercase"),
        ("length()", "length", "Length: length(value) - string length or array count"),
        ("toNumber()", "toNumber", "Convert: toNumber(value) - converts string to number"),
        // Math
        ("sum()", "sum", "Sum: sum(a, b, ...) - adds numbers or array elements"),
        ("max()", "max", "Maximum: max(a, b, ...) - returns largest value"),
        ("round()", "round", "Round: round(value, places) - rounds to decimal places"),
        ("ceil()", "ceil", "Ceiling: ceil(value) - rounds up to nearest integer"),
        ("floor()", "floor", "Floor: floor(value) - rounds down to nearest integer"),
        ("sqrt()", "sqrt", "Square root: sqrt(value) - returns square root"),
        ("pow()", "pow", "Power: pow(base, exponent) - raises base to power"),
        ("mod()", "mod", "Modulo: mod(a, b) - returns remainder of division"),
        // Date
        ("date()", "date", "Date: date(year, month, day) - creates a date"),
        ("day()", "day", "Day: day(date) - extracts day from date"),
        ("month()", "month", "Month: month(date) - extracts month from date"),
        ("year()", "year", "Year: year(date) - extracts year from date"),
        ("now()", "now", "Now: now() - returns current date/time"),
        ("dateAdd()", "dateAdd", "Add: dateAdd(date, amount, unit) - adds to date"),
        ("dateSubtract()", "dateSubtract", "Subtract: dateSubtract(date, amount, unit)"),
        // Array
        ("map()", "map", "Map: map(array, fn) - transforms each element"),
        ("filter()", "filter", "Filter: filter(array, fn) - filters elements"),
        ("find()", "find", "Find: find(array, fn) - finds first matching element"),
        ("reduce()", "reduce", "Reduce: reduce(array, fn, initial) - reduces to value"),
        ("flat()", "flat", "Flat: flat(array) - flattens nested arrays"),
        ("flatMap()", "flatMap", "FlatMap: flatMap(array, fn) - map then flatten"),
        ("every()", "every", "Every: every(array, fn) - all elements match"),
        ("some()", "some", "Some: some(array, fn) - any element matches"),
        ("countIf()", "countIf", "CountIf: countIf(array, fn) - counts matching"),
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
                destination: FormulaFunctionFormView(
                    documentEditor: documentEditor,
                    functionName: selectedFunction ?? ""
                ),
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
    let functionName: String
    
    @State private var showDocumentation = false
    @State private var markdownContent: String? = nil
    
    var body: some View {
        if let editor = documentEditor {
            VStack {
                Form(documentEditor: editor)
            }
            .navigationTitle(editor.document.name ?? "Formula Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        loadMarkdown()
                        showDocumentation = true
                    }) {
                        Image(systemName: "book.fill")
                            .foregroundColor(.indigo)
                    }
                }
            }
            .sheet(isPresented: $showDocumentation) {
                MarkdownPreviewView(
                    functionName: functionName,
                    content: markdownContent
                )
            }
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
    
    private func loadMarkdown() {
        // Try multiple ways to find the markdown file
        var path: String? = nil
        
        // Try direct lookup
        path = Bundle.main.path(forResource: functionName, ofType: "md")
        
        // Try with subdirectory
        if path == nil {
            path = Bundle.main.path(forResource: functionName, ofType: "md", inDirectory: "All Functions")
        }
        
        // Try URL-based lookup
        if path == nil, let url = Bundle.main.url(forResource: functionName, withExtension: "md") {
            path = url.path
        }
        
        guard let finalPath = path else {
            markdownContent = nil
            print("⚠️ Could not find \(functionName).md in bundle")
            return
        }
        
        do {
            markdownContent = try String(contentsOfFile: finalPath, encoding: .utf8)
            print("✅ Loaded \(functionName).md successfully")
        } catch {
            markdownContent = nil
            print("❌ Error loading \(functionName).md: \(error)")
        }
    }
}

// MARK: - Markdown Preview View

struct MarkdownPreviewView: View {
    let functionName: String
    let content: String?
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let content = content {
                    MarkdownRenderer(markdown: content)
                        .padding(20)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Documentation Not Available")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("No .md file found for \(functionName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                }
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle("\(functionName)() Documentation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.body.weight(.semibold))
                }
            }
        }
    }
}

// MARK: - Simple Markdown Renderer

struct MarkdownRenderer: View {
    let markdown: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(parseMarkdown(), id: \.id) { block in
                renderBlock(block)
            }
        }
    }
    
    private func parseMarkdown() -> [MarkdownBlock] {
        var blocks: [MarkdownBlock] = []
        var currentCodeBlock: [String] = []
        var inCodeBlock = false
        
        let lines = markdown.components(separatedBy: "\n")
        
        for line in lines {
            // Handle code blocks
            if line.hasPrefix("```") {
                if inCodeBlock {
                    blocks.append(MarkdownBlock(type: .code, content: currentCodeBlock.joined(separator: "\n")))
                    currentCodeBlock = []
                    inCodeBlock = false
                } else {
                    inCodeBlock = true
                }
                continue
            }
            
            if inCodeBlock {
                currentCodeBlock.append(line)
                continue
            }
            
            // Parse other elements
            if line.hasPrefix("# ") {
                blocks.append(MarkdownBlock(type: .h1, content: String(line.dropFirst(2))))
            } else if line.hasPrefix("## ") {
                blocks.append(MarkdownBlock(type: .h2, content: String(line.dropFirst(3))))
            } else if line.hasPrefix("### ") {
                blocks.append(MarkdownBlock(type: .h3, content: String(line.dropFirst(4))))
            } else if line.hasPrefix("- ") {
                blocks.append(MarkdownBlock(type: .bullet, content: String(line.dropFirst(2))))
            } else if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                blocks.append(MarkdownBlock(type: .paragraph, content: line))
            }
        }
        
        return blocks
    }
    
    @ViewBuilder
    private func renderBlock(_ block: MarkdownBlock) -> some View {
        switch block.type {
        case .h1:
            Text(block.content)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 8)
            
        case .h2:
            Text(block.content)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 16)
            
        case .h3:
            Text(block.content)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.top, 12)
            
        case .paragraph:
            Text(formatInlineCode(block.content))
                .font(.body)
                .foregroundColor(.primary)
            
        case .bullet:
            HStack(alignment: .top, spacing: 8) {
                Text("•")
                    .foregroundColor(.indigo)
                    .fontWeight(.bold)
                Text(formatInlineCode(block.content))
                    .font(.body)
                    .foregroundColor(.primary)
            }
            .padding(.leading, 8)
            
        case .code:
            Text(block.content)
                .font(.system(.body, design: .monospaced))
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    private func formatInlineCode(_ text: String) -> AttributedString {
        var result = AttributedString(text)
        
        // Simple inline code formatting (text between backticks)
        let pattern = "`([^`]+)`"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let nsString = text as NSString
            let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            
            for match in matches.reversed() {
                if let codeRange = Range(match.range(at: 1), in: text),
                   let fullRange = Range(match.range, in: text),
                   let attrCodeRange = result.range(of: String(text[fullRange])) {
                    var codeAttr = AttributedString(String(text[codeRange]))
                    codeAttr.font = .system(.body, design: .monospaced)
                    codeAttr.backgroundColor = Color(UIColor.secondarySystemBackground)
                    result.replaceSubrange(attrCodeRange, with: codeAttr)
                }
            }
        }
        
        return result
    }
}

struct MarkdownBlock: Identifiable {
    let id = UUID()
    let type: MarkdownBlockType
    let content: String
}

enum MarkdownBlockType {
    case h1, h2, h3, paragraph, bullet, code
}

#Preview {
    NavigationView {
        FormulaFunctionTestsView()
    }
}
