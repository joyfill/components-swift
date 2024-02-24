//
//  DisplayTextView.swift
//  JoyFill
//
//  Created by Vikash on 10/02/24.
//

import SwiftUI
import JoyfillModel

// Title or Description

struct DisplayTextView: View {
    @State var displayText: String = ""
    private let mode: Mode = .fill
    private let eventHandler: FieldEventHandler
    private let fieldPosition: FieldPosition
    private var fieldData: JoyDocField?
    
    public init(eventHandler: FieldEventHandler, fieldPosition: FieldPosition, fieldData: JoyDocField? = nil) {
        self.eventHandler = eventHandler
        self.fieldPosition = fieldPosition
        self.fieldData = fieldData
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Display Text")
                .fontWeight(.bold)

            TextField("", text: $displayText)
                .padding(.horizontal, 10)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .cornerRadius(10)
        }
        .onAppear{
            if let text = fieldData?.value?.textabc {
                displayText = text
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    DisplayTextView(eventHandler: FieldEventHandler(), fieldPosition: testDocument().fieldPosition!, fieldData: testDocument().fields!.first)
}
