//
//  DropdownView.swift
//  JoyFill
//
//  Created by Babblu Bhaiya on 10/02/24.
//

import SwiftUI
import JoyfillModel

struct DropdownView: View {
    var value: ValueUnion?
    @State var selectedDropdownValue: String = ""
    
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
            Text("Dropdown")
                .fontWeight(.bold)
            
                Picker("Select", selection: $selectedDropdownValue) {
                    Text("Yes").tag("Yes")
                    Text("No").tag("No")
                    Text("N/A").tag("N/A")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .colorMultiply(selectedDropdownValue == "" ? .secondary : .black)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(maxWidth: .infinity)
                )
        }
        .onAppear{
            
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    DropdownView(eventHandler: FieldEventHandler(), fieldPosition: testDocument().fieldPosition!, fieldData: testDocument().fields!.first)
}
