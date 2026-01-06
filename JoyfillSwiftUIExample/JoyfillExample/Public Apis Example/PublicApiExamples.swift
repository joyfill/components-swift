//
//  PublicApiExamples.swift
//  JoyfillExample
//
//  Created by Vivek on 30/09/25.
//

import SwiftUI
import Joyfill
import JoyfillModel

struct PublicApiExamples: View {
    @Binding var documentEditor: DocumentEditor?
    @State var pageID: String = ""
    @Binding var validateSchema: Bool
    @State var showPageNavigationView: Bool = false
    @State var mode: Mode = .fill
    @Binding var license: String
    @Binding var isPageDuplicate: Bool
    @Binding var isPageDelete: Bool
    @Binding var singleClickRowEdit: Bool
    @Environment(\.dismiss) var dismiss
    @State private var selectedPageOption: String = "custom"
    @State private var showCustomPageInput: Bool = false
    @State private var showMoreSheet: Bool = false
    @State var document: JoyDoc
    
    init(documentEditor: Binding<DocumentEditor?>, licenseKey: Binding<String>, validateSchema: Binding<Bool>, isPageDuplicate: Binding<Bool>, isPageDelete: Binding<Bool>, singleClickRowEdit: Binding<Bool>, document: JoyDoc) {
        self._documentEditor = documentEditor
        let editor = documentEditor.wrappedValue
        _pageID = State(initialValue: editor?.currentPageID ?? "")
        _showPageNavigationView = State(initialValue: editor?.showPageNavigationView ?? true)
        _mode = State(initialValue: editor?.mode ?? .fill)
        _selectedPageOption = State(initialValue: editor?.currentPageID ?? "")
        self._validateSchema = validateSchema
        self._isPageDuplicate = isPageDuplicate
        self._isPageDelete = isPageDelete
        self._singleClickRowEdit = singleClickRowEdit
        self.document = document
        self._license = licenseKey
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header Section
                        VStack(spacing: 8) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 50))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .padding(.top, 8)
                            
                            Text("Public API Examples")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Configure your document editor")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 20)

                        SettingCard(
                            icon: "doc.text.fill",
                            iconColor: .blue,
                            title: "Current Page"
                        ) {
                            VStack(spacing: 12) {
                                // Dropdown Menu
                                Menu {
                                    // Pre-defined pages from document
                                    if let pages = documentEditor?.pagesForCurrentView {
                                        ForEach(Array(pages.enumerated()), id: \.offset) { _, page in
                                            Button {
                                                selectedPageOption = page.id ?? ""
                                                showCustomPageInput = false
                                                pageID = page.id ?? ""
                                            } label: {
                                                HStack {
                                                    Text(page.id ?? "")
                                                    if selectedPageOption == page.id {
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    Divider()
                                    
                                    // Custom "Other" option
                                    Button {
                                        selectedPageOption = "custom"
                                        showCustomPageInput = true
                                    } label: {
                                        HStack {
                                            Text("Other (Custom ID)")
                                            if selectedPageOption == "custom" {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text(showCustomPageInput ? "Custom Page ID" : (selectedPageOption == "custom" ? "Select a page" : selectedPageOption))
                                            .font(.system(.body, design: .rounded))
                                            .foregroundColor(selectedPageOption == "custom" && !showCustomPageInput ? .secondary : .primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                                
                                // Custom TextField (appears when "Other" is selected)
                                if showCustomPageInput {
                                    HStack(spacing: 12) {
                                        Image(systemName: "pencil")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                        
                                        TextField("Enter custom page ID", text: $pageID)
                                            .textFieldStyle(.plain)
                                            .font(.system(.body, design: .rounded))
                                        
                                        if !pageID.isEmpty {
                                            Button(action: {
                                                pageID = ""
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.secondary)
                                                    .imageScale(.medium)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.blue.opacity(0.05))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                                    .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showCustomPageInput)
                        }

                        
                        // Validate Schema Card
                        SettingCard(
                            icon: "checkmark.shield.fill",
                            iconColor: .green,
                            title: "Validate Schema"
                        ) {
                            Toggle("", isOn: $validateSchema)
                                .labelsHidden()
                                .tint(.green)
                        }
                        
                        // Page Navigation Card
                        SettingCard(
                            icon: "arrow.left.arrow.right",
                            iconColor: .orange,
                            title: "Page Navigation"
                        ) {
                            Toggle("", isOn: $showPageNavigationView)
                                .labelsHidden()
                                .tint(.orange)
                        }
                        
                        SettingCard(
                            icon: "document.on.document",
                            iconColor: .orange,
                            title: "Page Duplication"
                        ) {
                            Toggle("", isOn: $isPageDuplicate)
                                .labelsHidden()
                                .tint(.orange)
                        }
                        
                        SettingCard(
                            icon: "trash",
                            iconColor: .orange,
                            title: "Page Deletion"
                        ) {
                            Toggle("", isOn: $isPageDelete)
                                .labelsHidden()
                                .tint(.orange)
                        }
                        
                        SettingCard(
                            icon: "square.and.pencil",
                            iconColor: .blue,
                            title: "Single-Click Row Edit"
                        ) {
                            Toggle("", isOn: $singleClickRowEdit)
                                .labelsHidden()
                                .tint(.blue)
                        }
                        
                        // Mode Selection Card
                        SettingCard(
                            icon: "pencil.and.list.clipboard",
                            iconColor: .purple,
                            title: "Editor Mode"
                        ) {
                            Picker("", selection: $mode) {
                                Label("Fill", systemImage: "pencil.line")
                                    .tag(Mode.fill)
                                Label("Read Only", systemImage: "eye.fill")
                                    .tag(Mode.readonly)
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                        }
                        
                        // License Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.pink.opacity(0.2), .pink.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "key.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.pink, .red],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                                
                                Text("License Key")
                                    .font(.system(.headline, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            
                            TextEditor(text: $license)
                                .font(.system(.body, design: .monospaced))
                                .autocorrectionDisabled()
                                .frame(minHeight: 160)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color(.systemGray4), lineWidth: 1)
                                )
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal, 20)
                        
                        SettingCard(
                            icon: "eye",
                            iconColor: .purple,
                            title: "Conditional Logic for fields"
                        ) {
                            Button {
                                showMoreSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "ellipsis.circle")
                                        .imageScale(.medium)
                                    Text("Show Field Visibility")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Show field visibility sheet")
                        }
                        
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
        .onChange(of: pageID) { newValue in
            documentEditor?.currentPageID = newValue
        }
        .onChange(of: validateSchema) { newValue in
            if let editor = documentEditor {
                documentEditor = DocumentEditor(
                    document: document,
                    mode: editor.mode,
                    events: editor.events,
                    pageID: editor.currentPageID,
                    navigation: editor.showPageNavigationView,
                    isPageDuplicateEnabled: editor.isPageDuplicateEnabled,
                    isPageDeleteEnabled: isPageDelete,
                    validateSchema: newValue,
                    license: self.license,
                    singleClickRowEdit: editor.singleClickRowEdit
                )
            }
        }
        .onChange(of: showPageNavigationView) { newValue in
            if let editor = documentEditor {
                documentEditor = DocumentEditor(
                    document: editor.document,
                    mode: editor.mode,
                    events: editor.events,
                    pageID: editor.currentPageID,
                    navigation: newValue,
                    isPageDuplicateEnabled: editor.isPageDuplicateEnabled,
                    isPageDeleteEnabled: isPageDelete,
                    validateSchema: validateSchema,
                    license: license,
                    singleClickRowEdit: editor.singleClickRowEdit
                )
            }
        }
        .onChange(of: isPageDuplicate) { newValue in
            if let editor = documentEditor {
                documentEditor = DocumentEditor(
                    document: editor.document,
                    mode: editor.mode,
                    events: editor.events,
                    pageID: editor.currentPageID,
                    navigation: editor.showPageNavigationView,
                    isPageDuplicateEnabled: newValue,
                    isPageDeleteEnabled: isPageDelete,
                    validateSchema: validateSchema,
                    license: license,
                    singleClickRowEdit: editor.singleClickRowEdit
                )
            }
        }
        .onChange(of: isPageDelete) { newValue in
            if let editor = documentEditor {
                documentEditor = DocumentEditor(
                    document: editor.document,
                    mode: editor.mode,
                    events: editor.events,
                    pageID: editor.currentPageID,
                    navigation: editor.showPageNavigationView,
                    isPageDuplicateEnabled: isPageDuplicate,
                    isPageDeleteEnabled: newValue,
                    validateSchema: validateSchema,
                    license: license,
                    singleClickRowEdit: editor.singleClickRowEdit
                )
            }
        }
        .onChange(of: mode) { newValue in
            if let editor = documentEditor {
                documentEditor = DocumentEditor(
                    document: editor.document,
                    mode: newValue,
                    events: editor.events,
                    pageID: editor.currentPageID,
                    navigation: editor.showPageNavigationView,
                    isPageDuplicateEnabled: editor.isPageDuplicateEnabled,
                    isPageDeleteEnabled: isPageDelete,
                    validateSchema: validateSchema,
                    license: license,
                    singleClickRowEdit: editor.singleClickRowEdit
                )
            }
        }
        .onChange(of: license) { newValue in
            if let editor = documentEditor {
                documentEditor = DocumentEditor(
                    document: editor.document,
                    mode: editor.mode,
                    events: editor.events,
                    pageID: editor.currentPageID,
                    navigation: editor.showPageNavigationView,
                    isPageDuplicateEnabled: editor.isPageDuplicateEnabled,
                    isPageDeleteEnabled: isPageDelete,
                    validateSchema: validateSchema,
                    license: newValue,
                    singleClickRowEdit: editor.singleClickRowEdit
                )
            }
        }
        .onChange(of: singleClickRowEdit) { newValue in
            if let editor = documentEditor {
                documentEditor = DocumentEditor(
                    document: editor.document,
                    mode: editor.mode,
                    events: editor.events,
                    pageID: editor.currentPageID,
                    navigation: editor.showPageNavigationView,
                    isPageDuplicateEnabled: editor.isPageDuplicateEnabled,
                    isPageDeleteEnabled: isPageDelete,
                    validateSchema: validateSchema,
                    license: license,
                    singleClickRowEdit: newValue
                )
            }
        }
        .sheet(isPresented: $showMoreSheet) {
            FieldVisibilitySheet(documentEditor: $documentEditor)
        }
    }
}

// Reusable Setting Card Component
struct SettingCard<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let content: Content
    
    init(
        icon: String,
        iconColor: Color,
        title: String,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [iconColor.opacity(0.2), iconColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [iconColor, iconColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Field Visibility Sheet
struct FieldVisibilitySheet: View {
    @Binding var documentEditor: DocumentEditor?

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Field Visibility")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Text("See which fields are currently shown or hidden based on conditional logic.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        // Pages & Fields
                        if let pages = documentEditor?.pagesForCurrentView, !pages.isEmpty {
                            VStack(spacing: 16) {
                                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Image(systemName: "doc.text")
                                            Text(page.id ?? "Untitled Page")
                                                .font(.headline)
                                            Spacer()
                                        }
                                        .foregroundColor(.primary)

                                        // Fields list
                                        if let fieldPos = page.fieldPositions, !fieldPos.isEmpty {
                                            VStack(spacing: 8) {
                                                ForEach(fieldPos, id: \.id) { fieldP in
                                                    FieldVisibilityRowContainer(
                                                        documentEditor: documentEditor,
                                                        fieldPosition: fieldP
                                                    )
                                                }
                                            }
                                        } else {
                                            Text("No fields on this page.")
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                                    )
                                    .padding(.horizontal, 20)
                                }
                            }
                            .padding(.bottom, 20)
                        } else {
                            Text("No pages available.")
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Field Row
struct FieldVisibilityRow: View {
    let title: String
    let isShown: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.18), Color.blue.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)

                Image(systemName: isShown ? "eye.fill" : "eye.slash.fill")
                    .foregroundStyle(
                        LinearGradient(
                            colors: isShown ? [Color.green, Color.green.opacity(0.7)] : [Color.red, Color.red.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.primary)

                Text(isShown ? "Shown" : "Hidden")
                    .font(.caption)
                    .foregroundColor(isShown ? .green : .red)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
                .opacity(0.3)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Helper container to simplify type-checking in ForEach
struct FieldVisibilityRowContainer: View {
    let documentEditor: DocumentEditor?
    let fieldPosition: FieldPosition

    var body: some View {
        let fieldID = fieldPosition.field ?? ""
        let field = documentEditor?.field(fieldID: fieldID)
        let title = field?.title ?? field?.id ?? "Untitled"
        let isShown = documentEditor?.shouldShow(fieldID: field?.id ?? "") ?? false
        return FieldVisibilityRow(title: title, isShown: isShown)
    }
}
