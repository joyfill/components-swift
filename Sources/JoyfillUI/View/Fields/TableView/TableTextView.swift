//
//  SwiftUIView.swift
//  
//
//  Created by Nand Kishore on 20/03/24.
//

import SwiftUI

struct TableTextView: View {
    var cellModel: TableCellModel
    @State var text = ""
    @FocusState private var isFocused: Bool

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
                .focused($isFocused) // Track focus state
                .accessibilityIdentifier("TabelTextFieldIdentifier")
                .onChange(of: text) { newText in
                    if cellModel.data.title != text {
                        var editedCell = cellModel.data
                        editedCell.title = text
                        cellModel.didChange?(editedCell)
                    }
                }
                .onChange(of: isFocused) { focused in
                    if !focused {
                        var editedCell = cellModel.data
                        editedCell.title = text
                        cellModel.refreshTable?()
                    }
                }
        }
    }
}
