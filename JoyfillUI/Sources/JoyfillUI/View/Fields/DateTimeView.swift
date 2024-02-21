//
//  DateTimeView.swift
//  JoyFill
//
//  Created by Babblu Bhaiya on 10/02/24.
//

import SwiftUI

// Date and time

struct DateTimeView: View {
    @State private var isDatePickerPresented = false
    @State private var selectedDate = Date()
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Date & Time")
            
            DatePicker("Select a date", selection: $selectedDate, displayedComponents: .date)
                .padding(.all, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(maxWidth: .infinity)
                )
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
