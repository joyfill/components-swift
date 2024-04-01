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
    private let rowHeight: CGFloat = 50
    @Environment(\.colorScheme) var colorScheme
    
    public init(fieldDependency: FieldDependency) {
        self.viewModel = TableViewModel(fieldDependency: fieldDependency)
    }
        
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.tableViewTitle)
                .lineLimit(1)
                .font(.headline.bold())
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
                }.frame(maxHeight: CGFloat(viewModel.quickRows.count) * rowHeight + rowHeight)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
            )
            
            Button(action: {
                viewModel.isTableModalViewPresented.toggle()
            }, label: {
                HStack(alignment: .center, spacing: 0) {
                    Text("Table View")
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
            .padding(.top, 6)
            
            NavigationLink(destination: TableModalView(viewModel: viewModel), isActive: $viewModel.isTableModalViewPresented) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
            .hidden()
        }
        .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
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
                .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
                .frame(width: (screenWidth / 3) - 8, height: rowHeight)
            }
        }
    }
    
    var table: some View {
        ScrollViewReader { cellProxy in
            ScrollView([.vertical, .horizontal], showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.quickRows, id: \.self) { row in
                        HStack(alignment: .top, spacing: 0) {
                            ForEach(Array(viewModel.quickColumns.enumerated()), id: \.offset) { index, col in
                                // Cell
                                let cell = viewModel.getQuickFieldTableColumn(row: row, col: index)
                                if let cell = cell {
                                    let cellModel = TableCellModel(data: cell, eventHandler: viewModel.fieldDependency.eventHandler, fieldData: viewModel.fieldDependency.fieldData, viewMode: .quickView, didChange: nil)
                                    ZStack {
                                        Rectangle()
                                            .stroke()
                                            .foregroundColor(Color.tableCellBorderColor)
                                        TableViewCellBuilder(cellModel: cellModel)
                                    }
                                    .frame(width: (screenWidth / 3) - 8, height: rowHeight)
                                }
                            }
                        }
                    }
                }
            }
            .disabled(true)
        }
    }
}
