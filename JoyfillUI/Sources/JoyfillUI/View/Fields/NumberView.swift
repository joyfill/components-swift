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
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = fieldDependency.fieldData?.title {
                Text("\(title)")
                    .fontWeight(.bold)
            }
            
            TextField("", text: $number)
                .disabled(fieldDependency.mode == .readonly)
                .padding(.horizontal, 16)
                .padding(.vertical, 5)
                .keyboardType(.decimalPad)
                .frame(minHeight: 40)
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
        .onAppear {
            if let number = fieldDependency.fieldData?.value?.number {
                self.number = String(number)
            }
        }
        .onChange(of: number) { oldValue, newValue in
            guard var fieldData = fieldDependency.fieldData else { return }
            let convertStringToInt = Double(newValue)
            fieldData.value = .integer(convertStringToInt ?? 0)
            let change = FieldChange(changeData: ["value" : newValue])
            fieldDependency.eventHandler.onChange(event: ChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData, changes: change))
        }
    }
}
