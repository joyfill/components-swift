//
//  PublicApiExamples.swift
//  JoyfillExample
//
//  Created by Vivek on 30/09/25.
//

import SwiftUI
import Joyfill

struct PublicApiExamples: View {
    @Binding var documentEditor: DocumentEditor?
    @State var pageID: String = ""
    @State var validateSchema: Bool = true
    @State var showPageNavigationView: Bool = false
    @State var mode: Mode = .fill
    @State var license: String = licenseKey
    @Environment(\.dismiss) var dismiss
    
    init(documentEditor: Binding<DocumentEditor?>, licenseKey: String = "") {
        self._documentEditor = documentEditor
        let editor = documentEditor.wrappedValue
        _pageID = State(initialValue: editor?.currentPageID ?? "")
        _validateSchema = State(initialValue: true)
        _showPageNavigationView = State(initialValue: editor?.showPageNavigationView ?? true)
        _mode = State(initialValue: editor?.mode ?? .fill)
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
                        
                        // Page ID Card
                        SettingCard(
                            icon: "doc.text.fill",
                            iconColor: .blue,
                            title: "Current Page"
                        ) {
                            HStack(spacing: 12) {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                TextField("Enter page ID", text: $pageID)
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
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
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
            validateSchema = newValue
            if let editor = documentEditor {
                documentEditor = DocumentEditor(
                    document: editor.document,
                    mode: editor.mode,
                    events: editor.events,
                    pageID: editor.currentPageID,
                    navigation: editor.showPageNavigationView,
                    isPageDuplicateEnabled: editor.isPageDuplicateEnabled,
                    validateSchema: newValue,
                    license: self.license
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
                    validateSchema: validateSchema,
                    license: license
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
                    validateSchema: validateSchema,
                    license: license
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
                    validateSchema: validateSchema,
                    license: newValue
                )
            }
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
