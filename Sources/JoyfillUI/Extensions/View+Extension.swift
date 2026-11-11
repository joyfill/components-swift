//
//  File.swift
//  
//
//  Created by Nand Kishore on 04/03/24.
//

import Foundation
import SwiftUI

extension View {
    /// Puts the modal's title in the nav bar and hosts the trailing controls as separate toolbar items — each gets its own Liquid Glass capsule on iOS 26+.
    func modalTopBar<Trailing: ToolbarContent>(
        title: String,
        @ToolbarContentBuilder trailing: () -> Trailing
    ) -> some View {
        // Custom title so a long title wraps and scrolls within the bar instead of truncating.
        let titleView = ScrollView(.vertical, showsIndicators: false) {
            Text(title)
                .font(.headline.bold())
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: 44)
        return self.navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) { titleView }
                trailing()
            }
    }

    @ViewBuilder
    func disableHoverEffect() -> some View {
        if #available(iOS 17.0, *) { self.hoverEffectDisabled() } else { self }
    }

    /// Applied only to the table/collection grid scroll area so the grid runs edge-to-edge while the rest of the modal keeps its safe-area insets.
    @ViewBuilder
    func fullWidth(_ documentEditor: DocumentEditor?) -> some View {
        if let documentEditor {
            modifier(FullWidthModifier(documentEditor: documentEditor))
        } else {
            self
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

/// Observes the editor so a runtime `usesFullWidth` change re-lays out the surface.
private struct FullWidthModifier: ViewModifier {
    @ObservedObject var documentEditor: DocumentEditor

    func body(content: Content) -> some View {
        content.ignoresSafeArea(.container, edges: documentEditor.usesFullWidth ? .horizontal : [])
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
