//
//  TextView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel

// Single line text

struct TextView: View {
    @State var enterText: String = ""
    private var fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool
    
    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = fieldDependency.fieldData?.title {
                HStack(spacing: 30) {
                    Text("\(title)")
                        .font(.headline.bold())
                    
                    if fieldDependency.fieldData?.fieldRequired == true && enterText.isEmpty {
                        Image(systemName: "asterisk")
                            .foregroundColor(.red)
                            .imageScale(.small)
                    }
                }
            }
            
            TextField("", text: $enterText)
                .disabled(fieldDependency.mode == .readonly)
                .padding(.horizontal, 10)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
                .cornerRadius(10)
                .focused($isFocused)
                .onChange(of: isFocused) { focused in
                    if focused {
                        let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                        fieldDependency.eventHandler.onFocus(event: fieldEvent)
                    } else {
                        let change = FieldChange(changeData: ["value" : enterText])
                        fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldDependency.fieldData, changes: change))
                    }
                }
        }
        .onAppear {
            if let text = fieldDependency.fieldData?.value?.text {
                enterText = text
            }
        }
    }
}
