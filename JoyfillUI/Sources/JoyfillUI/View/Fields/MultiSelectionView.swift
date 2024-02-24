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
    @State var isSelected: Bool = false
    
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
                  ForEach(0..<options.count) { index in
                    let optionValue = options[index].value ?? ""
                    let isSelected = fieldData?.value?.multiSelector?.first(where: {
                      $0 == options[index].id
                    }) != nil
                    MultiSelection(option: optionValue, isSelected: isSelected)
                  }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct MultiSelection: View {
    var option: String
    @State var isSelected: Bool
    var body: some View {
        Button(action: {
            isSelected.toggle()
        }, label: {
            
            HStack {
                Image(systemName: isSelected ? "record.circle.fill" : "record.circle")
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
