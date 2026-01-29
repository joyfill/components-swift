import SwiftUI
import JoyfillModel
import JoyfillFormulas

public struct Form: View {
    let documentEditor: DocumentEditor

    @available(*, deprecated, message: "Use init(documentEditor:) instead")
    public init(document: Binding<JoyDoc>, mode: Mode = .fill, events: FormChangeEvent? = nil, pageID: String?, navigation: Bool = true) {
        let documentEditor = DocumentEditor(document: document.wrappedValue, mode: mode, events: events, pageID: pageID, navigation: navigation)
        self.documentEditor = documentEditor
    }

    public init(documentEditor: DocumentEditor) {
        self.documentEditor = documentEditor
    }

    public var body: some View {
        if let error = documentEditor.schemaError {
            SchemaErrorView(error: error)
        } else {
            FilesView(documentEditor: documentEditor, files: documentEditor.files)
        }
    }
}

struct SchemaErrorView: View {
    let error: SchemaValidationError
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Warning Icon
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.black)
            
            // Main Error Message
            Text(getDisplayMessage())
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
            
            VStack(spacing: 8) {
                // Error Code
                Text(error.code)
                    .font(.body)
                    .foregroundColor(.gray)
                
                // SDK Version
                Text("SDK Version: \(error.details.sdkVersion)")
                    .font(.body)
                    .foregroundColor(.gray)
                
                // Schema Version
                Text("Schema Version: \(error.details.schemaVersion)")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func getDisplayMessage() -> String {
        switch error.code {
        case "ERROR_SCHEMA_VERSION":
            return "Unsupported document version.\nThis SDK version does not support\nthe document's schema version."
        case "ERROR_SCHEMA_VALIDATION":
            return "Error detected during\nschema validation."
        default:
            return "An error occurred while\nprocessing the document."
        }
    }
}

struct FilesView: View {
    let documentEditor: DocumentEditor
    let files: [File]

    var body: some View {
        FileView(file: files.first, documentEditor: documentEditor)
    }
}

struct FileView: View {
    let file: File?
    @ObservedObject var documentEditor: DocumentEditor

    var body: some View {
        if let file = file {
            PagesView(pageOrder: file.pageOrder, pageFieldModels: $documentEditor.pageFieldModels, documentEditor: documentEditor)
        }
    }
}

struct PagesView: View {
    @State private var isSheetPresented = false
    let pageOrder: [String]?
    @Binding var pageFieldModels: [String: PageModel]
    @ObservedObject var documentEditor: DocumentEditor

    init(isSheetPresented: Bool = false,
         pageOrder: [String]?,
         pageFieldModels: Binding<[String : PageModel]>,
         documentEditor: DocumentEditor) {
        self.isSheetPresented = isSheetPresented
        self.pageOrder = pageOrder
        _pageFieldModels = pageFieldModels
        self.documentEditor = documentEditor
    }

    var body: some View {
        VStack(alignment: .leading) {
            if documentEditor.showPageNavigationView {
                Button(action: {
                    isSheetPresented = true
                }, label: {
                    HStack {
                        Image(systemName: "chevron.down")
                        Text(documentEditor.firstValidPageFor(currentPageID: documentEditor.currentPageID)?.name ?? "")
                    }
                })
                .accessibilityIdentifier("PageNavigationIdentifier")
                .buttonStyle(.bordered)
                .padding(.leading, 16)
                .sheet(isPresented: $isSheetPresented) {
                    if #available(iOS 16, *) {
                        PageDuplicateListView(currentPageID: $documentEditor.currentPageID, pageOrder: pageOrder, documentEditor: documentEditor, pageFieldModels: $pageFieldModels)
                            .presentationDetents([.medium])
                    } else {
                        PageDuplicateListView(currentPageID: $documentEditor.currentPageID, pageOrder: pageOrder, documentEditor: documentEditor, pageFieldModels: $pageFieldModels)
                    }
                }
            }

            if let firstPage = pageFieldModels.first?.value ?? pageFieldModels[documentEditor.currentPageID] {
                let pageBinding = Binding(
                    get: { pageFieldModels[documentEditor.currentPageID] ?? firstPage },
                    set: { pageFieldModels[documentEditor.currentPageID] = $0 }
                )
                if documentEditor.shouldShow(pageID: pageBinding.wrappedValue.id) {
                    PageView(page: pageBinding, documentEditor: documentEditor)
                } else {
                    Text("No pages available")
                }
            } else {
                Text("No pages available")
            }
        }
    }
}

struct PageView: View {
    @Binding var page: PageModel
    var documentEditor: DocumentEditor

    var body: some View {
        FormView(listModels: $page.fields, documentEditor: documentEditor)
    }
}

enum FieldListModelType: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.text(let lhs), .text(let rhs)):
            return lhs.text == rhs.text
        case (.table(let lhs), .table(let rhs)):
            return lhs.cellModels == rhs.cellModels
        case (.chart(let lhs), .chart(let rhs)):
            return lhs.valueElements == rhs.valueElements
        case (.date(let lhs), .date(let rhs)):
            return lhs.value == rhs.value
        case (.block(let lhs), .block(let rhs)):
            return lhs.displayText == rhs.displayText
        case (.dropdown(let lhs), .dropdown(let rhs)):
            return lhs.dropdownValue == rhs.dropdownValue
        case (.image(let lhs), .image(let rhs)):
            return lhs.valueElements == rhs.valueElements
        case (.textarea(let lhs), .textarea(let rhs)):
            return lhs.multilineText == rhs.multilineText
        case (.multiSelect(let lhs), .multiSelect(let rhs)):
            return lhs.multiSelector == rhs.multiSelector
        case (.number(let lhs), .number(let rhs)):
            return lhs.number == rhs.number
        case (.richText(let lhs), .richText(let rhs)):
            return lhs.text == rhs.text
        case (.signature(let lhs), .signature(let rhs)):
            return lhs.signatureURL == rhs.signatureURL
        case (.none, .none):
            return true
        default:
            return false
        }
    }
    case text(TextDataModel)
    case table(TableDataModel)
    case collection(TableDataModel)
    case chart(ChartDataModel)
    case date(DateTimeDataModel)
    case block(DisplayTextDataModel)
    case dropdown(DropdownDataModel)
    case image(ImageDataModel)
    case textarea(MultiLineDataModel)
    case multiSelect(MultiSelectionDataModel)
    case number(NumberDataModel)
    case richText(RichTextDataModel)
    case signature(SignatureDataModel)
    case none
}

extension FieldListModelType {
    var tableDataModel: TableDataModel? {
        if case .table(let model) = self {
            return model
        }
        if case .collection(let model) = self {
            return model
        }
        return nil
    }
}

struct FormView: View {
    @Binding var listModels: [FieldListModel]
    @State var currentFocusedFieldsID: String = ""
    @State var lastFocusedFieldsID: String? = nil
    let documentEditor: DocumentEditor

    @ViewBuilder
    fileprivate func fieldView(listModelBinding: Binding<FieldListModel>) -> some View {
        let listModel = listModelBinding.wrappedValue
        switch listModel.model {
        case .text(let model):
            TextView(textDataModel: model, eventHandler: self)
                .disabled(listModel.fieldEditMode == .readonly)
        case .block(let model):

            DisplayTextView(displayTextDataModel: model)
                .disabled(listModel.fieldEditMode == .readonly)
        case .multiSelect(let model):
            MultiSelectionView(multiSelectionDataModel: model, eventHandler: self, currentFocusedFieldsDataId: currentFocusedFieldsID)
                .disabled(listModel.fieldEditMode == .readonly)
        case .dropdown(let model):
            DropdownView(dropdownDataModel: model, eventHandler: self)
                .disabled(listModel.fieldEditMode == .readonly)
        case .textarea(let model):

            MultiLineTextView(multiLineDataModel: model, eventHandler: self)
                .disabled(listModel.fieldEditMode == .readonly)
        case .date(let model):
            DateTimeView(dateTimeDataModel: model, eventHandler: self)
                .disabled(listModel.fieldEditMode == .readonly)
        case .signature(let model):
            SignatureView(signatureDataModel: model, eventHandler: self)
                .disabled(listModel.fieldEditMode == .readonly)
        case .number(let model):
            NumberView(numberDataModel: model, eventHandler: self)
                .disabled(listModel.fieldEditMode == .readonly)
        case .chart(let model):
            ChartView(chartDataModel: model, eventHandler: self)
        case .richText(let model):
            RichTextView(richTextDataModel: model, eventHandler: self)
                .disabled(listModel.fieldEditMode == .readonly)
        case .table(let model):
            TableQuickView(tableDataModel: model, eventHandler: self)
        case .collection(let model):
            CollectionQuickView(tableDataModel: model, eventHandler: self)
        case .image(let model):
            ImageView(listModel: listModelBinding, eventHandler: self)
        case .none:
            EmptyView()
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            List($listModels, id: \.wrappedValue.fieldIdentifier.fieldID) { $listModel in
                if documentEditor.shouldShow(fieldID: listModel.fieldIdentifier.fieldID) {
                    fieldView(listModelBinding: $listModel)
                        .listRowSeparator(.hidden)
                        .buttonStyle(.borderless)
                }
            }
            .listStyle(PlainListStyle())
            .modifier(KeyboardDismissModifier())
            .onChange(of: $currentFocusedFieldsID.wrappedValue) { newValue in
                guard newValue != nil else { return }
                guard lastFocusedFieldsID != newValue else { return }
                if let lastFocusedFieldsID = lastFocusedFieldsID {
                    let fieldEvent = documentEditor.getFieldIdentifier(for: lastFocusedFieldsID)
                    documentEditor.onBlur(event: fieldEvent)
                }
                self.lastFocusedFieldsID = currentFocusedFieldsID
            }
            .onChange(of: documentEditor.currentPageID) { _ in
                // Scroll to top when page changes
                if let firstFieldID = listModels.first?.fieldIdentifier.fieldID {
                    withAnimation {
                        proxy.scrollTo(firstFieldID, anchor: .top)
                    }
                }
            }
            .onChange(of: documentEditor.navigationTarget) { navigationTarget in
                // Handle navigation requests from DocumentEditor
                guard let navigationTarget = navigationTarget else { return }
                
                // Only handle navigation for the current page
                guard navigationTarget.pageId == documentEditor.currentPageID else { return }
                
                if let fieldID = navigationTarget.fieldID {
                    // Navigate to specific field
                    withAnimation {
                        proxy.scrollTo(fieldID, anchor: .top)
                    }
                    
                    // Clear navigation target after scroll completes
                    DispatchQueue.main.async {
                        documentEditor.navigationTarget = nil
                    }
                }
            }
        }
    }
}

// Dismiss Keyboard on Scroll
struct KeyboardDismissModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.scrollDismissesKeyboard(.immediately)
        } else {
            content.gesture(DragGesture().onChanged({ _ in
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }))
        }
    }
}

extension FormView: FieldChangeEvents {

    func onChange(event: FieldChangeData) {
        documentEditor.onChange(event: event)
    }

    func onFocus(event: FieldIdentifier) {
        currentFocusedFieldsID = event.fieldID
        if lastFocusedFieldsID == currentFocusedFieldsID {
            return
        } else {
            documentEditor.onFocus(event: event)
        }
    }

    func onUpload(event: UploadEvent) {
        documentEditor.onUpload(event: event)
    }

    private func updateFocusedField(event: FieldChangeData) {
        currentFocusedFieldsID = event.fieldIdentifier.fieldID
    }
}

struct PageDuplicateListView: View {
    @Binding var currentPageID: String
    let pageOrder: [String]?
    @Environment(\.presentationMode) var presentationMode
    @State var documentEditor: DocumentEditor
    @Binding var pageFieldModels: [String: PageModel]
    
    @State private var showDeleteConfirmation = false
    @State private var pageToDelete: String?
    @State private var deleteWarningMessage: String = ""

    private var pageIDs: [String] {
        if !documentEditor.currentPageOrder.isEmpty {
            return documentEditor.currentPageOrder
        }
        return Array(pageFieldModels.keys)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pages")
                        .font(.title2)
                        .fontWeight(.bold)
                        .darkLightThemeColor()
                    Text("\(pageIDs.count) page\(pageIDs.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                
                Spacer()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.gray)
                        .symbolRenderingMode(.hierarchical)
                })
                .accessibilityIdentifier("ClosePageSelectionSheetIdentifier")
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            Divider()
            
            // Pages List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(pageIDs.enumerated()), id: \.element) { index, pageID in
                        if documentEditor.shouldShow(pageID: pageID) {
                            if let page = documentEditor.firstPageFor(currentPageID: pageID) {
                                PageRowView(
                                    page: page,
                                    pageID: pageID,
                                    isSelected: currentPageID == pageID,
                                    documentEditor: documentEditor,
                                    onSelect: {
                                        currentPageID = pageID
                                        presentationMode.wrappedValue.dismiss()
                                    },
                                    onDuplicate: {
                                        documentEditor.duplicatePage(pageID: pageID)
                                    },
                                    onDelete: {
                                        let (canDelete, warnings) = documentEditor.canDeletePage(pageID: pageID)
                                        handleDeletePage(pageID: pageID, canDelete: canDelete, warnings: warnings)
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Page?"),
                message: Text(deleteWarningMessage.isEmpty ? 
                    "Are you sure you want to delete this page? This action cannot be undone." : 
                    "⚠️ Warning\n\n\(deleteWarningMessage)\n\nThis action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    if let pageID = pageToDelete {
                        let result = documentEditor.deletePage(pageID: pageID, force: true)
                        if result.success {
                            // Close the sheet if we deleted the current page
                            if currentPageID == pageID {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func handleDeletePage(pageID: String, canDelete: Bool, warnings: [String]) {
        guard canDelete else {
            return
        }
        
        pageToDelete = pageID
        deleteWarningMessage = warnings.joined(separator: "\n• ")
        showDeleteConfirmation = true
    }
}

// MARK: - Page Row View
struct PageRowView: View {
    let page: Page
    let pageID: String
    let isSelected: Bool
    let documentEditor: DocumentEditor
    let onSelect: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    private var canDelete: Bool {
        documentEditor.canDeletePage(pageID: pageID).canDelete
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onSelect()
            }
        }) {
            HStack(spacing: 16) {
                // Page Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(page.name ?? "Untitled Page")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isSelected ? .blue : .primary)
                        .lineLimit(1)
                }
                
                Spacer(minLength: 8)
                
                // Action Buttons
                HStack(spacing: 8) {
                    // Duplicate Button
                    if documentEditor.isPageDuplicateEnabled {
                        Button(action: {
                            onDuplicate()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(.blue)
                            }
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .accessibilityIdentifier("PageDuplicateIdentifier")
                    }
                    
                    // Delete Button
                    if documentEditor.isPageDeleteEnabled {
                        Button(action: {
                            onDelete()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(canDelete ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(canDelete ? .red : .gray)
                            }
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .disabled(!canDelete)
                        .accessibilityIdentifier("PageDeleteIdentifier")
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: isSelected ? Color.blue.opacity(0.2) : Color.black.opacity(0.05), 
                           radius: isSelected ? 8 : 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityIdentifier("PageSelectionIdentifier")
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

