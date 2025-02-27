import SwiftUI
import JoyfillModel

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
        FilesView(documentEditor: documentEditor, files: documentEditor.files)
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
            if documentEditor.showPageNavigationView && pageFieldModels.count > 1 {
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

            let pageBinding = Binding(
                get: {
                    pageFieldModels[documentEditor.currentPageID] ?? pageFieldModels.first!.value
                }, set: {
                    pageFieldModels[documentEditor.currentPageID] = $0
                })
            PageView(page: pageBinding, documentEditor: documentEditor)
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

enum FieldListModelType {
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

struct FormView: View {
    @Binding var listModels: [FieldListModel]
    @State var currentFocusedFielsID: String = ""
    @State var lastFocusedFielsID: String? = nil
    let documentEditor: DocumentEditor

    @ViewBuilder
    fileprivate func fieldView(listModel: FieldListModel) -> some View {
        switch listModel.model {
        case .text(let model):
            TextView(textDataModel: model, eventHandler: self)
                .disabled(listModel.fieldEditMode == .readonly)
        case .block(let model):

            DisplayTextView(displayTextDataModel: model)
                .disabled(listModel.fieldEditMode == .readonly)
        case .multiSelect(let model):
            MultiSelectionView(multiSelectionDataModel: model, eventHandler: self, currentFocusedFieldsDataId: currentFocusedFielsID)
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
            ImageView(imageDataModel: model, eventHandler: self)
        case .none:
            EmptyView()
        }
    }

    var body: some View {
        List(listModels, id: \.fieldIdentifier.fieldID) { listModel in
            if documentEditor.shouldShow(fieldID: listModel.fieldIdentifier.fieldID) {
                fieldView(listModel: listModel)
                    .listRowSeparator(.hidden)
                    .buttonStyle(.borderless)
            }
        }
        .listStyle(PlainListStyle())
        .modifier(KeyboardDismissModifier())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: $currentFocusedFielsID.wrappedValue) { newValue in
            guard newValue != nil else { return }
            guard lastFocusedFielsID != newValue else { return }
            if lastFocusedFielsID != nil {
                let fieldEvent = FieldIdentifier(fieldID: lastFocusedFielsID!)
                documentEditor.onBlur(event: fieldEvent)
            }
            lastFocusedFielsID = currentFocusedFielsID
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
        currentFocusedFielsID = event.fieldID
        if lastFocusedFielsID == currentFocusedFielsID {
            return
        } else {
            documentEditor.onFocus(event: event)
        }
    }

    func onUpload(event: UploadEvent) {
        documentEditor.onUpload(event: event)
    }

    private func updateFocusedField(event: FieldChangeData) {
        currentFocusedFielsID = event.fieldIdentifier.fieldID
    }
}

struct PageDuplicateListView: View {
    @Binding var currentPageID: String
    let pageOrder: [String]?
    @Environment(\.presentationMode) var presentationMode
    let documentEditor: DocumentEditor
    @Binding var pageFieldModels: [String: PageModel]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Pages")
                    .foregroundStyle(.gray)
                Spacer()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Close")
                })
                .accessibilityIdentifier("ClosePageSelectionSheetIdentifier")
            }
            ScrollView {
                ForEach(pageOrder ?? [], id: \.self) { pageID in
                    if documentEditor.shouldShow(pageID: pageID) {
                        if let page = documentEditor.firstPageFor(currentPageID: pageID) {
                            VStack(alignment: .leading) {
                                Button(action: {
                                    currentPageID = pageID ?? ""
                                    presentationMode.wrappedValue.dismiss()
                                }, label: {
                                    HStack {
                                        Image(systemName: currentPageID == pageID ? "checkmark.circle.fill" : "circle")
                                        Text(page.name ?? "")
                                            .darkLightThemeColor()
                                    }
                                })
                                .accessibilityIdentifier("PageSelectionIdentifier")
                                Divider()
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    .padding(.vertical, -10)
            )
            .padding(.vertical, 10)
        }
        .padding(.all, 16)
    }
    
    func duplicatePage() {
         // TODO: Append new page in pages
         // TODO: Append new page ID in pageOrder
         // TODO: Append new field Data in field data array
 //        guard var firstPage = pages.first else { return }
 //        firstPage.id = UUID().uuidString
 //        pages.append(firstPage)
     }
}
