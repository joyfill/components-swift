//
//  MultiSelectionView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel

// Select multiple options

struct MultiSelectionView: View {
    @State var isSelected: Bool = false
    @State private var selectedOption: String = ""
    @State var selectedOptionArray: [String] = []
    
    private let fieldDependency: FieldDependency
    private let currentFocusedFielsData: JoyDocField?
    @FocusState private var isFocused: Bool
    
    public init(fieldDependency: FieldDependency,currentFocusedFielsData: JoyDocField?) {
        self.fieldDependency = fieldDependency
        self.currentFocusedFielsData = currentFocusedFielsData
        if fieldDependency.fieldData?.multi ?? true {
            if let values = fieldDependency.fieldData?.value?.multiSelector {
                _selectedOptionArray = State(initialValue: values)
            }
        } else {
            _selectedOption = State(initialValue: fieldDependency.fieldData?.options?.filter { $0.id == fieldDependency.fieldData?.value?.multiSelector?[0] }.first?.value ?? "")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = fieldDependency.fieldData?.title {
                HStack(alignment: .top) {
                    Text("\(title)")
                        .font(.headline.bold())
                    
                    if fieldDependency.fieldData?.fieldRequired == true && selectedOptionArray.isEmpty  && selectedOption.isEmpty {
                        Image(systemName: "asterisk")
                            .foregroundColor(.red)
                            .imageScale(.small)
                    }
                }
            }
            VStack {
                if let options = fieldDependency.fieldData?.options {
                    ForEach(0..<options.count) { index in
                        let optionValue = options[index].value ?? ""
                        let isSelected = fieldDependency.fieldData?.value?.multiSelector?.first(where: {
                            $0 == options[index].id
                        }) != nil
                        if fieldDependency.fieldData?.multi ?? true {
                            MultiSelection(option: optionValue, isSelected: isSelected, selectedOptionArray: $selectedOptionArray,isAlreadyFocused: currentFocusedFielsData?.id == fieldDependency.fieldData?.id, fieldDependency: fieldDependency, selectedItemId: options[index].id ?? "")
                            if index < options.count - 1 {
                                Divider()
                            }
                        } else {
                            RadioView(option: optionValue, selectedOption: $selectedOption,isAlreadyFocused: currentFocusedFielsData?.id == fieldDependency.fieldData?.id, fieldDependency: fieldDependency)
                            if index < options.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    .padding(.vertical, -10)
            )
            .padding(.vertical, 10)
        }
        .onChange(of: selectedOption) { newValue in
            guard var fieldData = fieldDependency.fieldData else { return }
            fieldData.value = .string(newValue)
            let change = FieldChange(changeData: ["value" : newValue])
            fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData, changes: change))
        }
        .onChange(of: selectedOptionArray) { newValue in
            guard var fieldData = fieldDependency.fieldData else { return }
            fieldData.value = .array(newValue)
            let change = FieldChange(changeData: ["value" : newValue])
            fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData, changes: change))
        }
    }
}

struct MultiSelection: View {
    var option: String
    @State var isSelected: Bool
    @Binding var selectedOptionArray: [String]
    var isAlreadyFocused: Bool
    var fieldDependency: FieldDependency
    var selectedItemId: String
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
            if isAlreadyFocused == false {
                let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                fieldDependency.eventHandler.onFocus(event: fieldEvent)
            }
            if let index = selectedOptionArray.firstIndex(of: selectedItemId) {
                    selectedOptionArray.remove(at: index) // Item exists, so remove it
                } else {
                    selectedOptionArray.append(selectedItemId) // Item doesn't exist, so add it
                }
        }, label: {
            HStack(alignment: .top) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .padding(.top, 4)
                    .imageScale(.large)
                Text(option)
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        })
        .frame(maxWidth: .infinity)
    }
}
//Select only one choice
struct RadioView: View {
    var option: String
    @Binding var selectedOption: String
    var isAlreadyFocused: Bool
    var fieldDependency: FieldDependency
    
    var body: some View {
        Button(action: {
            if selectedOption == option {
                selectedOption = ""
            } else {
                selectedOption = option
            }
            if isAlreadyFocused == false {
                let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                fieldDependency.eventHandler.onFocus(event: fieldEvent)
            }
        }, label: {
            HStack(alignment: .top) {
                Image(systemName: selectedOption == option ? "smallcircle.filled.circle.fill" : "circle")
                    .padding(.top, 4)
                Text(option)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        })
        .frame(maxWidth: .infinity)
    }
}
