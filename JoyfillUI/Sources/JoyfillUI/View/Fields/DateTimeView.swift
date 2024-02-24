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
    var value: ValueUnion?
    @State private var isDatePickerPresented = false
    @State private var selectedDate = Date()
    @State private var showDefaultDate: Bool = true
    
    private let mode: Mode = .fill
    private let eventHandler: FieldEventHandler
    private let fieldPosition: FieldPosition
    private var fieldData: JoyDocField?
    
    public init(eventHandler: FieldEventHandler, fieldPosition: FieldPosition, fieldData: JoyDocField? = nil) {
        self.eventHandler = eventHandler
        self.fieldPosition = fieldPosition
        self.fieldData = fieldData
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
            if let value = self.value {
                let dateString = value.dateTime(format: fieldPosition.format ?? "") ?? ""
                if let date = stringToDate(dateString) {
                    selectedDate = date
                    showDefaultDate = false
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    func stringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy hh:mm a"
        return dateFormatter.date(from: dateString)
    }
}

#Preview {
    DateTimeView(eventHandler: FieldEventHandler(), fieldPosition: testDocument().fieldPosition!, fieldData: testDocument().fields!.first)
}
