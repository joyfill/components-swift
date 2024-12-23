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

    public init(cellModel: Binding<TableCellModel>, isUsedForBulkEdit: Bool = false) {
        _cellModel = cellModel
        self.isUsedForBulkEdit = isUsedForBulkEdit
        _showMoreImages = State(wrappedValue: 6)
    }
   
   var body: some View {
       Button(action: {
           showMoreImages = Int.random(in: 0...100)
       }, label: {
           HStack {
               VStack(alignment: .leading, spacing: 2) {
                   if let selectedValues = cellModel.data.multiSelectValues,
                      let options = cellModel.data.options?.filter({ !($0.deleted ?? false) }) {
                       ForEach(0..<options.count, id: \.self) { index in
                           let optionValue = options[index].value ?? ""
                           if selectedValues.contains(options[index].id ?? "") {
                               HStack {
                                   Image(systemName: "checkmark")
                                       .resizable()
                                       .frame(width: 12, height: 12)
                                       .foregroundStyle(.black)
                                   
                                   Text(optionValue)
                                       .lineLimit(1)
                                       .font(.system(size: 15))
                                       .foregroundStyle(.black)
                               }
                           }
                       }
                   }
               }
               .padding(.leading, 8)
               .padding(.vertical, 4)
               
               Spacer()
               
               Image(systemName: "chevron.down")
                   .foregroundStyle(.black)
                   .padding(.vertical, 12)
                   .padding(.trailing, 8)
           }
       })
       .background(Color(red: 239 / 255, green: 239 / 255, blue: 240 / 255))
       .cornerRadius(16)
       .padding(.horizontal, 8)
       .sheet(isPresented: $showMoreImages2) {
           TableMultiSelectSheetView(cellModel: $cellModel, isUsedForBulkEdit: isUsedForBulkEdit)
               .disabled(cellModel.editMode == .readonly)
       }
       .onChange(of: showMoreImages) { newValue in
           showMoreImages2 = true
       }
   }
}

struct TableMultiSelectSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var singleSelectedOptionArray: [String] = []
    @State var multiSelectedOptionArray: [String] = []
    @Binding var cellModel: TableCellModel
    private var isUsedForBulkEdit = false

    public init(cellModel: Binding<TableCellModel>, isUsedForBulkEdit: Bool = false) {
        _cellModel = cellModel
        self.isUsedForBulkEdit = isUsedForBulkEdit
        if !isUsedForBulkEdit {
            if cellModel.wrappedValue.data.multi ?? true {
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
        VStack(alignment: .leading) {
            if !isUsedForBulkEdit {
                HStack {
                    Text(cellModel.data.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark.circle")
                            .imageScale(.large)
                    })
                }
                .padding(.bottom, 12)
            }
            VStack {
                if let options = cellModel.data.options?.filter({ !($0.deleted ?? false) }) {
                    ForEach(0..<options.count, id: \.self) { index in
                        let optionValue = options[index].value ?? ""
                        let isSelected: Bool = {
                            let selectedArray = (cellModel.data.multi ?? true) ? multiSelectedOptionArray : singleSelectedOptionArray
                            return selectedArray.contains(options[index].id ?? "") ?? false
                        }()
                        
                        if cellModel.data.multi ?? true {
                            TableMultiSelection(option: optionValue,
                                           isSelected: isSelected,
                                           multiSelectedOptionArray: $multiSelectedOptionArray,
                                           selectedItemId: options[index].id ?? "")
                            if index < options.count - 1 {
                                Divider()
                            }
                        } else {
                            TableRadioView(option: optionValue,
                                      singleSelectedOptionArray: $singleSelectedOptionArray,
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
        .padding(.all, isUsedForBulkEdit ? 0 : 16)
        .onChange(of: singleSelectedOptionArray) { newValue in
            onChange(newValue: newValue)
        }
        .onChange(of: multiSelectedOptionArray) { newValue in
            onChange(newValue: newValue)
        }
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
