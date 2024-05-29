import SwiftUI
import JoyfillModel

struct PDFDropdownView: View {
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
        HStack() {
            
            if let options = fieldDependency.fieldData?.options {
                let optionID = fieldDependency.fieldData?.options![0].id
                if optionID == fieldDependency.fieldPosition.targetValue {
                    ForEach(options) { option in
                        Button(action: {
                            let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                            fieldDependency.eventHandler.onFocus(event: fieldEvent)
                            if selectedDropdownValueID == option.id {
                                selectedDropdownValueID = nil
                            } else {
                                selectedDropdownValueID = option.id
                            }
                        }, label: {
                            Image(systemName: "checkmark")
                        })
                    }
                }
            }
            
//            Button(action: {
//                isSheetPresented = true
//                let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
//                fieldDependency.eventHandler.onFocus(event: fieldEvent)
//            }, label: {
//                HStack {
//                    Text(fieldDependency.fieldData?.options?.filter {
//                        $0.id == selectedDropdownValueID
//                    }.first?.value  ?? "Select Option")
//                    .darkLightThemeColor()
//                    .lineLimit(1)
//                    Spacer()
//                    Image(systemName: "chevron.down")
//                }
//                .frame(maxWidth: .infinity)
//                .padding(.all, 10)
//            })
//            .accessibilityIdentifier("Dropdown")
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
//            )
//            .sheet(isPresented: $isSheetPresented) {
//
//                if #available(iOS 16, *) {
//                    PDFDropDownOptionList(fieldDependency: fieldDependency, selectedDropdownValueID: $selectedDropdownValueID)
//                        .presentationDetents([.medium])
//                    } else {
//                        PDFDropDownOptionList(fieldDependency: fieldDependency, selectedDropdownValueID: $selectedDropdownValueID)
//                    }
//            }
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


struct PDFDropDownOptionList: View {
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
                if let options = fieldDependency.fieldData?.options {
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



