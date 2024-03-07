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
    @FocusState private var isFocused: Bool // Declare a FocusState property
    
    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = fieldDependency.fieldData?.title {
                Text("\(title)")
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
            VStack {
                if let options = fieldDependency.fieldData?.options {
                    ForEach(0..<options.count) { index in
                        let optionValue = options[index].value ?? ""
                        let isSelected = fieldDependency.fieldData?.value?.multiSelector?.first(where: {
                            $0 == options[index].id
                        }) != nil
                        if fieldDependency.fieldData?.multi ?? true {
                            MultiSelection(option: optionValue, isSelected: isSelected)
                            if index < options.count - 1 {
                                Divider()
                            }
                        } else {
                            RadioView(option: optionValue, selectedOption: $selectedOption)
                            if index < options.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
                    .padding(.vertical,-10)
            )
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 10)
        .onAppear{
            selectedOption = fieldDependency.fieldData?.options?.filter { $0.id == fieldDependency.fieldData?.value?.multiSelector?[0] }.first?.value ?? ""
        }
        .onChange(of: selectedOption) { oldValue, newValue in
            guard var fieldData = fieldDependency.fieldData else { return }
            fieldData.value = .string(newValue)
            let change = Change(changeData: ["value" : newValue])
            fieldDependency.eventHandler.onChange(event: ChangeEvent(field: fieldDependency.fieldData, changes: [change]))
        }
    }
}

struct MultiSelection: View {
    var option: String
    @State var isSelected: Bool
    var body: some View {
        Button(action: {
            isSelected.toggle()
        }, label: {
            
            HStack {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .imageScale(.large)
                Text(option)
                    .foregroundStyle(.black)
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
    
    var body: some View {
        Button(action: {
            selectedOption = option
        }, label: {
            HStack {
                Image(systemName: selectedOption == option ? "largecircle.fill.circle" : "circle")
                Text(option)
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        })
        .frame(maxWidth: .infinity)
    }
}
