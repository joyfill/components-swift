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
    
    @State private var showingPopover = false

    var body: some View {
        HStack {
            if let title = viewModel.tableDataModel.title {
                Text("\(title)")
                    .font(.headline.bold())
            }

            Spacer()

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

    var rowTitle: String {
        "\(viewModel.tableDataModel.selectedRows.count) " + (viewModel.tableDataModel.selectedRows.count > 1 ? "rows": "row")
    }
}

struct CollectionEditMultipleRowsSheetView: View {
    @ObservedObject var viewModel: CollectionViewModel
    let tableColumns: [FieldTableColumn]
    @Environment(\.presentationMode) var presentationMode
    @State var changes = [Int: ValueUnion]()
    @State private var viewID = UUID() // Unique ID for the view
    @State private var debounceTask: Task<Void, Never>?

    init(viewModel: CollectionViewModel, tableColumns: [FieldTableColumn]) {
        self.viewModel = viewModel
        self.tableColumns = tableColumns
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
                                    .stroke(viewModel.tableDataModel.shouldDisableMoveUp ? .gray : .blue, lineWidth: 1)
                                    .frame(width: 27, height: 27)
                                
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(viewModel.tableDataModel.shouldDisableMoveUp ? .gray : .blue)
                            }
                        })
                        .disabled(viewModel.tableDataModel.shouldDisableMoveUp)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.selectBelowRow()
                            changes = [:]
                        }, label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(viewModel.tableDataModel.shouldDisableMoveDown ? .gray : .blue, lineWidth: 1)
                                    .frame(width: 27, height: 27)
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(viewModel.tableDataModel.shouldDisableMoveDown ? .gray : .blue)
                            }
                        })
                        .disabled(viewModel.tableDataModel.shouldDisableMoveDown)
                        
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
                            viewModel.bulkEdit(changes: changes)
                            viewModel.tableDataModel.emptySelection()
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text("Apply All")
                                .darkLightThemeColor()
                                .font(.system(size: 14))
                                .frame(width: 88, height: 27)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                                )
                        })
                        .accessibilityIdentifier("ApplyAllButtonIdentifier")
                        
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
                        let cell = viewModel.tableDataModel.getDummyNestedCell(col: colIndex, rowID: row)!
                        let isUsedForBulkEdit = !(viewModel.tableDataModel.selectedRows.count == 1)
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

                        
                        switch col.type {
                        case .text:
                            var str = viewModel.tableDataModel.selectedRows.count == 1 ? cellModel.data.title : ""
                            Text(col.title)
                                .font(.headline.bold())
                                .padding(.bottom, -8)
                            let binding = Binding<String>(
                                get: {
                                    str
                                },
                                set: { newValue in
                                    str = newValue
                                    if isUsedForBulkEdit {
                                        if !newValue.isEmpty {
                                            self.changes[colIndex] = ValueUnion.string(newValue)
                                        } else {
                                            self.changes.removeValue(forKey: colIndex)
                                        }
                                    } else {
                                        self.changes[colIndex] = ValueUnion.string(newValue)
                                    }
                                    
                                    Utility.debounceTextChange(debounceTask: &debounceTask) {
                                        if !isUsedForBulkEdit {
                                            viewModel.bulkEdit(changes: changes)
                                        }
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
                            Text(col.title)
                                .font(.headline.bold())
                                .padding(.bottom, -8)
                            TableDropDownOptionListView(cellModel: Binding.constant(cellModel), isUsedForBulkEdit: isUsedForBulkEdit)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                                )
                                .cornerRadius(10)
                                .accessibilityIdentifier("EditRowsDropdownFieldIdentifier")
                        case .date:
                            Text(col.title)
                                .font(.headline.bold())
                                .padding(.bottom, -8)
                            TableDateView(cellModel: Binding.constant(cellModel), isUsedForBulkEdit: isUsedForBulkEdit)
                                .padding(.vertical, 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                                )
                                .cornerRadius(10)
                                .accessibilityIdentifier("EditRowsDateFieldIdentifier")
                        case .number:
                            Text(col.title)
                                .font(.headline.bold())
                                .padding(.bottom, -8)
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
                            Text(col.title)
                                .font(.headline.bold())
                                .padding(.bottom, -8)
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
                            
                            Text(col.title)
                                .font(.headline.bold())
                                .padding(.bottom, -8)
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
                            
                        case .signature:
                            let bindingCellModel = Binding<TableCellModel>(
                                get: {
                                    return cellModel
                                },
                                set: { newValue in
                                    cellModel = newValue
                                }
                            )
                            Text(col.title)
                                .font(.headline.bold())
                                .padding(.bottom, -8)
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
                            
                        case .barcode:
                            Text(col.title)
                                .font(.headline.bold())
                                .padding(.bottom, -8)
                            TableBarcodeView(cellModel: Binding.constant(cellModel), isUsedForBulkEdit: isUsedForBulkEdit)
                                .frame(minHeight: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                                )
                                .cornerRadius(10)
                        default:
                            Text("")
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
    }
}
