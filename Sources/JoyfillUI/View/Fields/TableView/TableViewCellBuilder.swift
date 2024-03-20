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

    public init(cellModel: TableCellModel) {
        self.cellModel = cellModel
    }
    
    var body: some View {
        switch cellModel.data.type {
        case "text":
            TableTextView(cellModel: cellModel)
        case "dropdown":
            TableDropDownOptionListView(cellModel: cellModel)
        case "image":
            TableImageView(cellModel: cellModel)
        default:
            Text("")
        }
    }
}
