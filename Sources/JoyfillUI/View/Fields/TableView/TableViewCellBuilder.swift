//
//  SwiftUIView.swift
//
//
//  Created by Nand Kishore on 06/03/24.
//

import SwiftUI
import JoyfillModel

enum TableViewMode {
    case quickView
    case modalView
}

struct TableViewCellBuilder: View {
    @ObservedObject var viewModel: TableViewModel
    @Binding var cellModel: TableCellModel
    
    var body: some View {
        switch cellModel.data.type {
        case .text:
            TableTextView(cellModel: $cellModel)
                .disabled(cellModel.editMode == .readonly)
        case .dropdown:
            TableDropDownOptionListView(cellModel: $cellModel)
                .disabled(cellModel.editMode == .readonly)
        case .image:
            TableImageView(cellModel: $cellModel)
                .disabled(cellModel.editMode == .readonly)
        case .block:
            TableBlockView(cellModel: $cellModel)
        case .date:
            TableDateView(cellModel: $cellModel)
                .disabled(cellModel.editMode == .readonly)
        case .number:
            TableNumberView(cellModel: $cellModel)
                .disabled(cellModel.editMode == .readonly)
        case .multiSelect:
            TableMultiSelectView(cellModel: $cellModel)
                .disabled(cellModel.editMode == .readonly)
        case .progress:
            TableProgressView(cellModel: $cellModel, viewModel: viewModel)
        default:
            Text("")
        }
    }
}
