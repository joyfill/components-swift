//
//  MultiLineTextView.swift
//  JoyFill
//
//  Created by Babblu Bhaiya on 10/02/24.
//

import SwiftUI
import JoyfillModel

// MultiLine text

struct MultiLineTextView: View {
    var value: ValueUnion?
    @State var multilineText: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Multiline Text")
                TextEditor(text: $multilineText)
                    .autocorrectionDisabled()
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .cornerRadius(10)
        }
        .onAppear{
            if let multilineText = value?.multilineText{
                self.multilineText = multilineText
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    MultiLineTextView(multilineText: "")
}
