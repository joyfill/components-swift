import SwiftUI
import JoyfillModel

struct TableModalTopNavigationView: View {
    @ObservedObject var viewModel: TableViewModel
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
                        .foregroundStyle(.selection)
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
                                        .foregroundStyle(.selection)
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
                                        .foregroundStyle(.selection)
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
                                        .foregroundStyle(.selection)
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
                                    .foregroundStyle(.selection)
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
//                                    .foregroundStyle(.selection)
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
                                        .foregroundStyle(.selection)
                                        .font(.system(size: 14))
                                        .frame(height: 27)
                                }
                                .padding(.horizontal, 16)
                                .accessibilityIdentifier("TableInsertRowIdentifier")

                                Button(action: {
                                    showingPopover = false
                                    viewModel.moveUP()
                                }) {
                                    Text("Move Up")
                                        .foregroundStyle(.selection)
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
                                        .foregroundStyle(.selection)
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
                                    .foregroundStyle(.selection)
                                    .font(.system(size: 14))
                                    .frame(height: 27)
                            }
                            .padding(.horizontal, 16)
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
                            .accessibilityIdentifier("TableDeleteRowIdentifier")

//                            Button(action: {
//                                viewModel.duplicateRow()
//                                showingPopover = false
//                            }) {
//                                Text("Duplicate \(rowTitle)")
//                                    .foregroundStyle(.selection)
//                                    .font(.system(size: 14))
//                                    .frame(height: 27)
//                            }
//                            .padding(.horizontal, 16)
//                            .accessibilityIdentifier("TableDuplicateRowIdentifier")
                            Spacer()
                        }
                        .padding(.top, 12)
                    }
                }
            }

            Button(action: {
                viewModel.addRow()
            }) {
                Text(viewModel.tableDataModel.filterModels.noFilterApplied ? "Add Row +": "Add Row With Filters +")
                    .foregroundStyle(.selection)
                    .font(.system(size: 14))
                    .frame(height: 27)
                    .padding(.horizontal, 16)
                    .overlay(RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.buttonBorderColor, lineWidth: 1))
            }
            .disabled(viewModel.tableDataModel.mode == .readonly)
            .accessibilityIdentifier("TableAddRowIdentifier")
        }
    }

    var rowTitle: String {
        "\(viewModel.tableDataModel.selectedRows.count) " + (viewModel.tableDataModel.selectedRows.count > 1 ? "rows": "row")
    }
}

struct EditMultipleRowsSheetView: View {
    @ObservedObject var viewModel: TableViewModel
    @Environment(\.presentationMode)  var presentationMode
    @State var changes = [Int: ValueUnion]()
    @State private var viewID = UUID() // Unique ID for the view
    @State private var debounceTask: Task<Void, Never>?

    init(viewModel: TableViewModel) {
        self.viewModel =  viewModel
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
                            .accessibilityIdentifier("UpperRowButtonIdentifier")
                            
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
                            .accessibilityIdentifier("LowerRowButtonIdentifier")
                            
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
                            Text("\(viewModel.rowTitle) selected")
                                .font(.caption).bold()
                                .foregroundStyle(.blue)
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
                }

                ForEach(Array(viewModel.tableDataModel.tableColumns.enumerated()), id: \.offset) { colIndex, col in
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
                            switch cellModel.data.type {
                            case .text:
                                Text(viewModel.tableDataModel.getColumnTitle(columnId: col.id ?? ""))
                                    .font(.headline.bold())
                                    .padding(.bottom, -8)
                                
                                var str = !isUsedForBulkEdit ? cellModel.data.title : ""
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
                                Text(viewModel.tableDataModel.getColumnTitle(columnId: col.id ?? ""))
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
                                Text(viewModel.tableDataModel.getColumnTitle(columnId: col.id ?? ""))
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
                                Text(viewModel.tableDataModel.getColumnTitle(columnId: col.id ?? ""))
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
                                Text(viewModel.tableDataModel.getColumnTitle(columnId: col.id ?? ""))
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
                            case .barcode:
                                Text(viewModel.tableDataModel.getColumnTitle(columnId: col.id ?? ""))
                                    .font(.headline.bold())
                                    .padding(.bottom, -8)
                                TableBarcodeView(cellModel: Binding.constant(cellModel), isUsedForBulkEdit: isUsedForBulkEdit)
                                    .frame(minHeight: 40)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                                    )
                                    .cornerRadius(10)
                                    .accessibilityIdentifier("EditRowsBarcodeFieldIdentifier")
                            case .image:
                                let bindingCellModel = Binding<TableCellModel>(
                                    get: {
                                        return cellModel
                                    },
                                    set: { newValue in
                                        cellModel = newValue
                                    }
                                )
                                Text(viewModel.tableDataModel.getColumnTitle(columnId: col.id ?? ""))
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
                                Text(viewModel.tableDataModel.getColumnTitle(columnId: col.id ?? ""))
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
                                .accessibilityIdentifier("EditRowsSignatureFieldIdentifier")
                            case .block:
                                if !isUsedForBulkEdit {
                                    Text(viewModel.tableDataModel.getColumnTitle(columnId: col.id ?? ""))
                                        .font(.headline.bold())
                                        .padding(.bottom, -8)
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
