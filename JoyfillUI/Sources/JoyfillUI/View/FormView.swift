//
//  FormView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel

public struct JoyFillView: View {
    @State public var document: JoyDoc
    @State public var mode: Mode
    public var events: FormChangeEvent?

    public init(document: JoyDoc, mode: Mode = .fill, events: FormChangeEvent? = nil) {
        self.events = events
        _mode = State(initialValue: mode)
        _document = State(initialValue: document)
    }

    public var body: some View {
        FilesView(fieldsData: $document.fields, files: document.files, mode: mode, events: self)
    }
}

extension JoyFillView: FormChangeEvent {
    public func onChange(event: JoyfillModel.ChangeEvent) {
        var event = event
        event.document = document
        events?.onChange(event: event)
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
    let events: FormChangeEvent?
    
    var body: some View {
        FileView(fieldsData: $fieldsData, file: files.first, mode: mode, events: events)
    }
}

struct FileView: View {
    @Binding var fieldsData: [JoyDocField]?
    var file: File?
    let mode: Mode
    let events: FormChangeEvent?
    
    var body: some View {
        if file?.views?.count != 0 {
            if let view = file?.views?.first {
                if let pages = view.pages {
                    PagesView(fieldsData: $fieldsData, pages: pages, mode: mode, events: self)
                }
            }
        } else {
            if let pages = file?.pages {
                PagesView(fieldsData: $fieldsData, pages: pages, mode: mode, events: self)
            }
        }
    }
}

extension FileView: FormChangeEvent {
    func onChange(event: JoyfillModel.ChangeEvent) {
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
        events?.onUpload(event: event)
    }
}

struct PagesView: View {
    @Binding var fieldsData: [JoyDocField]?
    let pages: [Page]
    let mode: Mode
    let events: FormChangeEvent?
    
    var body: some View {
        if let page = pages.first {
            PageView(fieldsData: $fieldsData, page: page, mode: mode, events: events)
        }
    }
}

struct PageView: View {
    @Binding var fieldsData: [JoyDocField]?
    let page: Page
    let mode: Mode
    let events: FormChangeEvent?

    var body: some View {
        if let fieldPositions = page.fieldPositions {
            FormView(fieldPositions: fieldPositions, fieldsData: $fieldsData, mode: mode, eventHandler: self)
        }
    }
}

extension PageView: FormChangeEvent {
    func onChange(event: JoyfillModel.ChangeEvent) {
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
    let eventHandler: FormChangeEvent?
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
            TableQuickView(viewModel: TableViewModel(mode: fieldDependency.mode, joyDocModel: fieldData)) // TODO: Remove this
            //TableQuickView(fieldDependency: fieldDependency) // TODO: Uncomment this
        case .image:
            ImageView(fieldDependency: fieldDependency)
        }
    }
    
    var body: some View {
        ScrollView {
            ForEach(fieldPositions, id: \.field) { fieldPosition in
                fieldView(fieldPosition: fieldPosition)
            }
        }
        .onChange(of: currentFocusedFielsData) { oldValue, newValue in
            guard newValue != nil else { return }
            guard oldValue != newValue else { return }
            if oldValue != nil {
                let fieldEvent = FieldEvent(field: oldValue)
                eventHandler?.onBlur(event: fieldEvent)
            }
            let fieldEvent = FieldEvent(field: newValue)
            eventHandler?.onFocus(event: fieldEvent)
        }
    }
}

extension FormView: FieldChangeEvents {
    func onChange(event: ChangeEvent) {
        currentFocusedFielsData = event.field
        fieldsData = fieldsData?.compactMap { data in
            if data.id == event.field?.id {
                return event.field
            }
            return data
        }
        eventHandler?.onChange(event: event)
    }
    
    func onFocus(event: FieldEvent) {
        currentFocusedFielsData = event.field
        print("Current focus is ---\(currentFocusedFielsData?.title)")
    }
    
    func onUpload(event: UploadEvent) {
        eventHandler?.onUpload(event: event)
    }
}
