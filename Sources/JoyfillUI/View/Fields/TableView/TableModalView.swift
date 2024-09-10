import SwiftUI
import JoyfillModel

struct TableModalView : View {
    @Environment(\.colorScheme) var colorScheme
    @State private var offset = CGPoint.zero
    @State private var heights: [Int: CGFloat] = [:]
    @State private var refreshID = UUID()
    @State private var rowsCount: Int = 0

    @State var isTableModalViewPresented = false
    @State var shouldShowAddRowButton: Bool = false
    @State var shouldShowDeleteRowButton: Bool = false
    @State var showRowSelector: Bool = false
    @State var allRowSelected: Bool = false
    @State var viewMoreText: String = ""
    @State var rows: [String] = []
    @State var quickRows: [String] = []
    @State var columns: [String] = []
    @State var quickColumns: [String] = []
    @State var quickViewRowCount: Int = 0
    @State var cellModels = [[TableCellModel]]()
    @State var filteredcellModels = [[TableCellModel]]()
    @State var uuid = UUID()

    @State private var showEditMultipleRowsSheetView: Bool = false

    @State private var filterModels = [FilterModel]()
    @State private var currentSelectedCol: Int = Int.min

    @State var sortModel: SortModel

    @State var fieldDependency: FieldDependency

    @State private var rowToCellMap: [String?: [FieldTableColumn?]] = [:]
    @State private var quickRowToCellMap: [String?: [FieldTableColumn?]] = [:]
    @State private var columnIdToColumnMap: [String: FieldTableColumn] = [:]
    @State var selectedRows = [String]()

    @State private var tableDataDidChange = false

    private let rowHeight: CGFloat = 50
    private let mode: Mode

    init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
        self.mode = fieldDependency.mode
        self.sortModel = SortModel()
    }
    
    var body: some View {
        VStack {
            TableModalTopNavigationView(showMoreButton: $shouldShowDeleteRowButton, onDeleteTap: {
                deleteSelectedRow()
                heights = [:]
            }, onDuplicateTap: {
                duplicateRow()
            }, onAddRowTap: {
                addRow()
            }, onEditTap: {
                showEditMultipleRowsSheetView = true
            }, fieldDependency: fieldDependency)
            .sheet(isPresented: $showEditMultipleRowsSheetView) {
//                EditMultipleRowsSheetView(viewModel: viewModel)
            }
            .padding(EdgeInsets(top: 16, leading: 10, bottom: 10, trailing: 10))
            if currentSelectedCol != Int.min {
//                SearchBar(model: $filterModels[currentSelectedCol], sortModel: $sortModel, selectedColumnIndex: $currentSelectedCol, viewModel: viewModel)
                EmptyView()
            }
            scrollArea
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
        }
        .onDisappear(perform: {
            sendEventsIfNeeded()
        })
        .onAppear(perform: {
            let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
            fieldDependency.eventHandler.onFocus(event: fieldEvent)
        })
        .onChange(of: selectedRows) { newValue in
            allRowSelected = (newValue.count == rows.count)
            if selectedRows.isEmpty {
                setDeleteButtonVisibility()
            }
        }
        .onChange(of: sortModel.order) { _ in
            filterRowsIfNeeded()
            sortRowsIfNeeded()
        }
        .onChange(of: filterModels) { _ in
            filterRowsIfNeeded()
            sortRowsIfNeeded()
            resetLastSelection()
        }
        .onChange(of: cellModels) { _ in
            filterRowsIfNeeded()
            sortRowsIfNeeded()
        }
        .onChange(of: rows) { _ in
            if rows.isEmpty {
                currentSelectedCol = Int.min
                resetLastSelection()
                allRowSelected = false
            }
        }
        .onAppear {
            setupColumns()
            setup()
            setupCellModels()
            self.filterModels = columns.enumerated().map { colIndex, colID in
                FilterModel(colIndex: colIndex, colID: colID)
            }
            UIScrollView.appearance().bounces = false
            self.rowsCount = self.rows.count
            self.showRowSelector = mode == .fill
            self.shouldShowAddRowButton = mode == .fill

            let filterModels = self.columns.enumerated().map { colIndex, colID in
                FilterModel(colIndex: colIndex, colID: colID)
            }
        }
    }

    func sortRowsIfNeeded() {
        if currentSelectedCol != Int.min {
            guard sortModel.order != .none else { return }
            filteredcellModels = filteredcellModels.sorted { rowArr1, rowArr2 in
                let column = rowArr1[currentSelectedCol].data
                switch column.type {
                case "text":
                    switch sortModel.order {
                    case .ascending:
                        return (rowArr1[currentSelectedCol].data.title ?? "") < (rowArr2[currentSelectedCol].data.title ?? "")
                    case .descending:
                        return (rowArr1[currentSelectedCol].data.title ?? "") > (rowArr2[currentSelectedCol].data.title ?? "")
                    case .none:
                        return true
                    }
                case "dropdown":
                    switch sortModel.order {
                    case .ascending:
                        return (rowArr1[currentSelectedCol].data.selectedOptionText ?? "") < (rowArr2[currentSelectedCol].data.selectedOptionText ?? "")
                    case .descending:
                        return (rowArr1[currentSelectedCol].data.selectedOptionText ?? "") > (rowArr2[currentSelectedCol].data.selectedOptionText ?? "")
                    case .none:
                        return true
                    }
                default:
                    break
                }
                return false

            }
        }
    }

    func filterRowsIfNeeded() {
        filteredcellModels = cellModels
        guard !filterModels.allSatisfy({ model in model.filterText.isEmpty }) else {
            return
        }

        for model in filterModels {
            if model.filterText.isEmpty {
                continue
            }

             let filtred = filteredcellModels.filter { rowArr in
                 let column = rowArr[model.colIndex].data
                switch column.type {
                case "text":
                    return (column.title ?? "").localizedCaseInsensitiveContains(model.filterText)
                case "dropdown":
                    return (column.selectedOptionText ?? "") == model.filterText
                default:
                    break
                }
                return false
            }
            filteredcellModels = filtred
        }
    }

    var scrollArea: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    if showRowSelector  {
                        Image(systemName: allRowSelected ? "record.circle.fill" : "circle")
                            .frame(width: 40, height: 50)
                            .border(Color.tableCellBorderColor)
                            .foregroundColor(rowsCount == 0 ? Color.gray.opacity(0.4) : nil)
                            .onTapGesture {
                                allRowSelected.toggle()
                                if allRowSelected {
                                    selectAllRows()
                                } else {
                                    resetLastSelection()
                                }
                                setDeleteButtonVisibility()
                            }
                            .disabled(rowsCount == 0)
                            .accessibilityIdentifier("SelectAllButton")
                    }
                    Text("#")
                        .frame(width: 40, height: 50)
                        .border(Color.tableCellBorderColor)
                }
                .frame(width: showRowSelector ? 80 : 40, height: rowHeight)
                .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
                .cornerRadius(14, corners: [.topLeft])
                
                
                ScrollView([.vertical], showsIndicators: false) {
                    rowsHeader
                        .offset(y: offset.y)
                }
                .simultaneousGesture(DragGesture(minimumDistance: 0), including: .all)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                if #available(iOS 16, *) {
                    ScrollView([.horizontal], showsIndicators: false) {
                        colsHeader
                            .offset(x: offset.x)
                    }
                    .background(Color.tableCellBorderColor)
                    .cornerRadius(14, corners: [.topRight])
                    .scrollDisabled(true)
                } else {
                    ScrollView([.horizontal], showsIndicators: false) {
                        colsHeader
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

    var colsHeader: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(columns.enumerated()), id: \.offset) { index, columnId in
                Button(action: {
                    currentSelectedCol = currentSelectedCol == index ? Int.min : index
                }, label: {
                    ZStack {
                        Rectangle()
                            .stroke()
                            .foregroundColor(currentSelectedCol != index ? Color.tableCellBorderColor : Color.blue)
                        HStack {
                            Text(getColumnTitle(columnId: columnId))
                                .darkLightThemeColor()
                            if getColumnType(columnId: columnId) != "image" {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .foregroundColor(filterModels[index].filterText.isEmpty ? Color.gray : Color.blue)
                            }

                        }
                        .font(.system(size: 15))
                    }
                })
                .disabled(getColumnType(columnId: columnId) == "image" || rowsCount == 0)
                .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
                .frame(width: 170, height: rowHeight)
            }
        }
    }
    
    var rowsHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(filteredcellModels.enumerated()), id: \.offset) { (index, rowArray) in
                HStack(spacing: 0) {
                    if showRowSelector {
                        let isRowSelected = selectedRows.contains(rowArray.first?.rowID ?? "")
                        Image(systemName: isRowSelected ? "record.circle.fill" : "circle")
                            .frame(width: 40, height: heights[index] ?? 50)
                            .border(Color.tableCellBorderColor)
                            .onTapGesture {
                                toggleSelection(rowID: rowArray.first?.rowID ?? "")
                                setDeleteButtonVisibility()
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
                        ForEach(Array(filteredcellModels.enumerated()), id: \.offset) { rowIndex, rowCellModels in
                            HStack(alignment: .top, spacing: 0) {
                                ForEach(rowCellModels, id: \.id) { cellModel in
                                    ZStack {
                                        Rectangle()
                                            .stroke()
                                            .foregroundColor(Color.tableCellBorderColor)
                                        TableViewCellBuilder(cellModel: cellModel)
                                    }
                                    .frame(minWidth: 170, maxWidth: 170, minHeight: 50, maxHeight: .infinity)
                                    .background(GeometryReader { proxy in
                                        Color.clear.preference(key: HeightPreferenceKey.self, value: [rowIndex: proxy.size.height])
                                    })
                                }

                            }
                        }
                        .id(refreshID)
                        .onChange(of: rows) { value in
                            refreshUUIDIfNeeded()
                        }
//                        .(rows) { _ in
//                            refreshUUIDIfNeeded()
//                        }
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
//        resetLastSelection()
        setDeleteButtonVisibility()
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Note: This is an optimisation to stop force re-render entire table
    private func refreshUUIDIfNeeded() {
        if rowsCount != rows.count {
            self.rowsCount = rows.count
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

enum SortOder {
    case ascending
    case descending
    case none

    mutating func next() {
        switch self {
        case .ascending:
            self = .descending
        case .descending:
            self = .none
        case .none:
            self = .ascending
        }
    }
}
struct SortModel {
//    var selected: Bool = false
    var order: SortOder = .none
}

struct FilterModel:Equatable {
    var filterText: String = ""
    var colIndex: Int
    var colID: String
}

//struct SearchBar: View {
//    @Binding var model: FilterModel
//    @Binding var sortModel: SortModel
//    @Binding var selectedColumnIndex: Int
//
//    let viewModel: TableViewModel
//    
//    var body: some View {
//        HStack {
//            if !rows.isEmpty, selectedColumnIndex != Int.min {
//                let row = rows[0]
//                let column = getFieldTableColumn(row: row, col: selectedColumnIndex)
//                if let column = column {
//                    let cellModel = TableCellModel(rowID: "", data: column, eventHandler: fieldDependency.eventHandler, fieldData: fieldDependency.fieldData, viewMode: .modalView, editMode: fieldDependency.mode)
//                    { editedCell in
//                        switch column.type {
//                        case "text":
//                            self.model.filterText = editedCell.title ?? ""
//                        case "dropdown":
//                            self.model.filterText = editedCell.selectedOptionText ?? ""
//                        default:
//                            break
//                        }
//                    }
//                    switch cellModel.data.type {
//                    case "text":
//                        TextFieldSearchBar(text: $model.filterText)
//                    case "dropdown":
//                        TableDropDownOptionListView(cellModel: cellModel, isUsedForBulkEdit: true, selectedDropdownValue: model.filterText)
//                            .disabled(cellModel.editMode == .readonly)
//                    default:
//                        Text("")
//                    }
//                }
//                Button(action: {
//                    sortModel.order.next()
//                }, label: {
//                    HStack {
//                        Text("Sort")
//                        Image(systemName: getSortIcon())
//                            .foregroundColor(getIconColor())
//                    }
//                    .font(.system(size: 14))
//                    .foregroundColor(.black)
//                })
//                .frame(width: 75, height: 25)
//                .background(.white)
//                .cornerRadius(4)
//                
//                Button(action: {
//                    model.filterText = ""
//                    selectedColumnIndex = Int.min
//                }, label: {
//                    Image(systemName: "xmark")
//                        .resizable()
//                        .frame(width: 10, height: 10)
//                        .foregroundColor(.black)
//                        .padding(.all, 8)
//                        .background(.white)
//                        .cornerRadius(4)
//                        .padding(.trailing, 8)
//                    
//                })
//            }
//        }
//        .frame(height: 40)
//        .background(Color(.systemGray6))
//        .cornerRadius(8)
//        .padding(.horizontal, 12)
//    }
//    func getSortIcon() -> String {
//        switch sortModel.order {
//        case .ascending:
//            return "arrow.up"
//        case .descending:
//            return "arrow.down"
//        case .none:
//            return "arrow.up.arrow.down"
//        }
//    }
//    func getIconColor() -> Color {
//        switch sortModel.order {
//        case .none:
//            return .black
//        case .ascending, .descending:
//            return .blue
//        }
//    }
//}

struct TextFieldSearchBar: View {
    @Binding var text: String

    var body: some View {
        TextField("Search ", text: $text)
            .font(.system(size: 12))
            .foregroundColor(.black)
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


extension TableModalView {

    private func setup() {
        setupRows()
        quickViewRowCount = rows.count >= 3 ? 3 : rows.count
        setDeleteButtonVisibility()
        viewMoreText = rows.count > 1 ? "+\(rows.count)" : ""
    }

    func setupCellModels() {
        var cellModels = [[TableCellModel]]()
        rows.enumerated().forEach { rowIndex, rowID in
            var rowCellModels = [TableCellModel]()
            columns.enumerated().forEach { colIndex, colID in
                let columnModel = getFieldTableColumn(row: rowID, col: colIndex)
                if let columnModel = columnModel {
                    let cellModel = TableCellModel(rowID: rowID, data: columnModel, eventHandler: fieldDependency.eventHandler, fieldData: fieldDependency.fieldData, viewMode: .modalView, editMode: fieldDependency.mode) { editedCell  in
                        self.cellDidChange(rowId: rowID, colIndex: colIndex, editedCell: editedCell)
                    }
                    rowCellModels.append(cellModel)
                }
            }
            cellModels.append(rowCellModels)
        }
        self.cellModels = cellModels
        self.filteredcellModels = cellModels
    }

    func updateCellModel(rowIndex: Int, rowID: String, colIndex: Int, colID: String) {
        let columnModel = getFieldTableColumn(row: rowID, col: colIndex)
        if let columnModel = columnModel {
            let cellModel = TableCellModel(rowID: rowID, data: columnModel, eventHandler: fieldDependency.eventHandler, fieldData: fieldDependency.fieldData, viewMode: .modalView, editMode: fieldDependency.mode) { editedCell  in
                self.cellDidChange(rowId: rowID, colIndex: colIndex, editedCell: editedCell)
            }
            cellModels[rowIndex][colIndex] = cellModel
        }
    }

    func getFieldTableColumn(row: String, col: Int) -> FieldTableColumn? {
        return rowToCellMap[row]?[col]
    }

    func getQuickFieldTableColumn(row: String, col: Int) -> FieldTableColumn? {
        return quickRowToCellMap[row]?[col]
    }


    func getColumnTitle(columnId: String) -> String {
        return columnIdToColumnMap[columnId]?.title ?? ""
    }

    func getColumnTitleAtIndex(index: Int) -> String {
        guard index < columns.count else { return "" }
        return columnIdToColumnMap[columns[index]]?.title ?? ""
    }

    func getColumnType(columnId: String) -> String? {
        return columnIdToColumnMap[columnId]?.type
    }

    func getColumnIDAtIndex(index: Int) -> String? {
        guard index < columns.count else { return nil }
        return columnIdToColumnMap[columns[index]]?.id
    }

    func toggleSelection(rowID: String) {
        if selectedRows.contains(rowID) {
            selectedRows = selectedRows.filter({ $0 != rowID})
        } else {
            selectedRows.append(rowID)
        }
    }

    func selectAllRows() {
        selectedRows = rows
    }

    func resetLastSelection() {
        selectedRows = []
    }

    func setDeleteButtonVisibility() {
        shouldShowDeleteRowButton = (mode == .fill && !selectedRows.isEmpty && !filteredcellModels.isEmpty)
    }

    func deleteSelectedRow() {
        guard !selectedRows.isEmpty else {
            return
        }

        for row in selectedRows {
            fieldDependency.fieldData?.deleteRow(id: row)
            rowToCellMap.removeValue(forKey: row)
        }

        resetLastSelection()
        setup()
        uuid = UUID()
        setTableDataDidChange(to: true)
        setupCellModels()
    }

    func setTableDataDidChange(to: Bool) {
        tableDataDidChange = to
    }

    func duplicateRow() {
        guard !selectedRows.isEmpty else {
            return
        }
        setTableDataDidChange(to: true)


        for row in selectedRows {
            let id = generateObjectId()
            fieldDependency.fieldData?.duplicateRow(id: row)
            uuid = UUID()
        }
        fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldDependency.fieldData))
        resetLastSelection()
        setup()
        setupCellModels()
    }

    func addRow() {
        let id = generateObjectId()
        fieldDependency.fieldData?.addRow(id: id)
        resetLastSelection()
        setup()
        uuid = UUID()
        fieldDependency.eventHandler.addRow(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldDependency.fieldData), targetRowIndex: (fieldDependency.fieldData?.value?.valueElements?.count ?? 1) - 1)
        setupCellModels()
    }

    func cellDidChange(rowId: String, colIndex: Int, editedCell: FieldTableColumn) {
        setTableDataDidChange(to: true)
        fieldDependency.fieldData?.cellDidChange(rowId: rowId, colIndex: colIndex, editedCell: editedCell)
        setup()
        uuid = UUID()
//        setupCellModels()
        updateCellModel(rowIndex: rows.firstIndex(of: rowId) ?? 0, rowID: rowId, colIndex: colIndex, colID: columns[colIndex])
    }

    func cellDidChange(rowId: String, colIndex: Int, editedCellId: String, value: String) {
        fieldDependency.fieldData?.cellDidChange(rowId: rowId, colIndex: colIndex, editedCellId: editedCellId, value: value)
        resetLastSelection()
        setup()
        uuid = UUID()
        setTableDataDidChange(to: true)
        setupCellModels()
    }

    private func setupColumns() {
        guard let joyDocModel = fieldDependency.fieldData else { return }

        for column in joyDocModel.tableColumnOrder ?? [] {
            columnIdToColumnMap[column] = joyDocModel.tableColumns?.first { $0.id == column }
        }

        self.columns = joyDocModel.tableColumnOrder ?? []
        self.quickColumns = columns
        while quickColumns.count > 3 {
            quickColumns.removeLast()
        }
    }

    private func setupRows() {
        guard let joyDocModel = fieldDependency.fieldData else { return }
        guard let valueElements = joyDocModel.valueToValueElements, !valueElements.isEmpty else {
            setupQuickTableViewRows()
            return
        }

        let nonDeletedRows = valueElements.filter { !($0.deleted ?? false) }
        let sortedRows = sortElementsByRowOrder(elements: nonDeletedRows, rowOrder: joyDocModel.rowOrder)
        var rowToCellMap: [String?: [FieldTableColumn?]] = [:]

        for row in sortedRows {
            var cells: [FieldTableColumn?] = []
            for column in joyDocModel.tableColumnOrder ?? [] {
                let columnData = joyDocModel.tableColumns?.first { $0.id == column }
                let cell = buildCell(data: columnData, row: row, column: column)
                cells.append(cell)
            }
            rowToCellMap[row.id] = cells
        }

        rows = sortedRows.map { $0.id ?? "" }
        self.quickRows = self.rows
        self.rowToCellMap = rowToCellMap
        self.quickRowToCellMap = rowToCellMap
        setupQuickTableViewRows()
    }

    private func buildCell(data: FieldTableColumn?, row: ValueElement, column: String) -> FieldTableColumn? {
        var cell = data
        let valueUnion = row.cells?.first(where: { $0.key == column })?.value
        switch data?.type {
        case "text":
            cell?.title = valueUnion?.text ?? ""
        case "dropdown":
            cell?.defaultDropdownSelectedId = valueUnion?.dropdownValue
        case "image":
            cell?.images = valueUnion?.valueElements
        default:
            return nil
        }
        return cell
    }

    func setupQuickTableViewRows() {
        if quickRows.isEmpty {
            quickRowToCellMap = [:]
            let id = generateObjectId()
            quickRows = [id]
            quickRowToCellMap = [id : fieldDependency.fieldData?.tableColumns ?? []]
        }
        else {
            while quickRows.count > 3 {
                quickRows.removeLast()
            }
        }
    }

    func sortElementsByRowOrder(elements: [ValueElement], rowOrder: [String]?) -> [ValueElement] {
        guard let rowOrder = rowOrder else { return elements }
        let sortedRows = elements.sorted { (a, b) -> Bool in
            if let first = rowOrder.firstIndex(of: a.id ?? ""), let second = rowOrder.firstIndex(of: b.id ?? "") {
                return first < second
            }
            return false
        }
        return sortedRows
    }

    func sendEventsIfNeeded() {
        if tableDataDidChange {
            setTableDataDidChange(to: false)
            fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldDependency.fieldData))
        }
    }
}
