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
    
    private let fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool // Declare a FocusState property

    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Multiselection")
                .fontWeight(.bold)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            VStack {
                if let options = fieldDependency.fieldData?.options {
                  ForEach(0..<options.count) { index in
                    let optionValue = options[index].value ?? ""
                      let isSelected = fieldDependency.fieldData?.value?.multiSelector?.first(where: {
                      $0 == options[index].id
                    }) != nil
                      if fieldDependency.fieldData?.multi ?? true {
                          MultiSelection(option: optionValue, isSelected: isSelected)
                      } else {
                          RadioView(option: optionValue, selectedOption: $selectedOption)
                      }
                  }
                }
            }
            .onAppear{
                selectedOption = fieldDependency.fieldData?.options?.filter { $0.id == fieldDependency.fieldData?.value?.multiSelector?[0] }.first?.value ?? ""
            }
            .padding(.horizontal, 16)
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
                Image(systemName: isSelected ? "record.circle.fill" : "record.circle")
                Text(option)
                    .foregroundStyle(.black)
                Spacer()
            }
            .padding()
            
        })
        .frame(maxWidth: .infinity)
        .border(Color.gray, width: 1)
        .padding(.top, -9)
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
            .padding()
        })
        .frame(maxWidth: .infinity)
        .border(Color.gray, width: 1)
        .padding(.top, -9)
    }
}
