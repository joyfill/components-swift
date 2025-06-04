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
                        
                    Spacer()
                    
                    Button(action: {
                        applyFilters()
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
                        
                    Menu {
                        ForEach(Array(viewModel.tableDataModel.schema), id: \.key) { key, value in
                            Button("\(value.title ?? "")") {
                                selectedSchemaKey = key
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
        .font(.system(size: 15, weight: .bold))
    }
    
    private var sortingView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Sort")
                   
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
                }
            }
            
            Button(action: {
                
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
                if let index = viewModel.tableDataModel.filterModels.firstIndex(where: { $0.colID == selectedFilterColumnID }) {
//                    if let colIndex = viewModel.tableDataModel.filterTableColumns(key: selectedSchemaKey).firstIndex(where: {$0.id == selectedFilterColumnID }) {
                        CollectionSearchBar(model: $viewModel.tableDataModel.filterModels[index],
                                            selectedColumnIndex: $selectedColumnIndex,
                                            viewModel: viewModel)
//                    }
                }
            }
            
            Button(action: {
                
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
        // Load current filter state
        for (index, column) in viewModel.tableDataModel.tableColumns.enumerated() {
            if index < viewModel.tableDataModel.filterModels.count {
                let filterModel = viewModel.tableDataModel.filterModels[index]
                if !filterModel.filterText.isEmpty {
                    selectedFilters[column.id ?? ""] = filterModel.filterText
                }
            }
        }
    }
    
    private func clearColumnFilters() {
        selectedFilters.removeAll()
    }
    
    private func applyFilters() {
        // Clear existing filters first
        for i in 0..<viewModel.tableDataModel.filterModels.count {
            viewModel.tableDataModel.filterModels[i].filterText = ""
        }
        
        // Apply global search - set search text to all text-based columns
        if !searchText.isEmpty {
            for (index, column) in viewModel.tableDataModel.tableColumns.enumerated() {
                if index < viewModel.tableDataModel.filterModels.count {
                    switch column.type {
                    case .text, .barcode:
                        viewModel.tableDataModel.filterModels[index].filterText = searchText
                    default:
                        break
                    }
                }
            }
        }
        
        // Apply column-specific filters (will override global search for specific columns)
        for (index, column) in viewModel.tableDataModel.tableColumns.enumerated() {
            if let filterText = selectedFilters[column.id ?? ""], !filterText.isEmpty {
                if index < viewModel.tableDataModel.filterModels.count {
                    viewModel.tableDataModel.filterModels[index].filterText = filterText
                }
            }
        }
        
        // Trigger filtering
        viewModel.tableDataModel.filterRowsIfNeeded()
    }
    
    private func clearAllFilters() {
        searchText = ""
        selectedFilters.removeAll()
        
        // Clear all filter models
        for i in 0..<viewModel.tableDataModel.filterModels.count {
            viewModel.tableDataModel.filterModels[i].filterText = ""
        }
        
        // Reset filtered results
        viewModel.tableDataModel.filteredcellModels = viewModel.tableDataModel.cellModels
    }
}
