import SwiftUI
import JoyfillModel

struct TableRowView : View {
    @ObservedObject var viewModel: TableViewModel
    @Binding var rowDataModel: RowDataModel
    var longestBlockText: String

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach($rowDataModel.cells, id: \.id) { $cellModel in
                ZStack {
                    Rectangle()
                        .stroke()
                        .foregroundColor(Color.tableCellBorderColor)
                    TableViewCellBuilder(viewModel: viewModel, cellModel: $cellModel)
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
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    dismissKeyboard()
                }
            }
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
                .frame(width: viewModel.showRowSelector ? 80 : 40, height: textHeight)
                .border(Color.tableCellBorderColor)
                .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
                .cornerRadius(14, corners: [.topLeft], borderColor: Color.tableCellBorderColor)
                
                if #available(iOS 16, *) {
                    ScrollView([.vertical], showsIndicators: false) {
                        rowsHeader
                            .frame(width: viewModel.showRowSelector ? 80 : 40)
                            .offset(y: offset.y)
                    }
                    .simultaneousGesture(DragGesture(minimumDistance: 0), including: .all)
                    .scrollDisabled(true)
                } else {
                    ScrollView([.vertical], showsIndicators: false) {
                        rowsHeader
                            .frame(width: viewModel.showRowSelector ? 80 : 40)
                            .offset(y: offset.y)
                    }
                    .simultaneousGesture(DragGesture(minimumDistance: 0), including: .all)
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                if #available(iOS 16, *) {
                    ScrollView([.horizontal], showsIndicators: false) {
                        colsHeader
                            .offset(x: offset.x)
                    }
                    .background(Color.tableCellBorderColor)
                    .cornerRadius(14, corners: [.topRight], borderColor: Color.tableCellBorderColor)
                    .scrollDisabled(true)
                } else {
                    ScrollView([.horizontal], showsIndicators: false) {
                        colsHeader
                            .offset(x: offset.x)
                    }
                    .background(Color.tableCellBorderColor)
                    .cornerRadius(14, corners: [.topRight], borderColor: Color.tableCellBorderColor)
                }
                
                
                table
                    .coordinateSpace(name: "scroll")
            }
        }
        .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
    }

    var colsHeader: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(viewModel.tableDataModel.tableColumns.enumerated()), id: \.offset) { index, column in
                Button(action: {
                    currentSelectedCol = currentSelectedCol == index ? Int.min : index
                }, label: {
                    HStack {
                        Text(viewModel.tableDataModel.getColumnTitle(columnId: column.id!))
                            .multilineTextAlignment(.leading)
                            .darkLightThemeColor()
                        
                        if let required = column.required, required, !viewModel.isColumnFilled(columnId: column.id ?? "") {
                            Image(systemName: "asterisk")
                                .foregroundColor(.red)
                                .imageScale(.small)
                        }
                        
                        if ![.image, .block, .date, .progress, .signature].contains(viewModel.tableDataModel.getColumnType(columnId: column.id!)) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .foregroundColor(viewModel.tableDataModel.filterModels[index].filterText.isEmpty ? Color.gray : Color.blue)
                        }
                        
                    }
                    .padding(.all, 4)
                    .font(.system(size: 15))
                    .frame(width: Utility.getCellWidth(type: viewModel.tableDataModel.getColumnType(columnId: column.id!) ?? .unknown,
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
                .disabled([.image, .block, .date, .progress, .signature].contains(viewModel.tableDataModel.getColumnType(columnId: column.id!)) || viewModel.tableDataModel.rowOrder.count == 0)
//                .disabled(true)
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                let height = geometry.size.height
                                columnHeights[index] = height // Store height for this column
                                
                                // Calculate the maximum height after adding this column's height
                                if let maxColumnHeight = columnHeights.values.max() {
                                    self.textHeight = maxColumnHeight // Update textHeight with max height
                                }
                            }
                    }
                )
            }
        }
    }
    
    var rowsHeader: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
           ForEach(Array(viewModel.tableDataModel.filteredcellModels.enumerated()), id: \.offset) { (index, rowModel) in
                let rowArray = rowModel.cells
                HStack(spacing: 0) {
                    if viewModel.showRowSelector {
                        let isRowSelected = viewModel.tableDataModel.selectedRows.contains(rowModel.rowID)
                        Image(systemName: isRowSelected ? "record.circle.fill" : "circle")
                            .frame(width: 40, height: 60)
                            .border(Color.tableCellBorderColor)
                            .onTapGesture {
                                viewModel.tableDataModel.toggleSelection(rowID: rowArray.first?.rowID ?? "")
                            }
                            .accessibilityIdentifier("MyButton")
                        
                    }
                    Text("\(index+1)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .frame(width: 40, height: 60)
                        .border(Color.tableCellBorderColor)
                        .id("\(index)")
                }
            }
        }
    }
    
    var table: some View {
        ScrollViewReader { cellProxy in
            GeometryReader { geometry in
                if #available(iOS 16, *) {
                    ScrollView([.vertical, .horizontal], showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach($viewModel.tableDataModel.filteredcellModels, id: \.self) { $rowCellModels in
                                TableRowView(viewModel: viewModel, rowDataModel: $rowCellModels, longestBlockText: longestBlockText)
                                    .frame(height: 60)
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
                } else {
                    ScrollView([.vertical, .horizontal], showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach($viewModel.tableDataModel.filteredcellModels, id: \.self) { $rowCellModels in
                                TableRowView(viewModel: viewModel, rowDataModel: $rowCellModels, longestBlockText: longestBlockText)
                                    .frame(height: 60)
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
                }
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
