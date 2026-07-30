import SwiftUI
import JoyfillModel

// 1. A lightweight presentation token that decouples from active memory pointers
enum DropdownPresentationState: Identifiable {
    case active(model: DropdownDataModel)
    
    var id: String {
        switch self {
        case .active(let model):
            return model.fieldIdentifier.fieldID
        }
    }
}

struct DropdownView: View {
    @State var selectedDropdownValueID: String?
    @State private var presentationState: DropdownPresentationState? = nil
    @Environment(\.navigationFocusFieldId) private var navigationFocusFieldId
    private var dropdownDataModel: DropdownDataModel

    let eventHandler: FieldChangeEvents

    public init(dropdownDataModel: DropdownDataModel, eventHandler: FieldChangeEvents) {
        self.eventHandler = eventHandler
        self.dropdownDataModel = dropdownDataModel
        if let value = dropdownDataModel.dropdownValue {
            _selectedDropdownValueID = State(initialValue: value)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            FieldHeaderView(dropdownDataModel.fieldHeaderModel, isFilled: !(selectedDropdownValueID?.isEmpty ?? true)) { decorator in
                eventHandler.onDecoratorAction(event: dropdownDataModel.fieldIdentifier, action: decorator.action ?? "")
            }
            Button(action: {
                eventHandler.onFocus(event: dropdownDataModel.fieldIdentifier)
                presentationState = .active(model: dropdownDataModel)
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
            .buttonStyle(BorderlessButtonStyle())
            .fieldBorder(isFocused: navigationFocusFieldId == dropdownDataModel.fieldIdentifier.fieldID)
        }
        .sheet(item: $presentationState) { state in
            switch state {
            case .active(let model):
                if #available(iOS 16, *) {
                    DropDownOptionList(
                        dropdownDataModel: model,
                        initialSelectionID: selectedDropdownValueID,
                        onSelectionChanged: { newID in
                            self.selectedDropdownValueID = newID
                        }
                    )
                    .presentationDetents([.medium])
                } else {
                    DropDownOptionList(
                        dropdownDataModel: model,
                        initialSelectionID: selectedDropdownValueID,
                        onSelectionChanged: { newID in
                            self.selectedDropdownValueID = newID
                        }
                    )
                }
            }
        }
        .onChange(of: selectedDropdownValueID) { newValue in
            if newValue == dropdownDataModel.dropdownValue {
                return
            }
            let newDrodDownValue = ValueUnion.string(newValue ?? "")
            let fieldEvent = FieldChangeData(fieldIdentifier: dropdownDataModel.fieldIdentifier, updateValue: newDrodDownValue)
            eventHandler.onChange(event: fieldEvent)
        }
        .onChange(of: dropdownDataModel.dropdownValue) { newValue in
            if selectedDropdownValueID != newValue {
                selectedDropdownValueID = newValue
            }
        }
    }
}


struct DropDownOptionList: View {
    @Environment(\.presentationMode) var presentationMode
    private var dropdownDataModel: DropdownDataModel
    @State private var currentSelectionID: String?
    let onSelectionChanged: (String?) -> Void
    
    public init(dropdownDataModel: DropdownDataModel, initialSelectionID: String?, onSelectionChanged: @escaping (String?) -> Void) {
        self.dropdownDataModel = dropdownDataModel
        self._currentSelectionID = State(initialValue: initialSelectionID)
        self.onSelectionChanged = onSelectionChanged
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
                .buttonStyle(BorderlessButtonStyle())
            }
            ScrollView {
                if let options = dropdownDataModel.options?.filter({ !($0.deleted ?? false) }) {
                    ForEach(options) { option in
                        Button(action: {
                            let targetedID = (currentSelectionID == option.id) ? nil : option.id
                            
                            // 1. Update sheet view local state layout immediately
                            currentSelectionID = targetedID
                            
                            // 2. Safely bubble values back to the core parent object
                            onSelectionChanged(targetedID)
                            
                            // 3. Close the modal view cleanly
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            HStack(alignment: .top) {
                                Image(systemName: (currentSelectionID == option.id) ? "checkmark.circle.fill" : "circle")
                                    .padding(.top, 4)
                                Text(option.value ?? "")
                                    .darkLightThemeColor()
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding(.horizontal, 28)
                            .padding(.vertical, 10)
                            .contentShape(Rectangle()) // Ensures tap stability across the entire row
                        })
                        .buttonStyle(BorderlessButtonStyle())
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
