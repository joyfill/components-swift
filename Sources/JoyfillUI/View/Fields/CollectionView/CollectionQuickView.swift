//
//  File.swift
//  Joyfill
//
//  Created by Vivek on 14/02/25.
//

import SwiftUI
import JoyfillModel

struct CollectionQuickView : View {
    @State private var offset = CGPoint.zero
    @StateObject private var viewModel: CollectionViewModel
    private let rowHeight: CGFloat = 50
    @Environment(\.colorScheme) var colorScheme
    @State var isTableModalViewPresented = false
    var tableDataModel: TableDataModel
    let eventHandler: FieldChangeEvents
    @State private var refreshID = UUID()
    
    public init(tableDataModel: TableDataModel, eventHandler: FieldChangeEvents) {
        self._viewModel = StateObject(wrappedValue: CollectionViewModel(tableDataModel: tableDataModel))
        self.tableDataModel = tableDataModel
        self.eventHandler = eventHandler
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            FieldHeaderView(tableDataModel.fieldHeaderModel, isFilled: !viewModel.tableDataModel.rowOrder.isEmpty)

            if viewModel.isLoading {
                loadingView
            } else {
                collectionContent
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            HStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.2)
                Text("Loading collection...")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .frame(height: 120)
        }
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.allFieldBorderColor, lineWidth: 1)
        )
    }
    
    private var collectionContent: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    colsHeader
                        .disabled(true)
                        .background(.clear)
                        .cornerRadius(14, corners: [.topRight, .topLeft], borderColor: Color.tableCellBorderColor)
                        .frame(height: rowHeight)
                    
                    collection
                        .cornerRadius(14, corners: [.bottomLeft, .bottomRight], borderColor: Color.tableCellBorderColor)
                }
                .frame(height: min(CGFloat(viewModel.tableDataModel.filteredcellModels.count), 3) * rowHeight + rowHeight)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
            )
            
            Button(action: {
                isTableModalViewPresented = true
                eventHandler.onFocus(event: tableDataModel.fieldIdentifier)
            }, label: {
                HStack(alignment: .center, spacing: 0) {
                    Text("Collection View")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.blue)
                    
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.blue)
                        .font(.system(size: 8, weight: .heavy))
                        .padding(.horizontal, 4)
                    
                    Text(viewModel.tableDataModel.collectionRowsCount)
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
            .accessibilityIdentifier("CollectionDetailViewIdentifier")
            .padding(.top, 6)
            
            NavigationLink(destination: CollectionModalView(viewModel: viewModel), isActive: $isTableModalViewPresented) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
            .hidden()
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
                        Text(viewModel.tableDataModel.getColumnTitle(columnId: col.id ?? ""))
                            .padding(.horizontal, 4)
                    }
                    .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.tableColumnBgColor)
                    .frame(width: geometry.size.width / 3, height: rowHeight)
                }
            }
        }
    }
    
    var collection: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                let rowsDataModels = viewModel.getThreeRowsForQuickView()
                ForEach(rowsDataModels, id: \.self) { rowDataModel in
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(Array(viewModel.tableDataModel.tableColumns.prefix(3).enumerated()), id: \.offset) { index, col in
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
                                CollectionViewCellBuilder(viewModel: viewModel, cellModel: Binding.constant(cellModel))
                            }
                            .frame(width: geometry.size.width / 3, height: rowHeight)
                        }
                    }
                }
            }
            .id(viewModel.uuid)
            .disabled(true)
        }
    }
}
