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
            ForEach($rowDataModel.cells, id: \.id) { $cellModel in
                ZStack {
                    Rectangle()
                        .stroke()
                        .foregroundColor(Color.tableCellBorderColor)
                    CollectionViewCellBuilder(viewModel: viewModel, cellModel: $cellModel)
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

struct CollectionModalView : View {
    @State private var offset = CGPoint.zero
    @ObservedObject var viewModel: CollectionViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showEditMultipleRowsSheetView: Bool = false
    @State private var columnHeights: [Int: CGFloat] = [:] // Dictionary to hold the heights for each column
    @State private var textHeight: CGFloat = 50 // Default height
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
                CollectionEditMultipleRowsSheetView(viewModel: viewModel)
            }
            .padding(EdgeInsets(top: 16, leading: 10, bottom: 10, trailing: 10))
            if currentSelectedCol != Int.min {
                CollectionSearchBar(model: $viewModel.tableDataModel.filterModels [currentSelectedCol], sortModel: $viewModel.tableDataModel.sortModel, selectedColumnIndex: $currentSelectedCol, viewModel: viewModel)
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
                HStack(alignment: .center, spacing: 0) {
                    Text("#")
                        .frame(width: 40, height: textHeight)
                        .border(Color.tableCellBorderColor)
                }
                .frame(minHeight: 50)
                .frame(width: 40)
                .border(Color.tableCellBorderColor)
                .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
                .cornerRadius(14, corners: [.topLeft], borderColor: Color.tableCellBorderColor)
                
                if #available(iOS 16, *) {
                    ScrollView([.vertical], showsIndicators: false) {
                        rowsHeader
                            .frame(width: 40)
                            .offset(y: offset.y)
                    }
                    .simultaneousGesture(DragGesture(minimumDistance: 0), including: .all)
                    .scrollDisabled(true)
                } else {
                    ScrollView([.vertical], showsIndicators: false) {
                        rowsHeader
                            .frame(width: 40)
                            .offset(y: offset.y)
                    }
                    .simultaneousGesture(DragGesture(minimumDistance: 0), including: .all)
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                if #available(iOS 16, *) {
                    ScrollView([.horizontal], showsIndicators: false) {
                        HStack(spacing: 0) {
                            rowSelectorHeader
                            
                            CollectionColumnHeaderView(viewModel: viewModel,
                                                  tableColumns: viewModel.tableDataModel.tableColumns,
                                                  currentSelectedCol: $currentSelectedCol,
                                                  textHeight: $textHeight,
                                                  colorScheme: colorScheme,
                                                  columnHeights: $columnHeights,
                                                  longestBlockText: longestBlockText,
                                                  isHeaderNested: false)
                            .offset(x: offset.x)
                        }
                    }
                    .background(Color.tableCellBorderColor)
                    .cornerRadius(14, corners: [.topRight], borderColor: Color.tableCellBorderColor)
                    .scrollDisabled(true)
                } else {
                    ScrollView([.horizontal], showsIndicators: false) {
                        HStack(spacing: 0) {
                            rowSelectorHeader
                            
                            CollectionColumnHeaderView(viewModel: viewModel,
                                                       tableColumns: viewModel.tableDataModel.tableColumns,
                                                       currentSelectedCol: $currentSelectedCol,
                                                       textHeight: $textHeight,
                                                       colorScheme: colorScheme,
                                                       columnHeights: $columnHeights,
                                                       longestBlockText: longestBlockText,
                                                       isHeaderNested: false)
                            .offset(x: offset.x)
                        }
                    }
                    .background(Color.tableCellBorderColor)
                    .cornerRadius(14, corners: [.topRight], borderColor: Color.tableCellBorderColor)
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
        }
        .frame(minHeight: 50)
        .frame(width: viewModel.showRowSelector ? (viewModel.nestedTableCount > 0 ? 80 : 40) : 0, height: textHeight)
        .border(Color.tableCellBorderColor)
        .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
        .offset(x: offset.x)
    }
    
    var rowsHeader: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
           ForEach(Array($viewModel.tableDataModel.filteredcellModels.enumerated()), id: \.offset) { (index, $rowModel) in
                let rowArray = rowModel.cells
               HStack(spacing: 0) {
                   // Indexing View
                   switch rowModel.rowType {
                   case .header:
                       Text("#")
                           .frame(width: 40, height: 60)
                           .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
                           .border(Color.tableCellBorderColor)
                   case .nestedRow(let level, let nastedRowIndex, _):
                       Text("\(nastedRowIndex)")
                           .foregroundColor(.secondary)
                           .font(.caption)
                           .frame(width: 40, height: 60)
                           .border(Color.tableCellBorderColor)
                           .id("\(index)")
                   case .row(let rowIndex):
                       Text("\(rowIndex)")
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
    
    var collection: some View {
        ScrollViewReader { cellProxy in
            GeometryReader { geometry in
                ScrollView([.vertical, .horizontal], showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array($viewModel.tableDataModel.filteredcellModels.enumerated()), id: \.offset) { (index, $rowCellModels) in
                            HStack(spacing: 0) {
                                
                                ColllectionRowsHeaderView(viewModel: viewModel, rowModel: $rowCellModels, colorScheme: colorScheme, index: index)
                                
                                switch rowCellModels.rowType {
                                case .row:
                                    CollectionRowView(viewModel: viewModel, rowDataModel: $rowCellModels, longestBlockText: longestBlockText)
                                    .frame(height: 60)
                                case .nestedRow(level: let level, index: let index, parentID: let parentID):
                                    CollectionRowView(viewModel: viewModel, rowDataModel: $rowCellModels, longestBlockText: longestBlockText)
                                    .frame(height: 60)
                                case .header(level: let level, tableColumns: let tableColumns):
                                    CollectionColumnHeaderView(viewModel: viewModel,
                                                          tableColumns: tableColumns ?? [],
                                                          currentSelectedCol: $currentSelectedCol,
                                                          textHeight: $textHeight,
                                                          colorScheme: colorScheme,
                                                          columnHeights: $columnHeights,
                                                          longestBlockText: longestBlockText,
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
                    //TODO: calculate width acc to tablecolumns
                    .frame(minWidth: 1500, minHeight: geometry.size.height, alignment: .topLeading)
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

struct CollectionExpanderView: View {
    @Binding var rowDataModel: RowDataModel
    var schemaValue: (String, Schema)?
    @ObservedObject var viewModel: CollectionViewModel
    let level: Int
    let parentID: (columnID: String, rowID: String)
    
    var body: some View {
        HStack {
            Text(schemaValue?.1.title ?? "")
                .multilineTextAlignment(.leading)
                .darkLightThemeColor()
            
            Spacer()
            
            if rowDataModel.isExpanded {
                Button(action: {
                    let startingIndex = viewModel.tableDataModel.filteredcellModels.firstIndex(where: { $0.rowID == rowDataModel.rowID }) ?? 0
                    viewModel.addNestedRow(schemaKey: schemaValue?.0 ?? "", level: level, startingIndex: startingIndex, parentID: parentID, childrenSchemaKey: "")
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
        .padding(.all, 4)
        .font(.system(size: 15, weight: .bold))
        .frame(width: rowDataModel.rowType.width, height: 60)
        .border(Color.tableCellBorderColor)
    }
}

struct CollectionColumnHeaderView: View {
    @ObservedObject var viewModel: CollectionViewModel
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
                    .frame(minHeight: 60)
                    .overlay(
                        //TODO: Fix blue border(when select a column for search)
                        Rectangle()
                            .stroke(currentSelectedCol != index || isHeaderNested ? Color.tableCellBorderColor : Color.blue, lineWidth: 1)
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

struct ColllectionRowsHeaderView: View {
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
                       Rectangle()
                           .fill(Color.white)
                           .frame(width: 40, height: 60)
                           .verticalBorder(color: Color.tableCellBorderColor, includeBottom: isLastRow)
                   } else {
                       ForEach(0..<2*level , id: \.self) { _ in
                           Rectangle()
                               .fill(Color.white)
                               .frame(width: 40, height: 60)
                               .verticalBorder(color: Color.tableCellBorderColor, includeBottom: isLastRow)
                       }
                   }
                   Rectangle()
                       .fill(Color.white)
                       .frame(width: 40, height: 60)
                       .border(Color.tableCellBorderColor)
               case .row(index: let index):
                   Image(systemName: rowModel.isExpanded ? "chevron.down.square" : "chevron.right.square")
                       .frame(width: 40, height: 60)
                       .border(Color.tableCellBorderColor)
                       .background(rowModel.isExpanded ? (colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor) : .white)
                       .onTapGesture {
                           viewModel.expandTables(rowDataModel: rowModel, level: 0)
                           rowModel.isExpanded.toggle()
                       }
               case .nestedRow(level: let level, index: let nestedIndex, _):
                   HStack(spacing: 0) {
                       if level == 0 {
                           Rectangle()
                               .fill(Color.white)
                               .frame(width: 40, height: 60)
                               .verticalBorder(color: Color.tableCellBorderColor, includeBottom: isLastRow)
                       } else {
                           ForEach(0..<2*level , id: \.self) { _ in
                               Rectangle()
                                   .fill(Color.white)
                                   .frame(width: 40, height: 60)
                                   .verticalBorder(color: Color.tableCellBorderColor, includeBottom: isLastRow)
                           }
                       }
                       
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
                   }
               case .tableExpander(schemaValue: let schemaValue, level: let level, parentID: let parentID, _):
                   let backgroundColor = (colorScheme == .dark)
                   ? Color.black.opacity(0.8)
                   : Color.tableColumnBgColor
                   
                   HStack(spacing: 0){
                       if level == 0 {
                           Rectangle()
                               .fill(Color.white)
                               .frame(width: 40, height: 60)
                               .verticalBorder(color: Color.tableCellBorderColor, includeBottom: isLastRow)
                       } else {
                           ForEach(0..<2*level + 1, id: \.self) { _ in
                               Rectangle()
                                   .fill(Color.white)
                                   .frame(width: 40, height: 60)
                                   .verticalBorder(color: Color.tableCellBorderColor, includeBottom: isLastRow)
                                   
                           }
                       }
                       
                       Image(systemName: rowModel.isExpanded ? "chevron.down.circle" : "chevron.right.circle")
                           .frame(width: 40, height: 60)
                           .background(backgroundColor)
                           .border(Color.tableCellBorderColor)
                           .onTapGesture {
                               viewModel.expendSpecificTable(rowDataModel: rowModel, parentID: parentID ?? ("", ""), level: level)
                               rowModel.isExpanded.toggle()
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
           case .nestedRow(let level, let index, _):
               let isRowSelected = viewModel.tableDataModel.selectedRows.contains(rowModel.rowID)
               Image(systemName: isRowSelected ? "record.circle.fill" : "circle")
                   .frame(width: 40, height: 60)
                   .border(Color.tableCellBorderColor)
                   .onTapGesture {
                       viewModel.tableDataModel.toggleSelection(rowID: rowArray.first?.rowID ?? "")
                   }
                   .accessibilityIdentifier("MyButton")
           case .tableExpander:
               EmptyView()
           }
       }
    }
}

