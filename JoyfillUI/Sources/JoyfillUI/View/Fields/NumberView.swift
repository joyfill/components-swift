//
//  NumberView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel

// Numeric value only

struct NumberView: View {
    @State var number: String = ""
    private let fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool // Declare a FocusState property

    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Number")
                .fontWeight(.bold)
            
            TextField("", text: $number)
                .padding(.horizontal, 16)
                .keyboardType(.numberPad)
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
            if let number = fieldDependency.fieldData?.value?.number {
                self.number = String(number)
            }
        }
    }
}
