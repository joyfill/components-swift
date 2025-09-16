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
    @Environment(\.colorScheme) var colorScheme
    @State var selectedSchemaKey: String = ""
    @State var selectedSortedColumnID: String = ""
    @State var order: SortOder = .none
    @State var totalFiltersCount: Int = 1
    @State var refreshID = UUID()
    @State var collectionFilterModels: [FilterModel] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Main Content
                HStack {
                    Text("Filter")
                        .font(.system(size: 15, weight: .bold))
                        
                    Spacer()
                    
                    Button(action: {
                        Task {
                            viewModel.isSearching = true
                            // Give UI a chance to update
                            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                            
                            viewModel.tableDataModel.filterModels = collectionFilterModels
                            viewModel.tableDataModel.sortModel.colID = selectedSortedColumnID
                            viewModel.tableDataModel.sortModel.schemaKey = selectedSchemaKey
                            viewModel.tableDataModel.sortModel.order = order
                            
                            await MainActor.run {
                                if viewModel.tableDataModel.filterModels.noFilterApplied && viewModel.tableDataModel.sortModel.order == .none {
                                    viewModel.setupAllCellModels(targetSchema: viewModel.rootSchemaKey)
                                } else {
                                    viewModel.setupAllCellModels(targetSchema: selectedSchemaKey)
                                }
                                viewModel.sortRowsIfNeeded()
                                viewModel.isSearching = false
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }, label: {
                        ZStack {
                            if viewModel.isSearching {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                    .frame(width: 88, height: 27)
                            } else {
                                Text("Apply")
                                    .darkLightThemeColor()
                                    .font(.system(size: 14))
                                    .frame(width: 88, height: 27)
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.allFieldBorderColor, lineWidth: 1)
                        )
                    })
                    .disabled(viewModel.isSearching)
                    
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
                    Menu {
                        ForEach(viewModel.getOrderedSchemaKeys(), id: \.self) { key in
                            Button(action: {
                                selectedSchemaKey = key
                                clearAllFilters()
                                refreshID = UUID()
                            }) {
                                Text(viewModel.tableDataModel.schema[key]?.title ?? "")
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
                    .accessibilityIdentifier("SelectSchemaTypeIDentifier")
                    if !selectedSchemaKey.isEmpty {
                        sortingView
                        VStack(alignment: .leading) {
                            ForEach(0..<totalFiltersCount, id: \.self) { i in
                                FilteringView(viewModel: viewModel,
                                              selectedSchemaKey: $selectedSchemaKey,
                                              currentSelectedFilterColumnID: currentFiltersColumnsIDs().indices.contains(i) ? currentFiltersColumnsIDs()[i] : "",
                                              selectedFilterColumnID: currentFiltersColumnsIDs(),
                                              totalFiltersCount: $totalFiltersCount,
                                              refreshID: $refreshID,
                                              collectionFilterModels: $collectionFilterModels)
                            }
                            
                            Button(action: {
                                totalFiltersCount += 1
                            }, label: {
                                Text("+ Add Filter")
                                    .font(.system(size: 12))
                                    .frame(width: 80, height: 27)
                            })
                            .foregroundColor(shouldEnableAddFilter() ? .gray : .blue)
                            .disabled(shouldEnableAddFilter())
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(shouldEnableAddFilter() ? .gray : .blue, lineWidth: 1)
                            )
                            .accessibilityIdentifier("AddMoreFilterButtonIdentifier")
                        }
                    }
                    
                    Spacer()
                }
                .id(refreshID)
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
        .simultaneousGesture(DragGesture().onChanged({ _ in
            dismissKeyboard()
        }))
    }
    
    func shouldEnableAddFilter() -> Bool {
        let allColumnsWhichNeedFilters = viewModel.getFilteredColumns(for: selectedSchemaKey)
        return currentFiltersColumnsIDs().count != totalFiltersCount || allColumnsWhichNeedFilters.count == totalFiltersCount
    }
    
    private var sortingView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Sort")
                    .font(.system(size: 15, weight: .bold))
                    .darkLightThemeColor()
                   
                HStack {
                    Menu {
                        let columns = viewModel.getFilteredColumns(for: selectedSchemaKey)
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
                    .accessibilityIdentifier("CollectionSortColumnSelectorIdentifier")
                    
                    Button(action: {
                        order.next()
                    }, label: {
                        HStack {
                            Text("Sort")
                                .darkLightThemeColor()
                            Image(systemName: getSortIcon())
                                .foregroundColor(getIconColor())
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                    })
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
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
    
    func getSortIcon() -> String {
        switch order {
        case .ascending:
            return "arrow.up"
        case .descending:
            return "arrow.down"
        case .none:
            return "arrow.up.arrow.down"
        }
    }
    
    func getIconColor() -> Color {
        switch order {
        case .none:
            return colorScheme == .dark ? .white : .black
        case .ascending, .descending:
            return .blue
        }
    }
      
    private func getSelectedSchemaTitle() -> String {
        let schema = viewModel.tableDataModel.schema
        return schema[selectedSchemaKey]?.title ?? ""
    }
    
    private func getSelectedSortedColumnTitle() -> String {
        let tableColumns = viewModel.getFilteredColumns(for: selectedSchemaKey)
        return tableColumns.first(where: {$0.id == selectedSortedColumnID})?.title ?? ""
    }
    
    private func loadCurrentFilters() {
        collectionFilterModels = viewModel.tableDataModel.filterModels
        let activeFilters = collectionFilterModels.filter { !$0.filterText.isEmpty }
        selectedSchemaKey = activeFilters.first?.schemaKey ?? viewModel.rootSchemaKey
        
        if activeFilters.count == 0 {
            totalFiltersCount = 1
        } else {
            totalFiltersCount = activeFilters.count
        }
        
        selectedSchemaKey = viewModel.tableDataModel.sortModel.schemaKey == "" ? viewModel.rootSchemaKey : viewModel.tableDataModel.sortModel.schemaKey
        selectedSortedColumnID = viewModel.tableDataModel.sortModel.colID
        order = viewModel.tableDataModel.sortModel.order
    }
    
    private func currentFiltersColumnsIDs() -> [String] {
        var selectedFilterColumnID: [String] = []
        let activeFilters = collectionFilterModels.filter { !$0.filterText.isEmpty }
        for activeFilter in activeFilters {
            selectedFilterColumnID.append(activeFilter.colID)
        }
        return selectedFilterColumnID
    }
        
    private func clearSorting() {
        selectedSortedColumnID = ""
        viewModel.tableDataModel.sortModel.order = .none
        order = .none
        viewModel.tableDataModel.sortModel.colID = ""
        viewModel.tableDataModel.sortModel.schemaKey = ""
    }

    private func clearAllFilters() {
        // Clear filter models for the selected schema only
        for i in 0..<viewModel.tableDataModel.filterModels.count {
            viewModel.tableDataModel.filterModels[i].filterText = ""
        }
        collectionFilterModels = viewModel.tableDataModel.filterModels
        viewModel.tableDataModel.filteredcellModels = viewModel.tableDataModel.filteredcellModels
        selectedSortedColumnID = ""
        totalFiltersCount = 1
        clearSorting()
    }
}
struct FilteringView: View {
    @ObservedObject var viewModel: CollectionViewModel
    @Binding var selectedSchemaKey: String
    @State var currentSelectedFilterColumnID: String
    var selectedFilterColumnID: [String]
    @Environment(\.colorScheme) var colorScheme
    @Binding var totalFiltersCount: Int
    @Binding var refreshID: UUID
    @Binding var collectionFilterModels: [FilterModel]
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Filter")
                    .font(.system(size: 15, weight: .bold))
                
                Menu {
                    let columns = viewModel.getFilteredColumns(for: selectedSchemaKey)
                        .filter { column in
                            if let id = column.id {
                                return !selectedFilterColumnID.contains(id)
                            }
                            return false
                        }
                    ForEach(columns, id: \.id) { column in
                        Button("\(column.title ?? "")") {
                            if !currentSelectedFilterColumnID.isEmpty {
                                clearFilterForColumn(columnID: currentSelectedFilterColumnID, changeFilterCount: false)
                            }
                            currentSelectedFilterColumnID = column.id ?? ""
                        }
                    }
                } label: {
                    HStack {
                        Text(currentSelectedFilterColumnID.isEmpty ? "Select column type" : getSelectedFilteredColumnTitle(columnID: currentSelectedFilterColumnID))
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
                .accessibilityIdentifier("CollectionFilterColumnSelectorIdentifier")
                if let index = collectionFilterModels.firstIndex(where: { $0.colID == currentSelectedFilterColumnID && $0.schemaKey == selectedSchemaKey }) {
                    if let column = getSelectedColumn(columnID: currentSelectedFilterColumnID) {
                        CollectionSearchBar(
                            model: $collectionFilterModels[index],
                            column: column,
                            viewModel: viewModel
                        )
                    }
                }
            }
            
            Button(action: {
                clearFilterForColumn(columnID: currentSelectedFilterColumnID, changeFilterCount: true)
                refreshID = UUID()
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
    
    private func getSelectedFilteredColumnTitle(columnID: String) -> String {
        let tableColumns = viewModel.getFilteredColumns(for: selectedSchemaKey)
        return tableColumns.first(where: {$0.id == columnID})?.title ?? ""
    }
    
    func getSelectedColumn(columnID: String) -> FieldTableColumn? {
        viewModel.getFilteredColumns(for: selectedSchemaKey).first(where: { $0.id == columnID })
    }
    
    private func clearFilterForColumn(columnID: String, changeFilterCount: Bool) {
        if let index = collectionFilterModels.firstIndex(where: { $0.colID == columnID && $0.schemaKey == selectedSchemaKey }) {
            collectionFilterModels[index].filterText = ""
        }
        if changeFilterCount {
            totalFiltersCount -= 1
            if totalFiltersCount == 0 {
                totalFiltersCount = 1
            }
        }
        currentSelectedFilterColumnID = ""
    }
}
