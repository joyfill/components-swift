import SwiftUI
import JoyfillModel

struct DateTimeView: View {
    @State private var isDatePickerPresented = false
    @State private var isDatePickerVisible = false
    @State private var selectedDate = Date()
    private var dateTimeDataModel: DateTimeDataModel
    @FocusState private var isFocused: Bool
    
    public init(dateTimeDataModel: DateTimeDataModel) {
        self.dateTimeDataModel = dateTimeDataModel
        if let value = dateTimeDataModel.value {
            let dateString = value.dateTime(format: dateTimeDataModel.format ?? "") ?? ""
            if let date = stringToDate(dateString, format: dateTimeDataModel.format ?? "") {
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
        FieldHeaderView(dateTimeDataModel.fieldHeaderModel)
        Group {
            if isDatePickerPresented {
                DatePicker("", selection: $selectedDate, displayedComponents: getDateType(format: dateTimeDataModel.format ?? ""))
                    .accessibilityIdentifier("DateIdenitfier")
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
            let event = FieldChangeData(fieldID: dateTimeDataModel.fieldId, pageID: dateTimeDataModel.pageId, fileID: dateTimeDataModel.fileId, updateValue: newDateValue)
            dateTimeDataModel.eventHandler.onChange(event: event)
            let fieldEvent = FieldEvent(fieldID: dateTimeDataModel.fieldId, pageID: dateTimeDataModel.pageId, fileID: dateTimeDataModel.fileId)
            dateTimeDataModel.eventHandler.onFocus(event: fieldEvent)
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

