//
//  SwiftUIView.swift
//  
//
//  Created by Nand Kishore on 06/03/24.
//

import SwiftUI
import JoyfillModel

struct TableViewCellBuilder: View {
    private var data: FieldTableColumn?
    
    public init(data: FieldTableColumn?) {
        self.data = data
    }
    
    var body: some View {
        buildView(cell: data)
    }
    
    @ViewBuilder
    func buildView(cell: FieldTableColumn?) -> some View {
        if let cell = cell {
            switch cell.type {
            case "text":
                TextField(cell.title ?? "", text: .constant("\(cell.title ?? "")"))
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
    TableViewCellBuilder(data: nil)
}
