//
//  DropdownView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel

struct DropdownView: View {
    @State var selectedDropdownValueID: String?
    @State private var isSheetPresented = false
    private let fieldDependency: FieldDependency
    
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
                    Text(fieldDependency.fieldData?.options?.filter {
                        $0.id == selectedDropdownValueID
                    }.first?.value  ?? "Select Option")
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
                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
            )
            .sheet(isPresented: $isSheetPresented) {
                DropDownOptionList(fieldDependency: fieldDependency, selectedDropdownValueID: $selectedDropdownValueID)
//                    .presentationDetents([.medium])
            }
        }
        .onAppear {
            if let value = fieldDependency.fieldData?.value?.dropdownValue {
                self.selectedDropdownValueID = value
            }
        }
        .onChange(of: selectedDropdownValueID) { newValue in
            guard var fieldData = fieldDependency.fieldData else { return }
            fieldData.value = .string(newValue ?? "")
            let change = FieldChange(changeData: ["value" : newValue])
            fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData, changes: change))
        }
    }
}


struct DropDownOptionList: View {
    @Environment(\.presentationMode) var presentationMode
    private let fieldDependency: FieldDependency
    @Binding var selectedDropdownValueID: String?
    
    public init(fieldDependency: FieldDependency, selectedDropdownValueID: Binding<String?>) {
        self.fieldDependency = fieldDependency
        self._selectedDropdownValueID = selectedDropdownValueID
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
                            selectedDropdownValueID = option.id
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            HStack(alignment: .top) {
                                Image(systemName: (selectedDropdownValueID == option.id) ? "checkmark.circle.fill" : "circle")
                                    .padding(.top, 3)
                                Text(option.value ?? "")
                                    .multilineTextAlignment(.leading)
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


