//
//  DropdownView.swift
//  JoyFill
//
//  Created by Babblu Bhaiya on 10/02/24.
//

import SwiftUI
import JoyfillModel

struct DropdownView: View {
    @State var selectedDropdownValue: String?
    
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
                if let options = fieldData?.options {
                    ForEach(options) { option in
                        Text(option.value ?? "").tag("\(option.value)")
                    }
                }
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
            if let value = fieldData?.value {
                self.selectedDropdownValue = fieldData?.options?.filter { $0.id == value.dropdownValue }.first?.value ?? ""
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    DropdownView(eventHandler: FieldEventHandler(), fieldPosition: testDocument().fieldPosition!, fieldData: testDocument().fields!.first)
}
