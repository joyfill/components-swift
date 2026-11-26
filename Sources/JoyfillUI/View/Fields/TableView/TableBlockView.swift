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
    /// Pulled by the cell builder; a Wisdom cell formula result to show instead of the static title.
    let formulaValue: CellFormulaValue?

    public init(cellModel: Binding<TableCellModel>, formulaValue: CellFormulaValue? = nil) {
        _cellModel = cellModel
        self.formulaValue = formulaValue
    }

    /// The formula result when present, otherwise the authored label text.
    private var displayText: String {
        formulaValue?.text ?? cellModel.data.title
    }

    var body: some View {
        if cellModel.viewMode == .quickView {
            Text(displayText)
                .font(.system(size: 15))
                .lineLimit(1)
        } else {
                ScrollView {
                    Text(displayText)
                        .accessibilityIdentifier("TabelBlockFieldIdentifier")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.all, 8)
                }
        }
    }
}
