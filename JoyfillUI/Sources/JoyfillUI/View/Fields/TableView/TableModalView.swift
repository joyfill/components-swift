//
//  SwiftUIView.swift
//
//
//  Created by Nand Kishore on 04/03/24.
//

import SwiftUI
import JoyfillModel


struct TableModalView : View {
    @State private var offset = CGPoint.zero
    @ObservedObject var viewModel: TableViewModel
    
    init(viewModel: TableViewModel) {
        self.viewModel = viewModel
        UIScrollView.appearance().bounces = false
    }
    
    var body: some View {
        VStack {
            TableModalTopNavigationView(isDeleteButtonVisible: $viewModel.shouldShowDeleteRowButton, onDeleteTap: {
                viewModel.deleteSelectedRow()
            }, onAddRowTap: {
                viewModel.addRow()
            })
            .padding(EdgeInsets(top: 16, leading: 10, bottom: 10, trailing: 10))
            
            scrollArea
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
        }
    }
    
    var scrollArea: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    if viewModel.showRowSelector  {
                        Spacer()
                            .frame(height: 40)
                    }
                    
                    Text("#").frame(width: 40)
                }.frame(width: viewModel.showRowSelector ? 80 : 40, height: 50)
                    .background(Color.tableColumnBgColor)
                    .cornerRadius(14, corners: [.topLeft])
                
                ScrollView([.vertical]) {
                    rowsHeader
                        .offset(y: offset.y)
                }
                .scrollIndicators(.hidden)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                ScrollView([.horizontal]) {
                    colsHeader
                        .offset(x: offset.x)
                }
                .disabled(true)
                .background(Color.tableCellBorderColor)
                .cornerRadius(14, corners: [.topRight])
                
                table
                    .coordinateSpace(name: "scroll")
            }
        }
        
        .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
    }
    
    var colsHeader: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(viewModel.columns, id: \.self) { col in
                ZStack {
                    Rectangle()
                        .stroke()
                        .foregroundColor(Color.tableCellBorderColor)
                    Text(viewModel.getColumnTitle(columnId: col))
                }.background(Color.tableColumnBgColor).frame(width: 170, height: 50)
                
            }
        }
    }
    
    var rowsHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(viewModel.rowsSelection.enumerated()), id: \.offset) { (index, row) in
                HStack(spacing: 0) {
                    if viewModel.showRowSelector { Image(systemName: row ? "record.circle.fill" : "circle")
                            .frame(width: 40, height: 50)
                            .border(Color.tableCellBorderColor)
                            .onTapGesture {
                                viewModel.toggleSelection(at: index)
                                viewModel.setDeleteButtonVisibility()
                            }
                        
                    }
                    Text("\(index+1)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .frame(width: 40, height: 50)
                        .border(Color.tableCellBorderColor)
                        .id("\(index)")
                }
            }
        }
    }
    
    var table: some View {
        ScrollViewReader { cellProxy in
            GeometryReader { geometry in
                ScrollView([.vertical, .horizontal]) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.rows, id: \.self) { row in
                            HStack(alignment: .top, spacing: 0) {
                                ForEach(Array(viewModel.columns.enumerated()), id: \.offset) { index, col in
                                    // Cell
                                    let cell = viewModel.getFieldTableColumn(row: row, col: index)
                                    ZStack {
                                        Rectangle()
                                            .stroke()
                                            .foregroundColor(Color.tableCellBorderColor)
                                        TableViewCellBuilder(data: cell)
                                    }.frame(width: 170, height: 50).id("\(row)_\(col)")
                                }
                            }
                        }
                    }
                    .frame(minWidth: geometry.size.width, minHeight: geometry.size.height, alignment: .topLeading)
                    .background( GeometryReader { geo in
                        Color.clear
                            .preference(key: ViewOffsetKey.self, value: geo.frame(in: .named("scroll")).origin)
                    })
                    .onPreferenceChange(ViewOffsetKey.self) { value in
                        //ScrollView scrolling, offset changed
                        offset = value
                        viewModel.toggleSelection()
                        viewModel.setDeleteButtonVisibility()
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGPoint
    static var defaultValue = CGPoint.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.x += nextValue().x
        value.y += nextValue().y
    }
}

#Preview {
    TableModalView(viewModel: TableViewModel(mode: .fill, joyDocModel: fakeTableData()))
}


