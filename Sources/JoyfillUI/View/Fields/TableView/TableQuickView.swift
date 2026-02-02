//
//  SwiftUIView.swift
//
//
//  Created by Nand Kishore on 04/03/24.
//

import SwiftUI
import JoyfillModel

struct TableQuickView : View {
    @State private var offset = CGPoint.zero
    @State var showEditMultipleRowsSheetView: Bool = false
    private let screenWidth = UIScreen.main.bounds.width
    @StateObject private var viewModel: TableViewModel
    private let rowHeight: CGFloat = 50
    @Environment(\.colorScheme) var colorScheme
    @State var isTableModalViewPresented = false
    var tableDataModel: TableDataModel
    let eventHandler: FieldChangeEvents

    public init(tableDataModel: TableDataModel, eventHandler: FieldChangeEvents) {
        self._viewModel = StateObject(wrappedValue: TableViewModel(tableDataModel: tableDataModel))
        self.tableDataModel = tableDataModel
        self.eventHandler = eventHandler
    }
        
    fileprivate func openTable() {
        isTableModalViewPresented = true
        
        if tableDataModel.mode == .fill {
            eventHandler.onFocus(event: tableDataModel.fieldIdentifier)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            FieldHeaderView(tableDataModel.fieldHeaderModel, isFilled: !viewModel.tableDataModel.rowOrder.isEmpty)
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    colsHeader
                        .disabled(true)
                        .background(Color.clear)
                        .cornerRadius(14, corners: [.topRight, .topLeft], borderColor: Color.tableCellBorderColor)
                        .frame(height: rowHeight)
                    
                    table
                        .cornerRadius(14, corners: [.bottomLeft, .bottomRight], borderColor: Color.tableCellBorderColor)
                }
                .frame(height: min(CGFloat(viewModel.tableDataModel.filteredcellModels.count), 3) * rowHeight + rowHeight)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
            )
            
            Button(action: {
                self.showEditMultipleRowsSheetView = false
                openTable()
            }, label: {
                HStack(alignment: .center, spacing: 0) {
                    Text("Table View")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.blue)
                    
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.blue)
                        .font(.system(size: 8, weight: .heavy))
                        .padding(EdgeInsets(top: 2, leading: 2, bottom: 0, trailing: 8))
                    
                    Text(viewModel.tableDataModel.viewMoreText)
                        .darkLightThemeColor()
                        .font(.system(size: 16))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
            })
            .accessibilityIdentifier("TableDetailViewIdentifier")
            .padding(.top, 6)
            
            NavigationLink(destination: TableModalView(viewModel: viewModel, showEditMultipleRowsSheetView: showEditMultipleRowsSheetView), isActive: $isTableModalViewPresented) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
            .hidden()
        }
        .onChange(of: viewModel.tableDataModel.documentEditor?.navigationTarget) { newValue in
            // Check if this navigation is for THIS table field
            guard let fieldID = newValue?.fieldID,
                  fieldID == tableDataModel.fieldIdentifier.fieldID,
                  let rowId = newValue?.rowId,
                  !rowId.isEmpty else {
                return
            }
            
            // This navigation is for this table - open modal with selected row
            viewModel.tableDataModel.selectedRows = [rowId]
            if let open = newValue?.openRowForm {
                showEditMultipleRowsSheetView = open
            }
            
            openTable()
        }
    }
    
    var colsHeader: some View {
        GeometryReader { geometry in
            HStack(alignment: .top, spacing: 0) {
                ForEach(viewModel.tableDataModel.tableColumns.prefix(3), id: \.id) { col in
                    ZStack {
                        Rectangle()
                            .stroke()
                            .foregroundColor(Color.tableCellBorderColor)
                        Text(viewModel.tableDataModel.getColumnTitle(columnId: col.id!))
                            .padding(.horizontal, 4)
                    }
                    .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
                    .frame(width: geometry.size.width / 3, height: rowHeight)
                }
            }
        }
    }
    
    var table: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                let rowsDataModels = viewModel.getThreeRowsForQuickView()
                ForEach(rowsDataModels, id: \.self) { rowDataModel in
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(Array(viewModel.tableDataModel.tableColumns.prefix(3).enumerated()), id: \.offset) { index, col in
                            if rowDataModel.cells.indices.contains(index) {
                                let cell = rowDataModel.cells[index]

                                let cellModel = TableCellModel(rowID: cell.rowID,
                                                               timezoneId: cell.timezoneId,
                                                               data: cell.data,
                                                               documentEditor: viewModel.tableDataModel.documentEditor,
                                                               fieldIdentifier: viewModel.tableDataModel.fieldIdentifier,
                                                               viewMode: .quickView,
                                                               editMode: viewModel.tableDataModel.mode,
                                                               didChange: nil)
                                ZStack {
                                    Rectangle()
                                        .stroke()
                                        .foregroundColor(Color.tableCellBorderColor)
                                    TableViewCellBuilder(viewModel: viewModel, cellModel: Binding.constant(cellModel))
                                }
                                .frame(width: geometry.size.width / 3, height: rowHeight)
                            }
                        }
                    }
                }
            }
            .id(viewModel.uuid)
            .disabled(true)
        }
    }
}

