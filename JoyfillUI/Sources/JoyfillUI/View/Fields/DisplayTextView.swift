//
//  DisplayTextView.swift
//  JoyFill
//
//  Created by Vikash on 10/02/24.
//

import SwiftUI
import JoyfillModel

// Title or Description

struct DisplayTextView: View {
    var value: ValueUnion?
    @State var displayText: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Display Text")
                .fontWeight(.bold)

            TextField("", text: $displayText)
                .padding(.horizontal, 10)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .cornerRadius(10)
        }
        .onAppear{
            if let text = value?.textabc {
                displayText = text
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    DisplayTextView(displayText: "")
}
