//
//  SwiftUIView.swift
//
//
//  Created by Nand Kishore on 04/03/24.
//

import SwiftUI

struct TableQuickView : View {
    @State private var offset = CGPoint.zero
    private var data  = Array(1...3) // TODO: replace with actual rows
    private var data2  = Array(1...9) // TODO: replace with actual rows
    private let adaptiveColumn = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    @ObservedObject private var viewModel: TableViewModel
    
    //TODO: Remove this
    init(tableViewModel: TableViewModel) {
        self.viewModel = tableViewModel
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
        
        VStack {
            HStack {
                Text(viewModel.tableViewTitle)
                    .lineLimit(1)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(alignment: .center, spacing: 0) {
                    Text("View")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.blue)
                    
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.blue)
                        .font(.system(size: 8, weight: .heavy))
                        .padding(EdgeInsets(top: 2, leading: 2, bottom: 0, trailing: 8))
                    
                    Text(viewModel.viewMoreText)
                        .font(.system(size: 14))
                }
            }
            .padding(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14))
            .onTapGesture {
                viewModel.isTableModalViewPresented.toggle()
            }
            .sheet(isPresented: $viewModel.isTableModalViewPresented) {
                TableModalView(tableViewModel: viewModel)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView([.horizontal]) {
                        colsHeader
                            .offset(x: offset.x)
                    }
                    .disabled(true)
                    .background(Color.tableCellBorderColor)
                    .cornerRadius(14, corners: [.topRight])
                    
                    table
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.tableBorderBgColor, lineWidth: 1)
            )
            .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
            
        }
        
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
                .frame(width: (UIScreen.main.bounds.width / 3)-8, height: 50)
                
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
                                let t = viewModel.getQuickFieldTableColumn(row: row, col: index)
                                ZStack {
                                    Rectangle()
                                        .stroke()
                                        .foregroundColor(Color.tableCellBorderColor)
                                    // TODO: Switch view here
                                    Text(t?.title ?? "(\(row), \(col))")
                                }.frame(width: (UIScreen.main.bounds.width / 3)-8, height: 50).id("\(row)_\(col)")
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
    TableQuickView(tableViewModel: TableViewModel(mode: .fill, joyDocModel: fakeTableData()))
}
