//
//  DropdownView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel

struct DropdownView: View {
    @State var selectedDropdownValue: String?
    private let fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool // Declare a FocusState property

    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Dropdown")
                .fontWeight(.bold)
            
            Picker("Select", selection: $selectedDropdownValue) {
                if let options = fieldDependency.fieldData?.options {
                    ForEach(options) { option in
                        Text(option.value ?? "").tag("\(option.value)")
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .colorMultiply(selectedDropdownValue == "" ? .secondary : .black)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
                    .frame(maxWidth: .infinity)
            )
        }
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
        .onAppear{
            if let value = fieldDependency.fieldData?.value {
                self.selectedDropdownValue = fieldDependency.fieldData?.options?.filter { $0.id == value.dropdownValue }.first?.value ?? ""
            }
        }
        .padding(.horizontal, 16)
    }
}
