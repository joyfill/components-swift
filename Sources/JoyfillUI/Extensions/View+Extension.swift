//
//  File.swift
//  
//
//  Created by Nand Kishore on 04/03/24.
//

import Foundation
import SwiftUI

extension View {
    /// Puts the modal's title and trailing controls in the system nav bar; on iOS 26+ the controls drop the Liquid Glass background.
    @ViewBuilder
    func modalTopBar<Trailing: View>(
        title: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        let trailingView = trailing()
        if #available(iOS 26.0, *) {
            self.navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) { trailingView }
                        .sharedBackgroundVisibility(.hidden)
                }
        } else {
            self.navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) { trailingView }
                }
        }
    }

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
