//
//  SwiftUIView.swift
//
//
//  Created by Nand Kishore on 06/03/24.
//

import SwiftUI
import JoyfillModel

enum TableViewMode {
    case quickView
    case modalView
}

struct TableViewCellBuilder: View {
    private var cellModel: TableCellModel
    
    private var textFieldAxis: Axis {
        cellModel.viewMode == .quickView ? .horizontal : .vertical
    }
    
    private var lineLimit: Int? {
        cellModel.viewMode == .quickView ? 1 : nil
    }
    
    public init(cellModel: TableCellModel) {
        self.cellModel = cellModel
    }
    
    var body: some View {
        buildView()
    }
    
    @ViewBuilder
    func buildView() -> some View {
        switch cellModel.data.type {
        case "text":
            textField()
        case "dropdown":
            TableDropDownOptionListView(cellModel: cellModel)
        case "image":
            TableImageView(cellModel: cellModel)
        default:
            Text("")
        }
    }
    
    @State private var text = ""
    @FocusState private var isTextFieldFocused: Bool
    func textField() -> some View {
        TextField(text, text: $text)
            .lineLimit(lineLimit)
            .padding(4)
            .focused($isTextFieldFocused)
            .onChange(of: isTextFieldFocused) { isFocused in
                if !isFocused, cellModel.data.title != text {
                    var editedCell = cellModel.data
                    editedCell.title = text
                    cellModel.didChange?(editedCell)
                }
            }.onAppear {
                text = cellModel.data.title ?? ""
            }
    }
}
