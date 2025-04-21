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
    @State private var debounceTask: Task<Void, Never>?

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
                .onChange(of: cellModel.data.title) { _ in
                    Utility.debounceTextChange(debounceTask: &debounceTask) {
                        updateFieldValue()
                    }
                }
                .focused($isTextFieldFocused)
        }
    }
    
    func updateFieldValue() {
        cellModel.didChange?(cellModel.data)
    }
}
