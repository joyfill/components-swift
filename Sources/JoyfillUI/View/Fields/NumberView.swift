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
    @FocusState private var isFocused: Bool
    
    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
        if let number = fieldDependency.fieldData?.value?.number {
            _number = State(initialValue: String(number))
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = fieldDependency.fieldData?.title {
                HStack(alignment: .top) {
                    Text("\(title)")
                        .font(.headline.bold())
                    
                    if fieldDependency.fieldData?.fieldRequired == true && number.isEmpty {
                        Image(systemName: "asterisk")
                            .foregroundColor(.red)
                            .imageScale(.small)
                    }
                }
            }
            
            TextField("", text: $number)
                .disabled(fieldDependency.mode == .readonly)
                .padding(.horizontal, 16)
                .padding(.vertical, 5)
                .keyboardType(.decimalPad)
                .frame(minHeight: 40)
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
                        guard var fieldData = fieldDependency.fieldData else { return }
                        let convertStringToInt = Double(number)
                        fieldData.value = .integer(convertStringToInt ?? 0.0)
                        fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData))
                    }
                }
        }
    }
}
