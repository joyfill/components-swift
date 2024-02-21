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
    var value: ValueUnion?
    @State var options: [String] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Multiselection")
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            VStack {
                ForEach(options, id: \.self) { option in
                    MultiSelection(option: option)
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
    MultiSelectionView(options: ["Yes","NO","N/A"])
}
