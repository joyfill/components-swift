//
//  DropdownView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel

struct DropdownView: View {
    @State var selectedDropdownValue: String?
    @State private var isSheetPresented = false
    private let fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool // Declare a FocusState property
    @FocusState private var buttonFocused: Bool
    
    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = fieldDependency.fieldData?.title {
                Text("\(title)")
                    .fontWeight(.bold)
            }
            
            Button(action: {
                isSheetPresented = true
                let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                fieldDependency.eventHandler.onFocus(event: fieldEvent)
            }, label: {
                HStack {
                    Text(selectedDropdownValue ?? "Select Option")
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .frame(maxWidth: .infinity)
                .padding(.all, 10)
                .foregroundColor(.black)
            })
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 1)
            )
            .sheet(isPresented: $isSheetPresented) {
                DropDownOptionList(fieldDependency: fieldDependency, selectedDropdownValue: $selectedDropdownValue)
                    .presentationDetents([.medium])
            }
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


struct DropDownOptionList: View {
    @Environment(\.presentationMode) var presentationMode
    private let fieldDependency: FieldDependency
    @Binding var selectedDropdownValue: String?
    
    public init(fieldDependency: FieldDependency, selectedDropdownValue: Binding<String?>) {
        self.fieldDependency = fieldDependency
        self._selectedDropdownValue = selectedDropdownValue
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.black)
                        .imageScale(.large)
                })
                .padding(.horizontal, 16)
            }
            ScrollView {
                if let options = fieldDependency.fieldData?.options {
                    ForEach(options) { option in
                        Button(action: {
                            selectedDropdownValue = option.value
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            HStack {
                                Image(systemName: (selectedDropdownValue == option.value) ? "largecircle.fill.circle" : "circle")
                                Text(option.value ?? "")
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(.horizontal, 28)
                            .padding(.vertical, 10)
                        })
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 20)
    }
}



