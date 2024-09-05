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
    private var isUsedForBulkEdit = false
    private var cellModel: TableCellModel
    @FocusState private var isFocused: Bool // Declare a FocusState property
    @State private var lastSelectedValue: String?
    
    public init(cellModel: TableCellModel, isUsedForBulkEdit: Bool = false, selectedDropdownValue: String? = nil) {
        self.cellModel = cellModel
        self.isUsedForBulkEdit = isUsedForBulkEdit
        lastSelectedValue = cellModel.data.options?.filter { $0.id == cellModel.data.defaultDropdownSelectedId }.first?.value ?? ""
        _selectedDropdownValue = State(initialValue: selectedDropdownValue)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                isSheetPresented = true
            }, label: {
                HStack {
                    if let selectedDropdownValue = selectedDropdownValue, !selectedDropdownValue.isEmpty {
                        Text(selectedDropdownValue)
                            .darkLightThemeColor()
                            .lineLimit(1)
                    } else {
                        Text("Select Option")
                            .darkLightThemeColor()
                            .lineLimit(1)
                    }
                
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .font(.system(size: 15))
            })
            .padding(.horizontal, 10)
            .frame(height: 40)
            .accessibilityIdentifier("TableDropdownIdentifier")
            .sheet(isPresented: $isSheetPresented) {
                TableDropDownOptionList(data: cellModel.data, selectedDropdownValue: $selectedDropdownValue)
            }
        }
        .focused($isFocused) // Observe focus state
        .onAppear {
            if !isUsedForBulkEdit {
                self.selectedDropdownValue = cellModel.data.options?.filter { $0.id == cellModel.data.defaultDropdownSelectedId }.first?.value ?? ""
            }
        }
        .onChange(of: selectedDropdownValue) { value in
            var editedCell = cellModel.data
            editedCell.defaultDropdownSelectedId = editedCell.options?.filter { $0.value == value }.first?.id
            if (editedCell.defaultDropdownSelectedId != cellModel.data.defaultDropdownSelectedId) || isUsedForBulkEdit {
                cellModel.didChange?(editedCell)
            }
        }
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
                        .imageScale(.large)
                })
                .padding(.horizontal, 16)
            }
            ScrollView {
                if let options = data.options?.filter({ !($0.deleted ?? false) }) {
                    ForEach(options) { option in
                        Button(action: {
                            if selectedDropdownValue == option.value {
                                selectedDropdownValue = nil
                            } else {
                                selectedDropdownValue = option.value
                            }
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            HStack {
                                Image(systemName: (selectedDropdownValue == option.value) ? "largecircle.fill.circle" : "circle")
                                Text(option.value ?? "")
                                    .darkLightThemeColor()
                                Spacer()
                            }
                            .padding(.horizontal, 28)
                            .padding(.vertical, 10)
                        })
                        .accessibilityIdentifier("TableDropdownOptionsIdentifier")
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
