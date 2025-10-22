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
        if cellModel.viewMode == .quickView || cellModel.editMode == .readonly {
            Text(cellModel.data.title)
                .font(.system(size: 15))
                .lineLimit(1)
                .accessibilityIdentifier("TableTextFieldIdentifierReadonly")
        } else {
            if #available(iOS 16.0, *) {
                TextEditor(text: $cellModel.data.title)
                    .font(.system(size: 15))
                    .scrollContentBackground(.hidden)
                    .accessibilityIdentifier("TabelTextFieldIdentifier")
                    .onChange(of: cellModel.data.title) { _ in
                        updateFieldValue()
                    }
                    .focused($isTextFieldFocused)
            } else {
                TextEditor(text: $cellModel.data.title)
                    .font(.system(size: 15))
                    .accessibilityIdentifier("TabelTextFieldIdentifier")
                    .onChange(of: cellModel.data.title) { _ in
                        updateFieldValue()
                    }
                    .focused($isTextFieldFocused)
            }
        }
    }
    
    func updateFieldValue() {
        cellModel.didChange?(cellModel.data)
    }
}
