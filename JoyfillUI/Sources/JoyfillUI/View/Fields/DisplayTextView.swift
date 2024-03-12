//
//  DisplayTextView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel

struct DisplayTextView: View {
    @State var displayText: String = ""
    private var fieldDependency: FieldDependency
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
            if let data = fieldDependency.fieldData?.value?.displayText {
                displayText = data
            }
        }
        .onChange(of: displayText, { oldValue, newValue in
            guard var fieldData = fieldDependency.fieldData else { return }
            fieldData.value = .string(newValue)
            let change = FieldChange(changeData: ["value" : newValue])
            fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData, changes: change))
        })
    }
}

