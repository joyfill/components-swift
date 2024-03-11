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
    
    private var textFieldAxis: Axis {
        viewMode == .quickView ? .horizontal : .vertical
    }
    
    public init(data: FieldTableColumn?, viewMode: TableViewMode) {
        self.data = data
        self.viewMode = viewMode
    }
    
    var body: some View {
        buildView(cell: data)
    }
    
    @ViewBuilder
    func buildView(cell: FieldTableColumn?) -> some View {
        if let cell = cell {
            switch cell.type {
            case "text":
                TextField(cell.title ?? "", text: .constant("\(cell.title ?? "")"), axis: textFieldAxis)
                    .padding(4)
            case "dropdown":
                TableDropDownOptionListView(data: cell)
            case "image":
                TableImageView(data: cell)
            default:
                Text("")
            }
        } else {
            Text("")
        }
    }
}

#Preview {
    TableViewCellBuilder(data: nil,  viewMode: .modalView)
}
