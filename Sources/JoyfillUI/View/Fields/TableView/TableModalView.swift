import SwiftUI
import JoyfillModel
import Combine

struct TableRowView : View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: TableViewModel
    @Binding var rowDataModel: RowDataModel
    var isSelected: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if viewModel.showRowDecorators {
                RowDecoratorMenuView(
                    decorators: viewModel.tableDataModel.getTableRowDecorators(forRowID: rowDataModel.rowID),
                    visibleLimit: viewModel.decoratorConfig.visibleLimitInRows
                ) { decorator in
                    viewModel.tableDataModel.documentEditor?.reportDecoratorAction(
                        fieldIdentifier: viewModel.tableDataModel.fieldIdentifier,
                        action: decorator.action ?? "",
                        rowIds: [rowDataModel.rowID]
                    )
                }
                .padding(.all, 4)
                .frame(width: viewModel.decoratorsCellWidth(), height: 60)
                .background(Color.rowSelectionBackground(isSelected: isSelected, colorScheme: colorScheme))
                .border(Color.tableCellBorderColor)
            }
            LazyHStack(alignment: .top, spacing: 0) {
                ForEach($rowDataModel.cells, id: \.id) { $cellModel in
                    let showRequired = viewModel.isCellRequired(columnID: cellModel.data.id, rowID: rowDataModel.rowID) && !cellModel.isFilled
                    TableViewCellBuilder(viewModel: viewModel, cellModel: $cellModel)
                        .frame(width: Utility.singleColumnWidth, height: 60)
                        .background(Color.rowSelectionBackground(isSelected: isSelected, colorScheme: colorScheme))
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.tableCellBorderColor, lineWidth: 1.5)
                        )
                        .overlay {
                            if showRequired {
                                RoundedRectangle(cornerRadius: 8)
                                    .inset(by: 2)
                                    .stroke(colorScheme == .dark ? Color.pink : Color.red,
                                            lineWidth: colorScheme == .dark ? 1 : 0.5)
                            }
                        }
                }
            }
        }
    }
}

struct TableModalView : View {
    // UIKit-driven offset mirror; the grid's UIScrollView moves the left column without re-evaluating the body.
    @State private var scrollSync = TableScrollSync()
    @ObservedObject var viewModel: TableViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State var showEditMultipleRowsSheetView: Bool
    @State private var columnHeights: [Int: CGFloat] = [:] // Dictionary to hold the heights for each column
    @State private var textHeight: CGFloat = 50 // Default height
    @State private var currentSelectedCol: Int = Int.min
    @State private var isDismissingForNavigation = false

    init(viewModel: TableViewModel, showEditMultipleRowsSheetView: Bool) {
        self.viewModel = viewModel
        self.showEditMultipleRowsSheetView = showEditMultipleRowsSheetView
    }
    
    var body: some View {
        VStack {
            TableModalTopNavigationView(
                viewModel: viewModel,
                onEditTap: {
                viewModel.tableDataModel.navigationIntent = .none
                dismissKeyboard()
                showEditMultipleRowsSheetView = true
            })
            .sheet(isPresented: $showEditMultipleRowsSheetView, onDismiss: {
                if isDismissingForNavigation {
                    isDismissingForNavigation = false
                    dismiss()
                }
            }) {
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
                .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: 30) }
        }
        .safeAreaInset(edge: .bottom) {
            FormFooterView()
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        .presentsPageSelectionSheet(documentEditor: viewModel.tableDataModel.documentEditor)
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
                    let openRowForm = event.openRowForm && viewModel.tableDataModel.editability().formAllowed
                    viewModel.tableDataModel.selectedRows = [rowId]
                    viewModel.tableDataModel.navigationIntent = NavigationIntent(
                        rowFormOpenedViaGoto: openRowForm,
                        scrollToColumnId: event.columnId,
                        focusColumnId: event.focus ? event.columnId : nil
                    )
                    showEditMultipleRowsSheetView = openRowForm
                } else {
                    viewModel.tableDataModel.navigationIntent = .none
                    showEditMultipleRowsSheetView = false
                }
            }
        }
        .onReceive(viewModel.tableDataModel.documentEditor?.dismissNavigationPublisher.eraseToAnyPublisher() ?? Empty().eraseToAnyPublisher()) { targetFieldID in
            if targetFieldID == viewModel.tableDataModel.fieldIdentifier.fieldID {
                if showEditMultipleRowsSheetView {
                    isDismissingForNavigation = true
                    showEditMultipleRowsSheetView = false
                } else {
                    dismiss()
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
            var cellModels = viewModel.tableDataModel.cellModels
            var indexByID: [String: Int] = [:]
            indexByID.reserveCapacity(cellModels.count)
            for (i, m) in cellModels.enumerated() {
                indexByID[m.rowID] = i
            }
            for model in viewModel.tableDataModel.filteredcellModels {
                if let index = indexByID[model.rowID] {
                    cellModels[index] = model
                }
            }
            viewModel.tableDataModel.cellModels = cellModels
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
                    // Only a text column can hold a formula, so this is the one branch
                    // that sorts on a computed value rather than what is stored.
                    let text1 = viewModel.tableDataModel.searchableText(rowID: rowModel1.rowID, column: column1)
                    let text2 = viewModel.tableDataModel.searchableText(rowID: rowModel2.rowID, column: column2)
                    switch viewModel.tableDataModel.sortModel.order {
                    case .ascending:
                        return text1 < text2
                    case .descending:
                        return text1 > text2
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
                        return column1.title < column2.title
                    case .descending:
                        return column1.title > column2.title
                    case .none:
                        return true
                    }
                case .date:
                    switch viewModel.tableDataModel.sortModel.order {
                    case .ascending:
                        return (column1.date ?? -.infinity) < (column2.date ?? -.infinity)
                    case .descending:
                        return (column1.date ?? -.infinity) > (column2.date ?? -.infinity)
                    case .none:
                        return true
                    }
                default:
                    return false
                }
            }
        }
    }

    private var leftColumnWidth: CGFloat {
        var width: CGFloat = 40 // # column
        if viewModel.showRowSelector { width += 40 }
        if viewModel.tableDataModel.canShowSingleClickEditColumn() { width += 40 }
        return width
    }

    var scrollArea: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left row-number column: pinned left, synced to the grid via KVO, isolated in its own view.
            VStack(alignment: .leading, spacing: 0) {
                leftCornerHeader
                TableRowNumbersColumn(
                    viewModel: viewModel,
                    width: leftColumnWidth,
                    sync: scrollSync,
                    onEditRow: { rowModel in
                        viewModel.tableDataModel.emptySelection()
                        viewModel.tableDataModel.toggleSelection(rowID: rowModel.rowID)
                        viewModel.tableDataModel.navigationIntent = .none
                        dismissKeyboard()
                        showEditMultipleRowsSheetView = true
                    }
                )
            }

            // Header as a separate KVO-synced scroll view, not a pinned Section (a Section breaks TextEditor editing).
            VStack(alignment: .leading, spacing: 0) {
                columnsHeader
                table
            }
        }
        .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
    }

    @ViewBuilder
    var columnsHeader: some View {
        if #available(iOS 16, *) {
            columnsHeaderScroll.scrollDisabled(true)
        } else {
            // iOS 15 has no scrollDisabled: block user drags so the header can't desync from the grid.
            columnsHeaderScroll.simultaneousGesture(DragGesture(minimumDistance: 0), including: .all)
        }
    }

    private var columnsHeaderScroll: some View {
        ScrollView([.horizontal], showsIndicators: false) {
            colsHeader
                .background(TableScrollCapture { scrollSync.topScrollView = $0 })
        }
        .cornerRadius(14, corners: [.topRight], borderColor: Color.tableCellBorderColor)
    }

    var leftCornerHeader: some View {
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
            if viewModel.tableDataModel.canShowSingleClickEditColumn() {
                Image(systemName: "square.and.pencil")
                    .frame(width: 40, height: 60)
                    .foregroundColor(Color.gray.opacity(0.4))
                    .border(Color.tableCellBorderColor)
            }
        }
        .frame(minHeight: 50)
        .frame(width: leftColumnWidth, height: 60)
        .border(Color.tableCellBorderColor)
        .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.tableColumnBgColor)
        .cornerRadius(14, corners: [.topLeft], borderColor: Color.tableCellBorderColor)
    }

    var colsHeader: some View {
        HStack(alignment: .top, spacing: 0) {
            if viewModel.showRowDecorators {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundColor(Color.gray.opacity(0.4))
                    .frame(width: viewModel.decoratorsCellWidth(), height: 60)
                    .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.tableColumnBgColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .inset(by: 1)
                            .stroke(Color.tableCellBorderColor, lineWidth: 1.5)
                    )
            }
            ForEach(Array(viewModel.tableDataModel.tableColumns.enumerated()), id: \.offset) { index, column in
                HStack {
                    ScrollView {
                        Text(viewModel.tableDataModel.getColumnTitle(columnId: column.id ?? ""))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.all, 8)
                            .frame(maxHeight: .infinity, alignment: .center)
                            .darkLightThemeColor()
                    }
                    
                    if ![.image, .block, .progress, .signature].contains(viewModel.tableDataModel.getColumnType(columnId: column.id ?? "")) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(viewModel.tableDataModel.filterModels[index].filterText.isEmpty ? Color.gray : Color.blue)
                    }
                    
                }
                .padding(.all, 4)
                .font(.system(size: 15))
                .frame(width: Utility.singleColumnWidth, height: 60)
                .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.tableColumnBgColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .inset(by: 1)
                        .stroke(currentSelectedCol != index ? Color.tableCellBorderColor : Color.blue, lineWidth: 1.5)
                )
                .accessibilityIdentifier("\(column.title)/ColumnButtonIdentifier")
                .zIndex(currentSelectedCol == index ? 1 : 0)
                .onTapGesture {
                    if !([.image, .block, .progress, .signature].contains(viewModel.tableDataModel.getColumnType(columnId: column.id ?? "")) || viewModel.tableDataModel.rowOrder.count == 0) {
                        currentSelectedCol = currentSelectedCol == index ? Int.min : index
                    }
                }
            }
        }
    }
    
    // Keeps all columns horizontally scrollable when a filter matches zero rows.
    // minHeight fills the empty body so the whole area catches the horizontal swipe.
    @ViewBuilder
    private func emptyFilterSpacer(geometry: GeometryProxy) -> some View {
        if viewModel.tableDataModel.filteredcellModels.isEmpty {
            Color.clear
                .frame(width: viewModel.tableContentWidth)
                .frame(minHeight: geometry.size.height)
        }
    }

    var table: some View {
        ScrollViewReader { cellProxy in
            GeometryReader { geometry in
                ScrollView([.vertical, .horizontal], showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach($viewModel.tableDataModel.filteredcellModels, id: \.rowID) { $rowCellModels in
                            let isRowSelected = viewModel.tableDataModel.selectedRows.contains(rowCellModels.rowID)
                            TableRowView(viewModel: viewModel, rowDataModel: $rowCellModels, isSelected: isRowSelected)
                                .frame(height: 60)
                        }
                        emptyFilterSpacer(geometry: geometry)
                    }
                    // Removed .fixedSize(vertical: true): it forced full height and eagerly built every row.
                    .frame(minWidth: geometry.size.width, minHeight: geometry.size.height, alignment: .topLeading)
                    // KVO on the backing UIScrollView drives the left column (preferences don't fire reliably here).
                    .background(TableGridScrollReader(sync: scrollSync))
                }
                .accessibilityIdentifier("TableScrollView")
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.01, execute: {
                        cellProxy.scrollTo(0, anchor: .leading)
                        let selectedRows = viewModel.tableDataModel.selectedRows
                        if let selectedRowID = selectedRows.first, selectedRows.count == 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                cellProxy.scrollTo(selectedRowID, anchor: .leading)
                            }
                            // TODO: (NO-1927) Horizontal grid scrolling intentionally disabled for now.
//                            if let columnId = viewModel.tableDataModel.scrollToColumnId {
//                                cellProxy.scrollTo(columnId, anchor: .leading)
//                            }
                        }
                    })
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
        .simultaneousGesture(DragGesture().onChanged({ _ in
            dismissKeyboard()
        }))
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Shared handles to the left column's and top header's UIScrollViews so the grid can drive their offsets directly in UIKit.
fileprivate final class TableScrollSync {
    weak var leftScrollView: UIScrollView?
    weak var topScrollView: UIScrollView?
}

/// Observes the grid's UIScrollView and mirrors its offset onto the left column (y) and the header (x). Place in the grid background.
fileprivate struct TableGridScrollReader: UIViewRepresentable {
    let sync: TableScrollSync

    func makeUIView(context: Context) -> ReaderView { ReaderView(sync: sync) }
    func updateUIView(_ uiView: ReaderView, context: Context) {}

    final class ReaderView: UIView {
        let sync: TableScrollSync
        private var observation: NSKeyValueObservation?

        init(sync: TableScrollSync) {
            self.sync = sync
            super.init(frame: .zero)
            isUserInteractionEnabled = false
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            observation = nil
            guard window != nil else { return }
            var view = superview
            while let current = view, !(current is UIScrollView) { view = current.superview }
            guard let grid = view as? UIScrollView else {
                assertionFailure("TableGridScrollReader: no enclosing UIScrollView found")
                return
            }
            observation = grid.observe(\.contentOffset, options: [.initial, .new]) { [weak self] grid, _ in
                guard let self else { return }
                if let left = self.sync.leftScrollView, left.contentOffset.y != grid.contentOffset.y {
                    left.contentOffset.y = grid.contentOffset.y
                }
                if let top = self.sync.topScrollView, top.contentOffset.x != grid.contentOffset.x {
                    top.contentOffset.x = grid.contentOffset.x
                }
            }
        }
    }
}

/// Walks up to the enclosing UIScrollView and hands it to the given sink. Place in that scroll view's content background.
fileprivate struct TableScrollCapture: UIViewRepresentable {
    let assign: (UIScrollView?) -> Void

    func makeUIView(context: Context) -> CaptureView { CaptureView(assign: assign) }
    func updateUIView(_ uiView: CaptureView, context: Context) {}

    final class CaptureView: UIView {
        let assign: (UIScrollView?) -> Void

        init(assign: @escaping (UIScrollView?) -> Void) {
            self.assign = assign
            super.init(frame: .zero)
            isUserInteractionEnabled = false
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            guard window != nil else { return }
            var view = superview
            while let current = view, !(current is UIScrollView) { view = current.superview }
            let scrollView = view as? UIScrollView
            assert(scrollView != nil, "TableScrollCapture: no enclosing UIScrollView found")
            assign(scrollView)
        }
    }
}

/// Left row-number/selector column; offset driven by the grid in UIKit, so it only re-evaluates on data changes.
private struct TableRowNumbersColumn: View {
    @ObservedObject var viewModel: TableViewModel
    @Environment(\.colorScheme) var colorScheme
    let width: CGFloat
    let sync: TableScrollSync
    let onEditRow: (RowDataModel) -> Void

    var body: some View {
        if #available(iOS 16, *) {
            scroll.scrollDisabled(true)
        } else {
            // iOS 15 has no scrollDisabled: block user drags so the column can't desync from the grid.
            scroll.simultaneousGesture(DragGesture(minimumDistance: 0), including: .all)
        }
    }

    private var scroll: some View {
        ScrollView([.vertical], showsIndicators: false) {
            rows
                .frame(width: width)
                .background(TableScrollCapture { sync.leftScrollView = $0 })
        }
    }

    private var rows: some View {
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
                    if viewModel.tableDataModel.canShowSingleClickEditColumn() {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.blue)
                            .frame(width: 40, height: 60)
                            .background(Color.rowSelectionBackground(isSelected: isRowSelected, colorScheme: colorScheme))
                            .border(Color.tableCellBorderColor)
                            .onTapGesture { onEditRow(rowModel) }
                            .accessibilityIdentifier("SingleClickEditButton\(index)")
                    }
                }
            }
        }
    }
}
