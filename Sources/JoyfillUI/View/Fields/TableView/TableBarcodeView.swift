//
//  SwiftUIView.swift
//  Joyfill
//
//  Created by Vivek on 15/01/25.
//

import SwiftUI

struct TableBarcodeView: View {
    @Binding var cellModel: TableCellModel
    @State var text: String = ""

    public init(cellModel: Binding<TableCellModel>, isUsedForBulkEdit: Bool = false) {
        _cellModel = cellModel
        if !isUsedForBulkEdit {
            _text = State(initialValue: cellModel.wrappedValue.data.title)
        }
    }
    
    var body: some View {
        if cellModel.viewMode == .quickView {
            Text(cellModel.data.title)
                .font(.system(size: 15))
                .lineLimit(1)
        } else {
            HStack(spacing: 0) {
                TextEditor(text: $text)
                    .font(.system(size: 15))
                    .onChange(of: text) { newText in
                        cellModel.data.title = newText
                        cellModel.didChange?(cellModel.data)
                    }
                
                Image(systemName: "barcode.viewfinder")
                    .onTapGesture {
                        print("Tapped")
                    }
                    .padding(.trailing, 12)
            }
        }
    }
}

