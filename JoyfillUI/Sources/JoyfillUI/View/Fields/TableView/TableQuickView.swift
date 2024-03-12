//
//  SwiftUIView.swift
//
//
//  Created by Nand Kishore on 04/03/24.
//

import SwiftUI
import JoyfillModel

struct TableQuickView : View {
    @State private var offset = CGPoint.zero
    private let screenWidth = UIScreen.main.bounds.width
    @ObservedObject private var viewModel: TableViewModel
    
    //TODO: Remove this
    init(viewModel: TableViewModel) {
        self.viewModel = viewModel
    }
    
    // TODO: Uncomment this
    /*
     private let fieldDependency: FieldDependency
     @FocusState private var isFocused: Bool // Declare a FocusState property
     
     public init(fieldDependency: FieldDependency) {
     self.fieldDependency = fieldDependency
     self.viewModel = TableViewModel(mode: fieldDependency.mode, joyDocModel: fieldDependency.fieldData)
     }
     */
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.tableViewTitle)
                .lineLimit(1)
                .fontWeight(.bold)
            
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView([.horizontal]) {
                        colsHeader
                            .offset(x: offset.x)
                    }
                    .disabled(true)
                    .background(Color.tableCellBorderColor)
                    .cornerRadius(14, corners: [.topRight, .topLeft])
                    
                    table
                        .cornerRadius(14, corners: [.bottomLeft, .bottomRight])
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
            )
            
            Button(action: {
                viewModel.isTableModalViewPresented.toggle()
            }, label: {
                HStack(alignment: .center, spacing: 0) {
                    Text("View")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.blue)
                    
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.blue)
                        .font(.system(size: 8, weight: .heavy))
                        .padding(EdgeInsets(top: 2, leading: 2, bottom: 0, trailing: 8))
                    
                    Text(viewModel.viewMoreText)
                        .font(.system(size: 16))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
            })
            .padding(.top, 10)
            
            NavigationLink(destination: TableModalView(viewModel: viewModel), isActive: $viewModel.isTableModalViewPresented) {
                EmptyView()
            }
        }.padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
    }
    
    var colsHeader: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(viewModel.quickColumns, id: \.self) { col in
                ZStack {
                    Rectangle()
                        .stroke()
                        .foregroundColor(Color.tableCellBorderColor)
                    Text(viewModel.getColumnTitle(columnId: col))
                }
                .background(Color.tableColumnBgColor)
                .frame(width: (screenWidth / 3) - 8, height: 50)
            }
        }
    }
    
    var table: some View {
        ScrollViewReader { cellProxy in
            ScrollView([.vertical, .horizontal]) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.quickRows, id: \.self) { row in
                        HStack(alignment: .top, spacing: 0) {
                            ForEach(Array(viewModel.quickColumns.enumerated()), id: \.offset) { index, col in
                                // Cell
                                let cell = viewModel.getQuickFieldTableColumn(row: row, col: index)
                                ZStack {
                                    Rectangle()
                                        .stroke()
                                        .foregroundColor(Color.tableCellBorderColor)
                                    TableViewCellBuilder(data: cell, viewMode: .quickView)
                                }.frame(width: (screenWidth / 3) - 8, height: 50).id("\(row)_\(col)")
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .disabled(true)
        }
    }
}

#Preview {
    TableQuickView(viewModel: TableViewModel(mode: .fill, joyDocModel: fakeTableData()))
}
