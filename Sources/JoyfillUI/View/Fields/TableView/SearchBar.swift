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
                let row = viewModel.tableDataModel.rowOrder[0]
                let column = viewModel.tableDataModel.getFieldTableColumn(row: row, col: selectedColumnIndex)
                if let column = column {
                    let cellModel = TableCellModel(rowID: "",
                                                   data: column,
                                                   documentEditor: viewModel.tableDataModel.documentEditor,
                                                   fieldIdentifier: viewModel.tableDataModel.fieldIdentifier,
                                                   viewMode: .modalView,
                                                   editMode: viewModel.tableDataModel.mode)
                    { editedCell,_ in
                        switch column.type {
                        case "text":
                            self.model.filterText = editedCell.title ?? ""
                        case "dropdown":
                            self.model.filterText = editedCell.defaultDropdownSelectedId ?? ""
                        default:
                            break
                        }
                    }
                    switch cellModel.data.type {
                    case "text":
                        TextFieldSearchBar(text: $model.filterText)
                    case "dropdown":
                        TableDropDownOptionListView(cellModel: cellModel, isUsedForBulkEdit: true, selectedDropdownValue: model.filterText)
                            .disabled(cellModel.editMode == .readonly)
                            .accessibilityIdentifier("SearchBarDropdownIdentifier")
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
