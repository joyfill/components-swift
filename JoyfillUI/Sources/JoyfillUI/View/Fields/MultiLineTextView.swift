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
    
    private let mode: Mode = .fill
    private let eventHandler: FieldEventHandler
    private let fieldPosition: FieldPosition
    private var fieldData: JoyDocField?
    
    public init(eventHandler: FieldEventHandler, fieldPosition: FieldPosition, fieldData: JoyDocField? = nil) {
        self.eventHandler = eventHandler
        self.fieldPosition = fieldPosition
        self.fieldData = fieldData
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Multiline Text")
                .fontWeight(.bold)
            
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
    MultiLineTextView(eventHandler: FieldEventHandler(), fieldPosition: testDocument().fieldPosition!, fieldData: testDocument().fields!.first)
}
