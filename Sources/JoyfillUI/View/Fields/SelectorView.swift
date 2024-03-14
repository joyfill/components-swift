//
//  SelectorView.swift
//  JoyFill
//
//

import SwiftUI

// Select only one option

struct SelectorView: View {
    @State var toggle: Bool = true
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Selector")
                .font(.headline.bold())
            Button(action: {
                toggle.toggle()
            }, label: {
                HStack {
                    Image(systemName: toggle ? "record.circle.fill" : "record.circle")
                    Text("Yes")
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding()
            })
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
                    .frame(maxWidth: .infinity)
            )
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    SelectorView()
}
