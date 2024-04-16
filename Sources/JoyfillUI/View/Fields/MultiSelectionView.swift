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
    @State var singleSelectedOptionArray: [String] = []
    @State var multiSelectedOptionArray: [String] = []
    
    private let fieldDependency: FieldDependency
    private let currentFocusedFielsData: JoyDocField?
    @FocusState private var isFocused: Bool
    
    public init(fieldDependency: FieldDependency,currentFocusedFielsData: JoyDocField?) {
        self.fieldDependency = fieldDependency
        self.currentFocusedFielsData = currentFocusedFielsData
        if fieldDependency.fieldData?.multi ?? true {
            if let values = fieldDependency.fieldData?.value?.multiSelector {
                _multiSelectedOptionArray = State(initialValue: values)
            }
        } else {
            if let values = fieldDependency.fieldData?.value?.multiSelector {
                _singleSelectedOptionArray = State(initialValue: values)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            FieldHeaderView(fieldDependency)
            VStack {
                if let options = fieldDependency.fieldData?.options {
                    ForEach(0..<options.count, id: \.self) { index in
                        let optionValue = options[index].value ?? ""
                        let isSelected = fieldDependency.fieldData?.value?.multiSelector?.first(where: {
                            $0 == options[index].id
                        }) != nil
                        if fieldDependency.fieldData?.multi ?? true {
                            MultiSelection(option: optionValue, isSelected: isSelected, multiSelectedOptionArray: $multiSelectedOptionArray,isAlreadyFocused: currentFocusedFielsData?.id == fieldDependency.fieldData?.id, fieldDependency: fieldDependency, selectedItemId: options[index].id ?? "")
                            if index < options.count - 1 {
                                Divider()
                            }
                        } else {
                            RadioView(option: optionValue, singleSelectedOptionArray: $singleSelectedOptionArray,isAlreadyFocused: currentFocusedFielsData?.id == fieldDependency.fieldData?.id, fieldDependency: fieldDependency, selectedItemId: options[index].id ?? "")
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
        .onChange(of: singleSelectedOptionArray) { newValue in
            let newSingleSelectedValue = ValueUnion.array(newValue)
            guard fieldDependency.fieldData?.value != newSingleSelectedValue else { return }
            guard var fieldData = fieldDependency.fieldData else {
                fatalError("FieldData should never be null")
            }
            fieldData.value = newSingleSelectedValue
            fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData))
        }
        .onChange(of: multiSelectedOptionArray) { newValue in
            let newMultiSelectedValue = ValueUnion.array(newValue)
            guard fieldDependency.fieldData?.value != newMultiSelectedValue else { return }
            guard var fieldData = fieldDependency.fieldData else {
                fatalError("FieldData should never be null")
            }
            fieldData.value = newMultiSelectedValue
            fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData))
        }
    }
}

struct MultiSelection: View {
    var option: String
    @State var isSelected: Bool
    @Binding var multiSelectedOptionArray: [String]
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
            if let index = multiSelectedOptionArray.firstIndex(of: selectedItemId) {
                multiSelectedOptionArray.remove(at: index) // Item exists, so remove it
                } else {
                    multiSelectedOptionArray.append(selectedItemId) // Item doesn't exist, so add it
                }
        }, label: {
            HStack(alignment: .top) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .padding(.top, 4)
                    .imageScale(.large)
                Text(option)
                    .darkLightThemeColor()
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
    @Binding var singleSelectedOptionArray: [String]
    var isAlreadyFocused: Bool
    var fieldDependency: FieldDependency
    var selectedItemId: String
    
    var body: some View {
        Button(action: {
            if singleSelectedOptionArray.contains(selectedItemId) {
                singleSelectedOptionArray = []
            } else {
                singleSelectedOptionArray = [selectedItemId]
            }
            if isAlreadyFocused == false {
                let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                fieldDependency.eventHandler.onFocus(event: fieldEvent)
            }
        }, label: {
            HStack(alignment: .top) {
                Image(systemName: singleSelectedOptionArray == [selectedItemId] ? "smallcircle.filled.circle.fill" : "circle")
                    .padding(.top, 4)
                Text(option)
                    .darkLightThemeColor()
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        })
        .frame(maxWidth: .infinity)
    }
}
