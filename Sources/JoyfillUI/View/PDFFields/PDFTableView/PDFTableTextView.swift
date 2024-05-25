//
//  SwiftUIView.swift
//  
//
//  Created by Nand Kishore on 20/03/24.
//

import SwiftUI

struct PDFTableTextView: View {
    var cellModel: TableCellModel
    @State var text = ""

    public init(cellModel: TableCellModel) {
        self.cellModel = cellModel
        _text = State(initialValue: cellModel.data.title ?? "")
    }
    
    var body: some View {
        if cellModel.viewMode == .quickView {
            Text(text)
                .lineLimit(1)
        } else {
            TextEditor(text: $text)
                .accessibilityIdentifier("TabelTextFieldIdentifier")
                .onChange(of: text) { newText in
                    if cellModel.data.title != text {
                        var editedCell = cellModel.data
                        editedCell.title = text
                        cellModel.didChange?(editedCell)
                    }
                }
        }
    }
}
