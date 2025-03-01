//
//  File.swift
//  
//
//  Created by Nand Kishore on 04/03/24.
//

import Foundation
import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner, borderColor: Color, lineWidth: CGFloat = 1) -> some View {
        self
            .clipShape( RoundedCorner(radius: radius, corners: corners) )
            .overlay(
                RoundedCorner(radius: radius, corners: corners)
                    .stroke(borderColor, lineWidth: lineWidth)
            )
    }
}

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
