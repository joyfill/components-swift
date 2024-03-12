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
    @State var multiselectionViewTitle: String = ""
    
    private let fieldDependency: FieldDependency
    private let currentFocusedFielsData: JoyDocField?
    @FocusState private var isFocused: Bool
    
    public init(fieldDependency: FieldDependency,currentFocusedFielsData: JoyDocField?) {
        self.fieldDependency = fieldDependency
        self.currentFocusedFielsData = currentFocusedFielsData
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = fieldDependency.fieldData?.title {
                Text("\(title)")
                    .fontWeight(.bold)
            }
            VStack {
                if let options = fieldDependency.fieldData?.options {
                    ForEach(0..<options.count) { index in
                        let optionValue = options[index].value ?? ""
                        let isSelected = fieldDependency.fieldData?.value?.multiSelector?.first(where: {
                            $0 == options[index].id
                        }) != nil
                        if fieldDependency.fieldData?.multi ?? true {
                            MultiSelection(option: optionValue, isSelected: isSelected,isAlreadyFocused: currentFocusedFielsData?.id == fieldDependency.fieldData?.id, fieldDependency: fieldDependency)
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
        .onAppear{
            selectedOption = fieldDependency.fieldData?.options?.filter { $0.id == fieldDependency.fieldData?.value?.multiSelector?[0] }.first?.value ?? ""
        }
        .onChange(of: selectedOption) { oldValue, newValue in
            guard var fieldData = fieldDependency.fieldData else { return }
            fieldData.value = .string(newValue)
            let change = FieldChange(changeData: ["value" : newValue])
            fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData, changes: change))
        }
    }
}

struct MultiSelection: View {
    var option: String
    @State var isSelected: Bool
    var isAlreadyFocused: Bool
    var fieldDependency: FieldDependency
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
            if isAlreadyFocused == false {
                let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                fieldDependency.eventHandler.onFocus(event: fieldEvent)
            }
            
        }, label: {
            HStack {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
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
            selectedOption = option
            if isAlreadyFocused == false {
                let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                fieldDependency.eventHandler.onFocus(event: fieldEvent)
            }
        }, label: {
            HStack {
                Image(systemName: selectedOption == option ? "smallcircle.filled.circle.fill" : "circle")
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
