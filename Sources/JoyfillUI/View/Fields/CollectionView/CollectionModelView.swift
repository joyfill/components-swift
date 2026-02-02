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
    var isSelected: Bool = false

    var body: some View {
        LazyHStack(alignment: .top, spacing: 0) {
            ForEach($rowDataModel.cells, id: \.id) { $cellModel in
                let column = viewModel.columnsMap[cellModel.data.id]
                let showRequired = (column?.required ?? false) && !cellModel.data.isCellFilled

                CollectionViewCellBuilder(viewModel: viewModel, cellModel: $cellModel)
                    .frame(width: 200, height: 60)
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

struct CollectionModalView : View {
    @ObservedObject var viewModel: CollectionViewModel
    @Environment(\.colorScheme) var colorScheme
    @State var showEditMultipleRowsSheetView: Bool
    @State private var showFilterModal: Bool = false
    let textHeight: CGFloat = 50 // Default height
    @State private var currentSelectedCol: Int = Int.min
    
    init(viewModel: CollectionViewModel, showEditMultipleRowsSheetView: Bool) {
        self.viewModel = viewModel
        self.showEditMultipleRowsSheetView = showEditMultipleRowsSheetView
    }

    var body: some View {
        VStack {
            CollectionModalTopNavigationView(
                viewModel: viewModel,
                onEditTap: { showEditMultipleRowsSheetView = true },
                onFilterTap: { showFilterModal = true })
            .sheet(isPresented: $showEditMultipleRowsSheetView) {
                CollectionEditMultipleRowsSheetView(viewModel: viewModel, tableColumns: viewModel.getTableColumnsForSelectedRows())
                    .interactiveDismissDisabled(viewModel.isBulkLoading)
            }
            .sheet(isPresented: $showFilterModal) {
                CollectionFilterModal(viewModel: viewModel)
                    .interactiveDismissDisabled(viewModel.isSearching)
            }
            .padding(EdgeInsets(top: 16, leading: 10, bottom: 10, trailing: 10))

            scrollArea
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
        }
        .onDisappear(perform: {
            viewModel.sendEventsIfNeeded()
        })
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

    var scrollArea: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
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
                    .foregroundColor(viewModel.tableDataModel.filteredcellModels.count == 0 ? Color.gray.opacity(0.4) : nil)
                    .onTapGesture {
                        if !viewModel.tableDataModel.allRowSelected {
                            viewModel.tableDataModel.selectAllRows()
                        } else {
                            viewModel.tableDataModel.emptySelection()
                        }
                    }
                    .disabled(viewModel.tableDataModel.filteredcellModels.count == 0)
                    .accessibilityIdentifier("SelectParentAllRowSelectorButton")
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
        .frame(minHeight: 60)
        .frame(width: viewModel.showRowSelector ? (viewModel.nestedTableCount > 0 ? (viewModel.showSingleClickEditButton ? 160 : 120) : (viewModel.showSingleClickEditButton ? 120 : 80)) : (viewModel.nestedTableCount > 0 ? (viewModel.showSingleClickEditButton ? 120 : 80) : (viewModel.showSingleClickEditButton ? 80 : 40)), height: 60)
        .border(Color.tableCellBorderColor)
        .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.tableColumnBgColor)
    }

    var collection: some View {
        ScrollViewReader { cellProxy in
            GeometryReader { geometry in
                ScrollView([.vertical, .horizontal], showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        let rootSchema = viewModel.tableDataModel.schema[viewModel.rootSchemaKey]
                        RootTitleRowView(viewModel: viewModel, textHeight: textHeight, colorScheme: colorScheme, rootSchema: rootSchema)
                            .cornerRadius(14, corners: [.topLeft, .topRight], borderColor: Color.tableCellBorderColor)
                        
                        HStack(spacing: 0) {
                            rowSelectorHeader
                            
                            CollectionColumnHeaderView(viewModel: viewModel,
                                                       tableColumns: viewModel.tableDataModel.tableColumns,
                                                       currentSelectedCol: $currentSelectedCol,
                                                       colorScheme: colorScheme,
                                                       isHeaderNested: false)
                        }
                        
                        var safeFilteredModels = viewModel.tableDataModel.filteredcellModels
                        ForEach(Array(safeFilteredModels.enumerated()), id: \.element.rowID) { (index, rowCellModels) in
                            if index < safeFilteredModels.count {
                                HStack(spacing: 0) {
                                    let bindingRowModel = Binding(get: {
                                        safeFilteredModels[index]
                                    }, set: { newValue in
                                        if index < viewModel.tableDataModel.filteredcellModels.count {
                                            viewModel.tableDataModel.filteredcellModels[index] = newValue
                                            safeFilteredModels[index] = newValue
                                        } else {
                                            Log("Row not found at this index ", type: .error)
                                        }
                                    })
                                    CollectionRowsHeaderView(viewModel: viewModel, rowModel: bindingRowModel, colorScheme: colorScheme, index: index, showEditMultipleRowsSheetView: $showEditMultipleRowsSheetView)
                                    
                                    let isRowSelected = viewModel.tableDataModel.selectedRows.contains(rowCellModels.rowID)
                                    switch rowCellModels.rowType {
                                    case .row:
                                        CollectionRowView(viewModel: viewModel, rowDataModel: bindingRowModel, isSelected: isRowSelected)
                                            .frame(height: 60)
                                    case .nestedRow(level: let level, index: let index, parentID: let parentID, _):
                                        CollectionRowView(viewModel: viewModel, rowDataModel: bindingRowModel, isSelected: isRowSelected)
                                            .frame(height: 60)
                                    case .header(level: let level, tableColumns: let tableColumns):
                                        CollectionColumnHeaderView(viewModel: viewModel,
                                                                   tableColumns: tableColumns ?? [],
                                                                   currentSelectedCol: $currentSelectedCol,
                                                                   colorScheme: colorScheme,
                                                                   isHeaderNested: true)
                                        .frame(height: 60)
                                    case .tableExpander(schemaValue: let schemaValue, level: let level, parentID: let parentID, _):
                                        CollectionExpanderView(rowDataModel: bindingRowModel, schemaValue: schemaValue, viewModel: viewModel, level: level, parentID: parentID ?? ("",""))
                                            .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.tableColumnBgColor)
                                    }
                                }
                            }
                        }

                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minWidth: max(viewModel.collectionWidth, geometry.size.width), minHeight: geometry.size.height, alignment: .topLeading)
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
//                    viewModel.tableDataModel.filteredcellModels = viewModel.tableDataModel.cellModels
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
            let schemaID = schemaValue?.0 ?? ""
            let rowSchemaID = RowSchemaID(rowID: rowID, schemaID: schemaID)
            let childRows = viewModel.parentToChildRowMap[rowSchemaID] ?? []
            
            if !viewModel.isOnlySchemaValid(schemaID: schemaValue?.0 ?? "", rows: childRows) {
                Image(systemName: "asterisk")
                    .foregroundColor(.red)
                    .imageScale(.small)
                    .padding(.leading, 8)
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
                    .padding(.leading, 8)
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
        .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.tableColumnBgColor)
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
                    .frame(width: 200)
                    .frame(height: 60)
                    .overlay(
                        Rectangle()
                            .stroke(currentSelectedCol != index || isHeaderNested ? Color.tableCellBorderColor : Color.blue, lineWidth: 1)
                    )
                    .background(
                        colorScheme == .dark ? Color(UIColor.systemGray6) : Color.tableColumnBgColor
                    )
//                })
                .zIndex(currentSelectedCol == index ? 1 : 0)
                .accessibilityIdentifier("ColumnButtonIdentifier")
//                .disabled([.image, .block, .date, .progress, .table].contains(column.type ?? .unknown) || viewModel.tableDataModel.cellModels.count == 0 || isHeaderNested)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(width: viewModel.collectionWidth, alignment: .leading)
        .padding(.vertical, 1)
    }
}

struct CollectionRowsHeaderView: View {
    @ObservedObject var viewModel: CollectionViewModel
    @Binding var rowModel: RowDataModel
    let colorScheme: ColorScheme
    let index: Int
    @Binding var showEditMultipleRowsSheetView: Bool

    var body: some View {
        let rowArray = rowModel.cells
        let isLastRow = index == viewModel.tableDataModel.filteredcellModels.count - 1
        let isRowSelected = viewModel.tableDataModel.selectedRows.contains(rowModel.rowID)
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
                                .background(rowModel.isExpanded ? (colorScheme == .dark ? Color(UIColor.systemGray6) : Color.tableColumnBgColor) : (colorScheme == .dark ? Color(UIColor.systemGray6) : .white))
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
                                    .background(rowModel.isExpanded ? (colorScheme == .dark ? Color(UIColor.systemGray6) : Color.tableColumnBgColor) : (colorScheme == .dark ? Color(UIColor.systemGray6) : .white))
                                    .onTapGesture {
                                        viewModel.expandTables(rowDataModel: rowModel, level: level)
                                    }
                                    .accessibilityIdentifier("CollectionExpandCollapseNestedButton\(nestedIndex)")
                            } else {
                                EmptyRectangleWithBorders(colorScheme: colorScheme, width: 40, height: 60)
                            }
                        }
                    }
                case .tableExpander(schemaValue: let schemaValue, level: let level, parentID: let parentID, _):
                    let backgroundColor = (colorScheme == .dark)
                    ? Color(UIColor.systemGray6)
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
                    Image(systemName: isRowSelected ? "record.circle.fill" : "circle")
                        .frame(width: 40, height: 60)
                        .background(Color.rowSelectionBackground(isSelected: isRowSelected, colorScheme: colorScheme))
                        .border(Color.tableCellBorderColor)
                        .onTapGesture {
                            viewModel.tableDataModel.toggleSelectionForCollection(rowID: rowArray.first?.rowID ?? "")
                        }
                        .accessibilityIdentifier("selectRowItem\(index)")
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
                        .accessibilityIdentifier("selectAllNestedRows")
                }
            case .nestedRow(let level, let index, _, _):
                if viewModel.showRowSelector {
                    Image(systemName: isRowSelected ? "record.circle.fill" : "circle")
                        .frame(width: 40, height: 60)
                        .background(Color.rowSelectionBackground(isSelected: isRowSelected, colorScheme: colorScheme))
                        .border(Color.tableCellBorderColor)
                        .onTapGesture {
                            viewModel.tableDataModel.toggleSelectionForCollection(rowID: rowArray.first?.rowID ?? "")
                        }
                        .accessibilityIdentifier("selectNestedRowItem\(index)")
                }
            case .tableExpander:
                EmptyView()
            }

            // Indexing View
            switch rowModel.rowType {
            case .header:
                Text("#")
                    .frame(width: 40, height: 60)
                    .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.tableColumnBgColor)
                    .border(Color.tableCellBorderColor)
                if viewModel.showSingleClickEditButton {
                    Image(systemName: "square.and.pencil")
                        .frame(width: 40, height: 60)
                        .foregroundColor(Color.gray.opacity(0.4))
                        .border(Color.tableCellBorderColor)
                        .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.tableColumnBgColor)
                }
            case .nestedRow(let level, let nastedRowIndex, let parentID, let parentSchemaKey):
                if !viewModel.isRowValid(for: rowModel.rowID, parentSchemaID: parentSchemaKey) {
                    Image(systemName: "asterisk")
                        .foregroundColor(.red)
                        .imageScale(.small)
                        .frame(width: 40, height: 60)
                        .background(Color.rowSelectionBackground(isSelected: isRowSelected, colorScheme: colorScheme))
                        .border(Color.tableCellBorderColor)
                } else {
                    Text("\(nastedRowIndex)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .frame(width: 40, height: 60)
                        .background(Color.rowSelectionBackground(isSelected: isRowSelected, colorScheme: colorScheme))
                        .border(Color.tableCellBorderColor)
                }
                if viewModel.showSingleClickEditButton {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 60)
                        .background(Color.rowSelectionBackground(isSelected: isRowSelected, colorScheme: colorScheme))
                        .border(Color.tableCellBorderColor)
                        .onTapGesture {
                            viewModel.tableDataModel.emptySelection()
                            viewModel.tableDataModel.toggleSelectionForCollection(rowID: rowModel.rowID)
                            showEditMultipleRowsSheetView = true
                        }
                        .accessibilityIdentifier("SingleClickEditNestedButton\(nastedRowIndex)")
                }
            case .row(let rowIndex):
                if  !viewModel.isRowValid(for: rowModel.rowID, parentSchemaID: viewModel.rootSchemaKey) {
                    Image(systemName: "asterisk")
                        .foregroundColor(.red)
                        .imageScale(.small)
                        .frame(width: 40, height: 60)
                        .background(Color.rowSelectionBackground(isSelected: isRowSelected, colorScheme: colorScheme))
                        .border(Color.tableCellBorderColor)
                } else {
                    Text("\(rowIndex)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .frame(width: 40, height: 60)
                        .background(Color.rowSelectionBackground(isSelected: isRowSelected, colorScheme: colorScheme))
                        .border(Color.tableCellBorderColor)
                }
                if viewModel.showSingleClickEditButton {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 60)
                        .background(Color.rowSelectionBackground(isSelected: isRowSelected, colorScheme: colorScheme))
                        .border(Color.tableCellBorderColor)
                        .onTapGesture {
                            viewModel.tableDataModel.emptySelection()
                            viewModel.tableDataModel.toggleSelectionForCollection(rowID: rowModel.rowID)
                            showEditMultipleRowsSheetView = true
                        }
                        .accessibilityIdentifier("SingleClickEditButton\(rowIndex)")
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
            .fill(colorScheme == .dark ? Color(UIColor.systemGray6) : .white)
            .frame(width: width, height: height)
            .border(Color.tableCellBorderColor)
    }
}

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

