import SwiftUI
import JoyfillModel

struct TableModalView : View {
    @State private var offset = CGPoint.zero
    @ObservedObject var viewModel: TableViewModel
    @State private var heights: [Int: CGFloat] = [:]
    @State private var refreshID = UUID()
    @State private var rowsCount: Int = 0
    @Environment(\.colorScheme) var colorScheme
    @State private var showEditMultipleRowsSheetView: Bool = false
    @State private var textHeight: CGFloat = 0
    @State private var filterModels = [FilterModel]()
    @State private var currentSelectedCol: Int = Int.min
    @State var sortModel: SortModel

    init(viewModel: TableViewModel) {
        _sortModel = State(initialValue: SortModel())
        self.viewModel = viewModel
        let filterModels = self.viewModel.columns.enumerated().map { colIndex, colID in
            FilterModel(colIndex: colIndex, colID: colID)
        }
        _filterModels = State(initialValue: filterModels)
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
            }, onEditTap: {
                showEditMultipleRowsSheetView = true
            }, fieldDependency: viewModel.fieldDependency)
            .sheet(isPresented: $showEditMultipleRowsSheetView) {
                EditMultipleRowsSheetView(viewModel: viewModel)
            }
            .padding(EdgeInsets(top: 16, leading: 10, bottom: 10, trailing: 10))
            if currentSelectedCol != Int.min {
                SearchBar(model: $filterModels[currentSelectedCol], sortModel: $sortModel, selectedColumnIndex: $currentSelectedCol, viewModel: viewModel)
                EmptyView()
            }
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
        .onChange(of: viewModel.selectedRows) { newValue in
            viewModel.allRowSelected = (newValue.count == viewModel.rows.count)
            if viewModel.selectedRows.isEmpty {
                viewModel.setDeleteButtonVisibility()
            }
        }
        .onChange(of: sortModel.order) { _ in
            filterRowsIfNeeded()
            sortRowsIfNeeded()
        }
        .onChange(of: filterModels) { _ in
            filterRowsIfNeeded()
            sortRowsIfNeeded()
            viewModel.resetLastSelection()
        }
        .onChange(of: viewModel.cellModels) { _ in
            filterRowsIfNeeded()
            sortRowsIfNeeded()
        }
        .onChange(of: viewModel.rows) { _ in
            if viewModel.rows.isEmpty {
                currentSelectedCol = Int.min
                viewModel.resetLastSelection()
                viewModel.allRowSelected = false
            }
        }
    }

    func sortRowsIfNeeded() {
        if currentSelectedCol != Int.min {
            guard sortModel.order != .none else { return }
            viewModel.filteredcellModels = viewModel.filteredcellModels.sorted { rowArr1, rowArr2 in
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
        viewModel.filteredcellModels = viewModel.cellModels
        guard !filterModels.allSatisfy({ model in model.filterText.isEmpty }) else {
            return
        }

        for model in filterModels {
            if model.filterText.isEmpty {
                continue
            }

             let filtred = viewModel.filteredcellModels.filter { rowArr in
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
            viewModel.filteredcellModels = filtred
        }
    }

    var scrollArea: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    if viewModel.showRowSelector  {
                        Image(systemName: viewModel.allRowSelected ? "record.circle.fill" : "circle")
                            .frame(width: 40, height: textHeight > 50 ? textHeight : 50)
                            .foregroundColor(rowsCount == 0 ? Color.gray.opacity(0.4) : nil)
                            .onTapGesture {
                                viewModel.allRowSelected.toggle()
                                if viewModel.allRowSelected {
                                    viewModel.selectAllRows()
                                } else {
                                    viewModel.resetLastSelection()
                                }
                                viewModel.setDeleteButtonVisibility()
                            }
                            .disabled(rowsCount == 0)
                            .accessibilityIdentifier("SelectAllButton")
                    }
                    Text("#")
                        .frame(width: 40, height: textHeight > 50 ? textHeight : 50)
                        .border(Color.tableCellBorderColor)
                }
                .frame(minHeight: 50)
                .frame(width: viewModel.showRowSelector ? 80 : 40, height: textHeight > 50 ? textHeight : 50)
                .border(Color.tableCellBorderColor)
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
            ForEach(Array(viewModel.columns.enumerated()), id: \.offset) { index, columnId in
                Button(action: {
                    currentSelectedCol = currentSelectedCol == index ? Int.min : index
                }, label: {
                    HStack {
                        Text(viewModel.getColumnTitle(columnId: columnId))
                            .multilineTextAlignment(.leading)
                            .darkLightThemeColor()
                        if viewModel.getColumnType(columnId: columnId) != "image" {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .foregroundColor(filterModels[index].filterText.isEmpty ? Color.gray : Color.blue)
                        }
                        
                    }
                    .padding(.all, 4)
                    .font(.system(size: 15))
                    .frame(width: 170)
                    .frame(minHeight: textHeight > 50 ? textHeight : 50)
                    .overlay(
                        Rectangle()
                            .stroke(currentSelectedCol != index ? Color.tableCellBorderColor : Color.blue, lineWidth: 1)
                    )
                    .background(
                        colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor
                    )
                })
                .disabled(viewModel.getColumnType(columnId: columnId) == "image" || rowsCount == 0)
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                self.textHeight = geometry.size.height
                                print("\(textHeight)")
                            }
                    }
                )
            }
        }
    }
    
    var rowsHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(viewModel.filteredcellModels.enumerated()), id: \.offset) { (index, rowArray) in
                HStack(spacing: 0) {
                    if viewModel.showRowSelector {
                        let isRowSelected = viewModel.selectedRows.contains(rowArray.first?.rowID ?? "")
                        Image(systemName: isRowSelected ? "record.circle.fill" : "circle")
                            .frame(width: 40, height: heights[index] ?? 50)
                            .border(Color.tableCellBorderColor)
                            .onTapGesture {
                                viewModel.toggleSelection(rowID: rowArray.first?.rowID ?? "")
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
                        ForEach(Array(viewModel.filteredcellModels.enumerated()), id: \.offset) { rowIndex, rowCellModels in
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
//        viewModel.resetLastSelection()
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

struct SearchBar: View {
    @Binding var model: FilterModel
    @Binding var sortModel: SortModel
    @Binding var selectedColumnIndex: Int

    let viewModel: TableViewModel
    
    var body: some View {
        HStack {
            if !viewModel.rows.isEmpty, selectedColumnIndex != Int.min {
                let row = viewModel.rows[0]
                let column = viewModel.getFieldTableColumn(row: row, col: selectedColumnIndex)
                if let column = column {
                    let cellModel = TableCellModel(rowID: "", data: column, eventHandler: viewModel.fieldDependency.eventHandler, fieldData: viewModel.fieldDependency.fieldData, viewMode: .modalView, editMode: viewModel.fieldDependency.mode)
                    { editedCell in
                        switch column.type {
                        case "text":
                            self.model.filterText = editedCell.title ?? ""
                        case "dropdown":
                            self.model.filterText = editedCell.selectedOptionText ?? ""
                        default:
                            break
                        }
                    }
                    switch cellModel.data.type {
                    case "text":
                        TextFieldSearchBar(text: $model.filterText)
                    case "dropdown":
                        TableDropDownOptionListView(cellModel: cellModel, isUsedForBulkEdit: true, selectedDropdownValue: model.filterText)
                            .disabled(cellModel.editMode == .readonly)
                    default:
                        Text("")
                    }
                }
                Button(action: {
                    sortModel.order.next()
                }, label: {
                    HStack {
                        Text("Sort")
                        Image(systemName: getSortIcon())
                            .foregroundColor(getIconColor())
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                })
                .frame(width: 75, height: 25)
                .background(.white)
                .cornerRadius(4)
                
                Button(action: {
                    model.filterText = ""
                    selectedColumnIndex = Int.min
                }, label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.black)
                        .padding(.all, 8)
                        .background(.white)
                        .cornerRadius(4)
                        .padding(.trailing, 8)
                    
                })
            }
        }
        .frame(height: 40)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal, 12)
    }
    func getSortIcon() -> String {
        switch sortModel.order {
        case .ascending:
            return "arrow.up"
        case .descending:
            return "arrow.down"
        case .none:
            return "arrow.up.arrow.down"
        }
    }
    func getIconColor() -> Color {
        switch sortModel.order {
        case .none:
            return .black
        case .ascending, .descending:
            return .blue
        }
    }
}

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
