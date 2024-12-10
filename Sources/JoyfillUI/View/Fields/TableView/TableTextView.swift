//
//  SwiftUIView.swift
//  
//
//  Created by Nand Kishore on 20/03/24.
//

import SwiftUI

struct TableTextView: View {
    @FocusState private var isTextFieldFocused: Bool
    var cellModel: TableCellModel
    @State var text = ""

    public init(cellModel: TableCellModel) {
        self.cellModel = cellModel
        _text = State(initialValue: cellModel.data.title ?? "")
    }
    
    var body: some View {
        if cellModel.viewMode == .quickView {
            Text(text)
                .font(.system(size: 15))
                .lineLimit(1)
        } else {
            TextEditor(text: $text)
                .font(.system(size: 15))
                .accessibilityIdentifier("TabelTextFieldIdentifier")
                .onChange(of: text) { newText in
                    if cellModel.data.title != text {
                        var editedCell = cellModel.data
                        editedCell.title = text
                        cellModel.didChange?(editedCell, false)
                    }
                }
                .focused($isTextFieldFocused)
                .onChange(of: isTextFieldFocused) { isFocused in
                    if !isFocused {
                        if cellModel.data.title != text {
                            var editedCell = cellModel.data
                            editedCell.title = text
                            cellModel.didChange?(editedCell, true)
                        }
                    }
                }
        }
    }
}
