//
//  CollectionFilterModal.swift
//  Joyfill
//
//  Created by Vivek on 14/02/25.
//

import SwiftUI
import JoyfillModel

struct CollectionFilterModal: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: CollectionViewModel
    @State private var searchText: String = ""
    @State private var selectedFilters: [String: String] = [:]
    @Environment(\.colorScheme) var colorScheme
    @State var selectedSchemaKey: String = ""
    @State var selectedSortedColumnID: String = ""
    @State var selectedFilterColumnID: String = ""
    @State private var selectedColumnIndex: Int = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Main Content
                HStack {
                    Text("Filter")
                        .font(.system(size: 15, weight: .bold))
                        
                    Spacer()
                    
                    Button(action: {
                        viewModel.setupAllCellModels(targetSchema: selectedSchemaKey)
                    }, label: {
                        Text("Expand All")
                            .darkLightThemeColor()
                            .font(.system(size: 12))
                            .frame(width: 80, height: 27)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    })
                    
                    Button(action: {
                        viewModel.setupCellModels()
                    }, label: {
                        Text("Collapse All")
                            .darkLightThemeColor()
                            .font(.system(size: 12))
                            .frame(width: 80, height: 27)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.orange, lineWidth: 1)
                            )
                    })
                    
                    Button(action: {
                        viewModel.tableDataModel.filterRowsIfNeeded(schema: selectedSchemaKey)
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Apply")
                            .darkLightThemeColor()
                            .font(.system(size: 14))
                            .frame(width: 88, height: 27)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
                            )
                    })
                    
                    Button(action: {
                        clearAllFilters()
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.allFieldBorderColor, lineWidth: 1)
                                .frame(width: 27, height: 27)
                            
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 10, height: 10)
                                .darkLightThemeColor()
                        }
                    })
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)
                
                VStack(alignment: .leading, spacing: 12) {
                    // Filter by Column Section
                    Text("Schema type")
                        .font(.system(size: 15, weight: .bold))
                        
                    Menu {
                        ForEach(Array(viewModel.tableDataModel.schema), id: \.key) { key, value in
                            Button("\(value.title ?? "")") {
                                selectedSchemaKey = key
                                // Reset selections when schema changes
                                selectedSortedColumnID = ""
                                selectedFilterColumnID = ""
                                selectedColumnIndex = 0
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedSchemaKey.isEmpty ? "Select schema type" : getSelectedSchemaTitle())
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .background(colorScheme == .dark ? Color.gray.opacity(0.15) : Color.gray.opacity(0.08))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.allFieldBorderColor, lineWidth: 1)
                        )
                    }
                    if !selectedSchemaKey.isEmpty {
                        sortingView
                        
                        filteringView
                    }
                    
                    Spacer()
                }
                .padding(.all, 16)
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
        }
        .onAppear {
            // Initialize with root schema key if not set
            if selectedSchemaKey.isEmpty {
                selectedSchemaKey = viewModel.rootSchemaKey
            }
            loadCurrentFilters()
        }
    }
    
    private var sortingView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Sort")
                    .font(.system(size: 15, weight: .bold))
                   
                HStack {
                    Menu {
                        let columns = viewModel.tableDataModel.filterTableColumns(key: selectedSchemaKey)
                        ForEach(columns, id: \.id) { column in
                            Button("\(column.title ?? "")") {
                                selectedSortedColumnID = column.id ?? ""
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedSortedColumnID.isEmpty ? "Select column type" : getSelectedSortedColumnTitle())
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .background(colorScheme == .dark ? Color.gray.opacity(0.15) : Color.gray.opacity(0.08))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.allFieldBorderColor, lineWidth: 1)
                        )
                    }
                    
                    Button(action: {
                        viewModel.tableDataModel.sortModel.order.next()
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
                    .background(colorScheme == .dark ? Color.gray.opacity(0.15) : Color.gray.opacity(0.08))
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    )
                    .disabled(selectedSortedColumnID.isEmpty)
                }
            }
            
            Button(action: {
                clearSorting()
            }, label: {
                Image(systemName: "minus.circle")
                    .foregroundColor(.red)
            })
        }
        .padding(.all, 8)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.allFieldBorderColor, lineWidth: 1)
        )
        
    }
    
    private var filteringView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Filter")
                    .font(.system(size: 15, weight: .bold))
                
                Menu {
                    let columns = viewModel.tableDataModel.filterTableColumns(key: selectedSchemaKey)
                    ForEach(columns, id: \.id) { column in
                        Button("\(column.title ?? "")") {
                            selectedFilterColumnID = column.id ?? ""
                            selectedColumnIndex = columns.firstIndex(where: { column.id == $0.id }) ?? 0
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedFilterColumnID.isEmpty ? "Select column type" : getSelectedFilteredColumnTitle())
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background(colorScheme == .dark ? Color.gray.opacity(0.15) : Color.gray.opacity(0.08))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    )
                }
                if let index = viewModel.tableDataModel.filterModels.firstIndex(where: { $0.colID == selectedFilterColumnID && $0.schemaKey == selectedSchemaKey }) {
                    if let column = getSelectedColumn() {
                        CollectionSearchBar(
                            model: $viewModel.tableDataModel.filterModels[index],
                            column: column,
                            viewModel: viewModel
                        )
                    }
                }
            }
            
            Button(action: {
                clearFilterForColumn()
            }, label: {
                Image(systemName: "minus.circle")
                    .foregroundColor(.red)
            })
            .disabled(selectedFilterColumnID.isEmpty)
        }
        .padding(.all, 8)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.allFieldBorderColor, lineWidth: 1)
        )
    }
    
    func getSortIcon() -> String {
        switch viewModel.tableDataModel.sortModel.order {
        case .ascending:
            return "arrow.up"
        case .descending:
            return "arrow.down"
        case .none:
            return "arrow.up.arrow.down"
        }
    }
    
    func getIconColor() -> Color {
        switch viewModel.tableDataModel.sortModel.order {
        case .none:
            return .black
        case .ascending, .descending:
            return .blue
        }
    }
    
    func getSelectedColumn() -> FieldTableColumn? {
        viewModel.tableDataModel.filterTableColumns(key: selectedSchemaKey).first(where: { $0.id == selectedFilterColumnID })
    }
            
    private func getSelectedSchemaTitle() -> String {
        let schema = viewModel.tableDataModel.schema
        return schema[selectedSchemaKey]?.title ?? ""
    }
    
    private func getSelectedSortedColumnTitle() -> String {
        let tableColumns = viewModel.tableDataModel.filterTableColumns(key: selectedSchemaKey)
        return tableColumns.first(where: {$0.id == selectedSortedColumnID})?.title ?? ""
    }
    
    private func getSelectedFilteredColumnTitle() -> String {
        let tableColumns = viewModel.tableDataModel.filterTableColumns(key: selectedSchemaKey)
        return tableColumns.first(where: {$0.id == selectedFilterColumnID})?.title ?? ""
    }
        
    private var hasActiveColumnFilters: Bool {
        return selectedFilters.values.contains { !$0.isEmpty }
    }
    
    private func loadCurrentFilters() {
        // Load current filter state for the selected schema
        let schemaFilters = viewModel.tableDataModel.filterModels.filter { $0.schemaKey == selectedSchemaKey }
        for filterModel in schemaFilters {
            if !filterModel.filterText.isEmpty {
                selectedFilters[filterModel.colID] = filterModel.filterText
            }
        }
    }
    
    private func clearColumnFilters() {
        selectedFilters.removeAll()
    }
    
    private func clearSorting() {
        selectedSortedColumnID = ""
        viewModel.tableDataModel.sortModel.order = .none
    }
    
    private func clearFilterForColumn() {
        guard !selectedFilterColumnID.isEmpty else { return }
        
        if let index = viewModel.tableDataModel.filterModels.firstIndex(where: { $0.colID == selectedFilterColumnID && $0.schemaKey == selectedSchemaKey }) {
            viewModel.tableDataModel.filterModels[index].filterText = ""
        }
        
        selectedFilters.removeValue(forKey: selectedFilterColumnID)
        selectedFilterColumnID = ""
        selectedColumnIndex = 0
        
        viewModel.tableDataModel.filterRowsIfNeeded(schema: selectedSchemaKey)
    }
    
    private func clearAllFilters() {
        searchText = ""
        selectedFilters.removeAll()
        
        // Clear filter models for the selected schema only
        for i in 0..<viewModel.tableDataModel.filterModels.count {
            if viewModel.tableDataModel.filterModels[i].schemaKey == selectedSchemaKey {
                viewModel.tableDataModel.filterModels[i].filterText = ""
            }
        }
        
        // Reset filtered results
        viewModel.tableDataModel.filteredcellModels = viewModel.tableDataModel.cellModels
        
        // Clear selections
        selectedFilterColumnID = ""
        selectedSortedColumnID = ""
        selectedColumnIndex = 0
        
        // Reset sort order
        viewModel.tableDataModel.sortModel.order = .none
    }
}
