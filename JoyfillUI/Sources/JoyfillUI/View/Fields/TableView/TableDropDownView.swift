//
//  SwiftUIView.swift
//  
//
//  Created by Nand Kishore on 06/03/24.
//

import SwiftUI
import JoyfillModel

struct TableDropDownOptionListView: View {
    @State var selectedDropdownValue: String?
    @State private var isSheetPresented = false
    private let data: FieldTableColumn
    @FocusState private var isFocused: Bool // Declare a FocusState property
    
    public init(data: FieldTableColumn) {
        self.data = data
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                isSheetPresented = true
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
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.tableDropdownBorderColor, lineWidth: 1)
            )
            .sheet(isPresented: $isSheetPresented) {
                TableDropDownOptionList(data: data, selectedDropdownValue: $selectedDropdownValue)
                    .presentationDetents([.medium])
            }
        }
        .focused($isFocused) // Observe focus state
        .onChange(of: isFocused) { focused in
            if focused {
                print("dropdown in focus")
            } else {
                print("dropdown in blur")
            }
        }
        .onAppear {
            self.selectedDropdownValue = data.options?.filter { $0.id == data.defaultDropdownSelectedId }.first?.value ?? ""
        }
        .padding(4)
    }
}


struct TableDropDownOptionList: View {
    @Environment(\.presentationMode) var presentationMode
    private let data: FieldTableColumn
    @Binding var selectedDropdownValue: String?
    
    public init(data: FieldTableColumn, selectedDropdownValue: Binding<String?>) {
        self.data = data
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
                if let options = data.options {
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
