import SwiftUI
import JoyfillModel

struct MultiSelectionView: View {
    @State var isSelected: Bool = false
    @State var singleSelectedOptionArray: [String] = []
    @State var multiSelectedOptionArray: [String] = []
    
    private let multiSelectionDataModel: MultiSelectionDataModel
    private let currentFocusedFielsID: String?
    @FocusState private var isFocused: Bool
    
    public init(multiSelectionDataModel: MultiSelectionDataModel) {
        self.multiSelectionDataModel = multiSelectionDataModel
        self.currentFocusedFielsID = multiSelectionDataModel.currentFocusedFieldsDataId
        if multiSelectionDataModel.multi ?? true {
            if let values = multiSelectionDataModel.multiSelector {
                _multiSelectedOptionArray = State(initialValue: values)
            }
        } else {
            if let values = multiSelectionDataModel.multiSelector {
                _singleSelectedOptionArray = State(initialValue: values)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            FieldHeaderView(multiSelectionDataModel.fieldHeaderModel)
            VStack {
                if let options = multiSelectionDataModel.options?.filter({ !($0.deleted ?? false) }) {
                    ForEach(0..<options.count, id: \.self) { index in
                        let optionValue = options[index].value ?? ""
                        let isSelected = multiSelectionDataModel.multiSelector?.first(where: {
                            $0 == options[index].id
                        }) != nil
                        if multiSelectionDataModel.multi ?? true {
                            MultiSelection(option: optionValue,
                                           isSelected: isSelected,
                                           multiSelectedOptionArray: $multiSelectedOptionArray,
                                           isAlreadyFocused: currentFocusedFielsID == multiSelectionDataModel.fieldIdentifier.fieldID,
                                           multiSelectionDataModel: multiSelectionDataModel,
                                           selectedItemId: options[index].id ?? "")
                            if index < options.count - 1 {
                                Divider()
                            }
                        } else {
                            RadioView(option: optionValue,
                                      singleSelectedOptionArray: $singleSelectedOptionArray,
                                      isAlreadyFocused: currentFocusedFielsID == multiSelectionDataModel.fieldIdentifier.fieldID,
                                      multiSelectionDataModel: multiSelectionDataModel,
                                      selectedItemId: options[index].id ?? "")
                            if index < options.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    .padding(.vertical, -10)
            )
            .padding(.vertical, 10)
        }
        .onChange(of: singleSelectedOptionArray) { newValue in
            let newSingleSelectedValue = ValueUnion.array(newValue)
            let fieldEvent = FieldChangeData(fieldIdentifier: multiSelectionDataModel.fieldIdentifier, updateValue: newSingleSelectedValue)
            multiSelectionDataModel.eventHandler.onChange(event: fieldEvent)
        }
        .onChange(of: multiSelectedOptionArray) { newValue in
            let newMultiSelectedValue = ValueUnion.array(newValue)
            let fieldEvent = FieldChangeData(fieldIdentifier: multiSelectionDataModel.fieldIdentifier, updateValue: newMultiSelectedValue)
            multiSelectionDataModel.eventHandler.onChange(event: fieldEvent)
        }
    }
}

struct MultiSelection: View {
    var option: String
    @State var isSelected: Bool
    @Binding var multiSelectedOptionArray: [String]
    var isAlreadyFocused: Bool
    var multiSelectionDataModel: MultiSelectionDataModel
    var selectedItemId: String
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
            if isAlreadyFocused == false {
                multiSelectionDataModel.eventHandler.onFocus(event: multiSelectionDataModel.fieldIdentifier)
            }
            if let index = multiSelectedOptionArray.firstIndex(of: selectedItemId) {
                multiSelectedOptionArray.remove(at: index) // Item exists, so remove it
                } else {
                    multiSelectedOptionArray.append(selectedItemId) // Item doesn't exist, so add it
                }
        }, label: {
            HStack(alignment: .top) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .padding(.top, 4)
                    .imageScale(.large)
                Text(option)
                    .darkLightThemeColor()
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        })
        .accessibilityIdentifier("MultiSelectionIdenitfier")
        .frame(maxWidth: .infinity)
    }
}
//Select only one choice
struct RadioView: View {
    var option: String
    @Binding var singleSelectedOptionArray: [String]
    var isAlreadyFocused: Bool
    var multiSelectionDataModel: MultiSelectionDataModel
    var selectedItemId: String
    
    var body: some View {
        Button(action: {
            if singleSelectedOptionArray.contains(selectedItemId) {
                singleSelectedOptionArray = []
            } else {
                singleSelectedOptionArray = [selectedItemId]
            }
            if isAlreadyFocused == false {
                multiSelectionDataModel.eventHandler.onFocus(event: multiSelectionDataModel.fieldIdentifier)
            }
        }, label: {
            HStack(alignment: .top) {
                Image(systemName: singleSelectedOptionArray == [selectedItemId] ? "smallcircle.filled.circle.fill" : "circle")
                    .padding(.top, 4)
                Text(option)
                    .darkLightThemeColor()
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        })
        .accessibilityIdentifier("SingleSelectionIdentifier")
        .frame(maxWidth: .infinity)
    }
}

