//
//  TextView.swift
//  JoyFill
//
//  Created by Babblu Bhaiya on 10/02/24.
//

import SwiftUI

// Single line text

struct TextView: View {
    @State private var lastName: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Text")
            
            TextField("", text: $lastName)
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
    TextView()
}
