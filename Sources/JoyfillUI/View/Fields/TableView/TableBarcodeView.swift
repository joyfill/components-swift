//
//  SwiftUIView.swift
//  Joyfill
//
//  Created by Vivek on 15/01/25.
//

import SwiftUI
import JoyfillModel

struct TableBarcodeView: View {
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
        if cellModel.viewMode == .quickView {
            Text(cellModel.data.title)
                .font(.system(size: 15))
                .lineLimit(1)
        } else {
            HStack(spacing: 0) {
                TextEditor(text: $text)
                    .font(.system(size: 15))
                    .onChange(of: text) { newText in
                        var cellModelData = cellModel.data
                        cellModelData.title = newText
                        cellModel.data = cellModelData
                        cellModel.didChange?(cellModelData)
                    }
                    
                
                Image(systemName: "barcode.viewfinder")
                    .onTapGesture {
                        uploadAction()
                    }
                    .padding(.trailing, 12)
            }
        }
    }
    
    func uploadAction() {
        let uploadEvent = UploadEvent(fieldEvent: cellModel.fieldIdentifier) { urls in
            var cellModelData = cellModel.data
            cellModelData.title = urls[0]
            text = urls[0]
            cellModel.data = cellModelData
            cellModel.didChange?(cellModelData)
        }
        cellModel.documentEditor?.onUpload(event: uploadEvent)
    }
}

