//
//  DateTimeView.swift
//  JoyFill
//
//  Created by Babblu Bhaiya on 10/02/24.
//

import SwiftUI
import JoyfillModel

// Date and time

struct DateTimeView: View {
    @State private var isDatePickerPresented = false
    @State private var selectedDate = Date()
    @State private var showDefaultDate: Bool = true
    
    private let fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool // Declare a FocusState property

    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy h:mm a"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Date & Time")
                .fontWeight(.bold)
            
            Group {
                if showDefaultDate == false {
                    DatePicker("Date-Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .frame(height: 40)
                        .padding(.all, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(maxWidth: .infinity)
                        )
                } else {
                    if isDatePickerPresented {
                        DatePicker("Date-Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                            .frame(height: 40)
                            .padding(.all, 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                                    .frame(maxWidth: .infinity)
                            )
                    } else {
                        HStack {
                            Text("Select a Date -")
                            Spacer()
                            Image(systemName: "calendar")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .padding(.all, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(maxWidth: .infinity)
                        )
                        .onTapGesture {
                            isDatePickerPresented = true
                        }
                    }
                }
            }
        }
        .onAppear{
            if let value = fieldDependency.fieldData?.value {
                let dateString = value.dateTime(format: fieldDependency.fieldPosition.format ?? "") ?? ""
                if let date = stringToDate(dateString, format: fieldDependency.fieldPosition.format ?? "") {
                    selectedDate = date
                    showDefaultDate = false
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    func stringToDate(_ dateString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter.date(from: dateString)
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
