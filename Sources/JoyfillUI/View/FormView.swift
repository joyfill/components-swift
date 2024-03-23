//
//  FormView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel

public struct JoyFillView: View {
    @Binding public var document: JoyDoc
    @State public var mode: Mode
    @Binding public var currentPage: Int
    public var events: FormChangeEvent?
    
    public init(document: Binding<JoyDoc>, mode: Mode = .fill, events: FormChangeEvent? = nil, currentPage: Binding<Int>? = nil) {
        self.events = events
        _mode = State(initialValue: mode)
        _document = document
        _currentPage = currentPage ?? Binding(get: {
            0
        }, set: { value in
            
        })
    }
    
    public var body: some View {
        FilesView(fieldsData: $document.fields, files: document.files, mode: mode, events: self, currentPage: $currentPage)
    }
}

extension JoyFillView: FormChangeEventInternal {
    public func onChange(event: JoyfillModel.FieldChangeEvent) {
        var event = event
        let fieldChange = FieldChange(value: event.field!.value!)
        let change = Change(v: 1,
                            sdk: "swift",
                            target: "field.update",
                            _id: document.id!,
                            identifier: document.identifier,
                            fileId: event.file!.id!,
                            pageId: event.page!.id!,
                            fieldId: event.field!.id!,
                            fieldIdentifier: event.field!.identifier!,
                            fieldPositionId: event.fieldPosition.id!,
                            change: fieldChange,
                            createdOn: Date().timeIntervalSince1970)
        events?.onChange(changes: [change], document: document)
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

struct FilesView: View {
    @Binding var fieldsData: [JoyDocField]?
    var files: [File]
    let mode: Mode
    let events: FormChangeEventInternal?
    @Binding var currentPage: Int
    
    var body: some View {
        FileView(fieldsData: $fieldsData, file: files.first, mode: mode, events: events, currentPage: $currentPage)
    }
}

struct FileView: View {
    @Binding var fieldsData: [JoyDocField]?
    var file: File?
    let mode: Mode
    let events: FormChangeEventInternal?
    @Binding var currentPage: Int
    
    var body: some View {
        if file?.views?.count != 0 {
            if let view = file?.views?.first {
                if let pages = view.pages {
                    PagesView(fieldsData: $fieldsData, currentPage: $currentPage, pages: pages, mode: mode, events: self)
                }
            }
        } else {
            if let pages = file?.pages {
                PagesView(fieldsData: $fieldsData, currentPage: $currentPage, pages: pages, mode: mode, events: self)
            }
        }
    }
}

extension FileView: FormChangeEventInternal {
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

struct PagesView: View {
    @Binding var fieldsData: [JoyDocField]?
    @Binding var currentPage: Int
    let pages: [Page]
    let mode: Mode
    let events: FormChangeEventInternal?
    
    var body: some View {
        PageView(fieldsData: $fieldsData, page: pages[currentPage], mode: mode, events: events)
    }
}

struct PageView: View {
    @Binding var fieldsData: [JoyDocField]?
    let page: Page
    let mode: Mode
    let events: FormChangeEventInternal?

    var body: some View {
        if let fieldPositions = page.fieldPositions {
          let resultFieldPositions = mapWebViewToMobileView(fieldPositions: fieldPositions)
            FormView(fieldPositions: resultFieldPositions, fieldsData: $fieldsData, mode: mode, eventHandler: self)
        }
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

extension PageView: FormChangeEventInternal {
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

struct FieldDependency {
    let mode: Mode = .fill
    let eventHandler: FieldChangeEvents
    let fieldPosition: FieldPosition
    var fieldData: JoyDocField?
}

struct FormView: View {
    @State var fieldPositions: [FieldPosition]
    @Binding var fieldsData: [JoyDocField]?
    @State var mode: Mode = .fill
    let eventHandler: FormChangeEventInternal?
    @State var currentFocusedFielsData: JoyDocField? = nil
    
    @ViewBuilder
    fileprivate func fieldView(fieldPosition: FieldPosition) -> some View {
        let fieldData = fieldsData?.first(where: {
            $0.id == fieldPosition.field
        })
        let fieldDependency = FieldDependency(eventHandler: self, fieldPosition: fieldPosition, fieldData: fieldData)
        switch fieldPosition.type {
        case .text:
            TextView(fieldDependency: fieldDependency)
        case .block:
            DisplayTextView(fieldDependency: fieldDependency)
        case .multiSelect:
            MultiSelectionView(fieldDependency: fieldDependency, currentFocusedFielsData: currentFocusedFielsData)
        case .dropdown:
            DropdownView(fieldDependency: fieldDependency)
        case .textarea:
            MultiLineTextView(fieldDependency: fieldDependency)
        case .date:
            DateTimeView(fieldDependency: fieldDependency)
        case .signature:
            SignatureView(fieldDependency: fieldDependency)
        case .number:
            NumberView(fieldDependency: fieldDependency)
        case .chart:
            ChartView(fieldDependency: fieldDependency)
        case .richText:
            RichTextView(fieldDependency: fieldDependency)
        case .table:
            TableQuickView(fieldDependency: fieldDependency)
        case .image:
            ImageView(fieldDependency: fieldDependency)
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(fieldPositions, id: \.field) { fieldPosition in
                    fieldView(fieldPosition: fieldPosition)
                }
            }
            .padding(.horizontal, 16)
        }
        .gesture(DragGesture().onChanged({ _ in
            dismissKeyboardOnScroll()
        }))
        .onChange(of: currentFocusedFielsData) { newValue in
            guard newValue != nil else { return }
            //            guard oldValue != newValue else { return }
            //            if oldValue != nil {
            //                let fieldEvent = FieldEvent(field: oldValue)
            //                eventHandler?.onBlur(event: fieldEvent)
            //            }
            let fieldEvent = FieldEvent(field: newValue)
            eventHandler?.onFocus(event: fieldEvent)
        }
    }
    private func dismissKeyboardOnScroll() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension FormView: FieldChangeEvents {
    func onChange(event: FieldChangeEvent) {
        currentFocusedFielsData = event.field
        let temp = fieldsData?.compactMap { data in
            if data.id == event.field?.id {
                return event.field
            }
            return data
        }
        fieldsData?.removeAll()
        self.fieldsData = temp
        eventHandler?.onChange(event: event)
    }
    
    func onFocus(event: FieldEvent) {
        currentFocusedFielsData = event.field
    }
    
    func onUpload(event: UploadEvent) {
        eventHandler?.onUpload(event: event)
    }
}
