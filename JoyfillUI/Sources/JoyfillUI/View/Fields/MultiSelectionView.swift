//
//  MultiSelectionView.swift
//  JoyFill
//
//  Created by Babblu Bhaiya on 10/02/24.
//

import SwiftUI
import JoyfillModel

// Select multiple options

struct MultiSelectionView: View {
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
            Text("Multiselection")
                .fontWeight(.bold)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            VStack {
                if let options = fieldData?.options {
                    ForEach(options) { option in
                        MultiSelection(option: option.value ?? "")
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .onAppear{
//            options = value
        }
    }
}

struct MultiSelection: View {
    var option: String
    @State var toggle: Bool = true
    var body: some View {
        Button(action: {
            toggle.toggle()
        }, label: {
            
            HStack {
                Image(systemName: toggle ? "record.circle.fill" : "record.circle")
                Text(option)
                    .foregroundStyle(.black)
                Spacer()
            }
            .padding()
            
        })
        .frame(maxWidth: .infinity)
        .border(Color.gray, width: 1)
        .padding(.top, -9)
    }
}

#Preview {
    MultiSelectionView(eventHandler: FieldEventHandler(), fieldPosition: testDocument().fieldPosition!, fieldData: testDocument().fields!.first)
}
