import SwiftUI
import JoyfillModel

struct TableModalTopNavigationView: View {
    @ObservedObject var viewModel: TableViewModel
    var onEditTap: (() -> Void)?
    var fieldDependency: FieldDependency
    
    @State private var showingPopover = false

    var body: some View {
        HStack {
            if let title = fieldDependency.fieldData?.title {
                Text("\(title)")
                    .font(.headline.bold())
            }

            Spacer()

            if !viewModel.selectedRows.isEmpty {
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
                            if viewModel.selectedRows.count == 1 {
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
                                .accessibilityIdentifier("TableEditRowsIdentifier")
                                
                                Button(action: {
                                    showingPopover = false
                                    viewModel.moveUP()
                                }) {
                                    Text("Move Up")
                                        .foregroundStyle(.selection)
                                        .font(.system(size: 14))
                                        .frame(height: 27)
                                }
                                .padding(.horizontal, 16)
                                .accessibilityIdentifier("TableEditRowsIdentifier")
                                
                                Button(action: {
                                    showingPopover = false
                                    viewModel.moveDown()
                                }) {
                                    Text("Move Down")
                                        .foregroundStyle(.selection)
                                        .font(.system(size: 14))
                                        .frame(height: 27)
                                }
                                .padding(.horizontal, 16)
                                .accessibilityIdentifier("TableEditRowsIdentifier")
                                
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
                            .padding(.top, viewModel.selectedRows.count > 1 ? 16 : 0)
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
                            if viewModel.selectedRows.count == 1 {
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
                                .accessibilityIdentifier("TableEditRowsIdentifier")

                                Button(action: {
                                    showingPopover = false
                                    viewModel.moveUP()
                                }) {
                                    Text("Move Up")
                                        .foregroundStyle(.selection)
                                        .font(.system(size: 14))
                                        .frame(height: 27)
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .accessibilityIdentifier("TableEditRowsIdentifier")

                                Button(action: {
                                    showingPopover = false
                                    viewModel.moveDown()
                                }) {
                                    Text("Move Down")
                                        .foregroundStyle(.selection)
                                        .font(.system(size: 14))
                                        .frame(height: 27)
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .accessibilityIdentifier("TableEditRowsIdentifier")

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
                Text(viewModel.filterModels.noFilterApplied ? "Add Row +": "Add Row With Filters +")
                    .foregroundStyle(.selection)
                    .font(.system(size: 14))
                    .frame(height: 27)
                    .padding(.horizontal, 16)
                    .overlay(RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.buttonBorderColor, lineWidth: 1))
            }
            .accessibilityIdentifier("TableAddRowIdentifier")
        }
    }

    var rowTitle: String {
        "\(viewModel.selectedRows.count) " + (viewModel.selectedRows.count > 1 ? "rows": "row")
    }
}

struct EditMultipleRowsSheetView: View {
    let viewModel: TableViewModel
    @Environment(\.presentationMode)  var presentationMode
    @State var changes = [Int: String]()

    init(viewModel: TableViewModel) {
        self.viewModel =  viewModel
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    if let title = viewModel.fieldDependency.fieldData?.title {
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

                ForEach(Array(viewModel.columns.enumerated()), id: \.offset) { colIndex, col in
                    let row = viewModel.selectedRows.first!
                    let cell = viewModel.getFieldTableColumn(row: row, col: colIndex)
                    if let cell = cell {
                        let cellModel = TableCellModel(rowID: row, data: cell, eventHandler: viewModel.fieldDependency.eventHandler, fieldData: viewModel.fieldDependency.fieldData, viewMode: .modalView, editMode: viewModel.fieldDependency.mode)
                        { editedCell in
                            switch cell.type {
                            case "text":
                                self.changes[colIndex] = editedCell.title
                            case "dropdown":
                                self.changes[colIndex] = editedCell.defaultDropdownSelectedId
                            default:
                                break
                            }
                        }
                        switch cellModel.data.type {
                        case "text":
                            var str = ""
                            Text(viewModel.getColumnTitle(columnId: col))
                                .font(.headline.bold())
                                .padding(.bottom, -8)
                            let binding = Binding<String>(
                                get: {
                                    str
                                },
                                set: { newValue in
                                    str = newValue
                                    self.changes[colIndex] = newValue
                                }
                            )
                            TextField("", text: binding)
                                .font(.system(size: 15))
                                .accessibilityIdentifier("EditRowsTextFieldIdentifier")
                                .disabled(viewModel.fieldDependency.mode == .readonly)
                                .padding(.horizontal, 10)
                                .frame(height: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                                )
                                .cornerRadius(10)
                        case "dropdown":
                            Text(viewModel.getColumnTitle(columnId: col))
                                .font(.headline.bold())
                                .padding(.bottom, -8)
                            TableDropDownOptionListView(cellModel: cellModel, isUsedForBulkEdit: true)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                                )
                                .cornerRadius(10)
                                .disabled(cellModel.editMode == .readonly)
                                .accessibilityIdentifier("EditRowsDropdownFieldIdentifier")
                        default:
                            Text("")
                        }
                    }
                }
                Spacer()
            }
            .padding(.all, 16)
        }
    }
}
