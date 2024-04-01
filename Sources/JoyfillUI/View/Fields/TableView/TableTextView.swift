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

    public init(cellModel: TableCellModel) {
        self.cellModel = cellModel
        _text = State(initialValue: cellModel.data.title ?? "")
    }
    
    var body: some View {
        TextEditor(text: $text)
            .onChange(of: text) { newText in
                if cellModel.data.title != text {
                    var editedCell = cellModel.data
                    editedCell.title = text
                    cellModel.didChange?(editedCell)
                }
            }
    }
}
