import SwiftUI
import JoyfillModel

//onDeleteTap?()
//onDuplicateTap?()
//    .accessibilityIdentifier("TableDeleteRowIdentifier")
//    .accessibilityIdentifier("TableDuplicateRowIdentifier")

struct TableModalTopNavigationView: View {
    @Binding var showMoreButton: Bool
    var onDeleteTap: (() -> Void)?
    var onDuplicateTap: (() -> Void)?
    var onAddRowTap: (() -> Void)?
    var fieldDependency: FieldDependency
    @State private var showingPopover = false
    @State private var showEditMultipleRowsSheetView: Bool = false
    
    var body: some View {
        HStack {
            Text("Table Title")
                .lineLimit(1)
                .font(.headline.bold())
            
            Spacer()
            
            if showMoreButton {
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
                .popover(isPresented: $showingPopover) {
                    if #available(iOS 16.4, *) {
                        VStack(spacing: 8) {
                            Button(action: {
                                showEditMultipleRowsSheetView = true
                            }) {
                                Text("Edit rows")
                                    .foregroundStyle(.selection)
                                    .font(.system(size: 14))
                                    .frame(height: 27)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .sheet(isPresented: $showEditMultipleRowsSheetView) {
                                EditMultipleRowsSheetView(fieldDependency: fieldDependency)
                            }
                            .accessibilityIdentifier("TableEditRowsIdentifier")
                            
                            Button(action: {
                                onDeleteTap?()
                            }) {
                                Text("Delete")
                                    .foregroundStyle(.red)
                                    .font(.system(size: 14))
                                    .frame(height: 27)
                            }
                            .padding(.horizontal, 16)
                            .accessibilityIdentifier("TableDeleteRowIdentifier")
                            
                            Button(action: {
                                onDuplicateTap?()
                            }) {
                                Text("Duplicate")
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
                        // Fallback on earlier versions
                    }
                }
            }
            
            Button(action: {
                onAddRowTap?()
            }) {
                Text("Add Row +")
                    .foregroundStyle(.selection)
                    .font(.system(size: 14))
                    .frame(width: 94, height: 27)
                    .overlay(RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.buttonBorderColor, lineWidth: 1))
            }
            .accessibilityIdentifier("TableAddRowIdentifier")
        }
    }
}

struct EditMultipleRowsSheetView: View {
    @State var enterText: String = ""
    @State var selectedRowCount: Int = 5
    @State var textfieldColumnTitle: String = "TextField Title"
    @State var dropdownColumnTitle: String = "Dropdown Title"
    @Environment(\.presentationMode)  var presentationMode
    var fieldDependency: FieldDependency
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    if let title = fieldDependency.fieldData?.title {
                        VStack(alignment: .leading) {
                            Text("\(title)")
                                .font(.headline.bold())
                            Text("\(selectedRowCount) rows selected")
                                .font(.caption).bold()
                                .foregroundStyle(.blue)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        
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
                
                Text("\(textfieldColumnTitle)")
                    .font(.headline.bold())
                    .padding(.bottom, -8)
                TextField("", text: $enterText)
                    .accessibilityIdentifier("Text")
                    .disabled(fieldDependency.mode == .readonly)
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    )
                    .cornerRadius(10)
                
                Text("\(dropdownColumnTitle)")
                    .font(.headline.bold())
                    .padding(.bottom, -8)
                EditTableDropdownRows(fieldDependency: fieldDependency)
                
                Spacer()
            }
            .padding(.all, 16)
        }
    }
}

struct EditTableDropdownRows: View {
    @State var selectedDropdownValueID: String?
    @State private var isSheetPresented = false
    private let fieldDependency: FieldDependency
    
    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
        if let value = fieldDependency.fieldData?.value?.dropdownValue {
            _selectedDropdownValueID = State(initialValue: value)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                isSheetPresented = true
                let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                fieldDependency.eventHandler.onFocus(event: fieldEvent)
            }, label: {
                HStack {
                    Text(fieldDependency.fieldData?.options?.filter {
                        $0.id == selectedDropdownValueID
                    }.first?.value  ?? "Select Option")
                    .darkLightThemeColor()
                    .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .frame(maxWidth: .infinity)
                .padding(.all, 10)
            })
            .accessibilityIdentifier("EditTableDropdown")
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
            )
            .sheet(isPresented: $isSheetPresented) {
                if #available(iOS 16, *) {
                    DropDownOptionList(fieldDependency: fieldDependency, selectedDropdownValueID: $selectedDropdownValueID)
                        .presentationDetents([.medium])
                } else {
                    DropDownOptionList(fieldDependency: fieldDependency, selectedDropdownValueID: $selectedDropdownValueID)
                }
            }
        }
        .onChange(of: selectedDropdownValueID) { newValue in
            let newDrodDownValue = ValueUnion.string(newValue ?? "")
            guard fieldDependency.fieldData?.value != newDrodDownValue else { return }
            guard var fieldData = fieldDependency.fieldData else {
                fatalError("FieldData should never be null")
            }
            fieldData.value = newDrodDownValue
            fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData))
        }
    }
}


struct EditTableDropdownRowsOptionList: View {
    @Environment(\.presentationMode) var presentationMode
    private let fieldDependency: FieldDependency
    @Binding var selectedDropdownValueID: String?
    
    public init(fieldDependency: FieldDependency, selectedDropdownValueID: Binding<String?>) {
        self.fieldDependency = fieldDependency
        self._selectedDropdownValueID = selectedDropdownValueID
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark.circle")
                        .imageScale(.large)
                })
                .padding(.horizontal, 16)
            }
            ScrollView {
                if let options = fieldDependency.fieldData?.options?.filter({ !($0.deleted ?? false) }) {
                    ForEach(options) { option in
                        Button(action: {
                            if selectedDropdownValueID == option.id {
                                selectedDropdownValueID = nil
                            } else {
                                selectedDropdownValueID = option.id
                            }
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            HStack(alignment: .top) {
                                Image(systemName: (selectedDropdownValueID == option.id) ? "checkmark.circle.fill" : "circle")
                                    .padding(.top, 4)
                                Text(option.value ?? "")
                                    .darkLightThemeColor()
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding(.horizontal, 28)
                            .padding(.vertical, 10)
                        })
                        .accessibilityIdentifier("DropdownoptionIdentifier")
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 20)
    }
}
