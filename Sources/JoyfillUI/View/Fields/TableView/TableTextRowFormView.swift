//
//  SwiftUIView.swift
//  Joyfill
//
//  Created by Vivek on 17/11/25.
//
import SwiftUI
import JoyfillModel

struct TableTextRowFormView: View {
    @Binding var cellModel: TableCellModel
    @State var text: String = ""
    private var isUsedForBulkEdit: Bool

    public init(cellModel: Binding<TableCellModel>, isUsedForBulkEdit: Bool = false, text: String? = nil) {
        _cellModel = cellModel
        self.isUsedForBulkEdit = isUsedForBulkEdit
        if let providedText = text {
            _text = State(initialValue: providedText)
        } else if !isUsedForBulkEdit {
            _text = State(initialValue: cellModel.wrappedValue.data.title)
        }
    }
    
    var body: some View {
        if cellModel.viewMode == .quickView || cellModel.editMode == .readonly {
            HStack(spacing: 0) {
                Text(cellModel.data.title)
                    .font(.system(size: 15))
                    .lineLimit(1)
                    .padding(.leading, 4)
            }
        } else {
            HStack(spacing: 0) {
                if #available(iOS 16.0, *) {
                    TextEditor(text: $text)
                        .font(.system(size: 15))
                        .scrollContentBackground(.hidden)
                        .onChange(of: text) { newValue in
                            updateFieldValue(newText: newValue)
                        }
                } else {
                    TextEditor(text: $text)
                        .font(.system(size: 15))
                        .onChange(of: text) { newValue in
                            updateFieldValue(newText: newValue)
                        }
                }
            }
        }
    }
    
    func updateFieldValue(newText: String) {
        var cellModelData = cellModel.data
        cellModelData.title = newText
        cellModel.data = cellModelData
        cellModel.didChange?(cellModelData)
    }
}


