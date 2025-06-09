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
    @ObservedObject private var viewModel: CollectionViewModel
    private let rowHeight: CGFloat = 50
    @Environment(\.colorScheme) var colorScheme
    @State var isTableModalViewPresented = false
    var tableDataModel: TableDataModel
    let eventHandler: FieldChangeEvents
    @State private var refreshID = UUID()
    
    public init(tableDataModel: TableDataModel, eventHandler: FieldChangeEvents) {
        self.viewModel = CollectionViewModel(tableDataModel: tableDataModel)
        self.tableDataModel = tableDataModel
        self.eventHandler = eventHandler
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            FieldHeaderView(tableDataModel.fieldHeaderModel)
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView([.horizontal]) {
                        colsHeader
                            .offset(x: offset.x)
                    }
                    .disabled(true)
                    .background(Color.clear)
                    .cornerRadius(14, corners: [.topRight, .topLeft], borderColor: Color.tableCellBorderColor)
                    
                    collection
                        .id(refreshID)
                        .cornerRadius(14, corners: [.bottomLeft, .bottomRight], borderColor: Color.tableCellBorderColor)
                }
                .frame(maxHeight:
                        (CGFloat((viewModel.tableDataModel.cellModels.isEmpty ? 2:  viewModel.tableDataModel.cellModels.count)) * rowHeight + rowHeight)
                )
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
            )
            
            Button(action: {
                isTableModalViewPresented.toggle()
                eventHandler.onFocus(event: tableDataModel.fieldIdentifier)
            }, label: {
                HStack(alignment: .center, spacing: 0) {
                    Text("Collection View")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.blue)
                    
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.blue)
                        .font(.system(size: 8, weight: .heavy))
                        .padding(EdgeInsets(top: 2, leading: 2, bottom: 0, trailing: 8))
                    
                    Text(viewModel.tableDataModel.viewMoreText)
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
        .onAppear() {
            refreshID = UUID()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            // Handle orientation changes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                offset = CGPoint.zero // Reset scroll offset on rotation
                refreshID = UUID() // Force refresh of table
            }
        }
    }
    
    var colsHeader: some View {
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
                .frame(width: (UIScreen.main.bounds.width / 3) - 8, height: rowHeight)
            }
        }
    }
    
    var collection: some View {
        VStack(alignment: .leading, spacing: 0) {
            let rowsDataModels = viewModel.getThreeRowsForQuickView()
            ForEach(rowsDataModels, id: \.self) { rowDataModel in
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(viewModel.tableDataModel.tableColumns.prefix(3).enumerated()), id: \.offset) { index, col in
                        let cell = rowDataModel.cells[index]
                        
                        let cellModel = TableCellModel(rowID: cell.rowID,
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
                        .frame(width: (UIScreen.main.bounds.width / 3) - 8, height: rowHeight)
                    }
                }
            }
        }
        .id(viewModel.uuid)
        .disabled(true)
    }
}

