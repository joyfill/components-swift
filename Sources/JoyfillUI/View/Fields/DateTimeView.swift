import SwiftUI
import JoyfillModel

struct DateTimeView: View {
    @State private var isDatePickerPresented = false
    @State private var selectedDate = Date()
    private var dateTimeDataModel: DateTimeDataModel
    let eventHandler: FieldChangeEvents

    public init(dateTimeDataModel: DateTimeDataModel, eventHandler: FieldChangeEvents) {
        self.dateTimeDataModel = dateTimeDataModel
        self.eventHandler = eventHandler
        if let value = dateTimeDataModel.value {
            let dateString = value.dateTime(format: dateTimeDataModel.format ?? .empty) ?? ""
                        if let date = Utility.stringToDate(dateString, format: dateTimeDataModel.format ?? .empty) {
                _selectedDate = State(initialValue: date)
                _isDatePickerPresented = State(initialValue: true)
            }
        }
    }
    
    var body: some View {
        FieldHeaderView(dateTimeDataModel.fieldHeaderModel)
        Group {
            if isDatePickerPresented {
                DatePicker("", selection: $selectedDate, displayedComponents: Utility.getDateType(format: dateTimeDataModel.format ?? .empty))
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
            let event = FieldChangeData(fieldIdentifier: dateTimeDataModel.fieldIdentifier, updateValue: newDateValue)
            eventHandler.onChange(event: event)
            eventHandler.onFocus(event: dateTimeDataModel.fieldIdentifier)
        }
    }
}

