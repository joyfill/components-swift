//
//  TextView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel

// Single line text

struct TextView: View {
    @State private var lastName: String = ""
    private let fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool // Declare a FocusState property
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Text")
                .fontWeight(.bold)
            
            TextField("", text: $lastName)
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
    }
}
