import SwiftUI
import JoyfillModel

public struct Form: View {
    let currentPageID: String
    let mode: Mode

    let documentEditor: DocumentEditor
    private var navigation: Bool
    public var events: FormChangeEvent?

    public init(document: Binding<JoyDoc>, mode: Mode = .fill, events: FormChangeEvent? = nil, pageID: String?, navigation: Bool = true) {
        self.events = events
        self.mode = mode
        var pageId = pageID
        let documentEditor = DocumentEditor(document: document.wrappedValue, events: events)
        currentPageID = ((pageID == nil || pageID!.isEmpty) ? documentEditor.firstPageId : "") ?? ""
        self.navigation = navigation
        self.documentEditor = documentEditor
    }

    public init(documentEditor: DocumentEditor, mode: Mode = .fill, events: FormChangeEvent? = nil, pageID: String?, navigation: Bool = true) {
        self.events = events
        self.mode = mode
        currentPageID = ((pageID == nil || pageID!.isEmpty) ? documentEditor.firstPageId : "") ?? ""
        self.navigation = navigation
        self.documentEditor = documentEditor
    }

    public var body: some View {
        FilesView(currentPageID: currentPageID, documentEditor: documentEditor, files: documentEditor.files, mode: mode, showPageNavigationView: navigation)
    }
}

struct FilesView: View {
    let currentPageID: String
    let documentEditor: DocumentEditor
    let files: [File]
    let mode: Mode
    var showPageNavigationView: Bool

    var body: some View {
        FileView(currentPageID: currentPageID, file: files.first, mode: mode, showPageNavigationView: showPageNavigationView, documentEditor: documentEditor)
    }
}

struct FileView: View {
    let currentPageID: String
    let file: File?
    let mode: Mode
    var showPageNavigationView: Bool
    @ObservedObject var documentEditor: DocumentEditor

    var body: some View {
        if let file = file {
            PagesView(currentPageID: currentPageID, pageOrder: file.pageOrder, pageFieldModels: $documentEditor.pageFieldModels, mode: mode, showPageNavigationView: showPageNavigationView, documentEditor: documentEditor)
        }
    }
}

struct PagesView: View {
    @State private var isSheetPresented = false
    @State var currentPageID: String
    let pageOrder: [String]?
    @Binding var pageFieldModels: [String: PageModel]
    let mode: Mode
    var showPageNavigationView: Bool
    @ObservedObject var documentEditor: DocumentEditor

    init(isSheetPresented: Bool = false,
         currentPageID: String,
         pageOrder: [String]?,
         pageFieldModels: Binding<[String : PageModel]>,
         mode: Mode,
         showPageNavigationView: Bool,
         documentEditor: DocumentEditor) {
        self.isSheetPresented = isSheetPresented
        self.currentPageID = currentPageID
        self.pageOrder = pageOrder
        _pageFieldModels = pageFieldModels
        self.mode = mode
        self.showPageNavigationView = showPageNavigationView
        self.documentEditor = documentEditor
    }

    var body: some View {
        VStack(alignment: .leading) {
            if showPageNavigationView && pageFieldModels.count > 1 {
                Button(action: {
                    isSheetPresented = true
                }, label: {
                    HStack {
                        Image(systemName: "chevron.down")
                        Text(documentEditor.firstValidPageFor(currentPageID: currentPageID)?.name ?? "")
                    }
                })
                .accessibilityIdentifier("PageNavigationIdentifier")
                .buttonStyle(.bordered)
                .padding(.leading, 16)
                .sheet(isPresented: $isSheetPresented) {
                    if #available(iOS 16, *) {
                        PageDuplicateListView(currentPageID: $currentPageID, pageOrder: pageOrder, documentEditor: documentEditor, pageFieldModels: $pageFieldModels)
                            .presentationDetents([.medium])
                    } else {
                        PageDuplicateListView(currentPageID: $currentPageID, pageOrder: pageOrder, documentEditor: documentEditor, pageFieldModels: $pageFieldModels)
                    }
                }
            }

            let pageBinding = Binding(
                get: {
                    pageFieldModels[currentPageID] ?? pageFieldModels.first!.value
                }, set: {
                    pageFieldModels[currentPageID] = $0
                })
            PageView(page: pageBinding, mode: mode, documentEditor: documentEditor)
        }
    }
}

struct PageView: View {
    @Binding var page: PageModel
    let mode: Mode
    var documentEditor: DocumentEditor

    var body: some View {
        FormView(listModels: $page.fields, mode: mode, documentEditor: documentEditor)
    }

    func mapWebViewToMobileView(fieldPositions: [FieldPosition]) -> [FieldPosition] {
        let sortedFieldPositions =
        fieldPositions
            .sorted { fp1, fp2 in
                if let y2 = fp2.y, let y1 = fp1.y {
                    return Int(y1) < Int(y2)
                }
                return true
            }

        var resultFieldPositions =  [FieldPosition]()
        for fp in sortedFieldPositions {
            if !resultFieldPositions.contains(where: { $0.field == fp.field }) {
                resultFieldPositions.append(fp)
            }
        }
        return resultFieldPositions
    }
}

struct FormView: View {
    @Binding var listModels: [FieldListModel]
    @State var mode: Mode = .fill
    @State var currentFocusedFielsID: String = ""
    @State var lastFocusedFielsID: String? = nil
    let documentEditor: DocumentEditor

    @ViewBuilder
    fileprivate func fieldView(listModel: FieldListModel) -> some View {
        let fieldPosition: FieldPosition = documentEditor.fieldPosition(fieldID: listModel.fieldID)!

        let fieldData = documentEditor.field(fieldID: listModel.fieldID)

        let fieldEditMode: Mode = ((fieldData?.disabled == true) || (mode == .readonly) ? .readonly : .fill)

        var fieldHeaderModel = (fieldPosition.titleDisplay == nil || fieldPosition.titleDisplay != "none") ? FieldHeaderModel(title: fieldData?.title, required: fieldData?.required, tipDescription: fieldData?.tipDescription, tipTitle: fieldData?.tipTitle, tipVisible: fieldData?.tipVisible) : nil

        switch fieldPosition.type {
        case .text:
            let model = TextDataModel(fieldId: listModel.fieldID,
                                      pageId: listModel.pageID,
                                      fileId: listModel.fileID,
                                      text: fieldData?.value?.text ?? "",
                                      mode: fieldEditMode,
                                      eventHandler: self,
                                      fieldHeaderModel: fieldHeaderModel)
            TextView(textDataModel: model)
                .disabled(fieldEditMode == .readonly)
        case .block:
            let model = DisplayTextDataModel(displayText: fieldData?.value?.text,
                                             fontWeight: fieldPosition.fontWeight,
                                             fieldHeaderModel: fieldHeaderModel)
            DisplayTextView(displayTextDataModel: model)
                .disabled(fieldEditMode == .readonly)
        case .multiSelect:
            let model = MultiSelectionDataModel(fieldId: listModel.fieldID,
                                                pageId: listModel.pageID,
                                                fileId: listModel.fileID,
                                                currentFocusedFieldsDataId: currentFocusedFielsID,
                                                multi: fieldData?.multi,
                                                options: fieldData?.options,
                                                multiSelector: fieldData?.value?.multiSelector,
                                                eventHandler: self,
                                                fieldHeaderModel: fieldHeaderModel)
            MultiSelectionView(multiSelectionDataModel: model)
                .disabled(fieldEditMode == .readonly)
        case .dropdown:
            let model = DropdownDataModel(fieldId: listModel.fieldID,
                                          pageId: listModel.pageID,
                                          fileId: listModel.fileID,
                                          dropdownValue: fieldData?.value?.dropdownValue,
                                          options: fieldData?.options,
                                          eventHandler: self,
                                          fieldHeaderModel: fieldHeaderModel)
            DropdownView(dropdownDataModel: model)
                .disabled(fieldEditMode == .readonly)
        case .textarea:
            let model = MultiLineDataModel(fieldId: listModel.fieldID,
                                           pageId: listModel.pageID,
                                           fileId: listModel.fileID,
                                           multilineText: fieldData?.value?.multilineText,
                                           mode: fieldEditMode,
                                           eventHandler: self,
                                           fieldHeaderModel: fieldHeaderModel)
            MultiLineTextView(multiLineDataModel: model)
                .disabled(fieldEditMode == .readonly)
        case .date:
            let model = DateTimeDataModel(fieldId: listModel.fieldID,
                                          pageId: listModel.pageID,
                                          fileId: listModel.fileID,
                                          value: fieldData?.value,
                                          format: fieldPosition.format,
                                          eventHandler: self,
                                          fieldHeaderModel: fieldHeaderModel)
            DateTimeView(dateTimeDataModel: model)
                .disabled(fieldEditMode == .readonly)
        case .signature:
            let model = SignatureDataModel(fieldId: listModel.fieldID,
                                           pageId: listModel.pageID,
                                           fileId: listModel.fileID,
                                           signatureURL: fieldData?.value?.signatureURL ?? "",
                                           eventHandler: self,
                                           fieldHeaderModel: fieldHeaderModel)
            SignatureView(signatureDataModel: model)
                .disabled(fieldEditMode == .readonly)
        case .number:
            let model = NumberDataModel(fieldId: listModel.fieldID,
                                        pageId: listModel.pageID,
                                        fileId: listModel.fileID,
                                        number: fieldData?.value?.number,
                                        mode: fieldEditMode,
                                        eventHandler: self,
                                        fieldHeaderModel: fieldHeaderModel)
            NumberView(numberDataModel: model)
                .disabled(fieldEditMode == .readonly)
        case .chart:
            let model = ChartDataModel(fieldId: fieldData?.id,
                                       pageId: listModel.pageID,
                                       fileId: listModel.fileID,
                                       valueElements: fieldData?.value?.valueElements,
                                       yTitle: fieldData?.yTitle,
                                       yMax: fieldData?.yMax,
                                       yMin: fieldData?.yMin,
                                       xTitle: fieldData?.xTitle,
                                       xMax: fieldData?.xMax,
                                       xMin: fieldData?.xMin,
                                       mode: fieldEditMode,
                                       documentEditor: documentEditor,
                                       eventHandler: self,
                                       fieldHeaderModel: fieldHeaderModel)
            ChartView(chartDataModel: model)
        case .richText:
            let model = RichTextDataModel(text: fieldData?.value?.text,
                                          eventHandler: self,
                                          fieldHeaderModel: fieldHeaderModel)
            RichTextView(richTextDataModel: model)
                .disabled(fieldEditMode == .readonly)
        case .table:
            let model = TableDataModel(fieldHeaderModel: fieldHeaderModel,
                                       mode: fieldEditMode,
                                       documentEditor: documentEditor,
                                       listModel: listModel,
                                       eventHandler: self)
            TableQuickView(tableDataModel: model)
        case .image:
            let model = ImageDataModel(fieldId: listModel.fieldID,
                                       pageId: listModel.pageID,
                                       fileId: listModel.fileID,
                                       multi: fieldData?.multi,
                                       primaryDisplayOnly: fieldPosition.primaryDisplayOnly,
                                       valueElements: fieldData?.value?.valueElements?.map { element in
                                                   ValueElementLocal(
                                                       id: element.id ?? "",
                                                       url: element.url,
                                                       fileName: element.fileName,
                                                       filePath: element.filePath,
                                                       deleted: element.deleted,
                                                       title: element.title,
                                                       description: element.description,
                                                       points: element.points,
                                                       cells: element.cells?.mapValues { convertToValueUnionLocal($0) }
                                                   )
                                               },
                                       mode: fieldEditMode,
                                       eventHandler: self,
                                       fieldHeaderModel: fieldHeaderModel)
            ImageView(imageDataModel: model)
        case .none:
            EmptyView()
        case .unknown:
            EmptyView()
        }
    }
    
    func convertToValueUnionLocal(_ valueUnion: ValueUnion) -> ValueUnionLocal {
        switch valueUnion {
        case .double(let value):
            return .double(value)
        case .string(let value):
            return .string(value)
        case .array(let value):
            return .array(value)
        case .valueElementArray(let elements):
            return .valueElementArray(elements.map { $0.toLocal() })
        case .bool(let value):
            return .bool(value)
        case .null:
            return .null
        case .dictionary(_):
            return .null
        }
    }

    var body: some View {
        List(listModels, id: \.fieldID) { listModel in
            if documentEditor.shouldShow(fieldID: listModel.fieldID) {
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
        currentFocusedFielsID = event.fieldID
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
