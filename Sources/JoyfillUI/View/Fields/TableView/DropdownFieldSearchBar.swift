//
//  File.swift
//  
//
//  Created by Vishnu Dutt on 11/12/24.
//

import SwiftUI

struct DropdownFieldSearchBar: View {
    var body: some View {
        Button(action: {

        }, label: {
            HStack {
                Text("Select Option")
                .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.down")
            }
            .foregroundStyle(.gray)
            .font(.system(size: 12))
            .padding(.all, 6)
            .frame(height: 25)
            .background(.white)
            .cornerRadius(6)
            .padding(.leading, 8)
        })
    }
}
