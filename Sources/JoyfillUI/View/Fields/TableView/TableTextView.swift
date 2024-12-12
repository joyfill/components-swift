//
//  SwiftUIView.swift
//  
//
//  Created by Nand Kishore on 20/03/24.
//

import SwiftUI

struct TableTextView: View {
    @FocusState private var isTextFieldFocused: Bool
    @Binding var cellModel: TableCellModel

    public init(cellModel: Binding<TableCellModel>) {
        _cellModel = cellModel
    }
    
    var body: some View {
        if cellModel.viewMode == .quickView {
            Text(cellModel.data.title)
                .font(.system(size: 15))
                .lineLimit(1)
        } else {
            TextEditor(text: $cellModel.data.title)
                .font(.system(size: 15))
                .accessibilityIdentifier("TabelTextFieldIdentifier")
                .onChange(of: cellModel.data.title) { newText in
                    cellModel.didChange?(cellModel.data, false)
                }
                .focused($isTextFieldFocused)
        }
    }
}
