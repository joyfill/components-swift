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
            let text = cellModel.data.title
            let singleLineCharLimit = 30
            let isMultiLine = text.contains("\n") || text.count > singleLineCharLimit
            
            if #available(iOS 16.0, *) {
                TextEditor(text: $cellModel.data.title)
                    .font(.system(size: 15))
                    .scrollContentBackground(.hidden)
                    .accessibilityIdentifier("TabelTextFieldIdentifier")
                    .frame(minHeight: isMultiLine ? 60 : 20)
                    .fixedSize(horizontal: false, vertical: !isMultiLine)
                    .onChange(of: cellModel.data.title) { _ in
                        updateFieldValue()
                    }
                    .focused($isTextFieldFocused)
            } else {
                TextEditor(text: $cellModel.data.title)
                    .font(.system(size: 15))
                    .accessibilityIdentifier("TabelTextFieldIdentifier")
                    .frame(minHeight: isMultiLine ? 60 : 20)
                    .fixedSize(horizontal: false, vertical: !isMultiLine)
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
