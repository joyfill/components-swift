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
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Date & Time")
            
            Group {
                if isDatePickerPresented {
                    DatePicker("Select a date", selection: $selectedDate, displayedComponents: .date)
                        .frame(height: 40)
                        .padding(.all, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(maxWidth: .infinity)
                        )
                } else {
                    HStack {
                        Text("Select a date ")
                        Spacer()
                        Text("dd/mm/yy")
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
        .onAppear{
            
        }
        .padding(.horizontal, 16)
    }
    
    func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: date)
    }
}

#Preview {
    DateTimeView()
}
