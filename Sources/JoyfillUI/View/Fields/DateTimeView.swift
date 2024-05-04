import SwiftUI
import JoyfillModel

struct DateTimeView: View {
    @State private var isDatePickerPresented = false
    @State private var selectedDate = Date()
    
    var fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool
    
    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
        if let value = fieldDependency.fieldData?.value {
            let dateString = value.dateTime(format: fieldDependency.fieldPosition.format ?? "") ?? ""
            if let date = stringToDate(dateString, format: fieldDependency.fieldPosition.format ?? "") {
                _selectedDate = State(initialValue: date)
                _isDatePickerPresented = State(initialValue: true)
            }
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy h:mm a"
        return formatter
    }()
    
    var body: some View {
        FieldHeaderView(fieldDependency)
        Group {
            if isDatePickerPresented {
                DatePicker("", selection: $selectedDate, displayedComponents: getDateType(format: fieldDependency.fieldPosition.format ?? ""))
                    .accessibilityIdentifier("field_6629fb44309fbfe84376095e")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .labelsHidden()
                    .padding(.all, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.allFieldBorderColor, lineWidth: 1)
                    )
            } else {
                HStack {
                    Text("Select a Date -")
                    Spacer()
                    Image(systemName: "calendar")
                }
                .frame(maxWidth: .infinity)
                .padding(.all, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
                .onTapGesture {
                    isDatePickerPresented = true
                    selectedDate = Date()
                }
            }
        }
        .onChange(of: selectedDate) { newValue in
            let convertDateToInt = dateToTimestampMilliseconds(date: selectedDate)
            let newDateValue = ValueUnion.double(convertDateToInt)
            guard fieldDependency.fieldData?.value != newDateValue else { return }
            guard var fieldData = fieldDependency.fieldData else {
                fatalError("FieldData should never be null")
            }
            fieldData.value = newDateValue
            fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData))
        }
    }
    
    func stringToDate(_ dateString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatType(rawValue: format)?.dateFormat ?? ""
        return dateFormatter.date(from: dateString)
    }
    
    func getDateType(format: String) -> DatePickerComponents {
        switch DateFormatType(rawValue: format) {
        case .dateOnly:
            return [.date]
        case .timeOnly:
            return [.hourAndMinute]
        case .dateTime:
            return [.date, .hourAndMinute]
        case .none:
            return [.date, .hourAndMinute]
        case .some(.empty):
            return [.date, .hourAndMinute]
        }
    }
}
