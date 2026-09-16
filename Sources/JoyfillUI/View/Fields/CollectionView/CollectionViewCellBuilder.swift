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

    /// Pulled here rather than inside the cell view: passing it down as a plain value is
    /// what lets SwiftUI see it change. Read inside the cell, its inputs would be
    /// unchanged and the body would not re-run.
    private var formulaValue: CellFormulaValue? {
        viewModel.formulaValue(columnID: cellModel.data.id, rowID: cellModel.rowID)
    }

    var body: some View {
        if viewModel.shouldShowCell(columnID: cellModel.data.id, rowID: cellModel.rowID) {
            cellContent
        } else {
            HiddenCellView()
        }
    }

    @ViewBuilder
    private var cellContent: some View {
        switch cellModel.data.type {
        case .text:
            TableTextView(cellModel: $cellModel, formulaValue: formulaValue)
                .disabled(cellModel.editMode == .readonly)
        case .dropdown:
            TableDropDownOptionListView(cellModel: $cellModel)
                .disabled(cellModel.editMode == .readonly)
        case .image:
            TableImageView(cellModel: $cellModel, viewModel: viewModel)
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
            TableBarcodeView(cellModel: $cellModel, viewModel: viewModel)
                .disabled(cellModel.editMode == .readonly)
        case .signature:
            TableSignatureView(cellModel: $cellModel)
                .disabled(cellModel.editMode == .readonly)
        default:
            Text("")
        }
    }
}
