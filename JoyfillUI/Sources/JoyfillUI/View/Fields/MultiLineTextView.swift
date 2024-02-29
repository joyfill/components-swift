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
            Text("Multiline Text")
                .fontWeight(.bold)
            
                TextEditor(text: $multilineText)
                    .autocorrectionDisabled()
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .cornerRadius(10)
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
            if let multilineText = fieldDependency.fieldData?.value?.multilineText{
                self.multilineText = multilineText
            }
        }
        .padding(.horizontal, 16)
    }
}

