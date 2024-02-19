//
//  MultiLineTextView.swift
//  JoyFill
//
//  Created by Babblu Bhaiya on 10/02/24.
//

import SwiftUI

// MultiLine text

struct MultiLineTextView: View {
    @State private var yourBio: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Multiline Text")
            
            TextEditor(text: $yourBio)
                .autocorrectionDisabled()
                .frame(height: 200)
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
    MultiLineTextView()
}
