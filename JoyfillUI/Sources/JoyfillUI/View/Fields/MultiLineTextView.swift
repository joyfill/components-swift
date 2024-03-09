//
//  MultiLineTextView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel

// MultiLine text

struct MultiLineTextView: View {
    @State var multilineText: String = ""
    private let fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool // Declare a FocusState property

    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = fieldDependency.fieldData?.title {
                Text("\(title)")
                    .fontWeight(.bold)
            }
            
            TextEditor(text: $multilineText)
                .disabled(fieldDependency.mode == .readonly)
                .autocorrectionDisabled()
                .frame(maxHeight: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .cornerRadius(10)
                .focused($isFocused)
                .onChange(of: isFocused) { focused in
                    if focused {
                        let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                        fieldDependency.eventHandler.onFocus(event: fieldEvent)
                    } 
                }
        }
        .padding(.horizontal, 16)
        .onAppear{
            if let multilineText = fieldDependency.fieldData?.value?.multilineText {
                self.multilineText = multilineText
            }
        }
        .onChange(of: multilineText) { oldValue, newValue in
            guard var fieldData = fieldDependency.fieldData else { return }
            fieldData.value = .string(newValue)
            let change = FieldChange(changeData: ["value" : newValue])
            fieldDependency.eventHandler.onChange(event: ChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData, changes: change))
        }
    }
}

