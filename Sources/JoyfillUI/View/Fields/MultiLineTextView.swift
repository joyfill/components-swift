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
        if let multilineText = fieldDependency.fieldData?.value?.multilineText {
            _multilineText = State(initialValue: multilineText)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            FieldHeaderView(fieldDependency)
            TextEditor(text: $multilineText)
                .disabled(fieldDependency.mode == .readonly)
                .padding(.all, 10)
                .autocorrectionDisabled()
                .frame(minHeight: 200, maxHeight: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
                .cornerRadius(10)
                .focused($isFocused)
                .onChange(of: isFocused) { focused in
                    if focused {
                        let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                        fieldDependency.eventHandler.onFocus(event: fieldEvent)
                    } else {
                        let newValue = ValueUnion.string(multilineText)
                        guard fieldDependency.fieldData?.value != newValue else { return }
                        guard var fieldData = fieldDependency.fieldData else {
                            fatalError("FieldData should never be null")
                        }
                        fieldData.value = newValue
                        fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData))
                    }
                }
        }
    }
}

