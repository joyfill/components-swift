//
//  File.swift
//  Joyfill
//
//  Created by Vivek on 14/02/25.
//

import SwiftUI
import JoyfillModel

struct CollectionModalTopNavigationView: View {
    @ObservedObject var viewModel: CollectionViewModel
    var onEditTap: (() -> Void)?
    var onFilterTap: (() -> Void)?
    
    @State private var showingPopover = false
    
    private var hasActiveFilters: Bool {
        return viewModel.tableDataModel.hasActiveFilters
    }

    var body: some View {
        HStack {
            if let title = viewModel.tableDataModel.title {
                Text("\(title)")
                    .font(.headline.bold())
            }

            Spacer()
            
            // Filter button
            Button(action: {
                onFilterTap?()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .foregroundColor(hasActiveFilters ? .blue : .gray)
                }
                .font(.system(size: 14))
                .frame(height: 27)
                .padding(.horizontal, 12)
                .overlay(RoundedRectangle(cornerRadius: 6)
                    .stroke(hasActiveFilters ? Color.blue : Color.buttonBorderColor, lineWidth: 1))
            }
            .accessibilityIdentifier("CollectionFilterButtonIdentifier")
            
            if hasActiveFilters {
                Button(action: {
                    clearFilter()
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

            if !viewModel.tableDataModel.selectedRows.isEmpty {
                Button(action: {
                    showingPopover = true
                }) {
                    Text("More ^")
                        .foregroundStyle(.blue)
                        .font(.system(size: 14))
                        .frame(width: 80, height: 27)
                        .overlay(RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.buttonBorderColor, lineWidth: 1))
                }
                .accessibilityIdentifier("TableMoreButtonIdentifier")
                .popover(isPresented: $showingPopover) {
                    if #available(iOS 16.4, *) {
                        VStack(spacing: 8) {
                            if viewModel.tableDataModel.selectedRows.count == 1 && !hasActiveFilters {
                                Button(action: {
                                    showingPopover = false
                                    viewModel.insertBelow()
                                }) {
                                    Text("Insert Below")
                                        .foregroundStyle(.blue)
                                        .font(.system(size: 14))
                                        .frame(height: 27)
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .accessibilityIdentifier("TableInsertRowIdentifier")
                                
                                Button(action: {
                                    showingPopover = false
                                    viewModel.moveUP()
                                }) {
                                    Text("Move Up")
                                        .foregroundStyle(viewModel.tableDataModel.shouldDisableMoveUp ? .gray : .blue)
                                        .font(.system(size: 14))
                                        .frame(height: 27)
                                }
                                .disabled(viewModel.tableDataModel.shouldDisableMoveUp)
                                .padding(.horizontal, 16)
                                .accessibilityIdentifier("TableMoveUpRowIdentifier")
                                
                                Button(action: {
                                    showingPopover = false
                                    viewModel.moveDown()
                                }) {
                                    Text("Move Down")
                                        .foregroundStyle(viewModel.tableDataModel.shouldDisableMoveDown ? .gray : .blue)
                                        .font(.system(size: 14))
                                        .frame(height: 27)
                                }
                                .disabled(viewModel.tableDataModel.shouldDisableMoveDown)
                                .padding(.horizontal, 16)
                                .accessibilityIdentifier("TableMoveDownRowIdentifier")
                                
                            }
                            
                            Button(action: {
                                showingPopover = false
                                onEditTap?()
                            }) {
                                Text("Edit \(rowTitle)")
                                    .foregroundStyle(.blue)
                                    .font(.system(size: 14))
                                    .frame(height: 27)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, viewModel.tableDataModel.selectedRows.count > 1 ? 16 : 0)
                            .accessibilityIdentifier("TableEditRowsIdentifier")
                            if !hasActiveFilters {
                                Button(action: {
                                    showingPopover = false
                                    viewModel.deleteSelectedRow()
                                }) {
                                    Text("Delete \(rowTitle)")
                                        .foregroundStyle(.red)
                                        .font(.system(size: 14))
                                        .frame(height: 27)
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 10)
                                .accessibilityIdentifier("TableDeleteRowIdentifier")
                            }
//                            Button(action: {
//                                showingPopover = false
//                                viewModel.duplicateRow()
//                            }) {
//                                Text("Duplicate \(rowTitle)")
//                                    .foregroundStyle(.blue)
//                                    .font(.system(size: 14))
//                                    .frame(height: 27)
//                            }
//                            .padding(.horizontal, 16)
//                            .padding(.bottom, 10)
//                            .accessibilityIdentifier("TableDuplicateRowIdentifier")
                        }
                        .frame(width: 180)
                        .presentationCompactAdaptation(.popover)

                    } else {
                        VStack(spacing: 8) {
                            if viewModel.tableDataModel.selectedRows.count == 1 {
                                Button(action: {
                                    showingPopover = false
                                    viewModel.insertBelow()
                                }) {
                                    Text("Insert Below")
                                        .foregroundStyle(.blue)
                                        .font(.system(size: 14))
                                        .frame(height: 27)
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .accessibilityIdentifier("TableInsertRowIdentifier")

                                Button(action: {
                                    showingPopover = false
                                    viewModel.moveUP()
                                }) {
                                    Text("Move Up")
                                        .foregroundStyle(viewModel.tableDataModel.shouldDisableMoveUp ? .gray : .blue)
                                        .font(.system(size: 14))
                                        .frame(height: 27)
                                }
                                .disabled(viewModel.tableDataModel.shouldDisableMoveUp)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .accessibilityIdentifier("TableMoveUpRowIdentifier")

                                Button(action: {
                                    showingPopover = false
                                    viewModel.moveDown()
                                }) {
                                    Text("Move Down")
                                        .foregroundStyle(viewModel.tableDataModel.shouldDisableMoveDown ? .gray : .blue)
                                        .font(.system(size: 14))
                                        .frame(height: 27)
                                }
                                .disabled(viewModel.tableDataModel.shouldDisableMoveDown)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .accessibilityIdentifier("TableMoveDownRowIdentifier")

                            }
                            Button(action: {
                                showingPopover = false
                                onEditTap?()
                            }) {
                                Text("Edit \(rowTitle)")
                                    .foregroundStyle(.blue)
                                    .font(.system(size: 14))
                                    .frame(height: 27)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .accessibilityIdentifier("TableEditRowsIdentifier")

                            Button(action: {
                                viewModel.deleteSelectedRow()
                                showingPopover = false
                            }) {
                                Text("Delete \(rowTitle)")
                                    .foregroundStyle(.red)
                                    .font(.system(size: 14))
                                    .frame(height: 27)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 10)
                            .accessibilityIdentifier("TableDeleteRowIdentifier")

//                            Button(action: {
//                                viewModel.duplicateRow()
//                                showingPopover = false
//                            }) {
//                                Text("Duplicate \(rowTitle)")
//                                    .foregroundStyle(.blue)
//                                    .font(.system(size: 14))
//                                    .frame(height: 27)
//                            }
//                            .padding(.horizontal, 16)
//                            .padding(.bottom, 10)
//                            .accessibilityIdentifier("TableDuplicateRowIdentifier")
                            Spacer()
                        }
                    }
                }
            }

        }
    }
    
    fileprivate func clearSorting() {
        viewModel.tableDataModel.sortModel.order = .none
        viewModel.tableDataModel.sortModel.colID = ""
        viewModel.tableDataModel.sortModel.schemaKey = ""
    }
    
    func clearFilter() {
//        viewModel.tableDataModel.filteredcellModels = viewModel.tableDataModel.cellModels
        viewModel.setupCellModels()
        for i in 0..<viewModel.tableDataModel.filterModels.count {
            viewModel.tableDataModel.filterModels[i].filterText = ""
        }
        clearSorting()
        viewModel.tableDataModel.emptySelection()
    }

    var rowTitle: String {
        "\(viewModel.tableDataModel.selectedRows.count) " + (viewModel.tableDataModel.selectedRows.count > 1 ? "rows": "row")
    }
}

struct CollectionEditMultipleRowsSheetView: View {
    @ObservedObject var viewModel: CollectionViewModel
    let tableColumns: [FieldTableColumn]
    @Environment(\.presentationMode) var presentationMode
    @State var changes = [Int: ValueUnion]()
    @State private var isLoading = false
    @State private var viewID = UUID() // Unique ID for the view
    @State private var debounceTask: Task<Void, Never>?

    init(viewModel: CollectionViewModel, tableColumns: [FieldTableColumn]) {
        self.viewModel = viewModel
        self.tableColumns = tableColumns
    }
    
    @ViewBuilder
    private func fieldTitle(_ col: FieldTableColumn, isCellFilled: Bool) -> some View {
        HStack {
            if let required = col.required, required, !isCellFilled {
                Image(systemName: "asterisk")
                    .foregroundColor(.red)
                    .imageScale(.small)
            }
            Text(col.title)
                .font(.headline.bold())
        }
        .padding(.bottom, -8)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if viewModel.tableDataModel.selectedRows.count == 1 {
                    HStack(alignment: .top) {
                        Button(action: {
                            viewModel.selectUpperRow()
                            changes = [:]
                        }, label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(viewModel.tableDataModel.shouldDisableMoveUpFilterActive ? .gray : .blue, lineWidth: 1)
                                    .frame(width: 27, height: 27)
                                
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(viewModel.tableDataModel.shouldDisableMoveUpFilterActive ? .gray : .blue)
                            }
                        })
                        .disabled(viewModel.tableDataModel.shouldDisableMoveUpFilterActive)
                        .accessibilityIdentifier("UpperRowButtonIdentifier")
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.selectBelowRow()
                            changes = [:]
                        }, label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(viewModel.tableDataModel.shouldDisableMoveDownFilterActive ? .gray : .blue, lineWidth: 1)
                                    .frame(width: 27, height: 27)
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(viewModel.tableDataModel.shouldDisableMoveDownFilterActive ? .gray : .blue)
                            }
                        })
                        .disabled(viewModel.tableDataModel.shouldDisableMoveDownFilterActive)
                        .accessibilityIdentifier("LowerRowButtonIdentifier")
                        if !viewModel.tableDataModel.hasActiveFilters {
                            Button(action: {
                                viewModel.insertBelowFromBulkEdit()
                            }, label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(.blue, lineWidth: 1)
                                        .frame(width: 27, height: 27)
                                    
                                    Image(systemName: "plus")
                                        .foregroundStyle(.blue)
                                }
                            })
                            .accessibilityIdentifier("PlusTheRowButtonIdentifier")
                        }
                        
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
                        .accessibilityIdentifier("DismissEditSingleRowSheetButtonIdentifier")
                    }
                }
                
                HStack(alignment: .top) {
                    if let title = viewModel.tableDataModel.title {
                        VStack(alignment: .leading) {
                            Text("\(title)")
                                .font(.headline.bold())
                            if viewModel.tableDataModel.selectedRows.count > 1 {
                                Text("\(viewModel.rowTitle) selected")
                                    .font(.caption).bold()
                                    .foregroundStyle(.blue)
                            }
                        }
                    }

                    Spacer()

                    if viewModel.tableDataModel.selectedRows.count != 1 {
                        Button(action: {
                            Task {
                                isLoading = true
                                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                                
                                await MainActor.run {
                                    viewModel.bulkEdit(changes: changes)
                                    viewModel.tableDataModel.emptySelection()
                                    isLoading = false
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }, label: {
                            ZStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                        .frame(width: 88, height: 27)
                                } else {
                                    Text("Apply All")
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
                        .accessibilityIdentifier("ApplyAllButtonIdentifier")
                        .disabled(isLoading)
                        
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
                }

                ForEach(Array(tableColumns.enumerated()), id: \.offset) { colIndex, col in
                    if let row = viewModel.tableDataModel.selectedRows.first {
                        let isUsedForBulkEdit = !(viewModel.tableDataModel.selectedRows.count == 1)
                        if let cell = viewModel.tableDataModel.getDummyNestedCell(col: colIndex, isBulkEdit: isUsedForBulkEdit, rowID: row) {
                        var cellModel = TableCellModel(rowID: row,
                                                       data: cell,
                                                       documentEditor: viewModel.tableDataModel.documentEditor,
                                                       fieldIdentifier: viewModel.tableDataModel.fieldIdentifier,
                                                       viewMode: .modalView,
                                                       editMode: viewModel.tableDataModel.mode)
                        { cellDataModel in
                            switch cell.type {
                            case .text:
                                if isUsedForBulkEdit {
                                    if !cellDataModel.title.isEmpty {
                                        self.changes[colIndex] = ValueUnion.string(cellDataModel.title)
                                    } else {
                                        self.changes.removeValue(forKey: colIndex)
                                    }
                                } else {
                                    self.changes[colIndex] = ValueUnion.string(cellDataModel.title)
                                }
                            case .dropdown:
                                if isUsedForBulkEdit {
                                    if let dropdownSelectedId = cellDataModel.defaultDropdownSelectedId, !dropdownSelectedId.isEmpty {
                                        self.changes[colIndex] = ValueUnion.string(dropdownSelectedId)
                                    } else {
                                        self.changes.removeValue(forKey: colIndex)
                                    }
                                } else {
                                    self.changes[colIndex] = ValueUnion.string(cellDataModel.defaultDropdownSelectedId ?? "")
                                }
                                
                            case .date:
                                if isUsedForBulkEdit {
                                    if let date = cellDataModel.date {
                                        self.changes[colIndex] = ValueUnion.double(date)
                                    } else {
                                        self.changes.removeValue(forKey: colIndex)
                                    }
                                } else {
                                    self.changes[colIndex] = cellDataModel.date.map(ValueUnion.double) ?? .null
                                }
                            case .number:
                                if isUsedForBulkEdit {
                                    if let number = cellDataModel.number {
                                        self.changes[colIndex] = ValueUnion.double(number)
                                    } else {
                                        self.changes.removeValue(forKey: colIndex)
                                    }
                                } else {
                                    self.changes[colIndex] = cellDataModel.number.map(ValueUnion.double) ?? .null
                                }
                            case .multiSelect:
                                if isUsedForBulkEdit {
                                    if let multiSelectValues = cellDataModel.multiSelectValues, !multiSelectValues.isEmpty {
                                        self.changes[colIndex] = ValueUnion.array(multiSelectValues)
                                    } else {
                                        self.changes.removeValue(forKey: colIndex)
                                    }
                                } else {
                                    self.changes[colIndex] = cellDataModel.multiSelectValues.map(ValueUnion.array) ?? .null
                                }
                            case .barcode:
                                if isUsedForBulkEdit {
                                    if !cellDataModel.title.isEmpty {
                                        self.changes[colIndex] = ValueUnion.string(cellDataModel.title)
                                    } else {
                                        self.changes.removeValue(forKey: colIndex)
                                    }
                                } else {
                                    self.changes[colIndex] = ValueUnion.string(cellDataModel.title)
                                }
                            case .image:
                                if isUsedForBulkEdit {
                                    if cellDataModel.valueElements != [] {
                                        self.changes[colIndex] = ValueUnion.valueElementArray(cellDataModel.valueElements)
                                    } else {
                                        self.changes.removeValue(forKey: colIndex)
                                    }
                                } else {
                                    self.changes[colIndex] = ValueUnion.valueElementArray(cellDataModel.valueElements)
                                }
                            case .signature:
                                if isUsedForBulkEdit {
                                    if !cellDataModel.title.isEmpty {
                                        self.changes[colIndex] = ValueUnion.string(cellDataModel.title ?? "")
                                    } else {
                                        self.changes.removeValue(forKey: colIndex)
                                    }
                                } else {
                                    self.changes[colIndex] = ValueUnion.string(cellDataModel.title ?? "")
                                }
 
                            default:
                                break
                            }
                            
                            if !isUsedForBulkEdit {
                                viewModel.bulkEdit(changes: changes)
                            }
                        }

                        var isFilledBasedOnChange: Bool {
                            guard isUsedForBulkEdit, let changeValue = changes[colIndex] else {
                                return false
                            }

                            switch changeValue {
                            case .string(let str):
                                return !str.isEmpty
                            case .double:
                                return true
                            case .int:
                                return true
                            case .bool:
                                return true
                            case .array(let arr):
                                return !arr.isEmpty
                            case .valueElementArray(let arr):
                                return !arr.isEmpty
                            case .null:
                                return false
                            default:
                                return false
                            }
                        }

                        let isEffectivelyFilled = isUsedForBulkEdit ? isFilledBasedOnChange : cellModel.data.isCellFilled

                        switch col.type {
                        case .text:
                            var str = !isUsedForBulkEdit ? cellModel.data.title : ""
                            fieldTitle(col, isCellFilled: isEffectivelyFilled)
                            let binding = Binding<String>(
                                get: {
                                    if isUsedForBulkEdit {
                                        if case .string(let changedStr) = changes[colIndex] { return changedStr }
                                        return ""
                                    } else {
                                        return str
                                    }
                                },
                                set: { newValue in
                                    str = newValue
                                    if isUsedForBulkEdit {
                                        if !str.isEmpty {
                                            self.changes[colIndex] = ValueUnion.string(newValue)
                                        } else {
                                            self.changes.removeValue(forKey: colIndex)
                                        }
                                    } else {
                                        self.changes[colIndex] = ValueUnion.string(newValue)
                                    }
                                    
                                    if !isUsedForBulkEdit {
                                        viewModel.bulkEdit(changes: changes)
                                    }
                                }
                            )
                            TextField("", text: binding)
                                .font(.system(size: 15))
                                .accessibilityIdentifier("EditRowsTextFieldIdentifier")
                                .padding(.horizontal, 10)
                                .frame(height: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                                )
                                .cornerRadius(10)
                        case .dropdown:
                            fieldTitle(col, isCellFilled: isEffectivelyFilled)
                            TableDropDownOptionListView(cellModel: Binding.constant(cellModel), isUsedForBulkEdit: isUsedForBulkEdit)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                                )
                                .cornerRadius(10)
                                .accessibilityIdentifier("EditRowsDropdownFieldIdentifier")
                        case .date:
                            fieldTitle(col, isCellFilled: isEffectivelyFilled)
                            TableDateView(cellModel: Binding.constant(cellModel), isUsedForBulkEdit: isUsedForBulkEdit)
                                .padding(.vertical, 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                                )
                                .cornerRadius(10)
                                .accessibilityIdentifier("EditRowsDateFieldIdentifier")
                        case .number:
                            fieldTitle(col, isCellFilled: isEffectivelyFilled)
                            TableNumberView(cellModel: Binding.constant(cellModel), isUsedForBulkEdit: isUsedForBulkEdit)
                                .keyboardType(.decimalPad)
                                .frame(minHeight: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                                )
                                .cornerRadius(10)
                                .accessibilityIdentifier("EditRowsNumberFieldIdentifier")
                        case .multiSelect:
                            fieldTitle(col, isCellFilled: isEffectivelyFilled)
                            TableMultiSelectView(cellModel: Binding.constant(cellModel),isUsedForBulkEdit: isUsedForBulkEdit)
                                .padding(.vertical, 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                                )
                                .cornerRadius(10)
                                .accessibilityIdentifier("EditRowsMultiSelecionFieldIdentifier")
                        case .image:
                            let bindingCellModel = Binding<TableCellModel>(
                                get: {
                                    return cellModel
                                },
                                set: { newValue in
                                    cellModel = newValue
                                }
                            )
                            fieldTitle(col, isCellFilled: isEffectivelyFilled)
                            HStack {
                                Spacer()
                                TableImageView(cellModel: bindingCellModel, isUsedForBulkEdit: isUsedForBulkEdit)
                                    .padding(.vertical, 4)
                                Spacer()
                            }
                            .frame(minHeight: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
                            )
                            .cornerRadius(10)
                            .accessibilityIdentifier("EditRowsImageFieldIdentifier")
                        case .signature:
                            let bindingCellModel = Binding<TableCellModel>(
                                get: {
                                    return cellModel
                                },
                                set: { newValue in
                                    cellModel = newValue
                                }
                            )
                            fieldTitle(col, isCellFilled: isEffectivelyFilled)
                            HStack {
                                Spacer()
                                TableSignatureView(cellModel: bindingCellModel, isUsedForBulkEdit: isUsedForBulkEdit)
                                Spacer()
                            }
                            .frame(minHeight: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
                            )
                            .cornerRadius(10)
                            .accessibilityIdentifier("EditRowsSignatureFieldIdentifier")
                        case .barcode:
                            fieldTitle(col, isCellFilled: isEffectivelyFilled)
                            TableBarcodeView(cellModel: Binding.constant(cellModel), isUsedForBulkEdit: isUsedForBulkEdit)
                                .frame(minHeight: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                                )
                                .cornerRadius(10)
                                .accessibilityIdentifier("EditRowsBarcodeFieldIdentifier")
                        case .block:
                            if !isUsedForBulkEdit {
                                fieldTitle(col, isCellFilled: isEffectivelyFilled)
                                TableBlockView(cellModel: Binding.constant(cellModel))
                                    .frame(minHeight: 40)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                                    )
                                    .cornerRadius(10)
                            }
                        default:
                            Text("")
                        }
                    }
                }
                }
                Spacer()
            }
            .padding(.all, 16)
        }
        .id(viewID)
        .onChange(of: viewModel.tableDataModel.selectedRows.first ){ newValue in
            viewID = UUID()
        }
        .simultaneousGesture(DragGesture().onChanged({ _ in
            dismissKeyboard()
        }))
    }
}
