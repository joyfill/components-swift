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
    private var data: FieldTableColumn?
    private var viewMode: TableViewMode
    private var didChange: ((_ cell: FieldTableColumn) -> Void)?
    
    private var textFieldAxis: Axis {
        viewMode == .quickView ? .horizontal : .vertical
    }
    
    private var lineLimit: Int? {
        viewMode == .quickView ? 1 : nil
    }
    
    public init(data: FieldTableColumn?, viewMode: TableViewMode, _ delegate: ((_ cell: FieldTableColumn) -> Void)? = nil) {
        self.data = data
        self.viewMode = viewMode
        self.didChange = delegate
    }
    
    var body: some View {
        buildView(cell: data)
    }
    
    @ViewBuilder
    func buildView(cell: FieldTableColumn?) -> some View {
        if let cell = cell {
            switch cell.type {
            case "text":
                textField(cell: cell)
            case "dropdown":
                TableDropDownOptionListView(data: cell) { editedCell in
                    didChange?(editedCell)
                }
            case "image":
                TableImageView(data: cell) { editedCell in
                    didChange?(editedCell)
                }
            default:
                Text("")
            }
        } else {
            Text("")
        }
    }
    
    @State private var text = ""
    @FocusState private var isTextFieldFocused: Bool
    func textField(cell: FieldTableColumn) -> some View {
        TextField(text, text: $text)
        //        TextField(text, text: $text, axis: textFieldAxis)
            .lineLimit(lineLimit)
            .padding(4)
            .focused($isTextFieldFocused)
            .onChange(of: isTextFieldFocused) { isFocused in
                if !isFocused, cell.title != text {
                    var editedCell = cell
                    editedCell.title = text
                    didChange?(editedCell)
                }
            }.onAppear {
                text = cell.title ?? ""
            }
    }
}

#Preview {
    TableViewCellBuilder(data: nil,  viewMode: .modalView)
}
