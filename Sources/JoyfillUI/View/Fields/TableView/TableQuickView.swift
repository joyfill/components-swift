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
    @State var isTableModalViewPresented = false
    var tableDataModel: TableDataModel
    let eventHandler: FieldChangeEvents
    @State private var refreshID = UUID()

    public init(tableDataModel: TableDataModel, eventHandler: FieldChangeEvents) {
        self.viewModel = TableViewModel(tableDataModel: tableDataModel)
        self.tableDataModel = tableDataModel
        self.eventHandler = eventHandler
    }
        
    var body: some View {
        VStack(alignment: .leading) {
            FieldHeaderView(tableDataModel.fieldHeaderModel)
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView([.horizontal]) {
                        colsHeader
                            .offset(x: offset.x)
                    }
                    .disabled(true)
                    .background(Color.clear)
                    .cornerRadius(14, corners: [.topRight, .topLeft])
                    table
                        .id(refreshID)
                        .cornerRadius(14, corners: [.bottomLeft, .bottomRight])
                }
                .frame(maxHeight:
                        (CGFloat((viewModel.tableDataModel.rowOrder.isEmpty ? 2:  viewModel.tableDataModel.rowOrder.count)) * rowHeight + rowHeight)
                       )
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
            )
            
            Button(action: {
                isTableModalViewPresented.toggle()
                eventHandler.onFocus(event: tableDataModel.fieldIdentifier)
            }, label: {
                HStack(alignment: .center, spacing: 0) {
                    Text("Table View")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.blue)
                    
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.blue)
                        .font(.system(size: 8, weight: .heavy))
                        .padding(EdgeInsets(top: 2, leading: 2, bottom: 0, trailing: 8))
                    
                    Text(viewModel.tableDataModel.viewMoreText)
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
            .accessibilityIdentifier("TableDetailViewIdentifier")
            .padding(.top, 6)
            
            NavigationLink(destination: TableModalView(viewModel: viewModel), isActive: $isTableModalViewPresented) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
            .hidden()
        }
        .onAppear() {
            refreshID = UUID()
        }
    }
    
    var colsHeader: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(viewModel.tableDataModel.columns.prefix(3), id: \.self) { col in
                ZStack {
                    Rectangle()
                        .stroke()
                        .foregroundColor(Color.tableCellBorderColor)
                    Text(viewModel.tableDataModel.getColumnTitle(columnId: col))
                        .padding(.horizontal, 4)
                }
                .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
                .frame(width: (screenWidth / 3) - 8, height: rowHeight)
            }
        }
    }
    
    var table: some View {
        VStack(alignment: .leading, spacing: 0) {
            let rows = (viewModel.tableDataModel.rowOrder.prefix(3).count != 0) ? viewModel.tableDataModel.rowOrder.prefix(3) : ["Dummy-rowID"]
            ForEach(rows, id: \.self) { row in
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(viewModel.tableDataModel.columns.prefix(3).enumerated()), id: \.offset) { index, col in
                        // Cell
                        let cell = viewModel.tableDataModel.getQuickFieldTableColumn(row: row, col: index)
                        if let cell = cell {
                            let cellModel = TableCellModel(rowID: row,
                                                           data: cell,
                                                           documentEditor: viewModel.tableDataModel.documentEditor,
                                                           fieldIdentifier: viewModel.tableDataModel.fieldIdentifier,
                                                           viewMode: .quickView,
                                                           editMode: viewModel.tableDataModel.mode,
                                                           didChange: nil)
                            ZStack {
                                Rectangle()
                                    .stroke()
                                    .foregroundColor(Color.tableCellBorderColor)
                                TableViewCellBuilder(cellModel: Binding.constant(cellModel))
                            }
                            .frame(width: (screenWidth / 3) - 8, height: rowHeight)
                        }
                    }
                }
            }
        }
        .id(viewModel.uuid)
        .disabled(true)
    }
}

