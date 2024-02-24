//
//  FormView.swift
//  JoyFill
//
//  Created by Vikash on 06/02/24.
//

import SwiftUI
import JoyfillModel
import JoyfillAPIService

struct JoyFillView: View {
    private let document: JoyDoc
    private let mode: Mode
    private let events: Events?
    
    init(document: JoyDoc, mode: Mode = .fill, events: Events? = nil) {
        self.document = document
        self.mode = mode
        self.events = events
    }
    
    var body: some View {
        if let files = document.files {
            FilesView(files: files, fieldsData: document.fields, mode: mode, events: events)
        }
    }
}

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
        if let pages = file.pages {
            PagesView(pages: pages, fieldsData: fieldsData, mode: mode, events: events)
        }
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
            FormView(fieldPositions: fieldPositions, fieldsData: fieldsData, mode: mode, events: events)
        }
    }
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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20.0) {
                    ForEach(0..<fieldPositions.count) { index in
                        let fieldPosition = fieldPositions[index]
                        let fieldData = fieldsData?[index]
                        switch fieldPosition.type {
                        case FieldTypes.text:
                            DisplayTextView(eventHandler: eventHandler, fieldPosition: fieldPosition, fieldData: fieldData)
                        case FieldTypes.multiSelect:
                            MultiSelectionView(eventHandler: eventHandler, fieldPosition: fieldPosition, fieldData: fieldData)
                        case FieldTypes.dropdown:
                            DropdownView(eventHandler: eventHandler, fieldPosition: fieldPosition, fieldData: fieldData)
                        case FieldTypes.textarea:
                            MultiLineTextView(eventHandler: eventHandler, fieldPosition: fieldPosition, fieldData: fieldData)
                        case FieldTypes.date:
                            DateTimeView(eventHandler: eventHandler, fieldPosition: fieldPosition, fieldData: fieldData)
                        case FieldTypes.signature:
                            SignatureView(eventHandler: eventHandler, fieldPosition: fieldPosition, fieldData: fieldData)
                        case FieldTypes.block:
                            DisplayTextView(eventHandler: eventHandler, fieldPosition: fieldPosition, fieldData: fieldData)
                        case FieldTypes.number:
                            NumberView(eventHandler: eventHandler, fieldPosition: fieldPosition, fieldData: fieldData)
                        case FieldTypes.chart:
                            Text("")
                        case FieldTypes.richText:
                            Text("")
                        case FieldTypes.table:
                            Text("")
                        case FieldTypes.image:
                            ImageView(eventHandler: eventHandler, fieldPosition: fieldPosition, fieldData: fieldData)
                        default:
                            Text("Data no Available")
                        }
                    }
            }
            Button(action: {
                
            }, label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 50)
            
        }
    }
}

class FieldEventHandler: Events {
    var appEventHandler: Events?
    
    init(appEventHandler: Events? = nil) {
        self.appEventHandler = appEventHandler
    }
    
    func onChange(event: FieldEvent) {
        appEventHandler?.onChange(event: event)
    }
    
    func onFocus(event: FieldEvent) {
        appEventHandler?.onFocus(event: event)
    }
    
    func onBlur(event: FieldEvent) {
        appEventHandler?.onBlur(event: event)
    }
    
    func onUpload(event:FieldEvent) {
        appEventHandler?.onBlur(event: event)
    }
}

#Preview {
    MultiSelectionView(eventHandler: FieldEventHandler(), fieldPosition: testDocument().fieldPosition!, fieldData: testDocument().fields!.first)
}

