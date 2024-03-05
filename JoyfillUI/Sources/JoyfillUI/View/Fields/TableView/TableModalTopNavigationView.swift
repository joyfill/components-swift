//
//  SwiftUIView.swift
//  
//
//  Created by Nand Kishore on 04/03/24.
//

import SwiftUI

struct TableModalTopNavigationView: View {
    @Binding var isDeleteButtonVisible: Bool
    var onDeleteTap: (() -> Void)?
    var onAddRowTap: (() -> Void)?
    
    var body: some View {
        HStack {
            Text("Table Title")
                .lineLimit(1)
                .fontWeight(.bold)
            
            Spacer()
            if isDeleteButtonVisible {
                Button(action: {
                    onDeleteTap?()
                }) {
                    Text("Delete")
                        .foregroundStyle(.red)
                        .font(.system(size: 14))
                        .frame(width: 80, height: 27)
                        .overlay(RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.red, lineWidth: 1))
                }
            }
          
            
            Button(action: {
                onAddRowTap?()
            }) {
                Text("Add Row +")
                    .foregroundStyle(.black)
                    .font(.system(size: 14))
                    .frame(width: 94, height: 27)
                    .overlay(RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.buttonBorderColor, lineWidth: 1))
            }
            
        }
    }
}

#Preview {
    TableModalTopNavigationView(isDeleteButtonVisible: .constant(true))
}
