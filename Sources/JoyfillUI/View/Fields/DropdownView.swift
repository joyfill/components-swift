import SwiftUI
import JoyfillModel

struct DropdownView: View {
    @State var selectedDropdownValueID: String?
    @State private var isSheetPresented = false
    private var dropdownDataModel: DropdownDataModel
    
    public init(dropdownDataModel: DropdownDataModel) {
        self.dropdownDataModel = dropdownDataModel
        if let value = dropdownDataModel.dropdownValue {
            _selectedDropdownValueID = State(initialValue: value)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            FieldHeaderView(dropdownDataModel.fieldHeaderModel)
            Button(action: {
                isSheetPresented = true
                let fieldEvent = FieldEventInternal(fieldID: dropdownDataModel.fieldId!)
                dropdownDataModel.eventHandler.onFocus(event: fieldEvent)
            }, label: {
                HStack {
                    Text(dropdownDataModel.options?.filter {
                        $0.id == selectedDropdownValueID
                    }.first?.value  ?? "Select Option")
                    .darkLightThemeColor()
                    .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
                .frame(height: 40)
            })
            .accessibilityIdentifier("Dropdown")
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
            )
            .sheet(isPresented: $isSheetPresented) {
                if #available(iOS 16, *) {
                    DropDownOptionList(dropdownDataModel: dropdownDataModel, selectedDropdownValueID: $selectedDropdownValueID)
                        .presentationDetents([.medium])
                } else {
                    DropDownOptionList(dropdownDataModel: dropdownDataModel, selectedDropdownValueID: $selectedDropdownValueID)
                }
            }
        }
        .onChange(of: selectedDropdownValueID) { newValue in
            let newDrodDownValue = ValueUnion.string(newValue ?? "")
            let fieldEvent = FieldChangeEvent(fieldID: dropdownDataModel.fieldId!, updateValue: newDrodDownValue)
            dropdownDataModel.eventHandler.onChange(event: fieldEvent)
        }
    }
}


struct DropDownOptionList: View {
    @Environment(\.presentationMode) var presentationMode
    private var dropdownDataModel: DropdownDataModel
    @Binding var selectedDropdownValueID: String?
    
    public init(dropdownDataModel: DropdownDataModel, selectedDropdownValueID: Binding<String?>) {
        self.dropdownDataModel = dropdownDataModel
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
                if let options = dropdownDataModel.options?.filter({ !($0.deleted ?? false) }) {
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

