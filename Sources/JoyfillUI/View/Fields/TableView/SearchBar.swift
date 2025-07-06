//
//  File.swift
//  
//
//  Created by Vishnu Dutt on 11/12/24.
//

import SwiftUI
import JoyfillModel

struct SearchBar: View {
    @Binding var model: FilterModel
    @Binding var sortModel: SortModel
    @Binding var selectedColumnIndex: Int

    let viewModel: TableViewModel

    var body: some View {
        HStack {
            if !viewModel.tableDataModel.rowOrder.isEmpty, selectedColumnIndex != Int.min {
                let column = viewModel.tableDataModel.getDummyCell(col: selectedColumnIndex)
                if let column = column {
                    let cellModel = TableCellModel(rowID: "",
                                                   data: column,
                                                   documentEditor: viewModel.tableDataModel.documentEditor,
                                                   fieldIdentifier: viewModel.tableDataModel.fieldIdentifier,
                                                   viewMode: .modalView,
                                                   editMode: viewModel.tableDataModel.mode)
                    { cellDataModel in
                        switch column.type {
                        case .text:
                            self.model.filterText = cellDataModel.title ?? ""
                        case .dropdown:
                            self.model.filterText = cellDataModel.defaultDropdownSelectedId ?? ""
                        case .number:
                            var stringNumberValue: String
                            if let number = cellDataModel.number {
                                stringNumberValue = String(format: "%g", number)
                            } else {
                                stringNumberValue = ""
                            }
                            self.model.filterText = stringNumberValue
                        case .multiSelect:
                            self.model.filterText = cellDataModel.multiSelectValues?.first ?? ""
                        case .barcode:
                            self.model.filterText = cellDataModel.title ?? ""
                        default:
                            break
                        }
                    }
                    switch cellModel.data.type {
                    case .text:
                        TextFieldSearchBar(text: $model.filterText)
                            .frame(height: 25)
                    case .dropdown:
                        TableDropDownOptionListView(cellModel: Binding.constant(cellModel), isUsedForBulkEdit: true, selectedDropdownValue: model.filterText)
                            .accessibilityIdentifier("SearchBarDropdownIdentifier")
                    case .number:
                        TableNumberView(cellModel: Binding.constant(cellModel), isUsedForBulkEdit: true, number: model.filterText)
                            .accessibilityIdentifier("SearchBarNumberIdentifier")
                            .font(.system(size: 12))
                            .foregroundColor(.black)
                            .padding(.vertical, 4)
                            .frame(height: 25)
                            .background(.white)
                            .cornerRadius(6)
                            .padding(.leading, 8)
                    case .multiSelect:
                        TableMultiSelectView(cellModel: Binding.constant(cellModel), isUsedForBulkEdit: true, isSearching: true, searchValue: model.filterText)
                            .accessibilityIdentifier("SearchBarMultiSelectionFieldIdentifier")
                    case .barcode:
                        TableBarcodeView(cellModel: Binding.constant(cellModel), isUsedForBulkEdit: true, text: model.filterText)
                            .accessibilityIdentifier("SearchBarCodeFieldIdentifier")
                            .font(.system(size: 12))
                            .foregroundColor(.black)
                            .padding(.vertical, 4)
                            .frame(height: 25)
                            .background(.white)
                            .cornerRadius(6)
                            .padding(.leading, 8)
                    default:
                        Text("")
                    }
                }
                Button(action: {
                    sortModel.order.next()
                }, label: {
                    HStack {
                        Text("Sort")
                        Image(systemName: getSortIcon())
                            .foregroundColor(getIconColor())
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                })
                .accessibilityIdentifier("SortButtonIdentifier")
                .frame(width: 75, height: 25)
                .background(.white)
                .cornerRadius(4)

                Button(action: {
                    model.filterText = ""
                    sortModel.order = .none
                    selectedColumnIndex = Int.min
                }, label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.black)
                        .padding(.all, 8)
                        .background(.white)
                        .cornerRadius(4)
                        .padding(.trailing, 8)

                })
                .accessibilityIdentifier("HideFilterSearchBar")
            }
        }
        .frame(height: 40)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal, 12)
    }

    func getSortIcon() -> String {
        switch viewModel.tableDataModel.sortModel.order {
        case .ascending:
            return "arrow.up"
        case .descending:
            return "arrow.down"
        case .none:
            return "arrow.up.arrow.down"
        }
    }

    func getIconColor() -> Color {
        switch viewModel.tableDataModel.sortModel.order {
        case .none:
            return .black
        case .ascending, .descending:
            return .blue
        }
    }
}
