//
//  DisplayTextView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel

struct DisplayTextView: View {
    @State var displayText: String = ""
    private let fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool // Declare a FocusState property

    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
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
                .focused($isFocused) // Observe focus state
                .onChange(of: isFocused) { focused in
                    if focused {
                        let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                        fieldDependency.eventHandler.onFocus(event: fieldEvent)
                    } else {
                        let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                        fieldDependency.eventHandler.onBlur(event: fieldEvent)
                    }
                }
        }
        .onAppear{
            if let text = fieldDependency.fieldData?.value?.textabc {
                displayText = text
            }
        }
        .onChange(of: displayText, { oldValue, newValue in
            let change = ["value": newValue]
            let changeEvent = ChangeEvent(changes: [Change(changeData: change)])
            fieldDependency.eventHandler.onChange(event: changeEvent)
        })
        .padding(.horizontal, 16)
    }
}

