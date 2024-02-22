//
//  NumberView.swift
//  JoyFill
//
//  Created by Babblu Bhaiya on 10/02/24.
//

import SwiftUI
import JoyfillModel

// Numeric value only

struct NumberView: View {
    var value: ValueUnion?
    @State var number: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Number")
            
            TextField("", text: $number)
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
        .onAppear {
            if let number = value?.number {
                self.number = String(number)
            }
        }
    }
}

#Preview {
    NumberView()
}
