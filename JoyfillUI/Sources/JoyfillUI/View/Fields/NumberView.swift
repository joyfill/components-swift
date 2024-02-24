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
    @State var number: String = ""
    
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
            Text("Number")
                .fontWeight(.bold)
            
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
            if let number = fieldData?.value?.number {
                self.number = String(number)
            }
        }
    }
}

#Preview {
    NumberView(eventHandler: FieldEventHandler(), fieldPosition: testDocument().fieldPosition!, fieldData: testDocument().fields!.first)
}
