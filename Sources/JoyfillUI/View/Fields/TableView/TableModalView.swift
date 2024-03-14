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
    private let rowHeight: CGFloat = 50
    @State private var heights: [Int: CGFloat] = [:]
    @State private var refreshID = UUID()
    @State private var rowsCount: Int = 0
    
    init(viewModel: TableViewModel) {
        self.viewModel = viewModel
        UIScrollView.appearance().bounces = false
        self.rowsCount = self.viewModel.rows.count
    }
    
    var body: some View {
        VStack {
            TableModalTopNavigationView(isDeleteButtonVisible: $viewModel.shouldShowDeleteRowButton, onDeleteTap: {
                viewModel.deleteSelectedRow()
                heights = [:]
            }, onAddRowTap: {
                viewModel.addRow()
            })
            .padding(EdgeInsets(top: 16, leading: 10, bottom: 10, trailing: 10))
            
            scrollArea
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
        }
        .onDisappear(perform: {
            viewModel.sendEventsIfNeeded()
        })
    }
    
    var scrollArea: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    if viewModel.showRowSelector  {
                        Spacer()
                            .frame(height: 40)
                    }
                    
                    Text("#")
                        .frame(width: 40)
                }
                .frame(width: viewModel.showRowSelector ? 80 : 40, height: rowHeight)
                .background(Color.tableColumnBgColor)
                .cornerRadius(14, corners: [.topLeft])
                
                ScrollView([.vertical], showsIndicators: false) {
                    rowsHeader
                        .offset(y: offset.y)
                }
                .simultaneousGesture(DragGesture(minimumDistance: 0), including: .all)
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
                }
                .background(Color.tableColumnBgColor).frame(width: 170, height: rowHeight)
            }
        }
    }
    
    var rowsHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(viewModel.rowsSelection.enumerated()), id: \.offset) { (index, row) in
                HStack(spacing: 0) {
                    if viewModel.showRowSelector { Image(systemName: row ? "record.circle.fill" : "circle")
                            .frame(width: 40, height: heights[index] ?? 50)
                            .border(Color.tableCellBorderColor)
                            .onTapGesture {
                                viewModel.toggleSelection(at: index)
                                viewModel.setDeleteButtonVisibility()
                            }
                        
                    }
                    Text("\(index+1)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .frame(width: 40, height: heights[index] ?? 50)
                        .border(Color.tableCellBorderColor)
                        .id("\(index)")
                }
            }
        }
    }
    
    var table: some View {
        ScrollViewReader { cellProxy in
            GeometryReader { geometry in
                ScrollView([.vertical, .horizontal], showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(viewModel.rows.enumerated()), id: \.offset) { i, row in
                            HStack(alignment: .top, spacing: 0) {
                                ForEach(Array(viewModel.columns.enumerated()), id: \.offset) { index, col in
                                    // Cell
                                    let cell = viewModel.getFieldTableColumn(row: row, col: index)
                                    if let cell = cell {
                                        let cellModel = TableCellModel(data: cell, eventHandler: viewModel.fieldDependency.eventHandler, fieldData: viewModel.joyDocModel, viewMode: .quickView) { editedCell  in
                                            viewModel.cellDidChange(rowId: row, colIndex: index, editedCell: editedCell)
                                        }
                                        
                                        ZStack {
                                            Rectangle()
                                                .stroke()
                                                .foregroundColor(Color.tableCellBorderColor)
                                            TableViewCellBuilder(cellModel: cellModel)
                                        }
                                        .frame(minWidth: 170, maxWidth: 170, minHeight: 50, maxHeight: .infinity)
                                        .background(GeometryReader { proxy in
                                            Color.clear.preference(key: HeightPreferenceKey.self, value: [i: proxy.size.height])
                                        })
                                    }
                                   
                                }
                            }
                        }
                        .id(refreshID)
                        .onReceive(viewModel.$rows) { _ in
                            refreshUUIDIfNeeded()
                        }
                        .onPreferenceChange(HeightPreferenceKey.self) { value in
                            updateNewHeight(newValue: value)
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minWidth: geometry.size.width, minHeight: geometry.size.height, alignment: .topLeading)
                    .background( GeometryReader { geo in
                        Color.clear
                            .preference(key: ViewOffsetKey.self, value: geo.frame(in: .named("scroll")).origin)
                    })
                    .onPreferenceChange(ViewOffsetKey.self) { value in
                        offset = value
                        viewModel.toggleSelection()
                        viewModel.setDeleteButtonVisibility()
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        }
    }
    
    // Note: This is an optimisation to stop force re-render entire table
    private func refreshUUIDIfNeeded() {
        if rowsCount != viewModel.rows.count {
            self.rowsCount = viewModel.rows.count
            self.refreshID = UUID()
        }
    }
    
    private func updateNewHeight(newValue: [Int: CGFloat]) {
        for (key, value) in newValue {
            heights[key] = max(value, heights[key] ?? 0)
        }
    }
}

struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        for (key, newValue) in nextValue() {
            if let currentValue = value[key] {
                value[key] = max(currentValue, newValue)
            } else {
                value[key] = newValue
            }
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


