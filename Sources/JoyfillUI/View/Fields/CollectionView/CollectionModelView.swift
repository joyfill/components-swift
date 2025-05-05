//
//  File.swift
//  Joyfill
//
//  Created by Vivek on 14/02/25.
//

import SwiftUI
import JoyfillModel

struct CollectionRowView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: CollectionViewModel
    @Binding var rowDataModel: RowDataModel
    var longestBlockText: String

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            let columns = viewModel.tableDataModel.schema[rowDataModel.rowType.isRow ? viewModel.rootSchemaKey : rowDataModel.rowType.parentSchemaKey]?.tableColumns ?? []
            ForEach($rowDataModel.cells, id: \.id) { $cellModel in
                let column = columns.first(where: { $0.id == cellModel.data.id })

                CollectionViewCellBuilder(viewModel: viewModel, cellModel: $cellModel)
                    .frame(
                        minWidth: viewModel.cellWidthMap[cellModel.data.id],
                        maxWidth: viewModel.cellWidthMap[cellModel.data.id],
                        minHeight: 50,
                        maxHeight: .infinity
                    )
                    .overlay(
                        ZStack {
                            // Outer border
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.tableCellBorderColor, lineWidth: 1.5)

                            if let required = column?.required, required, !cellModel.data.isCellFilled {
                                RoundedRectangle(cornerRadius: 8)
                                    .inset(by: 2)
                                    .stroke(colorScheme == .dark ? Color.pink : Color.red, lineWidth: colorScheme == .dark ? 1 : 0.5)
                            }
                        }
                    )
            }
        }
    }
}

struct CollectionModalView : View {
    @State private var offset = CGPoint.zero
    @ObservedObject var viewModel: CollectionViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showEditMultipleRowsSheetView: Bool = false
    let textHeight: CGFloat = 50 // Default height
    @State private var currentSelectedCol: Int = Int.min
    var longestBlockText: String = ""

    init(viewModel: CollectionViewModel) {
        self.viewModel = viewModel
        UIScrollView.appearance().bounces = false
        longestBlockText = viewModel.tableDataModel.getLongestBlockText()
    }

    var body: some View {
        VStack {
            CollectionModalTopNavigationView(
                viewModel: viewModel,
                onEditTap: { showEditMultipleRowsSheetView = true })
            .sheet(isPresented: $showEditMultipleRowsSheetView) {
                CollectionEditMultipleRowsSheetView(viewModel: viewModel, tableColumns: viewModel.getTableColumnsForSelectedRows())
            }
            .padding(EdgeInsets(top: 16, leading: 10, bottom: 10, trailing: 10))
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
//            for model in viewModel.tableDataModel.filteredcellModels {
//                if let index = viewModel.tableDataModel.cellModels.firstIndex(of: model) {
//                    viewModel.tableDataModel.cellModels[index] = model
//                }
//            }
        }
        .alert(isPresented: $viewModel.tableDataModel.showResetSelectionAlert) {
            Alert(
                title: Text("Reset Selection"),
                message: Text("The selected row is of a different table. Do you want to reset the selection and choose the new row?"),
                primaryButton: .destructive(Text("Yes"), action: {
                    viewModel.tableDataModel.confirmResetSelection()
                }),
                secondaryButton: .cancel(Text("No"), action: {
                    viewModel.tableDataModel.cancelResetSelection()
                })
            )
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
                let rootSchema = viewModel.tableDataModel.schema[viewModel.rootSchemaKey]

                if #available(iOS 16, *) {
                    ScrollView([.horizontal], showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            RootTitleRowView(viewModel: viewModel, textHeight: textHeight, colorScheme: colorScheme, rootSchema: rootSchema)
                                .cornerRadius(14, corners: [.topLeft, .topRight], borderColor: Color.tableCellBorderColor)
                                .offset(x: offset.x)

                            HStack(spacing: 0) {
                                rowSelectorHeader

                                CollectionColumnHeaderView(viewModel: viewModel,
                                                           tableColumns: viewModel.tableDataModel.tableColumns,
                                                           currentSelectedCol: $currentSelectedCol,
                                                           colorScheme: colorScheme,
                                                           isHeaderNested: false)
                                .offset(x: offset.x)
                            }
                        }
                    }
                    .scrollDisabled(true)
                } else {
                    ScrollView([.horizontal], showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            RootTitleRowView(viewModel: viewModel, textHeight: textHeight, colorScheme: colorScheme, rootSchema: rootSchema)
                                .cornerRadius(14, corners: [.topLeft, .topRight], borderColor: Color.tableCellBorderColor)
                                .offset(x: offset.x)

                            HStack(spacing: 0) {
                                rowSelectorHeader
                                CollectionColumnHeaderView(viewModel: viewModel,
                                                           tableColumns: viewModel.tableDataModel.tableColumns,
                                                           currentSelectedCol: $currentSelectedCol,
                                                           colorScheme: colorScheme,
                                                           isHeaderNested: false)
                                .offset(x: offset.x)
                            }
                        }
                    }
                }

                collection
                    .coordinateSpace(name: "scroll")
            }
        }
        .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
    }

    var rowSelectorHeader: some View {
        HStack(alignment: .center, spacing: 0) {
            if viewModel.nestedTableCount > 0 {
                Spacer()
            }
            if viewModel.showRowSelector  {
                Image(systemName: viewModel.tableDataModel.allRowSelected ? "circle.square.fill" : "square")
                    .frame(width: 40, height: textHeight)
                    .foregroundColor(viewModel.tableDataModel.cellModels.count == 0 ? Color.gray.opacity(0.4) : nil)
                    .onTapGesture {
                        if !viewModel.tableDataModel.allRowSelected {
                            viewModel.tableDataModel.selectAllRows()
                        } else {
                            viewModel.tableDataModel.emptySelection()
                        }
                    }
                    .disabled(viewModel.tableDataModel.cellModels.count == 0)
                    .accessibilityIdentifier("SelectAllRowSelectorButton")
            }

            Text("#")
                .frame(width: 40, height: 60)
                .border(Color.tableCellBorderColor)
        }
        .frame(minHeight: 60)
        .frame(width: viewModel.showRowSelector ? (viewModel.nestedTableCount > 0 ? 120 : 80) : 80, height: 60)
        .border(Color.tableCellBorderColor)
        .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
        .offset(x: offset.x)
    }

    var collection: some View {
        ScrollViewReader { cellProxy in
            GeometryReader { geometry in
                ScrollView([.vertical, .horizontal], showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array($viewModel.tableDataModel.filteredcellModels.enumerated()), id: \.element.wrappedValue.rowID) { (index, $rowCellModels) in
                            HStack(spacing: 0) {
                                CollectionRowsHeaderView(viewModel: viewModel, rowModel: $rowCellModels, colorScheme: colorScheme, index: index)

                                switch rowCellModels.rowType {
                                case .row:
                                    CollectionRowView(viewModel: viewModel, rowDataModel: $rowCellModels, longestBlockText: longestBlockText)
                                        .frame(height: 60)
                                case .nestedRow(level: let level, index: let index, parentID: let parentID, _):
                                    CollectionRowView(viewModel: viewModel, rowDataModel: $rowCellModels, longestBlockText: longestBlockText)
                                        .frame(height: 60)
                                case .header(level: let level, tableColumns: let tableColumns):
                                    CollectionColumnHeaderView(viewModel: viewModel,
                                                               tableColumns: tableColumns ?? [],
                                                               currentSelectedCol: $currentSelectedCol,
                                                               colorScheme: colorScheme,
                                                               isHeaderNested: true)
                                    .frame(height: 60)
                                case .tableExpander(schemaValue: let schemaValue, level: let level, parentID: let parentID, _):
                                    CollectionExpanderView(rowDataModel: $rowCellModels, schemaValue: schemaValue, viewModel: viewModel, level: level, parentID:  parentID ?? ("",""))
                                        .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
                                }
                            }
                        }

                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minWidth: max(viewModel.collectionWidth, geometry.size.width), minHeight: geometry.size.height, alignment: .topLeading)
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
                .simultaneousGesture(DragGesture().onChanged({ _ in
                    dismissKeyboard()
                }))
            }
        }
    }
}

struct CollectionExpanderView: View {
    @Binding var rowDataModel: RowDataModel
    var schemaValue: (String, Schema)?
    @ObservedObject var viewModel: CollectionViewModel
    let level: Int
    let parentID: (columnID: String, rowID: String)

    var body: some View {
        HStack {
            if viewModel.tableDataModel.mode != .readonly {
                Button(action: {
                    let startingIndex = viewModel.tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == rowDataModel.rowID }) ?? 0
                    viewModel.addNestedRow(schemaKey: schemaValue?.0 ?? "", level: level, startingIndex: startingIndex, parentID: parentID)
                }) {
                    Text("+ Row")
                        .foregroundStyle(viewModel.tableDataModel.mode == .readonly ? .gray : .blue)
                        .font(.system(size: 14))
                        .frame(height: 27)
                        .padding(.horizontal, 16)
                        .overlay(RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.buttonBorderColor, lineWidth: 1))
                }
                .accessibilityIdentifier("collectionSchemaAddRowButton")
            }
            let rowID = parentID.rowID
            let children = viewModel.getChildren(forRowId: rowID, in: viewModel.tableDataModel.valueToValueElements ?? [])

            let schemaID = schemaValue?.0 ?? ""
            let childValueElements = children?[schemaID]?.valueToValueElements

            if !viewModel.isOnlySchemaValid(schemaID: schemaValue?.0 ?? "", valueElements: childValueElements ?? []) {
                Image(systemName: "asterisk")
                    .foregroundColor(.red)
                    .imageScale(.small)
            }

            ScrollView {
                Text(schemaValue?.1.title ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.all, 8)
                    .frame(maxHeight: .infinity, alignment: .center)
            }

            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .font(.system(size: 15, weight: .bold))
        .frame(width: rowDataModel.rowType.width, height: 60)
        .border(Color.tableCellBorderColor)
    }
}

struct RootTitleRowView: View {
    @ObservedObject var viewModel: CollectionViewModel
    let textHeight: CGFloat
    let colorScheme: ColorScheme
    let rootSchema: Schema?

    var body: some View {
        HStack(spacing: 0) {
            if viewModel.tableDataModel.mode != .readonly {
                Button(action: {
                    viewModel.addRow()
                }) {
                    Text("+ Row")
                        .foregroundStyle(viewModel.tableDataModel.mode == .readonly ? .gray : .blue)
                        .font(.system(size: 14))
                        .frame(height: 27)
                        .padding(.horizontal, 16)
                        .overlay(RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.buttonBorderColor, lineWidth: 1))
                }
                .accessibilityIdentifier("TableAddRowIdentifier")
            }

            if !viewModel.isRootSchemaValid() {
                Image(systemName: "asterisk")
                    .foregroundColor(.red)
                    .imageScale(.small)
            }

            ScrollView {
                Text(rootSchema?.title ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.all, 8)
                    .frame(maxHeight: .infinity, alignment: .center)
            }

            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(minHeight: 50)
        .frame(width: viewModel.rowWidth(viewModel.tableDataModel.tableColumns, 0), height: 60)
        .font(.system(size: 15, weight: .bold))
        .border(Color.tableCellBorderColor)
        .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
    }
}

struct CollectionColumnHeaderView: View {
    @ObservedObject var viewModel: CollectionViewModel
    let tableColumns: [FieldTableColumn]
    @Binding var currentSelectedCol: Int
    let colorScheme: ColorScheme
    let isHeaderNested: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(tableColumns.enumerated()), id: \.element.id) { index, column in
//                Button(action: {
////                    currentSelectedCol = currentSelectedCol == index ? Int.min : index
//                }, label: {
                    HStack {
//                        Text(column.title)
//                            .multilineTextAlignment(.leading)

                        ScrollView {
                            Text(column.title)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.all, 8)
                                .frame(maxHeight: .infinity, alignment: .center)
                                .darkLightThemeColor()
                        }

                        //TODO: Handle required for nested table columns
//                        if let required = column.required, required, !viewModel.isColumnFilled(columnId: column.id ?? "") {
//                            Image(systemName: "asterisk")
//                                .foregroundColor(.red)
//                                .imageScale(.small)
//                        }

//                        if ![.image, .block, .date, .progress, .table].contains(column.type) && !isHeaderNested {
//                            Image(systemName: "line.3.horizontal.decrease.circle")
//                                .foregroundColor(viewModel.tableDataModel.filterModels[index].filterText.isEmpty ? Color.gray : Color.blue)
//                        }
                    }
                    .padding(.all, 4)
                    .font(.system(size: 15))
                    .frame(width: viewModel.cellWidthMap[column.id ?? ""])
                    .frame(height: 60)
                    .overlay(
                        Rectangle()
                            .stroke(currentSelectedCol != index || isHeaderNested ? Color.tableCellBorderColor : Color.blue, lineWidth: 1)
                    )
                    .background(
                        colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor
                    )
//                })
                .zIndex(currentSelectedCol == index ? 1 : 0)
                .accessibilityIdentifier("ColumnButtonIdentifier")
//                .disabled([.image, .block, .date, .progress, .table].contains(column.type ?? .unknown) || viewModel.tableDataModel.cellModels.count == 0 || isHeaderNested)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 1)
    }
}

struct CollectionRowsHeaderView: View {
    @ObservedObject var viewModel: CollectionViewModel
    @Binding var rowModel: RowDataModel
    let colorScheme: ColorScheme
    let index: Int

    var body: some View {
        let rowArray = rowModel.cells
        let isLastRow = index == viewModel.tableDataModel.filteredcellModels.count - 1
        HStack(spacing: 0) {
            // Expand Button View
            if viewModel.nestedTableCount > 0 {
                switch rowModel.rowType {
                case .header(level: let level, tableColumns: let columns):
                    if level == 0 {
                        EmptyRectangleView(colorScheme: colorScheme, width: 40, height: 60, isLastRow: isLastRow)
                    } else {
                        ForEach(0..<2*level - level, id: \.self) { _ in
                            EmptyRectangleView(colorScheme: colorScheme, width: 40, height: 60, isLastRow: isLastRow)
                        }
                    }
                    EmptyRectangleWithBorders(colorScheme: colorScheme, width: 40, height: 60)
                case .row(index: let index):
                    if let childrens = viewModel.tableDataModel.schema[viewModel.rootSchemaKey]?.children {
                        if !childrens.isEmpty {
                            Image(systemName: rowModel.isExpanded ? "chevron.down.square" : "chevron.right.square")
                                .frame(width: 40, height: 60)
                                .border(Color.tableCellBorderColor)
                                .background(rowModel.isExpanded ? (colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor) : (colorScheme == .dark ? Color.black.opacity(0.8) : .white))
                                .onTapGesture {
                                    viewModel.expandTables(rowDataModel: rowModel, level: 0)
                                }
                                .accessibilityIdentifier("CollectionExpandCollapseButton\(index)")
                        }
                    } else {
                        EmptyRectangleWithBorders(colorScheme: colorScheme, width: 40, height: 60)
                    }

                case .nestedRow(level: let level, index: let nestedIndex, _, parentSchemaKey: let parentSchemaKey):
                    HStack(spacing: 0) {
                        if level == 0 {
                            EmptyRectangleView(colorScheme: colorScheme, width: 40, height: 60, isLastRow: isLastRow)
                        } else {
                            ForEach(0..<2*level - level, id: \.self) { _ in
                                EmptyRectangleView(colorScheme: colorScheme, width: 40, height: 60, isLastRow: isLastRow)
                            }
                        }
                        if let childrens = viewModel.tableDataModel.schema[parentSchemaKey]?.children {
                            if !childrens.isEmpty {
                                Image(systemName: rowModel.isExpanded ? "chevron.down.square" : "chevron.right.square")
                                    .frame(width: 40, height: 60)
                                    .border(Color.tableCellBorderColor)
                                    .onTapGesture {
                                        viewModel.expandTables(rowDataModel: rowModel, level: level)
                                    }
                            } else {
                                EmptyRectangleWithBorders(colorScheme: colorScheme, width: 40, height: 60)
                            }
                        }
                    }
                case .tableExpander(schemaValue: let schemaValue, level: let level, parentID: let parentID, _):
                    let backgroundColor = (colorScheme == .dark)
                    ? Color.black.opacity(0.8)
                    : Color.tableColumnBgColor

                    HStack(spacing: 0){
                        if level == 0 {
                            EmptyRectangleView(colorScheme: colorScheme, width: 40, height: 60, isLastRow: isLastRow)
                        } else {
                            ForEach(0..<2*level + 1 - level, id: \.self) { _ in
                                EmptyRectangleView(colorScheme: colorScheme, width: 40, height: 60, isLastRow: isLastRow)

                            }
                        }
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

                }
            case .header:
                if viewModel.showRowSelector {
                    Image(systemName: viewModel.tableDataModel.allNestedRowSelected(rowID: rowModel.rowID) ? "circle.square.fill" : "square")
                        .frame(width: 40, height: 60)
                        .foregroundColor(viewModel.tableDataModel.getAllNestedRowsForRow(rowID: rowModel.rowID).count == 0 ? Color.gray.opacity(0.4) : nil)
                        .border(Color.tableCellBorderColor)
                        .onTapGesture {
                            if !viewModel.tableDataModel.allNestedRowSelected(rowID: rowModel.rowID) {
                                viewModel.tableDataModel.selectAllNestedRows(rowID: rowModel.rowID)
                            } else {
                                viewModel.tableDataModel.emptySelection()
                            }
                        }
                        .disabled(viewModel.tableDataModel.getAllNestedRowsForRow(rowID: rowModel.rowID).count == 0)
                }
            case .nestedRow(let level, let index, _, _):
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
            case .tableExpander:
                EmptyView()
            }

            // Indexing View
            switch rowModel.rowType {
            case .header:
                Text("#")
                    .frame(width: 40, height: 60)
                    .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
                    .border(Color.tableCellBorderColor)
            case .nestedRow(let level, let nastedRowIndex, let parentID, let parentSchemaKey):
                if !viewModel.isRowValid(for: rowModel.rowID, parentSchemaID: parentSchemaKey) {
                    Image(systemName: "asterisk")
                        .foregroundColor(.red)
                        .imageScale(.small)
                        .frame(width: 40, height: 60)
                        .border(Color.tableCellBorderColor)
                } else {
                    Text("\(nastedRowIndex)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .frame(width: 40, height: 60)
                        .border(Color.tableCellBorderColor)
                }
            case .row(let rowIndex):
                if  !viewModel.isRowValid(for: rowModel.rowID, parentSchemaID: viewModel.rootSchemaKey) {
                    Image(systemName: "asterisk")
                        .foregroundColor(.red)
                        .imageScale(.small)
                        .frame(width: 40, height: 60)
                        .border(Color.tableCellBorderColor)
                } else {
                    Text("\(rowIndex)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .frame(width: 40, height: 60)
                        .border(Color.tableCellBorderColor)
                }
            case .tableExpander:
                EmptyView()
            }
        }
    }
}

struct EmptyRectangleView: View {
    let colorScheme: ColorScheme
    let width: CGFloat
    let height: CGFloat
    let isLastRow: Bool

    var body: some View {
        Rectangle()
            .fill(colorScheme == .dark ? Color.black.opacity(0.8) : .white)
            .frame(width: width, height: height)
            .verticalBorder(color: Color.tableCellBorderColor, includeBottom: isLastRow)
    }
}

struct EmptyRectangleWithBorders: View {
    let colorScheme: ColorScheme
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Rectangle()
            .fill(colorScheme == .dark ? Color.black.opacity(0.8) : .white)
            .frame(width: width, height: height)
            .border(Color.tableCellBorderColor)
    }
}
struct CollectionRowsView: View {
    @ObservedObject var viewModel: CollectionViewModel
    @Binding var currentSelectedCol: Int
    let longestBlockText: String
    let colorScheme: ColorScheme

    var body: some View {
        ForEach(Array(zip(viewModel.tableDataModel.filteredcellModels.indices, $viewModel.tableDataModel.filteredcellModels)), id: \.0) { index, $rowDataModel in
            HStack(spacing: 0) {
                CollectionRowsHeaderView(
                    viewModel: viewModel,
                    rowModel: $rowDataModel,
                    colorScheme: colorScheme,
                    index: index
                )

                switch rowDataModel.rowType {
                case .row, .nestedRow:
                    CollectionRowView(
                        viewModel: viewModel,
                        rowDataModel: $rowDataModel,
                        longestBlockText: longestBlockText
                    )
                    .frame(height: 60)

                case .header(_, let tableColumns):
                    CollectionColumnHeaderView(
                        viewModel: viewModel,
                        tableColumns: tableColumns ?? [],
                        currentSelectedCol: $currentSelectedCol,
                        colorScheme: colorScheme,
                        isHeaderNested: true
                    )
                    .frame(height: 60)

                case .tableExpander(let schemaValue, let level, let parentID, _):
                    CollectionExpanderView(
                        rowDataModel: $rowDataModel,
                        schemaValue: schemaValue,
                        viewModel: viewModel,
                        level: level,
                        parentID: parentID ?? ("", "")
                    )
                    .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
                }
            }
        }
    }
}

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

fileprivate extension Array {
    subscript(safe index: Index) -> Element {
        get {
            guard indices.contains(index) else {
                print("⚠️  Array safe subscript out of range: index \(index), count \(count)")
                fatalError("")
            }
            print("✅  Array safe subscript ok: index \(index), count \(count)")
            return self[index]
        }
        set {
//            guard let newValue = newValue, indices.contains(index) else {
//                fatalError("")
//            }
            self[index] = newValue
        }
    }
}


