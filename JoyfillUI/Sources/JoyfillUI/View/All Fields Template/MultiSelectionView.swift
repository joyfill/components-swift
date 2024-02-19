//
//  MultiSelectionView.swift
//  JoyFill
//
//  Created by Babblu Bhaiya on 10/02/24.
//

import SwiftUI

// Select multiple options

struct MultiSelectionView: View {
    @State var options: [String]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(options, id: \.self) { option in
                    MultiSelection(option: option)
                        .padding(.horizontal)
                }
            }
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
            }
            
        })
    }
}

#Preview {
    MultiSelectionView(options: ["Yes","NO"])
}
