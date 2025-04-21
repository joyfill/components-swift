//
//  File.swift
//  Joyfill
//
//  Created by Vivek on 14/02/25.
//

import SwiftUI
import JoyfillModel

struct CollectionViewCellBuilder: View {
    @ObservedObject var viewModel: CollectionViewModel
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
            CollectionProgressView(cellModel: $cellModel, viewModel: viewModel)
        case .barcode:
            TableBarcodeView(cellModel: $cellModel)
                .disabled(cellModel.editMode == .readonly)
        case .signature:
            TableSignatureView(cellModel: $cellModel)
                .disabled(cellModel.editMode == .readonly)
        default:
            Text("")
        }
    }
}
