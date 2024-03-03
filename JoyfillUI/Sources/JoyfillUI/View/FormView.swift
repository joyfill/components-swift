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
    
    public init(document: JoyDoc, mode: Mode = .fill) {
        self.mode = mode
        self.document = document
    }
    
    public var body: some View {
        if let files = document.files {
            FilesView(files: files, fieldsData: document.fields, mode: mode, events: nil)
        } else {
            Text("Empty form")
        }
    }
}

//extension JoyFillView: Events {
//    public func onChange(event: JoyfillModel.ChangeEvent) {
//        var event = event
//        event.document = document
//        onChange(event: event)
//    }
//    
//    public func onFocus(event: JoyfillModel.FieldEvent) {
//        events?.onFocus(event: event)
//    }
//    
//    public func onBlur(event: JoyfillModel.FieldEvent) {
//        events?.onBlur(event: event)
//    }
//    
//    public func onUpload(event: JoyfillModel.UploadEvent) {
//        events?.onUpload(event: event)
//    }
//}

struct FilesView: View {
    private var files: [File]
    private var fieldsData: [JoyDocField]?
    private let mode: Mode
    private let events: Events?
    
    init(files: [File], fieldsData: [JoyDocField]?, mode: Mode, events: Events?) {
        self.files = files
        self.fieldsData = fieldsData
        self.mode = mode
        self.events = events
    }
    
    var body: some View {
        if let file = files.first {
            FileView(file: file, fieldsData: fieldsData, mode: mode, events: events)
        }
    }
}

struct FileView: View {
    private let file: File
    private var fieldsData: [JoyDocField]?
    private let mode: Mode
    private let events: Events?
    
    init(file: File, fieldsData: [JoyDocField]?, mode: Mode, events: Events?) {
        self.file = file
        self.fieldsData = fieldsData
        self.mode = mode
        self.events = events
    }
    
    var body: some View {
        if file.views?.count != 0 {
            if let view = file.views?.first {
                if let pages = view.pages {
                    PagesView(pages: pages, fieldsData: fieldsData, mode: mode, events: self)
                }
            }
        } else {
            if let pages = file.pages {
                PagesView(pages: pages, fieldsData: fieldsData, mode: mode, events: self)
            }
        }
    }
}

extension FileView: Events {
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
    private let pages: [Page]
    private var fieldsData: [JoyDocField]?
    private let mode: Mode
    private let events: Events?
    
    init(pages: [Page], fieldsData: [JoyDocField]?, mode: Mode, events: Events?) {
        self.pages = pages
        self.fieldsData = fieldsData
        self.mode = mode
        self.events = events
    }
    
    var body: some View {
        if let page = pages.first {
            PageView(page: page, fieldsData: fieldsData, mode: mode, events: events)
        }
    }
}

struct PageView: View {
    private let page: Page
    private var fieldsData: [JoyDocField]?
    private let mode: Mode
    private let events: Events?
    
    init(page: Page, fieldsData: [JoyDocField]? = nil, mode: Mode, events: Events?) {
        self.page = page
        self.fieldsData = fieldsData
        self.mode = mode
        self.events = events
    }
    
    var body: some View {
        if let fieldPositions = page.fieldPositions {
            FormView(fieldPositions: fieldPositions, fieldsData: fieldsData, mode: mode, events: self)
        }
    }
}

extension PageView: Events {
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
    let eventHandler: FieldEventHandler
    let fieldPosition: FieldPosition
    var fieldData: JoyDocField?
}

struct FormView: View {
    @State var fieldPositions: [FieldPosition]
    private var fieldsData: [JoyDocField]?
    @State var mode: Mode = .fill
    private let eventHandler: FieldEventHandler
    
    init(fieldPositions: [FieldPosition], fieldsData: [JoyDocField]?, mode: Mode, events: Events? = nil) {
        self.fieldPositions = fieldPositions
        self.fieldsData = fieldsData
        self.mode = mode
        self.eventHandler = FieldEventHandler(appEventHandler: events)
    }
    
    @ViewBuilder
    fileprivate func fieldView(fieldPosition: FieldPosition) -> some View {
        let fieldData = fieldsData?.first(where: {
            $0.id == fieldPosition.field
        })
        
        let fieldDependency = FieldDependency(eventHandler: eventHandler, fieldPosition: fieldPosition, fieldData: fieldData)
        switch fieldPosition.type {
        case .text:
           TextView(fieldDependency: fieldDependency)
        case .block:
            DisplayTextView(fieldDependency: fieldDependency)
        case .multiSelect:
            MultiSelectionView(fieldDependency: fieldDependency)
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
            TableView(fieldDependency: fieldDependency)
        case .image:
            ImageView(fieldDependency: fieldDependency)
        }
    }
    
    var body: some View {
        List(fieldPositions, id: \.field, rowContent: fieldView)
            .listSectionSeparator(.hidden)
            .listStyle(PlainListStyle())
    }
}

class FieldEventHandler: Events {
    var appEventHandler: Events?
    
    init(appEventHandler: Events? = nil) {
        self.appEventHandler = appEventHandler
    }
    
    func onChange(event: ChangeEvent) {
        appEventHandler?.onChange(event: event)
    }
    
    func onFocus(event: FieldEvent) {
        appEventHandler?.onFocus(event: event)
    }
    
    func onBlur(event: FieldEvent) {
        appEventHandler?.onBlur(event: event)
    }
    
    func onUpload(event: UploadEvent) {
        appEventHandler?.onUpload(event: event)
    }
}
