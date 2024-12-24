//
//  SwiftUIView.swift
//  Joyfill
//
//  Created by Vivek on 20/12/24.
//

import SwiftUI

struct TableMultiSelectView: View {
    @State var showMoreImages: Int = 5
    @State var showMoreImages2: Bool = false
    @Binding var cellModel: TableCellModel
    private var isUsedForBulkEdit = false
    @State var singleSelectedOptionArray: [String] = []
    @State var multiSelectedOptionArray: [String] = []
    var isSearching: Bool = false
    
    var isMulti: Bool {
        cellModel.data.multi ?? true
    }

    public init(cellModel: Binding<TableCellModel>, isUsedForBulkEdit: Bool = false, isSearching: Bool = false) {
        _cellModel = cellModel
        self.isUsedForBulkEdit = isUsedForBulkEdit
        _showMoreImages = State(wrappedValue: 6)
        self.isSearching = isSearching
        if !isUsedForBulkEdit {
            if isMulti {
                if let values = cellModel.wrappedValue.data.multiSelectValues {
                    _multiSelectedOptionArray = State(initialValue: values)
                }
            } else {
                if let values = cellModel.wrappedValue.data.multiSelectValues {
                    _singleSelectedOptionArray = State(initialValue: values)
                }
            }
        }
    }
   
    var body: some View {
        Button(action: {
            showMoreImages = Int.random(in: 0...100)
        }, label: {
            HStack {
                let selectedValues = isSearching ? singleSelectedOptionArray : isMulti ? multiSelectedOptionArray : singleSelectedOptionArray
                
                if let firstSelectedOption = cellModel.data.options?.first(where: { selectedValues.contains($0.id ?? "") }) {
                    let optionValue = firstSelectedOption.value ?? ""
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(.black)
                    
                    Text(optionValue)
                        .lineLimit(1)
                        .font(.system(size: 15))
                        .foregroundStyle(.black)
                }
                
                Spacer()
                
                if selectedValues.count > 1 {
                    Text("+\(selectedValues.count - 1)")
                        .font(.system(size: 15))
                        .foregroundStyle(.black)
                }
                
                Image(systemName: "chevron.down")
                    .foregroundStyle(.black)
                    .padding(.vertical, 2)
            }
            
        })
        .padding(.all, 8)
        .background(Color(red: 239 / 255, green: 239 / 255, blue: 240 / 255))
        .cornerRadius(16)
        .padding(.horizontal, 8)
        .sheet(isPresented: $showMoreImages2) {
            TableMultiSelectSheetView(cellModel: $cellModel, isUsedForBulkEdit: isUsedForBulkEdit,singleSelectedOptionArray: $singleSelectedOptionArray, multiSelectedOptionArray: $multiSelectedOptionArray, isMulti: isSearching ? false : isMulti)
                .disabled(cellModel.editMode == .readonly)
        }
        .onChange(of: showMoreImages) { newValue in
            showMoreImages2 = true
        }
    }
}

struct TableMultiSelectSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var singleSelectedOptionArray: [String]
    @Binding var multiSelectedOptionArray: [String]
    @State private var tempSingleSelectedOptionArray: [String] = []
    @State private var tempMultiSelectedOptionArray: [String] = []
    @Binding var cellModel: TableCellModel
    private var isUsedForBulkEdit = false
    let isMulti: Bool

    public init(cellModel: Binding<TableCellModel>, isUsedForBulkEdit: Bool = false, singleSelectedOptionArray: Binding<[String]>, multiSelectedOptionArray: Binding<[String]>, isMulti: Bool) {
        _cellModel = cellModel
        self.isUsedForBulkEdit = isUsedForBulkEdit
        _singleSelectedOptionArray = singleSelectedOptionArray
        _multiSelectedOptionArray = multiSelectedOptionArray
        self.isMulti = isMulti
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(cellModel.data.title)
                    .fontWeight(.bold)

                Spacer()

                Button(action: {
                    applyChanges()
                }, label: {
                    Text("Apply")
                        .darkLightThemeColor()
                        .font(.system(size: 14))
                        .frame(width: 88, height: 27)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.allFieldBorderColor, lineWidth: 1)
                        )
                })

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                            .frame(width: 27, height: 27)

                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .darkLightThemeColor()
                    }
                })
            }
            .padding(.bottom, 12)

            VStack {
                if let options = cellModel.data.options?.filter({ !($0.deleted ?? false) }) {
                    ForEach(0..<options.count, id: \.self) { index in
                        let optionValue = options[index].value ?? ""
                        let isSelected: Bool = {
                            let selectedArray = isMulti ? multiSelectedOptionArray : singleSelectedOptionArray
                            return selectedArray.contains(options[index].id ?? "") ?? false
                        }()

                        if isMulti {
                            TableMultiSelection(option: optionValue,
                                                isSelected: isSelected,
                                                multiSelectedOptionArray: $tempMultiSelectedOptionArray,
                                                selectedItemId: options[index].id ?? "")
                            if index < options.count - 1 {
                                Divider()
                            }
                        } else {
                            TableRadioView(option: optionValue,
                                           singleSelectedOptionArray: $tempSingleSelectedOptionArray,
                                           selectedItemId: options[index].id ?? "")
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
            .padding(.vertical, 12)
            
            Spacer()
        }
        .padding(.all, 16)
        .onAppear {
            tempSingleSelectedOptionArray = singleSelectedOptionArray
            tempMultiSelectedOptionArray = multiSelectedOptionArray
        }
    }
    
    func applyChanges() {
        if isMulti {
            multiSelectedOptionArray = tempMultiSelectedOptionArray
        } else {
            singleSelectedOptionArray = tempSingleSelectedOptionArray
        }
        isMulti ? onChange(newValue: multiSelectedOptionArray) : onChange(newValue: singleSelectedOptionArray)
        presentationMode.wrappedValue.dismiss()
    }
    
    func onChange(newValue: [String]) {
        var cellDataModel = cellModel.data
        cellDataModel.multiSelectValues = newValue
        cellModel.didChange?(cellDataModel)
        cellModel.data = cellDataModel
    }
}

struct TableMultiSelection: View {
    var option: String
    @State var isSelected: Bool
    @Binding var multiSelectedOptionArray: [String]
    var selectedItemId: String

    var body: some View {
        Button(action: {
            isSelected.toggle()
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
struct TableRadioView: View {
    var option: String
    @Binding var singleSelectedOptionArray: [String]
    var selectedItemId: String

    var body: some View {
        Button(action: {
            if singleSelectedOptionArray.contains(selectedItemId) {
                singleSelectedOptionArray = []
            } else {
                singleSelectedOptionArray = [selectedItemId]
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
