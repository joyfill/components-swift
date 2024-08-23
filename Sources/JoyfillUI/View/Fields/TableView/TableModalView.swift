import SwiftUI
import JoyfillModel

struct TableModalView : View {
    @State private var offset = CGPoint.zero
    @ObservedObject var viewModel: TableViewModel
    private let rowHeight: CGFloat = 50
    @State private var heights: [Int: CGFloat] = [:]
    @State private var refreshID = UUID()
    @State private var rowsCount: Int = 0
    @State private var searchText = ""
    @Environment(\.colorScheme) var colorScheme
    
    init(viewModel: TableViewModel) {
        self.viewModel = viewModel
        UIScrollView.appearance().bounces = false
        self.rowsCount = self.viewModel.rows.count
    }
    
    var body: some View {
        VStack {
            TableModalTopNavigationView(showMoreButton: $viewModel.shouldShowDeleteRowButton, onDeleteTap: {
                viewModel.deleteSelectedRow()
                heights = [:]
            }, onDuplicateTap: {
                viewModel.duplicateRow()
            }, onAddRowTap: {
                viewModel.addRow()
            }, fieldDependency: viewModel.fieldDependency)
            .padding(EdgeInsets(top: 16, leading: 10, bottom: 10, trailing: 10))
            
            SearchBar(text: $searchText)
            
            scrollArea
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
        }
        .onDisappear(perform: {
            viewModel.sendEventsIfNeeded()
        })
        .onAppear(perform: {
            let fieldEvent = FieldEvent(field: viewModel.fieldDependency.fieldData)
            viewModel.fieldDependency.eventHandler.onFocus(event: fieldEvent)
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
                .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
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
                .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
                .frame(width: 170, height: rowHeight)
            }
        }
    }
    
    var rowsHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(viewModel.rowsSelection.enumerated()), id: \.offset) { (index, row) in
                HStack(spacing: 0) {
                    if viewModel.showRowSelector {
                        Image(systemName: row ? "record.circle.fill" : "circle")
                            .frame(width: 40, height: heights[index] ?? 50)
                            .border(Color.tableCellBorderColor)
                            .onTapGesture {
                                viewModel.toggleSelection(at: index)
                                viewModel.setDeleteButtonVisibility()
                            }
                            .accessibilityIdentifier("MyButton")
                        
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
                                        let cellModel = TableCellModel(data: cell, eventHandler: viewModel.fieldDependency.eventHandler, fieldData: viewModel.fieldDependency.fieldData, viewMode: .modalView, editMode: viewModel.fieldDependency.mode) { editedCell  in
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
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.01, execute: {
                        cellProxy.scrollTo(0, anchor: .leading)
                    })
                }
                .gesture(DragGesture().onChanged({ _ in
                    dismissKeyboard()
                }))
            }
        }
    }
    
    private func dismissKeyboard() {
        viewModel.toggleSelection()
        viewModel.setDeleteButtonVisibility()
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
            heights[key] = value > 0 ? value : heights[key] ?? 50
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

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextFieldSearchBar(text: $text)
//            DropdownFieldSearchBar()
            
            Button(action: {
                
            }, label: {
                HStack {
                    Text("Sort")
                    Image(systemName: "arrow.up.arrow.down")
                }
                .font(.system(size: 14))
                .foregroundColor(.black)
            })
            .frame(height: 25)
            .padding(.horizontal, 12)
            .background(.white)
            .cornerRadius(4)
            
            Button(action: {
                
            }, label: {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 10, height: 10)
                    .darkLightThemeColor()
                    .padding(.all, 8)
                    .background(.white)
                    .cornerRadius(4)
                    .padding(.trailing, 8)
                    
            })
        }
        .frame(height: 40)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal, 12)
    }
}

struct TextFieldSearchBar: View {
    @Binding var text: String
    
    var body: some View {
        TextField("Search ", text: $text)
            .font(.system(size: 12))
            .padding(.all, 4)
            .frame(height: 25)
            .background(.white)
            .cornerRadius(6)
            .padding(.leading, 8)
            .overlay(
                HStack {
                    Spacer()
                    if !text.isEmpty {
                        Button(action: {
                            self.text = ""
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.all, 4)
                        }
                    }
                }
            )
    }
}

struct DropdownFieldSearchBar: View {
    var body: some View {
        Button(action: {
            
        }, label: {
            HStack {
                Text("Select Option")
                .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.down")
            }
            .foregroundStyle(.gray)
            .font(.system(size: 12))
            .padding(.all, 6)
            .frame(height: 25)
            .background(.white)
            .cornerRadius(6)
            .padding(.leading, 8)
        })
    }
}
