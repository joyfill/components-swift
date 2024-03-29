//
//  DateTimeView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel

// Date and time

struct DateTimeView: View {
    @State private var isDatePickerPresented = false
    @State private var selectedDate = Date()
    @State private var showDefaultDate: Bool = true
    
    var fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool
    
    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
        if let value = fieldDependency.fieldData?.value {
            let dateString = value.dateTime(format: fieldDependency.fieldPosition.format ?? "") ?? ""
            if let date = stringToDate(dateString, format: fieldDependency.fieldPosition.format ?? "") {
                _selectedDate = State(initialValue: date)
                _showDefaultDate = State(initialValue: false)
            }
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy h:mm a"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = fieldDependency.fieldData?.title {
                HStack(alignment: .top) {
                    Text("\(title)")
                        .font(.headline.bold())
                    
                    if fieldDependency.fieldData?.fieldRequired == true && showDefaultDate == true {
                        Image(systemName: "asterisk")
                            .foregroundColor(.red)
                            .imageScale(.small)
                    }
                }
            }
            
            Group {
                if showDefaultDate == false {
                    DatePicker("", selection: $selectedDate, displayedComponents: getDateType(format: fieldDependency.fieldPosition.format ?? ""))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .labelsHidden()
                        .padding(.all, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.allFieldBorderColor, lineWidth: 1)
                        )
                } else {
                    if isDatePickerPresented {
                        DatePicker("", selection: $selectedDate, displayedComponents: getDateType(format: fieldDependency.fieldPosition.format ?? ""))
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
                            showDefaultDate = false
                        }
                    }
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

public func testDocument() -> JoyDoc {
    if let url = Bundle.main.url(forResource: "RetriveDocument", withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let joyDocStruct = try JSONDecoder().decode(JoyDoc.self, from: data)
            return joyDocStruct
        } catch {
            print("Error reading JSON file:", error)
        }
    } else {
        print("File not found")
    }
    fatalError()
}
