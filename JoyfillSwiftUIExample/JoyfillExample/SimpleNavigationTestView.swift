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
        // Return all rows including deleted ones
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
                Text("Manual Path")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    TextField("pageId/fieldPositionId/rowId", text: $manualPath)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Button(action: {
                        guard !manualPath.isEmpty else { return }
                        let status = documentEditor.goto(manualPath, gotoConfig: GotoConfig(open: openModal))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
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
                
                // Open Modal Toggle
                Toggle("Open Modal", isOn: $openModal)
                    .font(.caption)
                    .padding(.horizontal, 4)
            }
            .padding(12)
            .background(Color(UIColor.systemGroupedBackground))
            
            Divider()
            
            // Dropdown Navigation Section
            VStack(spacing: 8) {
                Text("Select Page, Field & Row")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    // Page Dropdown
                    Picker("Page", selection: $selectedPageId) {
                        Text("Select page...").tag("")
                        ForEach(allPages, id: \.id) { page in
                            if let id = page.id {
                                Text(page.name ?? "Page \(id.prefix(8))").tag(id)
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
                        ForEach(fieldPositionsForSelectedPage, id: \.id) { fieldPosition in
                            if let id = fieldPosition.id {
                                if let fieldId = fieldPosition.field,
                                   let field = documentEditor.field(fieldID: fieldId) {
                                    Text(field.title ?? "Field \(id.prefix(8))").tag(id)
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
                                    } else {
                                        Text(label)
                                            .tag(id)
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
                        
                    }
                    
                    // Navigate Button
                    Button(action: {
                        if !selectedPageId.isEmpty {
                            let status: NavigationStatus
                            if !selectedRowId.isEmpty {
                                status = documentEditor.goto("\(selectedPageId)/\(selectedFieldPositionId)/\(selectedRowId)", gotoConfig: GotoConfig(open: openModal))
                            } else if !selectedFieldPositionId.isEmpty {
                                status = documentEditor.goto("\(selectedPageId)/\(selectedFieldPositionId)")
                            } else {
                                status = documentEditor.goto(selectedPageId)
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
