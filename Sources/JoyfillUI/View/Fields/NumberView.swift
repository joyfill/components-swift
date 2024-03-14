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
                HStack(spacing: 30) {
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
                        let change = FieldChange(changeData: ["value" : number])
                        fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldDependency.fieldData, changes: change))
                    }
                }
        }
        .onAppear {
            if let number = fieldDependency.fieldData?.value?.number {
                self.number = String(number)
            }
        }
    }
}
