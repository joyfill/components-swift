import SwiftUI
import JoyfillModel

struct DateTimeView: View {
    @State private var isDatePickerPresented = false
    @State private var selectedDate = Date()
    @State private var lastModelValue: ValueUnion?
    @State private var ignoreOnChangeOnModelUpdate = false
    @Environment(\.navigationFocusFieldId) private var navigationFocusFieldId
    private var dateTimeDataModel: DateTimeDataModel
    @State var dateString: String = ""
    let eventHandler: FieldChangeEvents

    public init(dateTimeDataModel: DateTimeDataModel, eventHandler: FieldChangeEvents) {
        self.dateTimeDataModel = dateTimeDataModel
        self.eventHandler = eventHandler
        if let value = dateTimeDataModel.value {
            let dateString = value.dateTime(format: dateTimeDataModel.format ?? .empty, tzId: dateTimeDataModel.timezoneId) ?? ""
            _dateString = State(initialValue: dateString)
            if let date = Utility.stringToDate(dateString, format: dateTimeDataModel.format ?? .empty, tzId: dateTimeDataModel.timezoneId) {
                _selectedDate = State(initialValue: date)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
        FieldHeaderView(dateTimeDataModel.fieldHeaderModel, isFilled: dateTimeDataModel.value?.number != nil)
        Group {
            if !dateString.isEmpty {
                HStack(spacing: 8) {
                    Button {
                        isDatePickerPresented = true
                    } label: {
                        Text(dateString)
                            .darkLightThemeColor()
                            .font(.system(size: 16))
                    }
                    .contentShape(Rectangle())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .circular)
                            .fill(Color(uiColor: .secondarySystemFill))
                    )
                    .accessibilityIdentifier("ChangeDateIdentifier")
                    
                    Spacer()
                    
                    Button(action: {
                        self.dateString = ""
                        let event = FieldChangeData(fieldIdentifier: dateTimeDataModel.fieldIdentifier, updateValue: ValueUnion.null)
                        eventHandler.onFocus(event: dateTimeDataModel.fieldIdentifier)
                        eventHandler.onChange(event: event)
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                    })
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .accessibilityIdentifier("DateClearIdentifier")
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear")
                }
                .padding(.all, 8)
                .fieldBorder(isFocused: navigationFocusFieldId == dateTimeDataModel.fieldIdentifier.fieldID)
            } else {
                HStack {
                    Text("Select a Date -")
                    Spacer()
                    Image(systemName: "calendar")
                        .font(.system(size: 18))
                }
                .frame(maxWidth: .infinity)
                .padding(.all, 10)
                .fieldBorder(isFocused: navigationFocusFieldId == dateTimeDataModel.fieldIdentifier.fieldID)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedDate = Date()
                    convertDateAccToTimezone()
                }
            }
        }
        }
        .datePopup(
            date: $selectedDate,
            components: Utility.getDateType(format: dateTimeDataModel.format ?? .empty),
            isPresented: $isDatePickerPresented,
            onCommit: { _ in },
            timeZone: TimeZone(identifier: dateTimeDataModel.timezoneId ?? TimeZone.current.identifier) ?? .current,
            format: dateTimeDataModel.format ?? .empty
        )
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
            
            self.dateString = newDateValue.dateTime(format: dateTimeDataModel.format ?? .empty, tzId: dateTimeDataModel.timezoneId) ?? ""
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
                    }
                } else {
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
            self.dateString = dateString
            if let date = Utility.stringToDate(dateString, format: dateTimeDataModel.format ?? .empty, tzId: dateTimeDataModel.timezoneId) {
                self.selectedDate = date
            }
        }
    }
}
