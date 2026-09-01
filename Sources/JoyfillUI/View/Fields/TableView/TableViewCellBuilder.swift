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
            TableTextView(cellModel: $cellModel)
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
            TableProgressView(cellModel: $cellModel, viewModel: viewModel)
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

struct HiddenCellView: View {
    @State private var showTooltip = false

    var body: some View {
        Button {
            dismissKeyboard()
            showTooltip = true
        } label: {
            Image(systemName: "eye.slash.fill")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("HiddenCellIdentifier")
        .popover(isPresented: $showTooltip) {
            if #available(iOS 16.4, *) {
                HiddenCellTooltip()
                    .presentationCompactAdaptation(.popover)
            } else {
                HiddenCellTooltip()
            }
        }
    }
}

struct HiddenCellTooltip: View {
    var body: some View {
        Text("This cell is hidden by logic")
            .font(.system(size: 14))
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(16)
            .frame(width: 180)
            .accessibilityIdentifier("HiddenCellTooltipIdentifier")
    }
}
