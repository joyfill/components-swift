import SwiftUI
import JoyfillModel


public struct Form: View {
    ///  The JoyDoc JSON object to load into the SDK. Must be in the JoyDoc JSON data structure.
    ///
    ///  The SDK uses object reference equality checks to determine if the `doc` or any of its internal `pages` or `fields` have changed in the JSON.
    ///  Ensure you’re creating new object instances when updating the document, pages, or fields before passing the updated `doc` JSON back to the SDK.
    ///  This will ensure your changes are properly detected and reflected in the SDK.
    @Binding public var document: JoyDoc
    
    /// Enables and disables certain JoyDoc functionality and features.
    ///
    /// The mode of the form default is `fill`.
    ///
    /// Options:
    /// - `fill` :  The mode where you simply input the field data into the form.
    /// - `readonly` :  The mode where everything in the form is set to read-only.
    @State public var mode: Mode
    
    /// Specify the page to display in the form.
    ///
    /// Utilize the `_id` property of a Page object. For instance, `page._id`.
    /// If the page is not found within the `doc`, it will fallback to displaying the first page in the `pages` array.
    /// You can use this property to navigate to a specific page in the form.
    @State public var currentPageID: String

    private var navigation: Bool

    ///  Used to listen to form events.
    public var events: FormChangeEvent?

    /// Creates a new `Form` view with the given document, mode, events, and page ID.
    ///
    /// - Parameters:
    ///   - document: The `JoyDoc` object to load into the SDK.
    ///   - mode: The mode of the form. The default is `fill`.
    ///   - events: The events delegate for the form.
    ///   - pageID: The ID of the page to display in the form.
    public init(document: Binding<JoyDoc>, mode: Mode = .fill, events: FormChangeEvent? = nil, pageID: String?, navigation: Bool = true) {
        self.events = events
        _mode = State(initialValue: mode)
        _document = document
        var pageId = pageID
        if let pageID = pageID, pageID != "" {
            _currentPageID = State(initialValue: pageID)
        } else {
            _currentPageID = State(initialValue: document.wrappedValue.firstPageId ?? "")
        }
        self.navigation = navigation
    }
    
    /**
     A SwiftUI view representing a form view.
     
     Use this view to display a form with files.
     
     - Parameters:
     - fieldsData: The data for the form fields.
     - files: The files associated with the form.
     - mode: The mode of the form view.
     - events: The events delegate for the form view.
     - currentPageID: The ID of the current page.
     
     - Returns: A SwiftUI view representing the form view.
     */
    public var body: some View {
        FilesView(fieldsData: $document.fields, document: $document, files: document.files, mode: mode, events: self, currentPageID: $currentPageID, showPageNavigationView: navigation)
    }
}

extension Form: FormChangeEventInternal {
    public func addRow(event: JoyfillModel.FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        var changes = [Change]()
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowCreate",
                                _id: document.id!,
                                identifier: document.identifier,
                                fileId: event.file!.id!,
                                pageId: event.page!.id!,
                                fieldId: event.field!.id!,
                                fieldIdentifier: event.field!.identifier!,
                                fieldPositionId: event.fieldPosition.id!,
                                change: addRowChanges(fieldData: event.field!, targetRow: targetRow),
                                createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }

        events?.onChange(changes: changes, document: document)
    }


    public func deleteRow(event: JoyfillModel.FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        var changes = [Change]()
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowDelete",
                                _id: document.id!,
                                identifier: document.identifier,
                                fileId: event.file!.id!,
                                pageId: event.page!.id!,
                                fieldId: event.field!.id!,
                                fieldIdentifier: event.field!.identifier!,
                                fieldPositionId: event.fieldPosition.id!,
                                change: ["rowId": targetRow.id],
                                createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }

        events?.onChange(changes: changes, document: document)
    }

    public func moveRow(event: JoyfillModel.FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        var changes = [Change]()
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowMove",
                                _id: document.id!,
                                identifier: document.identifier,
                                fileId: event.file!.id!,
                                pageId: event.page!.id!,
                                fieldId: event.field!.id!,
                                fieldIdentifier: event.field!.identifier!,
                                fieldPositionId: event.fieldPosition.id!,
                                change: [
                                    "rowId": targetRow.id,
                                    "targetRowIndex": targetRow.index,
                                ],
                                createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }

        events?.onChange(changes: changes, document: document)
    }

    public func onChange(event: JoyfillModel.FieldChangeEvent) {
        var change = Change(v: 1,
                            sdk: "swift",
                            target: "field.update",
                            _id: document.id!,
                            identifier: document.identifier,
                            fileId: event.file!.id!,
                            pageId: event.page!.id!,
                            fieldId: event.field!.id!,
                            fieldIdentifier: event.field!.identifier!,
                            fieldPositionId: event.fieldPosition.id!,
                            change: changes(fieldData: event.field!),
                            createdOn: Date().timeIntervalSince1970)
        events?.onChange(changes: [change], document: document)
    }

    /// Returns the changes for the given field data.
    /// - Parameter fieldData: The field data containing information about the field.
    /// - Returns: A dictionary containing the changes for the field.
    private func changes(fieldData: JoyDocField) -> [String: Any] {
        switch fieldData.type {
        case "chart":
            return chartChanges(fieldData: fieldData)
        default:
            return ["value": fieldData.value!.dictionary]
        }
    }

    /// Returns a dictionary containing the changes for a chart based on the given field data.
    ///
    /// - Parameters:
    ///   - fieldData: The field data used to generate the chart changes.
    ///
    /// - Returns: A dictionary containing the chart changes.
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

    /// Adds row changes to the form view.
    ///
    /// - Parameter fieldData: The field data containing the value elements.
    /// - Returns: A dictionary containing the row changes.
    private func addRowChanges(fieldData: JoyDocField, targetRow: TargetRowModel) -> [String: Any] {
        let lastValueElement = fieldData.value!.valueElements?.first(where: { valueElement in
            valueElement.id == targetRow.id
        })
        var valueDict: [String: Any] = ["row": lastValueElement?.anyDictionary]
        valueDict["targetRowIndex"] = targetRow.index
        return valueDict
    }

    public func onFocus(event: JoyfillModel.FieldEvent) {
        events?.onFocus(event: event)
    }
    
    public func onBlur(event: JoyfillModel.FieldEvent) {
        events?.onBlur(event: event)
    }
    
    public func onUpload(event: JoyfillModel.UploadEvent) {
        events?.onUpload(event: event)
    }
}

/// A view that displays a list of files.
///
/// Use `FilesView` to display a list of files along with other form fields.
struct FilesView: View {
    /// The `JoyDocField` objects that represent the data for each field in the form.
    @Binding var fieldsData: [JoyDocField]
    @Binding public var document: JoyDoc
    
    /// The `File` objects that represent the files to be displayed.
    var files: [File]
    
    /// The mode of the form.
    let mode: Mode
    
    /// The events delegate for the form. This is used to listen to form events.
    let events: FormChangeEventInternal?
    
    /// The ID of the current page being displayed in the form.
    @Binding var currentPageID: String

    var showPageNavigationView: Bool

    /// The body of the `FilesView`. This is a SwiftUI view that represents a collection of files.
    ///
    /// - Returns: A SwiftUI view representing the files view.
    var body: some View {
        FileView(fieldsData: $fieldsData, document: $document, file: files.first, mode: mode, events: events, currentPageID: $currentPageID, showPageNavigationView: showPageNavigationView)
    }
}

/// A view that represents a single `file`.
///
/// It uses a `JoyDocField` object, a `File` object, a `Mode`, a `FormChangeEventInternal`, and a `currentPageID` to manage and display the file.
struct FileView: View {
    @Binding var fieldsData: [JoyDocField]
    @Binding public var document: JoyDoc
    var file: File?
    let mode: Mode
    let events: FormChangeEventInternal?
    @Binding var currentPageID: String
    var showPageNavigationView: Bool

    /// The body of the `FileView`. This is a SwiftUI view that represents a single file.
    ///
    /// - Returns: A SwiftUI view representing the file view.
    var body: some View {
        if let file = file {
            PagesView(document: $document, fieldsData: $fieldsData, currentPageID: $currentPageID, pages: $document.pagesForCurrentView, pageOrder: file.pageOrder, mode: mode, events: self, showPageNavigationView: showPageNavigationView)
        }
    }
}

extension FileView: FormChangeEventInternal {
    func addRow(event: JoyfillModel.FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        var event = event
        event.file = file
        events?.addRow(event: event, targetRowIndexes: targetRowIndexes)
    }

    func moveRow(event: JoyfillModel.FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        var event = event
        event.file = file
        events?.moveRow(event: event, targetRowIndexes: targetRowIndexes)
    }

    func deleteRow(event: JoyfillModel.FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        var event = event
        event.file = file
        events?.deleteRow(event: event, targetRowIndexes: targetRowIndexes)
    }

    func onChange(event: JoyfillModel.FieldChangeEvent) {
        var event = event
        event.file = file
        events?.onChange(event: event)
    }

    func onFocus(event: JoyfillModel.FieldEvent) {
        var event = event
        event.file = file
        events?.onFocus(event: event)
    }

    func onBlur(event: JoyfillModel.FieldEvent) {
        var event = event
        event.file = file
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
    @Binding public var document: JoyDoc
    @Binding var fieldsData: [JoyDocField]
    @Binding var currentPageID: String
    @Binding var pages: [Page]
    @State var pageOrder: [String]?
    let mode: Mode
    let events: FormChangeEventInternal?
    @State private var isSheetPresented = false
    var showPageNavigationView: Bool

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
                        Text(document.firstValidPageFor(currentPageID: currentPageID)?.name ?? "")
                    }
                })
                .accessibilityIdentifier("PageNavigationIdentifier")
                .buttonStyle(.bordered)
                .padding(.leading, 16)
                .sheet(isPresented: $isSheetPresented) {
                    if #available(iOS 16, *) {
                        PageDuplicateListView(document: $document, pages: $pages, currentPageID: $currentPageID, pageOrder: $pageOrder)
                            .presentationDetents([.medium])
                    } else {
                        PageDuplicateListView(document: $document, pages: $pages, currentPageID: $currentPageID, pageOrder: $pageOrder)
                    }
                }
            }
            if let page = document.firstValidPageFor(currentPageID: currentPageID) {
                PageView(document: $document, fieldsData: $fieldsData, page: page, mode: mode, events: events)
            }
        }
    }

}

/// A `View` that represents a page in a form.
struct PageView: View {
    @Binding public var document: JoyDoc
    @Binding var fieldsData: [JoyDocField]
    let page: Page
    let mode: Mode
    let events: FormChangeEventInternal?

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
            FormView(document: $document, fieldPositions: binding, fieldsData: $fieldsData, mode: mode, eventHandler: self)
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
    func addRow(event: JoyfillModel.FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        var event = event
        event.page = page
        events?.addRow(event: event, targetRowIndexes: targetRowIndexes)
    }

    func moveRow(event: JoyfillModel.FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        var event = event
        event.page = page
        events?.moveRow(event: event, targetRowIndexes: targetRowIndexes)
    }

    func deleteRow(event: JoyfillModel.FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        var event = event
        event.page = page
        events?.deleteRow(event: event, targetRowIndexes: targetRowIndexes)
    }

    func onChange(event: JoyfillModel.FieldChangeEvent) {
        var event = event
        event.page = page
        events?.onChange(event: event)
    }
    
    func onFocus(event: JoyfillModel.FieldEvent) {
        var event = event
        event.page = page
        events?.onFocus(event: event)
    }
    
    func onBlur(event: JoyfillModel.FieldEvent) {
        var event = event
        event.page = page
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
    @Binding public var document: JoyDoc
    @Binding var fieldPositions: [FieldPosition]
    @Binding var fieldsData: [JoyDocField]
    @State var mode: Mode = .fill
    let eventHandler: FormChangeEventInternal?
    @State var currentFocusedFielsData: JoyDocField? = nil
    @State var lastFocusedFielsData: JoyDocField? = nil

    @ViewBuilder
    fileprivate func fieldView(fieldPosition: FieldPosition) -> some View {
        let fieldData = fieldsData.first(where: {
            $0.id == fieldPosition.field
        })
        let fieldEditMode: Mode = ((fieldData?.disabled == true) || (mode == .readonly) ? .readonly : .fill)
        let fieldDependency = FieldDependency(mode: fieldEditMode, eventHandler: self, fieldPosition: fieldPosition, fieldData: fieldData)
        let fieldHeaderModel = FieldHeaderModel(title: fieldData?.title,
                                                required: fieldData?.required,
                                                tipDescription: fieldData?.tipDescription,
                                                tipTitle: fieldData?.tipTitle,
                                                tipVisible: fieldData?.tipVisible)
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
            MultiSelectionView(fieldDependency: fieldDependency, currentFocusedFielsData: currentFocusedFielsData)
                .disabled(fieldEditMode == .readonly)
        case .dropdown:
            DropdownView(fieldDependency: fieldDependency)
                .disabled(fieldEditMode == .readonly)
        case .textarea:
            MultiLineTextView(fieldDependency: fieldDependency)
                .disabled(fieldEditMode == .readonly)
        case .date:
            DateTimeView(dateTimeDataModel: DateTimeDataModel(value: fieldData?.value,
                                                              format: fieldDependency.fieldPosition.format,
                                                              eventHandler: fieldDependency.eventHandler,
                                                              fieldHeaderModel: fieldHeaderModel))
                .disabled(fieldEditMode == .readonly)
        case .signature:
            SignatureView(fieldDependency: fieldDependency)
                .disabled(fieldEditMode == .readonly)
        case .number:
            NumberView(fieldDependency: fieldDependency)
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
        }
    }

    var body: some View {
        List(fieldPositions, id: \.field) { fieldPosition in
            let fieldData = fieldsData.first(where: {
                $0.id == fieldPosition.field
            })

            if DocumentEngine.shouldShowItem(fields: document.fields, logic: fieldData?.logic,isItemHidden: fieldData?.hidden) {
                fieldView(fieldPosition: fieldPosition)
                    .listRowSeparator(.hidden)
                    .buttonStyle(.borderless)
            }
        }
        .listStyle(PlainListStyle())
        .gesture(DragGesture().onChanged({ _ in
            dismissKeyboardOnScroll()
        }))
        .onChange(of: currentFocusedFielsData) { newValue in
            guard newValue != nil else { return }
            guard lastFocusedFielsData != newValue else { return }
            if lastFocusedFielsData != nil {
                let fieldEvent = FieldEvent(field: lastFocusedFielsData)
                eventHandler?.onBlur(event: fieldEvent)
            }
            let fieldEvent = FieldEvent(field: newValue)
            eventHandler?.onFocus(event: fieldEvent)
        }
    }
    private func dismissKeyboardOnScroll() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension FormView: FieldChangeEvents {

    func deleteRow(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        currentFocusedFielsData = event.field
        let temp = fieldsData.compactMap { data in
            if data.id == event.field?.id {
                return event.field
            }
            return data
        }
        fieldsData.removeAll()
        self.fieldsData = temp
        eventHandler?.deleteRow(event: event, targetRowIndexes: targetRowIndexes)
    }

    func moveRow(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        currentFocusedFielsData = event.field
        let temp = fieldsData.compactMap { data in
            if data.id == event.field?.id {
                return event.field
            }
            return data
        }
        fieldsData.removeAll()
        self.fieldsData = temp
        eventHandler?.moveRow(event: event, targetRowIndexes: targetRowIndexes)
    }

    func addRow(event: JoyfillModel.FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        currentFocusedFielsData = event.field
        let temp = fieldsData.compactMap { data in
            if data.id == event.field?.id {
                return event.field
            }
            return data
        }
        fieldsData.removeAll()
        self.fieldsData = temp
        eventHandler?.addRow(event: event, targetRowIndexes: targetRowIndexes)
    }

    func onChange(event: FieldChangeEvent) {
        currentFocusedFielsData = event.field
        let temp = fieldsData.compactMap { data in
            if data.id == event.field?.id {
                return event.field
            }
            return data
        }
        fieldsData.removeAll()
        self.fieldsData = temp
        eventHandler?.onChange(event: event)
    }

    func onFocus(event: FieldEvent) {
        lastFocusedFielsData = currentFocusedFielsData
        currentFocusedFielsData = event.field
    }

    func onUpload(event: UploadEvent) {
        eventHandler?.onUpload(event: event)
    }
}

struct PageDuplicateListView: View {
    @Binding public var document: JoyDoc
    @Binding var pages: [Page]
    @Binding var currentPageID: String
    @Binding var pageOrder: [String]?
    @Environment(\.presentationMode) var presentationMode
    
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
                ForEach(pageOrder ?? [], id: \.self) { id in
                    if let page = document.firstPageFor(currentPageID: id) {
                        if DocumentEngine.shouldShowItem(fields: document.fields, logic: page.logic, isItemHidden: page.hidden) {

                            VStack(alignment: .leading) {
                                Button(action: {
                                    currentPageID = id ?? ""
                                    presentationMode.wrappedValue.dismiss()
                                }, label: {
                                    HStack {
                                        Image(systemName: currentPageID == id ? "checkmark.circle.fill" : "circle")
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
