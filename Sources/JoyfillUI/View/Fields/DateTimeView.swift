import SwiftUI
import JoyfillModel

struct DateTimeView: View {
    @State private var isDatePickerPresented = false
    @State private var selectedDate = Date()
    @State private var lastModelValue: ValueUnion?
    @State private var ignoreOnChangeOnModelUpdate = false
    private var dateTimeDataModel: DateTimeDataModel
    let eventHandler: FieldChangeEvents

    public init(dateTimeDataModel: DateTimeDataModel, eventHandler: FieldChangeEvents) {
        self.dateTimeDataModel = dateTimeDataModel
        self.eventHandler = eventHandler
        if let value = dateTimeDataModel.value {
            let dateString = value.dateTime(format: dateTimeDataModel.format ?? .empty, tzId: dateTimeDataModel.timezoneId) ?? ""
            if let date = Utility.stringToDate(dateString, format: dateTimeDataModel.format ?? .empty, tzId: dateTimeDataModel.timezoneId) {
                _selectedDate = State(initialValue: date)
                _isDatePickerPresented = State(initialValue: true)
            }
        }
    }
    
    var body: some View {
        FieldHeaderView(dateTimeDataModel.fieldHeaderModel, isFilled: dateTimeDataModel.value?.number != nil)
        Group {
            if isDatePickerPresented {
                HStack(spacing: 8) {
                    DatePicker("", selection: $selectedDate, displayedComponents: Utility.getDateType(format: dateTimeDataModel.format ?? .empty))
                        .accessibilityIdentifier("DateIdenitfier")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .labelsHidden()
                        .environment(\.timeZone, TimeZone(identifier: dateTimeDataModel.timezoneId ?? TimeZone.current.identifier) ?? .current)

                    Button(action: {
                        isDatePickerPresented.toggle()
                        let event = FieldChangeData(fieldIdentifier: dateTimeDataModel.fieldIdentifier, updateValue: ValueUnion.null)
                        eventHandler.onFocus(event: dateTimeDataModel.fieldIdentifier)
                        eventHandler.onChange(event: event)
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.large)
                            .foregroundStyle(.secondary)
                    })
                    .accessibilityIdentifier("DateClearIdentifier")
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear")
                }
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
                    isDatePickerPresented.toggle()
                    selectedDate = Date()
                    convertDateAccToTimezone()
                }
            }
        }
        .onChange(of: selectedDate) { newValue in
            guard !ignoreOnChangeOnModelUpdate else {
                ignoreOnChangeOnModelUpdate = false
                return
            }
            let convertDateToInt = dateToTimestampMilliseconds(date: selectedDate)
            let newDateValue = ValueUnion.double(convertDateToInt)
            let event = FieldChangeData(fieldIdentifier: dateTimeDataModel.fieldIdentifier, updateValue: newDateValue)
            eventHandler.onFocus(event: dateTimeDataModel.fieldIdentifier)
            eventHandler.onChange(event: event)
        }
        .onAppear {
            lastModelValue = dateTimeDataModel.value
        }
        .onChange(of: dateTimeDataModel.value) { newValue in
            if lastModelValue != newValue {
                if let value = newValue {
                    let dateString = value.dateTime(format: dateTimeDataModel.format ?? .empty, tzId: dateTimeDataModel.timezoneId) ?? ""
                    if let date = Utility.stringToDate(dateString, format: dateTimeDataModel.format ?? .empty, tzId: dateTimeDataModel.timezoneId) {
                        selectedDate = date
                        isDatePickerPresented.toggle()
                    }
                } else {
                    isDatePickerPresented.toggle()
                    ignoreOnChangeOnModelUpdate = true
                    selectedDate = Date()
                }
                lastModelValue = newValue
            }
        }
    }
    
    fileprivate func convertDateAccToTimezone() {
        let timeZone = TimeZone(identifier: dateTimeDataModel.timezoneId ?? TimeZone.current.identifier)
        let convertedDate = Utility.convertEpochBetweenTimezones(epochMillis: dateToTimestampMilliseconds(date: selectedDate), from: TimeZone.current, to: timeZone ?? TimeZone.current, format: dateTimeDataModel.format)
        
        if let dateString = ValueUnion.double(convertedDate).dateTime(format: dateTimeDataModel.format ?? .empty, tzId: dateTimeDataModel.timezoneId) {
            if let date = Utility.stringToDate(dateString, format: dateTimeDataModel.format ?? .empty, tzId: dateTimeDataModel.timezoneId) {
                self.selectedDate = date
            }
        }
    }
}
