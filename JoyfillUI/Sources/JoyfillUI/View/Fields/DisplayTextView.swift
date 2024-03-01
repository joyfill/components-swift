//
//  DisplayTextView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel

struct DisplayTextView: View {
    @State var displayText: String = ""
    private let fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool // Declare a FocusState property
    
    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("\(displayText)")
                .fontWeight(.bold)
        }
        .onAppear {
            if let hello = fieldDependency.fieldData?.value?.displayText {
                displayText = hello
            }
        }
        .onChange(of: displayText, { oldValue, newValue in
            let change = ["value": newValue]
            let changeEvent = ChangeEvent(changes: [Change(changeData: change)])
            fieldDependency.eventHandler.onChange(event: changeEvent)
        })
        .padding(.horizontal, 16)
    }
}

