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
                            .accessibilityIdentifier("TableDeleteRowIdentifier")
                            
                            Button(action: {
                                showingPopover = false
                                viewModel.duplicateRow()
                            }) {
                                Text("Duplicate \(rowTitle)")
                                    .foregroundStyle(.selection)
                                    .font(.system(size: 14))
                                    .frame(height: 27)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 10)
                            .accessibilityIdentifier("TableDuplicateRowIdentifier")
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
                                .padding(.top, 16)
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
                                .padding(.top, 16)
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
                            .accessibilityIdentifier("TableDeleteRowIdentifier")

                            Button(action: {
                                viewModel.duplicateRow()
                                showingPopover = false
                            }) {
                                Text("Duplicate \(rowTitle)")
                                    .foregroundStyle(.selection)
                                    .font(.system(size: 14))
                                    .frame(height: 27)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 10)
                            .accessibilityIdentifier("TableDuplicateRowIdentifier")
                            Spacer()
                        }
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
    let viewModel: TableViewModel
    @Environment(\.presentationMode)  var presentationMode
    @State var changes = [Int: ValueUnion]()

    init(viewModel: TableViewModel) {
        self.viewModel =  viewModel
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
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

                    Button(action: {
                        viewModel.bulkEdit(changes: changes)
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

                ForEach(Array(viewModel.tableDataModel.tableColumns.enumerated()), id: \.offset) { colIndex, col in
                    let row = viewModel.tableDataModel.selectedRows.first!
                    let cell = viewModel.tableDataModel.getDummyCell(col: colIndex)!
                    var cellModel = TableCellModel(rowID: row,
                                                   data: cell,
                                                   documentEditor: viewModel.tableDataModel.documentEditor,
                                                   fieldIdentifier: viewModel.tableDataModel.fieldIdentifier,
                                                   viewMode: .modalView,
                                                   editMode: viewModel.tableDataModel.mode)
                    { cellDataModel in
                        switch cell.type {
                        case "text":
                            self.changes[colIndex] = ValueUnion.string(cellDataModel.title)
                        case "dropdown":
                            self.changes[colIndex] = ValueUnion.string(cellDataModel.defaultDropdownSelectedId ?? "")
                        case "date":
                            self.changes[colIndex] = cellDataModel.date.map(ValueUnion.double) ?? .null
                        case "number":
                            self.changes[colIndex] = cellDataModel.number.map(ValueUnion.double) ?? .null
                        case "multiSelect":
                            self.changes[colIndex] = cellDataModel.multiSelectValues.map(ValueUnion.array) ?? .null
                        default:
                            break
                        }
                    }
                    switch cellModel.data.type {
                    case "text":
                        var str = ""
                        Text(viewModel.tableDataModel.getColumnTitle(columnId: col.id!))
                            .font(.headline.bold())
                            .padding(.bottom, -8)
                        let binding = Binding<String>(
                            get: {
                                str
                            },
                            set: { newValue in
                                str = newValue
                                self.changes[colIndex] = ValueUnion.string(newValue) 
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
                    case "dropdown":
                        Text(viewModel.tableDataModel.getColumnTitle(columnId: col.id!))
                            .font(.headline.bold())
                            .padding(.bottom, -8)
                        TableDropDownOptionListView(cellModel: Binding.constant(cellModel), isUsedForBulkEdit: true)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
                            )
                            .cornerRadius(10)
                            .accessibilityIdentifier("EditRowsDropdownFieldIdentifier")
                    case "date":
                        Text(viewModel.tableDataModel.getColumnTitle(columnId: col.id!))
                            .font(.headline.bold())
                            .padding(.bottom, -8)
                        TableDateView(cellModel: Binding.constant(cellModel), isUsedForBulkEdit: true)
                            .padding(.vertical, 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
                            )
                            .cornerRadius(10)
                            .accessibilityIdentifier("EditRowsDateFieldIdentifier")
                    case "number":
                        Text(viewModel.tableDataModel.getColumnTitle(columnId: col.id!))
                            .font(.headline.bold())
                            .padding(.bottom, -8)
                        TableNumberView(cellModel: Binding.constant(cellModel), isUsedForBulkEdit: true)
                            .keyboardType(.decimalPad)
                            .frame(minHeight: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
                            )
                            .cornerRadius(10)
                            .accessibilityIdentifier("EditRowsNumberFieldIdentifier")
                    case "multiSelect":
                        Text(viewModel.tableDataModel.getColumnTitle(columnId: col.id!))
                            .font(.headline.bold())
                            .padding(.bottom, -8)
                        TableMultiSelectView(cellModel: Binding.constant(cellModel),isUsedForBulkEdit: true)
                            .padding(.vertical, 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
                            )
                            .cornerRadius(10)
                    default:
                        Text("")
                    }
                }
                Spacer()
            }
            .padding(.all, 16)
        }
    }
}
