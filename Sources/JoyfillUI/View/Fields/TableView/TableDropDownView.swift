//
//  SwiftUIView.swift
//  
//
//  Created by Nand Kishore on 06/03/24.
//

import SwiftUI
import JoyfillModel

struct TableDropDownOptionListView: View {
    @State var selectedDropdownValue: String = ""
    @State private var isSheetPresented: Int = 0
    @State private var isSheetPresented2 = false

    private var isUsedForBulkEdit = false
    @Binding var cellModel: TableCellModel
    @FocusState private var isFocused: Bool // Declare a FocusState property
   
    public init(cellModel: Binding<TableCellModel>, isUsedForBulkEdit: Bool = false, selectedDropdownValue: String? = nil) {
        _cellModel = cellModel
        self.isUsedForBulkEdit = isUsedForBulkEdit
        
        if let selectedDropdownValue = selectedDropdownValue {
            _selectedDropdownValue = State(initialValue: cellModel.wrappedValue.data.optionsMap[selectedDropdownValue]?.value ?? "")
        } else if !isUsedForBulkEdit {
            _selectedDropdownValue = State(initialValue: cellModel.wrappedValue.data.optionsMap[cellModel.wrappedValue.data.defaultDropdownSelectedId ?? ""]?.value ?? "")
        }
    }
    
    var body: some View {
        if cellModel.viewMode == .quickView {
            HStack {
                Text(cellModel.data.optionsMap[cellModel.data.defaultDropdownSelectedId ?? "Select Option"]?.value ?? "Select Option")
                Spacer()
                Image(systemName: "chevron.down")
            }
            .font(.system(size: 15))
            .padding(.horizontal, 10)
        } else {
            VStack(alignment: .leading) {
                Button(action: {
                    isSheetPresented = Int.random(in: 0...100)
                }, label: {
                    HStack {
                        Text(selectedDropdownValue.isEmpty ? "Select Option" : selectedDropdownValue)
                            .darkLightThemeColor()
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .font(.system(size: 15))
                })
                .padding(.horizontal, 10)
                .accessibilityIdentifier("TableDropdownIdentifier")
                .onChange(of: isSheetPresented) { newValue in
                    isSheetPresented2.toggle()
                }
                .sheet(isPresented: $isSheetPresented2) {
                    TableDropDownOptionList(data: cellModel.data, selectedDropdownValue: $selectedDropdownValue)
                }
            }
            .frame(height: 40)
            .focused($isFocused) // Observe focus state
            .onChange(of: selectedDropdownValue) { value in
                var cellDataModel = cellModel.data
                cellDataModel.defaultDropdownSelectedId = cellDataModel.options?.filter { $0.value == value }.first?.id
                cellDataModel.selectedOptionText = value
                if (cellDataModel.defaultDropdownSelectedId != cellModel.data.defaultDropdownSelectedId) || isUsedForBulkEdit {
                    cellModel.didChange?(cellDataModel)
                }
                cellModel.data = cellDataModel
            }
        }
    }
}


struct TableDropDownOptionList: View {
    @Environment(\.presentationMode) var presentationMode
    private let data: CellDataModel
    @Binding var selectedDropdownValue: String
    
    public init(data: CellDataModel, selectedDropdownValue: Binding<String>) {
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
                                selectedDropdownValue = ""
                            } else {
                                selectedDropdownValue = option.value ?? ""
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
