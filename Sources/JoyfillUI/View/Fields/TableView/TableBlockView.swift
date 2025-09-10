//
//  SwiftUIView.swift
//  Joyfill
//
//  Created by Vivek on 26/12/24.
//

import SwiftUI

struct TableBlockView: View {
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
                ScrollView {
                    Text(cellModel.data.title)
                        .accessibilityIdentifier("TabelBlockFieldIdentifier")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.all, 8)
                }
        }
    }
}
