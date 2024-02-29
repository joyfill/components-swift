//
//  TextView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel

// Single line text

struct TextView: View {
    @State var enterText: String = ""
    @State var textViewTitle: String = ""
    private let fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool // Declare a FocusState property
    
    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(textViewTitle)")
                .fontWeight(.bold)
            
            TextField("", text: $enterText)
                .padding(.horizontal, 10)
                .frame(height: 40)
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
                    } else {
                        let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                        fieldDependency.eventHandler.onBlur(event: fieldEvent)
                    }
                }
        }
        .padding(.horizontal, 16)
        .onAppear {
            if let text = fieldDependency.fieldData?.value?.text {
                enterText = text
            }
            if let title = fieldDependency.fieldData?.title {
                textViewTitle = title
            }
        }
    }
}
