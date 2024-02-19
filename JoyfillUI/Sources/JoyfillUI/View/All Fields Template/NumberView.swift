//
//  NumberView.swift
//  JoyFill
//
//  Created by Babblu Bhaiya on 10/02/24.
//

import SwiftUI

// Numeric value only

struct NumberView: View {
    @State private var phoneNumber: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Number")
            
            TextField("", text: $phoneNumber)
                .padding(.horizontal, 16)
                .keyboardType(.numberPad)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .cornerRadius(10)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    NumberView()
}
