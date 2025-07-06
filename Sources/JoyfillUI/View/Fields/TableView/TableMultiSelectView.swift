//
//  SwiftUIView.swift
//  Joyfill
//
//  Created by Vivek on 20/12/24.
//

import SwiftUI

struct TableMultiSelectView: View {
    @State private var showMoreImages = 5
    @State private var showMoreImages2 = false
    @Binding var cellModel: TableCellModel
    @State private var singleSelectedOptionArray: [String] = []
    @State private var multiSelectedOptionArray: [String] = []

    private var isUsedForBulkEdit: Bool
    private var isSearching: Bool

    private var isMulti: Bool {
        cellModel.data.multi ?? true
    }

    private var selectedValues: [String] {
        isSearching ? singleSelectedOptionArray : (isMulti ? multiSelectedOptionArray : singleSelectedOptionArray)
    }

    private var selectedOptionColor: Color {
        if let firstSelectedOption = cellModel.data.options?.first(where: { selectedValues.contains($0.id ?? "") }),
           let color = firstSelectedOption.color {
            return Color(hex: color)
        }
        return Color(red: 239 / 255, green: 239 / 255, blue: 240 / 255)
    }

    public init(cellModel: Binding<TableCellModel>, isUsedForBulkEdit: Bool = false, isSearching: Bool = false, searchValue: String? = nil) {
        _cellModel = cellModel
        self.isUsedForBulkEdit = isUsedForBulkEdit
        self.isSearching = isSearching
        
        if !isUsedForBulkEdit {
            let values = cellModel.wrappedValue.data.multiSelectValues ?? []
            if cellModel.wrappedValue.data.multi ?? true {
                _multiSelectedOptionArray = State(initialValue: values)
            } else {
                _singleSelectedOptionArray = State(initialValue: values)
            }
        }
        if isSearching {
            if let searchValue = searchValue {
                _singleSelectedOptionArray = State(initialValue: [searchValue])
            }
        }
    }

    var body: some View {
        Button(action: {
            showMoreImages = Int.random(in: 0...100)
        }) {
            HStack {
                if let firstSelectedOption = cellModel.data.options?.first(where: { selectedValues.contains($0.id ?? "") }),
                   let optionValue = firstSelectedOption.value {
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
        }
        .accessibilityIdentifier("TableMultiSelectionFieldIdentifier")
        .padding(8)
        .background(selectedOptionColor)
        .cornerRadius(16)
        .padding(.horizontal, 8)
        .sheet(isPresented: $showMoreImages2) {
            TableMultiSelectSheetView(
                cellModel: $cellModel,
                isUsedForBulkEdit: isUsedForBulkEdit,
                singleSelectedOptionArray: $singleSelectedOptionArray,
                multiSelectedOptionArray: $multiSelectedOptionArray,
                isMulti: isSearching ? false : isMulti
            )
            .disabled(cellModel.editMode == .readonly)
        }
        .onChange(of: showMoreImages) { _ in
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
                .accessibilityIdentifier("TableMultiSelectionFieldApplyIdentifier")

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
            
            ScrollView {
                VStack(spacing: 0){
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
                                                    selectedItemId: options[index].id ?? "",
                                                    color: Color(hex: options[index].color ?? ""))
                                
                                if index < options.count - 1 {
                                    Divider()
                                }
                            } else {
                                TableRadioView(option: optionValue,
                                               singleSelectedOptionArray: $tempSingleSelectedOptionArray,
                                               selectedItemId: options[index].id ?? "",
                                               color: Color(hex: options[index].color ?? ""))
                                if index < options.count - 1 {
                                    Divider()
                                }
                            }
                        }
                    }
                }
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
            }
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
    var color: Color = .primary

    var body: some View {
        Button(action: {
            isSelected.toggle()
            if let index = multiSelectedOptionArray.firstIndex(of: selectedItemId) {
                multiSelectedOptionArray.remove(at: index) // Item exists, so remove it
            } else {
                multiSelectedOptionArray.append(selectedItemId) // Item doesn't exist, so add it
            }
        }, label: {
            HStack {
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
            .background(color)
        })
        .accessibilityIdentifier("TableMultiSelectOptionsSheetIdentifier")
        .frame(maxWidth: .infinity)
    }
}

//Select only one choice
struct TableRadioView: View {
    var option: String
    @Binding var singleSelectedOptionArray: [String]
    var selectedItemId: String
    var color: Color = .primary

    var body: some View {
        Button(action: {
            if singleSelectedOptionArray.contains(selectedItemId) {
                singleSelectedOptionArray = []
            } else {
                singleSelectedOptionArray = [selectedItemId]
            }
        }, label: {
            HStack {
                Image(systemName: singleSelectedOptionArray == [selectedItemId] ? "smallcircle.filled.circle.fill" : "circle")
                    .padding(.top, 4)
                Text(option)
                    .darkLightThemeColor()
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(color)
        })
        .accessibilityIdentifier("TableSingleSelectOptionsSheetIdentifier")
        .frame(maxWidth: .infinity)
    }
}
