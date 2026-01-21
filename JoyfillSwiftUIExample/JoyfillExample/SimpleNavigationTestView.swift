//
//  SimpleNavigationTestView.swift
//  JoyfillExample
//
//  Simple navigation with dropdowns
//

import SwiftUI
import Joyfill
import JoyfillModel

struct SimpleNavigationTestView: View {
    @StateObject var documentEditor: DocumentEditor
    @State private var selectedPageId: String = ""
    @State private var selectedFieldPositionId: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var allPages: [Page] {
        documentEditor.pagesForCurrentView
    }
    
    var fieldPositionsForSelectedPage: [FieldPosition] {
        guard let page = allPages.first(where: { $0.id == selectedPageId }) else {
            return []
        }
        return page.fieldPositions ?? []
    }
    
    init() {
        let sampleDoc = sampleJSONDocument(fileName: "Joydocjson")
        let editor = DocumentEditor(
            document: sampleDoc,
            mode: .fill,
            validateSchema: false,
            license: licenseKey
        )
        _documentEditor = StateObject(wrappedValue: editor)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Controls - Compact
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
                
                // Navigate Button
                Button(action: {
                    if !selectedPageId.isEmpty {
                        let status: NavigationStatus
                        if !selectedFieldPositionId.isEmpty {
                            status = documentEditor.goto("\(selectedPageId)/\(selectedFieldPositionId)")
                        } else {
                            status = documentEditor.goto(selectedPageId)
                        }
                        
                        if status == .failure {
                            alertMessage = getFailureMessage()
                            showAlert = true
                        }
                    }
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                }
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
                .background(selectedPageId.isEmpty ? Color.gray : Color.blue)
                .cornerRadius(8)
                .disabled(selectedPageId.isEmpty)
            }
            .padding(12)
            .background(Color(UIColor.systemGroupedBackground))
            
            Divider()
                .padding(.bottom, 20)
            
            // The Form
            Form(documentEditor: documentEditor)
        }
        .navigationTitle("Navigation Test")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Navigation Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            // Auto-select first page
            if let firstPage = allPages.first, let firstPageId = firstPage.id {
                selectedPageId = firstPageId
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getFailureMessage() -> String {
        // Check if page exists
        guard allPages.contains(where: { $0.id == selectedPageId }) else {
            return "Page not found"
        }
        
        // Check if page is visible
        guard documentEditor.shouldShow(pageID: selectedPageId) else {
            return "Page is hidden by conditional logic"
        }
        
        if !selectedFieldPositionId.isEmpty {
            let page = allPages.first(where: { $0.id == selectedPageId })
            let fieldPosition = page?.fieldPositions?.first(where: { $0.id == selectedFieldPositionId })
            
            guard let fieldPosition = fieldPosition else {
                return "Field position not found. Navigated to page top."
            }
            
            if let fieldID = fieldPosition.field {
                guard documentEditor.shouldShow(fieldID: fieldID) else {
                    return "Field is hidden by conditional logic. Navigated to page top."
                }
            }
        }
        
        return "Navigation failed"
    }
}

// MARK: - Preview

struct SimpleNavigationTestView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SimpleNavigationTestView()
        }
    }
}
