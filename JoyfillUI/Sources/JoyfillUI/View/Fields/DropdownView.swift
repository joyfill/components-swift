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
    @State var selectedPaymentMethod = "Select"
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Dropdown")
                Picker("Select", selection: $selectedPaymentMethod) {
                    Text("Yes").tag("Yes")
                    Text("No").tag("No")
                    Text("N/A").tag("N/A")
                }
                .frame(maxWidth: .infinity)
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
    DropdownView()
}
