import SwiftUI
import JoyfillModel

struct TableRowView: View {
    @ObservedObject var viewModel: TableViewModel
    @Binding var rowDataModel: RowDataModel
    var longestBlockText: String
    var action: (_ columnID: String) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach($rowDataModel.cells, id: \.id) { $cellModel in
                ZStack {
                    Rectangle()
                        .stroke()
                        .foregroundColor(Color.tableCellBorderColor)
                    TableViewCellBuilder(viewModel: viewModel, cellModel: $cellModel, action: action)
                }
                .frame(minWidth: Utility.getCellWidth(type: cellModel.data.type ?? .unknown,
                                                      format: cellModel.data.format ?? .empty,
                                                      text: cellModel.data.type == .block ? longestBlockText : ""),
                       maxWidth: Utility.getCellWidth(type: cellModel.data.type ?? .unknown,
                                                      format: cellModel.data.format ?? .empty,
                                                      text: cellModel.data.type == .block ? longestBlockText : ""),
                       minHeight: 50,
                       maxHeight: .infinity)
            }
        }
    }
}

struct TableModalView : View {
    @State private var offset = CGPoint.zero
    @ObservedObject var viewModel: TableViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showEditMultipleRowsSheetView: Bool = false
    @State private var columnHeights: [Int: CGFloat] = [:] // Dictionary to hold the heights for each column
    @State private var textHeight: CGFloat = 50 // Default height
    @State private var currentSelectedCol: Int = Int.min
    var longestBlockText: String = ""

    init(viewModel: TableViewModel) {
        self.viewModel = viewModel
        UIScrollView.appearance().bounces = false
        longestBlockText = viewModel.tableDataModel.getLongestBlockText()
    }
    
    var body: some View {
        VStack {
            TableModalTopNavigationView(
                viewModel: viewModel,
                onEditTap: { showEditMultipleRowsSheetView = true })
            .sheet(isPresented: $showEditMultipleRowsSheetView) {
                EditMultipleRowsSheetView(viewModel: viewModel)
            }
            .padding(EdgeInsets(top: 16, leading: 10, bottom: 10, trailing: 10))
            if currentSelectedCol != Int.min {
                SearchBar(model: $viewModel.tableDataModel.filterModels [currentSelectedCol], sortModel: $viewModel.tableDataModel.sortModel, selectedColumnIndex: $currentSelectedCol, viewModel: viewModel)
                EmptyView()
            }
            scrollArea
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
        }
        .onDisappear(perform: {
            viewModel.sendEventsIfNeeded()
            clearFilter()
        })
        .onChange(of: viewModel.tableDataModel.sortModel.order) { _ in
            viewModel.tableDataModel.filterRowsIfNeeded()
            sortRowsIfNeeded()
        }
        .onChange(of: viewModel.tableDataModel.filterModels ) { _ in
            viewModel.tableDataModel.filterRowsIfNeeded()
            sortRowsIfNeeded()
            viewModel.tableDataModel.emptySelection()
        }
        .onChange(of: viewModel.tableDataModel.filteredcellModels) { _ in
            for model in viewModel.tableDataModel.filteredcellModels {
                if let index = viewModel.tableDataModel.cellModels.firstIndex(of: model) {
                    viewModel.tableDataModel.cellModels[index] = model
                }
            }
        }
        .onChange(of: viewModel.tableDataModel.rowOrder) { _ in
            if viewModel.tableDataModel.rowOrder.isEmpty {
                currentSelectedCol = Int.min
                viewModel.tableDataModel.emptySelection()
            }
        }
    }
    
    func clearFilter() {
        viewModel.tableDataModel.filteredcellModels = viewModel.tableDataModel.cellModels
        for i in 0..<viewModel.tableDataModel.filterModels.count {
            viewModel.tableDataModel.filterModels[i].filterText = ""
        }
        viewModel.tableDataModel.emptySelection()
    }

    func sortRowsIfNeeded() {
        if currentSelectedCol != Int.min {
            guard viewModel.tableDataModel.sortModel.order != .none else { return }
            viewModel.tableDataModel.filteredcellModels = viewModel.tableDataModel.filteredcellModels.sorted { rowModel1, rowModel2 in
                let column1 = rowModel1.cells[currentSelectedCol].data
                let column2 = rowModel2.cells[currentSelectedCol].data
                switch column1.type {
                case .text:
                    switch viewModel.tableDataModel.sortModel.order {
                    case .ascending:
                        return (column1.title ?? "") < (column2.title ?? "")
                    case .descending:
                        return (column1.title ?? "") > (column2.title ?? "")
                    case .none:
                        return true
                    }
                case .dropdown:
                    switch viewModel.tableDataModel.sortModel.order {
                    case .ascending:
                        return (column1.selectedOptionText ?? "") < (column2.selectedOptionText ?? "")
                    case .descending:
                        return (column1.selectedOptionText ?? "") > (column2.selectedOptionText ?? "")
                    case .none:
                        return true
                    }
                case .number:
                    switch viewModel.tableDataModel.sortModel.order {
                    case .ascending:
                        return (column1.number ?? 0) < (column2.number ?? 0)
                    case .descending:
                        return (column1.number ?? 0) > (column2.number ?? 0)
                    case .none:
                        return true
                    }
                case .barcode:
                    switch viewModel.tableDataModel.sortModel.order {
                    case .ascending:
                        return (column1.title ?? "") < (column2.title ?? "")
                    case .descending:
                        return (column1.title ?? "") > (column2.title ?? "")
                    case .none:
                        return true
                    }
                default:
                    return false
                }
            }
        }
    }

    var scrollArea: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    if viewModel.nestedTableCount > 0 {
                        Spacer()
                    }
                    if viewModel.showRowSelector  {
                        Image(systemName: viewModel.tableDataModel.allRowSelected ? "record.circle.fill" : "circle")
                            .frame(width: 40, height: textHeight)
                            .foregroundColor(viewModel.tableDataModel.rowOrder.count == 0 ? Color.gray.opacity(0.4) : nil)
                            .onTapGesture {
                                if !viewModel.tableDataModel.allRowSelected {
                                    viewModel.tableDataModel.selectAllRows()
                                } else {
                                    viewModel.tableDataModel.emptySelection()
                                }
                            }
                            .disabled(viewModel.tableDataModel.rowOrder.count == 0)
                            .accessibilityIdentifier("SelectAllRowSelectorButton")
                    }
                    Text("#")
                        .frame(width: 40, height: textHeight)
                        .border(Color.tableCellBorderColor)
                }
                .frame(minHeight: 50)
                .frame(width: viewModel.showRowSelector ? (viewModel.nestedTableCount > 0 ? 120 : 80) : 40, height: textHeight)
                .border(Color.tableCellBorderColor)
                .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
                .cornerRadius(14, corners: [.topLeft])
                
                if #available(iOS 16, *) {
                    ScrollView([.vertical], showsIndicators: false) {
                        rowsHeader
                            .frame(width: viewModel.showRowSelector ? (viewModel.nestedTableCount > 0 ? 120 : 80) : 40)
                            .offset(y: offset.y)
                    }
                    .simultaneousGesture(DragGesture(minimumDistance: 0), including: .all)
                    .scrollDisabled(true)
                } else {
                    ScrollView([.vertical], showsIndicators: false) {
                        rowsHeader
                            .offset(y: offset.y)
                    }
                    .simultaneousGesture(DragGesture(minimumDistance: 0), including: .all)
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                if #available(iOS 16, *) {
                    ScrollView([.horizontal], showsIndicators: false) {
                        TableColumnHeaderView(viewModel: viewModel,
                                              tableColumns: viewModel.tableDataModel.tableColumns,
                                              currentSelectedCol: $currentSelectedCol,
                                              textHeight: $textHeight,
                                              colorScheme: colorScheme,
                                              columnHeights: $columnHeights,
                                              longestBlockText: longestBlockText,
                                              isHeaderNested: false)
                            .offset(x: offset.x)
                    }
                    .background(Color.tableCellBorderColor)
                    .cornerRadius(14, corners: [.topRight])
                    .scrollDisabled(true)
                } else {
                    ScrollView([.horizontal], showsIndicators: false) {
                        TableColumnHeaderView(viewModel: viewModel,
                                              tableColumns: viewModel.tableDataModel.tableColumns,
                                              currentSelectedCol: $currentSelectedCol,
                                              textHeight: $textHeight,
                                              colorScheme: colorScheme,
                                              columnHeights: $columnHeights,
                                              longestBlockText: longestBlockText,
                                              isHeaderNested: false)
                            .offset(x: offset.x)
                    }
                    .background(Color.tableCellBorderColor)
                    .cornerRadius(14, corners: [.topRight])
                }
                
                table
                    .coordinateSpace(name: "scroll")
            }
        }
        .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
    }
    
    var rowsHeader: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
           ForEach(Array($viewModel.tableDataModel.filteredcellModels.enumerated()), id: \.offset) { (index, $rowModel) in
                let rowArray = rowModel.cells
               HStack(spacing: 0) {
                   // Expand Button View
                   if viewModel.nestedTableCount > 0 {
                       switch rowModel.rowType {
                       case .header(tableColumns: let columns):
                           Rectangle()
                               .fill(Color.white)
                               .frame(width: 40, height: 60)
                               .border(Color.tableCellBorderColor)
                       case .row(index: let index):
                           Image(systemName: rowModel.isExpanded ? "chevron.down.square" : "chevron.right.square")
                               .frame(width: 40, height: 60)
                               .border(Color.tableCellBorderColor)
                               .onTapGesture {
                                   viewModel.expandTables(rowDataModel: rowModel, level: 0)
                                   rowModel.isExpanded.toggle()
                               }
                       case .nestedRow(level: let level, index: let index):
                           if rowModel.hasMoreNestedRows {
                               Image(systemName: rowModel.isExpanded ? "chevron.down.square" : "chevron.right.square")
                                   .frame(width: 40, height: 60)
                                   .border(Color.tableCellBorderColor)
                                   .onTapGesture {
                                       viewModel.expandTables(rowDataModel: rowModel, level: level)
                                       rowModel.isExpanded.toggle()
                                   }
                           } else {
                               Rectangle()
                                   .fill(Color.white)
                                   .frame(width: 40, height: 60)
                                   .border(Color.tableCellBorderColor)
                           }
                       case .tableExpander(tableColumn: let column, level: let level):
                           Image(systemName: rowModel.isExpanded ? "chevron.down.square" : "chevron.right.square")
                               .frame(width: 40, height: 60)
                               .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
                               .border(Color.tableCellBorderColor)
                               .onTapGesture {
                                   viewModel.expendSpecificTable(rowDataModel: rowModel, columnID: column?.id ?? "", level: level, isOpenedFromTable: false)
                                   rowModel.isExpanded.toggle()
                               }
                       }
                   }
                   
                   // Selector Button View
                   switch rowModel.rowType {
                   case .row(let index):
                       if viewModel.showRowSelector {
                           let isRowSelected = viewModel.tableDataModel.selectedRows.contains(rowModel.rowID)
                           Image(systemName: isRowSelected ? "record.circle.fill" : "circle")
                               .frame(width: 40, height: 60)
                               .border(Color.tableCellBorderColor)
                               .onTapGesture {
                                   viewModel.tableDataModel.toggleSelection(rowID: rowArray.first?.rowID ?? "")
                               }
                               .accessibilityIdentifier("MyButton")
                           
                       } else {
                           Rectangle()
                               .fill(Color.white)
                               .frame(width: 40, height: 60)
                               .border(Color.tableCellBorderColor)
                       }
                   case .header:
                       Rectangle()
                           .fill(Color.white)
                           .frame(width: 40, height: 60)
                           .border(Color.tableCellBorderColor)
                   case .nestedRow(let level, let index):
                       let isRowSelected = viewModel.tableDataModel.selectedRows.contains(rowModel.rowID)
                       Image(systemName: isRowSelected ? "record.circle.fill" : "circle")
                           .frame(width: 40, height: 60)
                           .border(Color.tableCellBorderColor)
                           .onTapGesture {
                               viewModel.tableDataModel.toggleSelection(rowID: rowArray.first?.rowID ?? "")
                           }
                           .accessibilityIdentifier("MyButton")
                   case .tableExpander:
                       Spacer()
                           .frame(width: 40, height: 60)
                           .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
                           .border(Color.tableCellBorderColor)
                   }
                   
                   // Indexing View
                   switch rowModel.rowType {
                   case .header:
                       Text("#")
                           .frame(width: 40, height: textHeight)
                           .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
                           .border(Color.tableCellBorderColor)
                   case .nestedRow(let level, let nastedRowIndex):
                       Text("\(nastedRowIndex)")
                           .foregroundColor(.secondary)
                           .font(.caption)
                           .frame(width: 40, height: 60)
                           .border(Color.tableCellBorderColor)
                           .id("\(index)")
                   case .row(let index):
                       Text("\(index)")
                           .foregroundColor(.secondary)
                           .font(.caption)
                           .frame(width: 40, height: 60)
                           .border(Color.tableCellBorderColor)
                           .id("\(index)")
                   case .tableExpander:
                       Spacer()
                           .frame(width: 40, height: 60)
                           .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
                           .border(Color.tableCellBorderColor)
                   }
               }
            }
        }
    }
    
    var table: some View {
        ScrollViewReader { cellProxy in
            GeometryReader { geometry in
                ScrollView([.vertical, .horizontal], showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach($viewModel.tableDataModel.filteredcellModels, id: \.self) { $rowCellModels in
                            switch rowCellModels.rowType {
                            case .row:
                                TableRowView(viewModel: viewModel, rowDataModel: $rowCellModels, longestBlockText: longestBlockText, action: { columnID in 
                                    viewModel.expendSpecificTable(rowDataModel: rowCellModels, columnID: columnID, level: 0, isOpenedFromTable: true)
                                    rowCellModels.isExpanded.toggle()
                                })
                                .frame(height: 60)
                            case .nestedRow(level: let level, index: let index):
                                TableRowView(viewModel: viewModel, rowDataModel: $rowCellModels, longestBlockText: longestBlockText, action: { columnID in
                                    viewModel.expendSpecificTable(rowDataModel: rowCellModels, columnID: columnID, level: level, isOpenedFromTable: true)
                                    rowCellModels.isExpanded.toggle()
                                })
                                .frame(height: 60)
                            case .header(level: let level, tableColumns: let tableColumns):
                                TableColumnHeaderView(viewModel: viewModel,
                                                      tableColumns: tableColumns ?? [],
                                                      currentSelectedCol: $currentSelectedCol,
                                                      textHeight: $textHeight,
                                                      colorScheme: colorScheme,
                                                      columnHeights: $columnHeights,
                                                      longestBlockText: longestBlockText,
                                                      isHeaderNested: true)
                                    .frame(height: 60)
                            case .tableExpander(tableColumn: let tableColumn, level: let level):
                                TableExpanderView(rowDataModel: $rowCellModels, tableColumn: tableColumn)
                                    .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
                            }
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
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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

struct TableExpanderView: View {
    @Binding var rowDataModel: RowDataModel
    var tableColumn: FieldTableColumn?
    
    var body: some View {
        HStack {
            Text(tableColumn?.title ?? "")
            Spacer()
            
            if rowDataModel.isExpanded {
                Button(action: {
                    
                }) {
                    Text("Add Row +")
                        .foregroundStyle(.selection)
                        .font(.system(size: 14))
                        .frame(height: 27)
                        .padding(.horizontal, 16)
                        .overlay(RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.buttonBorderColor, lineWidth: 1))
                }
            }
        }
        .frame(height: 60)
        .border(Color.tableCellBorderColor)
    }
}

struct TableColumnHeaderView: View {
    @ObservedObject var viewModel: TableViewModel
    let tableColumns: [FieldTableColumn]
    @Binding var currentSelectedCol: Int
    @Binding var textHeight: CGFloat
    let colorScheme: ColorScheme
    @Binding var columnHeights: [Int: CGFloat]
    let longestBlockText: String
    let isHeaderNested: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(tableColumns.enumerated()), id: \.offset) { index, column in
                Button(action: {
                    currentSelectedCol = currentSelectedCol == index ? Int.min : index
                }, label: {
                    HStack {
                        Text(column.title)
                            .multilineTextAlignment(.leading)
                            .darkLightThemeColor()
                        
                        //TODO: Handle required for nested table columns
                        if let required = column.required, required, !viewModel.isColumnFilled(columnId: column.id ?? "") {
                            Image(systemName: "asterisk")
                                .foregroundColor(.red)
                                .imageScale(.small)
                        }
                        
                        if ![.image, .block, .date, .progress, .table].contains(column.type) && !isHeaderNested {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .foregroundColor(viewModel.tableDataModel.filterModels[index].filterText.isEmpty ? Color.gray : Color.blue)
                        }
                    }
                    .padding(.all, 4)
                    .font(.system(size: 15))
                    .frame(width: Utility.getCellWidth(type: column.type ?? .unknown,
                                                       format: viewModel.tableDataModel.getColumnFormat(columnId: column.id!) ?? .empty,
                                                     text: longestBlockText))
                    .frame(minHeight: textHeight)
                    .overlay(
                        Rectangle()
                            .stroke(currentSelectedCol != index ? Color.tableCellBorderColor : Color.blue, lineWidth: 1)
                    )
                    .background(
                        colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor
                    )
                })
                .accessibilityIdentifier("ColumnButtonIdentifier")
                .disabled([.image, .block, .date, .progress, .table].contains(column.type ?? .unknown) || viewModel.tableDataModel.rowOrder.count == 0 || isHeaderNested)
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                let height = geometry.size.height
                                columnHeights[index] = height
                                
                                if let maxColumnHeight = columnHeights.values.max() {
                                    textHeight = maxColumnHeight
                                }
                            }
                    }
                )
            }
        }
    }
}
