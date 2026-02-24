//
//  SimpleNavigationTestView.swift
//  JoyfillExample
//
//  Simple navigation with dropdowns and manual path input
//

import SwiftUI
import Joyfill
import JoyfillModel

struct SimpleNavigationTestView: View {
    @StateObject var documentEditor: DocumentEditor
    @State private var selectedPageId: String = ""
    @State private var selectedFieldPositionId: String = ""
    @State private var selectedRowId: String = ""
    @State private var manualPath: String = ""
    @State private var openModal: Bool = true
    @State private var focusField: Bool = true
    @State private var selectedColumnId: String = ""
    @State private var manualColumnId: String = ""
    @Binding var showAlert: Bool
    @Binding var alertMessage: String

    var allPages: [Page] {
        documentEditor.pagesForCurrentView
    }
    
    var fieldPositionsForSelectedPage: [FieldPosition] {
        guard let page = allPages.first(where: { $0.id == selectedPageId }) else {
            return []
        }
        return page.fieldPositions ?? []
    }
    
    var rowsForSelectedField: [ValueElement] {
        guard let fieldPosition = fieldPositionsForSelectedPage.first(where: { $0.id == selectedFieldPositionId }),
              let fieldId = fieldPosition.field,
              let field = documentEditor.field(fieldID: fieldId),
              (field.fieldType == .table || field.fieldType == .collection),
              let valueElements = field.value?.valueElements else {
            return []
        }
        return valueElements
    }
    
    var selectedFieldIsTableOrCollection: Bool {
        guard let fieldPosition = fieldPositionsForSelectedPage.first(where: { $0.id == selectedFieldPositionId }),
              let fieldId = fieldPosition.field,
              let field = documentEditor.field(fieldID: fieldId) else {
            return false
        }
        return field.fieldType == .table || field.fieldType == .collection
    }
    
    var columnsForSelectedField: [FieldTableColumn] {
        guard let fieldPosition = fieldPositionsForSelectedPage.first(where: { $0.id == selectedFieldPositionId }),
              let fieldId = fieldPosition.field,
              let field = documentEditor.field(fieldID: fieldId) else {
            return []
        }
        if field.fieldType == .collection {
            guard let schema = field.schema,
                  let rootSchema = schema.first(where: { $0.value.root == true })?.value,
                  let columns = rootSchema.tableColumns else {
                return []
            }
            return columns
        }
        return field.tableColumns ?? []
    }
    
    init(showAlert: Binding<Bool>, alertMessage: Binding<String>) {
        let sampleDoc = sampleJSONDocument(fileName: "Navigation")
        let editor = DocumentEditor(
            document: sampleDoc,
            mode: .fill,
            validateSchema: false,
            license: licenseKey,
            singleClickRowEdit: true
        )
        _documentEditor = StateObject(wrappedValue: editor)
        _showAlert = showAlert
        _alertMessage = alertMessage
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Manual Path Input Section
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    TextField("pageId/fpId/rowId/colId", text: $manualPath)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Button(action: {
                        guard !manualPath.isEmpty else { return }
                        let status = documentEditor.goto(manualPath, gotoConfig: GotoConfig(open: openModal, focus: focusField))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            if status == .failure {
                                alertMessage = "Navigation failed for path: \(manualPath)"
                                showAlert = true
                            }
                        })
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                    }
                    .frame(width: 44, height: 44)
                    .foregroundColor(.white)
                    .background(manualPath.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(8)
                    .disabled(manualPath.isEmpty)
                }
                
                HStack {
                    Toggle("Open Modal", isOn: $openModal)
                        .font(.caption)
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.blue, lineWidth: 1)
                                .padding(.all, -4)
                        }
                                        
                    Toggle("Focus", isOn: $focusField)
                        .font(.caption)
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.blue, lineWidth: 1)
                                .padding(.all, -4)
                        }
                }
                .padding(.horizontal, 4)
            }
            .padding(12)
            .background(Color(UIColor.systemGroupedBackground))
            
            Divider()
            
            // Dropdown Navigation Section
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    // Page Dropdown
                    Picker("Page", selection: $selectedPageId) {
                        Text("Select page...").tag("")
                            .lineLimit(1)
                        ForEach(allPages, id: \.id) { page in
                            if let id = page.id {
                                Text(page.name ?? "Page \(id.prefix(8))").tag(id)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal, 12)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(8)
                    .onChange(of: selectedPageId) { _ in
                        selectedFieldPositionId = ""
                        selectedRowId = ""
                    }
                    
                    // Field Position Dropdown
                    Picker("Field", selection: $selectedFieldPositionId) {
                        Text("Select field...").tag("")
                            .lineLimit(1)
                        ForEach(fieldPositionsForSelectedPage, id: \.id) { fieldPosition in
                            if let id = fieldPosition.id {
                                if let fieldId = fieldPosition.field,
                                   let field = documentEditor.field(fieldID: fieldId) {
                                    Text(field.title ?? "Field \(id.prefix(8))").tag(id)
                                        .lineLimit(1)
                                } else {
                                    Text("Field \(id.prefix(8))").tag(id)
                                }
                            }
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal, 12)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(8)
                    .disabled(selectedPageId.isEmpty)
                    .onChange(of: selectedFieldPositionId) { _ in
                        selectedRowId = ""
                    }
                    
                    // Row Dropdown (only shown for table/collection fields)
                    if selectedFieldIsTableOrCollection {
                        Picker("Row", selection: $selectedRowId) {
                            Text("Select row...").tag("")
                                .lineLimit(1)
                            ForEach(Array(rowsForSelectedField.enumerated()), id: \.offset) { index, row in
                                if let id = row.id {
                                    let isDeleted = row.deleted == true
                                    let label = isDeleted 
                                        ? "Row \(index + 1) - \(id.prefix(8)) [DELETED]"
                                        : "Row \(index + 1) - \(id.prefix(8))"
                                    
                                    if isDeleted {
                                        Text(label)
                                            .foregroundStyle(.red)
                                            .tag(id)
                                            .lineLimit(1)
                                    } else {
                                        Text(label)
                                            .tag(id)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.horizontal, 12)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(8)
                        .disabled(selectedFieldPositionId.isEmpty)
                        .onChange(of: selectedRowId) { _ in
                            selectedColumnId = ""
                        }
                        
                    }
                    
                    // Column Dropdown (only shown when a row is selected in table/collection)
                    if selectedFieldIsTableOrCollection && !selectedRowId.isEmpty {
                        Picker("Column", selection: $selectedColumnId) {
                            Text("No column").tag("")
                                .lineLimit(1)
                            ForEach(columnsForSelectedField, id: \.id) { col in
                                if let id = col.id {
                                    Text(col.title.isEmpty ? "Col \(id.prefix(8))" : col.title).tag(id)
                                        .lineLimit(1)
                                }
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.horizontal, 12)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(8)
                    }
                    
                    // Navigate Button
                    Button(action: {
                        if !selectedPageId.isEmpty {
                            let status: NavigationStatus
                            if !selectedRowId.isEmpty {
                                var path = "\(selectedPageId)/\(selectedFieldPositionId)/\(selectedRowId)"
                                if !selectedColumnId.isEmpty {
                                    path += "/\(selectedColumnId)"
                                }
                                status = documentEditor.goto(path, gotoConfig: GotoConfig(open: openModal, focus: focusField))
                            } else if !selectedFieldPositionId.isEmpty {
                                status = documentEditor.goto("\(selectedPageId)/\(selectedFieldPositionId)", gotoConfig: GotoConfig(focus: focusField))
                            } else {
                                status = documentEditor.goto(selectedPageId, gotoConfig: GotoConfig(focus: focusField))
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                                if status == .failure {
                                    alertMessage = "Navigation failed"
                                    showAlert = true
                                }
                            })
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("Navigate")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .foregroundColor(.white)
                    .background(selectedPageId.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(8)
                    .disabled(selectedPageId.isEmpty)
                }
            }
            .padding(12)
            .background(Color(UIColor.systemGroupedBackground))
            
            Divider()
                .padding(.bottom, 12)
            // The Form
            Form(documentEditor: documentEditor)
        }
        .navigationTitle("Navigation Test")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Auto-select first page
            if let firstPage = allPages.first, let firstPageId = firstPage.id {
                selectedPageId = firstPageId
            }
        }
    }
}

// MARK: - Preview

private struct SimpleNavigationTestViewPreviewWrapper: View {
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        SimpleNavigationTestView(showAlert: $showAlert, alertMessage: $alertMessage)
            .alert("Navigation Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
    }
}

struct SimpleNavigationTestView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SimpleNavigationTestViewPreviewWrapper()
        }
    }
}
