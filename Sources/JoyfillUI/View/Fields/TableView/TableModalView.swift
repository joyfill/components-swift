import SwiftUI
import JoyfillModel
import Combine

struct TableRowView : View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: TableViewModel
    @Binding var rowDataModel: RowDataModel
    var longestBlockText: String
    var isSelected: Bool = false

    var body: some View {
        LazyHStack(alignment: .top, spacing: 0) {
            ForEach($rowDataModel.cells, id: \.id) { $cellModel in
                TableViewCellBuilder(viewModel: viewModel, cellModel: $cellModel)
                    .frame(width: 200, height: 60)
                    .background(Color.rowSelectionBackground(isSelected: isSelected, colorScheme: colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(Color.tableCellBorderColor, lineWidth: 1.5)
                    )
            }
        }
    }
}

struct TableModalView : View {
    @State private var offset = CGPoint.zero
    @ObservedObject var viewModel: TableViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State var showEditMultipleRowsSheetView: Bool
    @State private var columnHeights: [Int: CGFloat] = [:] // Dictionary to hold the heights for each column
    @State private var textHeight: CGFloat = 50 // Default height
    @State private var currentSelectedCol: Int = Int.min
    var longestBlockText: String = ""

    init(viewModel: TableViewModel, showEditMultipleRowsSheetView: Bool) {
        self.viewModel = viewModel
        longestBlockText = viewModel.tableDataModel.getLongestBlockText()
        self.showEditMultipleRowsSheetView = showEditMultipleRowsSheetView
    }
    
    var body: some View {
        VStack {
            TableModalTopNavigationView(
                viewModel: viewModel,
                onEditTap: {
                viewModel.tableDataModel.rowFormOpenedViaGoto = false
                viewModel.tableDataModel.scrollToColumnId = nil
                showEditMultipleRowsSheetView = true
            })
            .sheet(isPresented: $showEditMultipleRowsSheetView) {
                EditMultipleRowsSheetView(viewModel: viewModel)
                    .interactiveDismissDisabled(viewModel.isBulkLoading)
            }
            .padding(EdgeInsets(top: 16, leading: 10, bottom: 10, trailing: 10))
            if currentSelectedCol != Int.min {
                SearchBar(model: $viewModel.tableDataModel.filterModels [currentSelectedCol], sortModel: $viewModel.tableDataModel.sortModel, selectedColumnIndex: $currentSelectedCol, viewModel: viewModel)
                EmptyView()
            }
            scrollArea
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    dismissKeyboard()
                }
            }
        }
        .onReceive(viewModel.tableDataModel.documentEditor?.navigationPublisher.eraseToAnyPublisher() ?? Empty().eraseToAnyPublisher()) { event in
            guard let fieldID = event.fieldID,
                  fieldID == viewModel.tableDataModel.fieldIdentifier.fieldID else {
                dismiss()
                return
            }
            
            // Same table, handle row change
            if let rowId = event.rowId, !rowId.isEmpty {
                let rowIdExists = viewModel.tableDataModel.rowOrder.contains(rowId)
                if rowIdExists {
                    viewModel.tableDataModel.selectedRows = [rowId]
                    viewModel.tableDataModel.rowFormOpenedViaGoto = event.openRowForm
                    viewModel.tableDataModel.scrollToColumnId = event.columnId
                    showEditMultipleRowsSheetView = event.openRowForm
                } else {
                    viewModel.tableDataModel.scrollToColumnId = nil
                    showEditMultipleRowsSheetView = false
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
                            .frame(width: 40, height: 60)
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
                        .frame(width: 40, height: 60)
                        .border(Color.tableCellBorderColor)
                    if viewModel.showSingleClickEditButton {
                        Image(systemName: "square.and.pencil")
                            .frame(width: 40, height: 60)
                            .foregroundColor(Color.gray.opacity(0.4))
                            .border(Color.tableCellBorderColor)
                    }
                }
                .frame(minHeight: 50)
                .frame(width: viewModel.showRowSelector ? (viewModel.showSingleClickEditButton ? 120 : 80) : (viewModel.showSingleClickEditButton ? 80 : 40), height: 60)
                .border(Color.tableCellBorderColor)
                .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.tableColumnBgColor)
                .cornerRadius(14, corners: [.topLeft], borderColor: Color.tableCellBorderColor)
                
                if #available(iOS 16, *) {
                    ScrollView([.vertical], showsIndicators: false) {
                        rowsHeader
                            .frame(width: viewModel.showRowSelector ? (viewModel.showSingleClickEditButton ? 120 : 80) : (viewModel.showSingleClickEditButton ? 80 : 40))
                            .offset(y: offset.y)
                    }
                    .simultaneousGesture(DragGesture(minimumDistance: 0), including: .all)
                    .scrollDisabled(true)
                } else {
                    ScrollView([.vertical], showsIndicators: false) {
                        rowsHeader
                            .frame(width: viewModel.showRowSelector ? (viewModel.showSingleClickEditButton ? 120 : 80) : (viewModel.showSingleClickEditButton ? 80 : 40))
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
                    .cornerRadius(14, corners: [.topRight], borderColor: Color.tableCellBorderColor)
                    .scrollDisabled(true)
                } else {
                    ScrollView([.horizontal], showsIndicators: false) {
                        colsHeader
                            .offset(x: offset.x)
                    }
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
                HStack {
                    ScrollView {
                        Text(viewModel.tableDataModel.getColumnTitle(columnId: column.id ?? ""))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.all, 8)
                            .frame(maxHeight: .infinity, alignment: .center)
                            .darkLightThemeColor()
                    }
                    
                    if let required = column.required, required, !viewModel.isColumnFilled(columnId: column.id ?? "") {
                        Image(systemName: "asterisk")
                            .foregroundColor(.red)
                            .imageScale(.small)
                    }
                    
                    if ![.image, .block, .date, .progress, .signature].contains(viewModel.tableDataModel.getColumnType(columnId: column.id ?? "")) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(viewModel.tableDataModel.filterModels[index].filterText.isEmpty ? Color.gray : Color.blue)
                    }
                    
                }
                .padding(.all, 4)
                .font(.system(size: 15))
                .frame(width: 200, height: 60)
                .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.tableColumnBgColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .inset(by: 1)
                        .stroke(currentSelectedCol != index ? Color.tableCellBorderColor : Color.blue, lineWidth: 1.5)
                )
                .accessibilityIdentifier("ColumnButtonIdentifier")
                .zIndex(currentSelectedCol == index ? 1 : 0)
                .onTapGesture {
                    if !([.image, .block, .date, .progress, .signature].contains(viewModel.tableDataModel.getColumnType(columnId: column.id ?? "")) || viewModel.tableDataModel.rowOrder.count == 0) {
                        currentSelectedCol = currentSelectedCol == index ? Int.min : index
                    }
                }
            }
        }
    }
    
    var rowsHeader: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
           ForEach(Array(viewModel.tableDataModel.filteredcellModels.enumerated()), id: \.offset) { (index, rowModel) in
                let rowArray = rowModel.cells
                let isRowSelected = viewModel.tableDataModel.selectedRows.contains(rowModel.rowID)
                HStack(spacing: 0) {
                    if viewModel.showRowSelector {
                        Image(systemName: isRowSelected ? "record.circle.fill" : "circle")
                            .frame(width: 40, height: 60)
                            .background(Color.rowSelectionBackground(isSelected: isRowSelected, colorScheme: colorScheme))
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
                        .background(Color.rowSelectionBackground(isSelected: isRowSelected, colorScheme: colorScheme))
                        .border(Color.tableCellBorderColor)
                        .id("\(index)")
                    
                    if viewModel.showSingleClickEditButton {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.blue)
                            .frame(width: 40, height: 60)
                            .background(Color.rowSelectionBackground(isSelected: isRowSelected, colorScheme: colorScheme))
                            .border(Color.tableCellBorderColor)
                            .onTapGesture {
                                viewModel.tableDataModel.emptySelection()
                                viewModel.tableDataModel.toggleSelection(rowID: rowModel.rowID)
                                viewModel.tableDataModel.rowFormOpenedViaGoto = false
                                viewModel.tableDataModel.scrollToColumnId = nil
                                showEditMultipleRowsSheetView = true
                            }
                            .accessibilityIdentifier("SingleClickEditButton\(index)")
                    }
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
                            ForEach($viewModel.tableDataModel.filteredcellModels, id: \.rowID) { $rowCellModels in
                                let isRowSelected = viewModel.tableDataModel.selectedRows.contains(rowCellModels.rowID)
                                TableRowView(viewModel: viewModel, rowDataModel: $rowCellModels, longestBlockText: longestBlockText, isSelected: isRowSelected)
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
                    .accessibilityIdentifier("TableScrollView")
                    
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.01, execute: {
                            cellProxy.scrollTo(0, anchor: .leading)
                        })
                        let selectedRows = viewModel.tableDataModel.selectedRows
                        if let selectedRowID = selectedRows.first, selectedRows.count == 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                cellProxy.scrollTo(selectedRowID, anchor: .leading)
                            }
//                            if let columnId = viewModel.tableDataModel.scrollToColumnId {
//                                cellProxy.scrollTo(columnId, anchor: .leading)
//                            }
                        }
                    }
                    .onChange(of: viewModel.tableDataModel.selectedRows) { selectedRows in
                        // Scroll to keep selected row in view when navigating with arrows
                        if let selectedRowID = selectedRows.first, selectedRows.count == 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                cellProxy.scrollTo(selectedRowID, anchor: .leading)
                            }
                        }
                    }
                    .gesture(DragGesture().onChanged({ _ in
                        dismissKeyboard()
                    }))
                } else {
                    ScrollView([.vertical, .horizontal], showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach($viewModel.tableDataModel.filteredcellModels, id: \.rowID) { $rowCellModels in
                                let isRowSelected = viewModel.tableDataModel.selectedRows.contains(rowCellModels.rowID)
                                TableRowView(viewModel: viewModel, rowDataModel: $rowCellModels, longestBlockText: longestBlockText, isSelected: isRowSelected)
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
                        let selectedRows = viewModel.tableDataModel.selectedRows
                        if let selectedRowID = selectedRows.first, selectedRows.count == 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                cellProxy.scrollTo(selectedRowID, anchor: .leading)
                            }
//                            if let columnId = viewModel.tableDataModel.scrollToColumnId {
//                                cellProxy.scrollTo(columnId, anchor: .leading)
//                            }
                        }
                    }
                    .onChange(of: viewModel.tableDataModel.selectedRows) { selectedRows in
                        // Scroll to keep selected row in view when navigating with arrows
                        if let selectedRowID = selectedRows.first, selectedRows.count == 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                cellProxy.scrollTo(selectedRowID, anchor: .leading)
                            }
                        }
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
