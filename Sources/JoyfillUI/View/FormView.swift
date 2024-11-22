import SwiftUI
import JoyfillModel

public struct Form: View {
    @Binding public var document: JoyDoc
    @State public var currentPageID: String
    public let mode: Mode

    let documentEditor: DocumentEditor
    private var navigation: Bool
    public var events: FormChangeEvent?

    public init(document: Binding<JoyDoc>, mode: Mode = .fill, events: FormChangeEvent? = nil, pageID: String?, navigation: Bool = true) {
        self.events = events
        self.mode = mode
        _document = document
        var pageId = pageID
        let documentEditor = DocumentEditor(document: document.wrappedValue)
        if let pageID = pageID, pageID != "" {
            _currentPageID = State(initialValue: pageID)
        } else {
            _currentPageID = State(initialValue: documentEditor.firstPageId ?? "")
        }
        self.navigation = navigation
        self.documentEditor = documentEditor
    }

    public init(documentEditor: DocumentEditor, mode: Mode = .fill, events: FormChangeEvent? = nil, pageID: String?, navigation: Bool = true) {
        self.events = events
        self.mode = mode

        _document = Binding(get: { documentEditor.document }, set: { _ in })
        var pageId = pageID
        if let pageID = pageID, pageID != "" {
            _currentPageID = State(initialValue: pageID)
        } else {
            _currentPageID = State(initialValue: documentEditor.firstPageId ?? "")
        }
        self.navigation = navigation
        self.documentEditor = documentEditor
    }

    public var body: some View {
        FilesView(currentPageID: $currentPageID, documentEditor: documentEditor, files: documentEditor.files, mode: mode, events: self, showPageNavigationView: navigation)
    }

    private func updateValue(event: FieldChangeEvent) {
        if var field = documentEditor.field(fieldID: event.fieldID) {
            field.value = event.updateValue
            if let chartData = event.chartData {
                field.xMin = chartData.xMin
                field.yMin = chartData.yMin
                field.xMax = chartData.xMax
                field.yMax = chartData.yMax
                field.xTitle = chartData.xTitle
                field.yTitle = chartData.yTitle
            }
            documentEditor.updatefield(field: field)
            document.fields = documentEditor.allFields
        }
    }
}

extension Form: FormChangeEventInternal {
    func addRow(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        updateValue(event: event)
        var changes = [Change]()
        let field = documentEditor.field(fieldID: event.fieldID)!
        let fieldPosition = documentEditor.fieldPosition(fieldID: event.fieldID)!
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowCreate",
                                _id: documentEditor.documentID!,
                                identifier: documentEditor.documentIdentifier,
                                fileId: event.fileID!,
                                pageId: event.pageID!,
                                fieldId: event.fieldID,
                                fieldIdentifier: field.identifier!,
                                fieldPositionId: fieldPosition.id!,
                                change: addRowChanges(fieldData: field, targetRow: targetRow),
                                createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }

        events?.onChange(changes: changes, document: documentEditor.document)
    }

    func deleteRow(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        updateValue(event: event)
        var changes = [Change]()
        let field = documentEditor.field(fieldID: event.fieldID)!
        let fieldPosition = documentEditor.fieldPosition(fieldID: event.fieldID)!
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowDelete",
                                _id: documentEditor.documentID!,
                                identifier: documentEditor.documentIdentifier,
                                fileId: event.fileID!,
                                pageId: event.pageID!,
                                fieldId: event.fieldID,
                                fieldIdentifier: field.identifier!,
                                fieldPositionId: fieldPosition.id!,
                                change: ["rowId": targetRow.id],
                                createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }

        events?.onChange(changes: changes, document: documentEditor.document)
    }

    func moveRow(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        updateValue(event: event)
        var changes = [Change]()
        let field = documentEditor.field(fieldID: event.fieldID)!
        let fieldPosition = documentEditor.fieldPosition(fieldID: event.fieldID)!
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowMove",
                                _id: documentEditor.documentID!,
                                identifier: documentEditor.documentIdentifier,
                                fileId: event.fileID!,
                                pageId: event.pageID!,
                                fieldId: event.fieldID,
                                fieldIdentifier: field.identifier!,
                                fieldPositionId: fieldPosition.id!,
                                change: [
                                    "rowId": targetRow.id,
                                    "targetRowIndex": targetRow.index,
                                ],
                                createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }
        events?.onChange(changes: changes, document: documentEditor.document)
    }

    func onChange(event: FieldChangeEvent) {
        updateValue(event: event)
        let field = documentEditor.field(fieldID: event.fieldID)!
        let fieldPosition = documentEditor.fieldPosition(fieldID: event.fieldID)!
        var change = Change(v: 1,
                            sdk: "swift",
                            target: "field.update",
                            _id: documentEditor.documentID!,
                            identifier: documentEditor.documentIdentifier,
                            fileId: event.fileID!,
                            pageId: event.pageID!,
                            fieldId: event.fieldID,
                            fieldIdentifier: field.identifier!,
                            fieldPositionId: fieldPosition.id!,
                            change: changes(fieldData: field),
                            createdOn: Date().timeIntervalSince1970)
        events?.onChange(changes: [change], document: documentEditor.document)
    }

    private func changes(fieldData: JoyDocField) -> [String: Any] {
        switch fieldData.type {
        case "chart":
            return chartChanges(fieldData: fieldData)
        default:
            return ["value": fieldData.value!.dictionary]
        }
    }

    private func chartChanges(fieldData: JoyDocField) -> [String: Any] {
        var valueDict = ["value": fieldData.value!.dictionary]
        valueDict["yTitle"] = fieldData.yTitle
        valueDict["yMin"] = fieldData.yMin
        valueDict["yMax"] = fieldData.yMax
        valueDict["xTitle"] = fieldData.xTitle
        valueDict["xMin"] = fieldData.xMin
        valueDict["xMax"] = fieldData.xMax
        return valueDict
    }

    private func addRowChanges(fieldData: JoyDocField, targetRow: TargetRowModel) -> [String: Any] {
        let lastValueElement = fieldData.value!.valueElements?.first(where: { valueElement in
            valueElement.id == targetRow.id
        })
        var valueDict: [String: Any] = ["row": lastValueElement?.anyDictionary]
        valueDict["targetRowIndex"] = targetRow.index
        return valueDict
    }

    func onFocus(event: FieldEventInternal) {
        // TODO:
//        events?.onFocus(event: event)
    }
    
    func onBlur(event: FieldEventInternal) {
        // TODO:
//        events?.onBlur(event: event)
    }
    
    func onUpload(event: JoyfillModel.UploadEvent) {
        events?.onUpload(event: event)
    }
}

struct FilesView: View {
    @Binding var currentPageID: String
    let documentEditor: DocumentEditor
    let files: [File]
    let mode: Mode
    let events: FormChangeEventInternal?
    var showPageNavigationView: Bool

    var body: some View {
        FileView(currentPageID: $currentPageID, file: files.first, mode: mode, events: events, showPageNavigationView: showPageNavigationView, documentEditor: documentEditor)
    }
}

struct FileView: View {
    @Binding var currentPageID: String
    let file: File?
    let mode: Mode
    let events: FormChangeEventInternal?
    var showPageNavigationView: Bool
    let documentEditor: DocumentEditor

    var body: some View {
        if let file = file {
            PagesView(currentPageID: $currentPageID, pageOrder: file.pageOrder, pages: documentEditor.pagesForCurrentView, mode: mode, events: self, showPageNavigationView: showPageNavigationView, documentEditor: documentEditor)
        }
    }
}

extension FileView: FormChangeEventInternal {
    func addRow(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        var event = event
        event.fileID = file?.id
        events?.addRow(event: event, targetRowIndexes: targetRowIndexes)
    }

    func moveRow(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        var event = event
        event.fileID = file?.id
        events?.moveRow(event: event, targetRowIndexes: targetRowIndexes)
    }

    func deleteRow(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        var event = event
        event.fileID = file?.id
        events?.deleteRow(event: event, targetRowIndexes: targetRowIndexes)
    }

    func onChange(event: FieldChangeEvent) {
        var event = event
        event.fileID = file?.id
        events?.onChange(event: event)
    }

    func onFocus(event: FieldEventInternal) {
        var event = event
        event.fileID = file?.id
        events?.onFocus(event: event)
    }

    func onBlur(event: FieldEventInternal) {
        var event = event
        event.fileID = file?.id
        events?.onBlur(event: event)
    }

    func onUpload(event: JoyfillModel.UploadEvent) {
        var event = event
        event.file = file
        events?.onUpload(event: event)
    }
}

/// A view that represents a collection of pages.
struct PagesView: View {
    @State private var isSheetPresented = false
    @Binding var currentPageID: String
    let pageOrder: [String]?
    let pages: [Page]
    let mode: Mode
    let events: FormChangeEventInternal?
    var showPageNavigationView: Bool
    let documentEditor: DocumentEditor

    /// The body of the `PagesView`. This is a SwiftUI view that represents a collection of pages.
    ///
    /// - Returns: A SwiftUI view representing the pages view.
    var body: some View {
        VStack(alignment: .leading) {
            if showPageNavigationView && pages.count > 1 {
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
                        PageDuplicateListView(currentPageID: $currentPageID, pageOrder: pageOrder, documentEditor: documentEditor, pages: pages)
                            .presentationDetents([.medium])
                    } else {
                        PageDuplicateListView(currentPageID: $currentPageID, pageOrder: pageOrder, documentEditor: documentEditor, pages: pages)
                    }
                }
            }
            if let page = documentEditor.firstValidPageFor(currentPageID: currentPageID) {
                PageView(page: page, mode: mode, events: events, documentEditor: documentEditor)
            }
        }
    }

}

/// A `View` that represents a page in a form.
struct PageView: View {
    let page: Page
    let mode: Mode
    let events: FormChangeEventInternal?
    let documentEditor: DocumentEditor

    /// The body of the `PageView`.
    ///
    /// If the page has field positions, it creates a `FormView` with the field positions mapped from web view to mobile view.
    var body: some View {
        if let fieldPositions = page.fieldPositions {
            let resultFieldPositions = mapWebViewToMobileView(fieldPositions: fieldPositions)
            let binding = Binding {
                resultFieldPositions
            } set: { _ in
                
            }
            FormView(fieldPositions: binding, mode: mode, eventHandler: self, documentEditor: documentEditor)
        }
    }
    
    /// Maps the field positions from web view to mobile view.
    ///
    /// - Parameter fieldPositions: An array of `FieldPosition` objects representing the positions of fields in a web view.
    /// - Returns: An array of `FieldPosition` objects representing the positions of fields in a mobile view.
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

extension PageView: FormChangeEventInternal {
    func addRow(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        var event = event
        event.pageID = page.id
        events?.addRow(event: event, targetRowIndexes: targetRowIndexes)
    }

    func moveRow(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        var event = event
        event.pageID = page.id
        events?.moveRow(event: event, targetRowIndexes: targetRowIndexes)
    }

    func deleteRow(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        var event = event
        event.pageID = page.id
        events?.deleteRow(event: event, targetRowIndexes: targetRowIndexes)
    }

    func onChange(event: FieldChangeEvent) {
        var event = event
        event.pageID = page.id
        events?.onChange(event: event)
    }
    
    func onFocus(event: FieldEventInternal) {
        var event = event
        event.pageID = page.id
        events?.onFocus(event: event)
    }
    
    func onBlur(event: FieldEventInternal) {
        var event = event
        event.pageID = page.id
        events?.onBlur(event: event)
    }
    
    func onUpload(event: JoyfillModel.UploadEvent) {
        var event = event
        event.page = page
        events?.onUpload(event: event)
    }
}

/// `FieldDependency` is a struct that encapsulates the dependencies of a field in a form.
///
/// It contains the mode of the form, an event handler for field changes, the position of the field, and the data of the field.
struct FieldDependency {
    /// The mode in which the form is being displayed.
    let mode: Mode
    
    /// The event handler that handles field change events.
    let eventHandler: FieldChangeEvents
    
    /// The position of the field in the form.
    let fieldPosition: FieldPosition
    
    /// The data of the field. This is optional and can be `nil`.
    var fieldData: JoyDocField?
}

struct FormView: View {
    @Binding var fieldPositions: [FieldPosition]
    @State var mode: Mode = .fill
    let eventHandler: FormChangeEventInternal?
    @State var currentFocusedFielsID: String = ""
    @State var lastFocusedFielsID: String? = nil
    let documentEditor: DocumentEditor

    @ViewBuilder
    fileprivate func fieldView(fieldPosition: FieldPosition) -> some View {
        let fieldData = documentEditor.field(fieldID: fieldPosition.field)

        let fieldEditMode: Mode = ((fieldData?.disabled == true) || (mode == .readonly) ? .readonly : .fill)
        let fieldDependency = FieldDependency(mode: fieldEditMode, eventHandler: self, fieldPosition: fieldPosition, fieldData: fieldData)
        var fieldHeaderModel = (fieldDependency.fieldPosition.titleDisplay == nil || fieldDependency.fieldPosition.titleDisplay != "none") ? FieldHeaderModel(title: fieldData?.title, required: fieldData?.required, tipDescription: fieldData?.tipDescription, tipTitle: fieldData?.tipTitle, tipVisible: fieldData?.tipVisible) : nil
        
   switch fieldPosition.type {
        case .text:
            TextView(textDataModel: TextDataModel(text: fieldDependency.fieldData?.value?.text ?? "",
                                                  mode: fieldDependency.mode,
                                                  eventHandler: fieldDependency.eventHandler,
                                                  fieldHeaderModel: fieldHeaderModel))
                .disabled(fieldEditMode == .readonly)
        case .block:
            DisplayTextView(displayTextDataModel: DisplayTextDataModel(displayText: fieldDependency.fieldData?.value?.text,
                                                                       fontWeight: fieldDependency.fieldPosition.fontWeight,
                                                                       fieldHeaderModel: fieldHeaderModel))
                .disabled(fieldEditMode == .readonly)
        case .multiSelect:
            MultiSelectionView(fieldDependency: fieldDependency, currentFocusedFielsID: currentFocusedFielsID)
                .disabled(fieldEditMode == .readonly)
        case .dropdown:
            DropdownView(fieldDependency: fieldDependency)
                .disabled(fieldEditMode == .readonly)
        case .textarea:
            MultiLineTextView(fieldDependency: fieldDependency)
                .disabled(fieldEditMode == .readonly)
        case .date:
            DateTimeView(fieldDependency: fieldDependency)
                .disabled(fieldEditMode == .readonly)
        case .signature:
            SignatureView(fieldDependency: fieldDependency)
                .disabled(fieldEditMode == .readonly)
        case .number:
            NumberView(numberDataModel: NumberDataModel(number: fieldData?.value?.number,
                                                        mode: fieldDependency.mode,
                                                        eventHandler: fieldDependency.eventHandler,
                                                        fieldHeaderModel: fieldHeaderModel))
                .disabled(fieldEditMode == .readonly)
        case .chart:
            ChartView(fieldDependency: fieldDependency)
        case .richText:
            RichTextView(fieldDependency: fieldDependency)
                .disabled(fieldEditMode == .readonly)
        case .table:
            TableQuickView(fieldDependency: fieldDependency)
        case .image:
            ImageView(fieldDependency: fieldDependency)
        case .none:
            EmptyView()
        case .unknown:
            EmptyView()
        }
    }

    var body: some View {
        List(fieldPositions, id: \.field) { fieldPosition in
            if documentEditor.shouldShow(fieldID: fieldPosition.field) {
                fieldView(fieldPosition: fieldPosition)
                    .listRowSeparator(.hidden)
                    .buttonStyle(.borderless)
            }
        }
        .listStyle(PlainListStyle())
        .gesture(DragGesture().onChanged({ _ in
            dismissKeyboardOnScroll()
        }))
        .onChange(of: $currentFocusedFielsID.wrappedValue) { newValue in
            guard newValue != nil else { return }
            guard lastFocusedFielsID != newValue else { return }
            if lastFocusedFielsID != nil {
                let fieldEvent = FieldEventInternal(fieldID: lastFocusedFielsID!)
                eventHandler?.onBlur(event: fieldEvent)
            }
            let fieldEvent = FieldEventInternal(fieldID: newValue)
            eventHandler?.onFocus(event: fieldEvent)
        }
    }
    private func dismissKeyboardOnScroll() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension FormView: FieldChangeEvents {

    func deleteRow(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        updateFocusedField(event: event)
        eventHandler?.deleteRow(event: event, targetRowIndexes: targetRowIndexes)
    }

    func moveRow(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        updateFocusedField(event: event)
        eventHandler?.moveRow(event: event, targetRowIndexes: targetRowIndexes)
    }

    func addRow(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        updateFocusedField(event: event)
        eventHandler?.addRow(event: event, targetRowIndexes: targetRowIndexes)
    }

    func onChange(event: FieldChangeEvent) {
        updateFocusedField(event: event)
        eventHandler?.onChange(event: event)
    }

    func onFocus(event: FieldEventInternal) {
        lastFocusedFielsID = currentFocusedFielsID
        currentFocusedFielsID = event.fieldID
    }

    func onUpload(event: UploadEvent) {
        eventHandler?.onUpload(event: event)
    }

    private func updateFocusedField(event: FieldChangeEvent) {
        currentFocusedFielsID = event.fieldID
    }
}

struct PageDuplicateListView: View {
    @Binding var currentPageID: String
    let pageOrder: [String]?
    @Environment(\.presentationMode) var presentationMode
    let documentEditor: DocumentEditor
    let pages: [Page]

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
