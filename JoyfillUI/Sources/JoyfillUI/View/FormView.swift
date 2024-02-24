//
//  FormView.swift
//  JoyFill
//
//  Created by Vikash on 06/02/24.
//

import SwiftUI
import JoyfillModel
import JoyfillAPIService


struct PageView {
    
}

struct FormView: View {
    @State var document: JoyDoc
    @State var mode: Mode = .fill
    private let eventHandler: FieldEventHandler
    
    init(document: JoyDoc, mode: Mode, events: Events? = nil) {
        self.document = document
        self.mode = mode
        self.eventHandler = FieldEventHandler(appEventHandler: events)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20.0) {
                if let fields = document.fields {
                    ForEach(fields) { joyDocField in
                        switch joyDocField.type {
                        case FieldTypes.text:
                            DisplayTextView(eventHandler: eventHandler, fieldPosition: document.fieldPosition!, fieldData: joyDocField)
                        case FieldTypes.multiSelect:
                            MultiSelectionView(eventHandler: eventHandler, fieldPosition: document.fieldPosition!, fieldData: joyDocField)
                        case FieldTypes.dropdown:
                            DropdownView(eventHandler: eventHandler, fieldPosition: document.fieldPosition!, fieldData: joyDocField)
                        case FieldTypes.textarea:
                            MultiLineTextView(eventHandler: eventHandler, fieldPosition: document.fieldPosition!, fieldData: joyDocField)
                        case FieldTypes.date:
                            DateTimeView(eventHandler: eventHandler, fieldPosition: document.fieldPosition!, fieldData: joyDocField)
                        case FieldTypes.signature:
                            SignatureView(eventHandler: eventHandler, fieldPosition: document.fieldPosition!, fieldData: joyDocField)
                        case FieldTypes.block:
                            DisplayTextView(eventHandler: eventHandler, fieldPosition: document.fieldPosition!, fieldData: joyDocField)
                        case FieldTypes.number:
                            NumberView(eventHandler: eventHandler, fieldPosition: document.fieldPosition!, fieldData: joyDocField)
                        case FieldTypes.chart:
                            Text("")
                        case FieldTypes.richText:
                            Text("")
                        case FieldTypes.table:
                            Text("")
                        case FieldTypes.image:
                            ImageView(eventHandler: eventHandler, fieldPosition: document.fieldPosition!, fieldData: joyDocField)
                        default:
                            Text("Data no Available")
                        }
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

