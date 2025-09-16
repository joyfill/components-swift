//
//  File.swift
//  
//
//  Created by Vishnu Dutt on 11/12/24.
//

import SwiftUI

struct TextFieldSearchBar: View {
    @Binding var text: String

    var body: some View {
        TextField("Search ", text: $text)
            .accessibilityIdentifier("TextFieldSearchBarIdentifier")
            .font(.system(size: 12))
            .foregroundColor(.black)
            .padding(.all, 4)
            .background(.white)
            .cornerRadius(6)
            .padding(.leading, 8)
            .overlay(
                HStack {
                    Spacer()
                    if !text.isEmpty {
                        Button(action: {
                            self.text = ""
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.all, 4)
                        }
                    }
                }
            )
    }
}
