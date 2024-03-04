//
//  SwiftUIView.swift
//  
//
//  Created by Nand Kishore on 04/03/24.
//

import SwiftUI


struct TableModalView : View {
    @State private var offset = CGPoint.zero
    @ObservedObject var tableViewModel: TableViewModel
    
    init(tableViewModel: TableViewModel) {
        self.tableViewModel = tableViewModel
        UIScrollView.appearance().bounces = false
    }
    
    var body: some View {
        VStack {
            TableModalTopNavigationView()
                .padding(10)
            scrollArea
        }
    }
    
    var scrollArea: some View {
        
        HStack(alignment: .top, spacing: 0) {
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("")
                    Text("#")
                }.frame(width: 80, height: 50)
                
                ScrollView([.vertical]) {
                    rowsHeader
                        .offset(y: offset.y)
                    
                }
                .scrollIndicators(.hidden)
                .disabled(true)
            }
            VStack(alignment: .leading, spacing: 0) {
                ScrollView([.horizontal]) {
                    colsHeader
                        .offset(x: offset.x)
                }
                .disabled(true)
                
                table
                    .coordinateSpace(name: "scroll")
            }
        }
        
        .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
    }
    
    var colsHeader: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(tableViewModel.columns, id: \.self) { col in
                
                ZStack {
                    Rectangle()
                        .stroke()
                        .foregroundColor(Color.tableCellBorderColor)
                    Text(tableViewModel.getColumnTitle(columnId: col))
                }.background(Color.tableColumnBgColor).frame(width: 170, height: 50)
                
            }
        }
    }
    
    var rowsHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(tableViewModel.rows.enumerated()), id: \.offset) { (index, row) in
                HStack(spacing: 0) {
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: false ? "record.circle.fill" : "circle")
                            .frame(width: 40, height: 50)
                            .border(Color.tableCellBorderColor)
                    })
                    
                    Text("\(index)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .frame(width: 40, height: 50)
                        .border(Color.tableCellBorderColor)
                        .id("\(row)")
                }
            }
        }
    }
    
    var table: some View {
        ScrollViewReader { cellProxy in
            ScrollView([.vertical, .horizontal]) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(tableViewModel.rows, id: \.self) { row in
                        HStack(alignment: .top, spacing: 0) {
                            ForEach(Array(tableViewModel.columns.enumerated()), id: \.offset) { index, col in
                                // Cell
                                let t = tableViewModel.getFieldTableColumn(row: row, col: index)
                                ZStack {
                                    Rectangle()
                                        .stroke()
                                        .foregroundColor(Color.tableCellBorderColor)
                                    //fieldTableColumnToView(data: t)
                                    
                                    //Text(t?.title ?? "(\(row), \(col))")
                                }.frame(width: 170).id("\(row)_\(col)")
                            }
                        }
                    }
                }
                .background( GeometryReader { geo in
                    Color.clear
                        .preference(key: ViewOffsetKey.self, value: geo.frame(in: .named("scroll")).origin)
                })
                .onPreferenceChange(ViewOffsetKey.self) { value in
                    //ScrollView scrolling, offset changed
                    offset = value
                }
            }
        }
    }
    @State var selectedDropdownValue: String?
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGPoint
    static var defaultValue = CGPoint.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.x += nextValue().x
        value.y += nextValue().y
    }
}
