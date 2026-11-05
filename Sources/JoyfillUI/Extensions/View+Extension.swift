//
//  File.swift
//  
//
//  Created by Nand Kishore on 04/03/24.
//

import Foundation
import SwiftUI

extension View {
    /// Custom single-row top bar (back chevron + leading title + trailing controls) replacing the system nav bar, which can't left-align a title without squeezing the controls.
    func modalTopBar<Trailing: View>(
        title: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        modifier(ModalTopBar(title: title, trailing: trailing().disableHoverEffect()))
    }

    @ViewBuilder
    func disableHoverEffect() -> some View {
        if #available(iOS 17.0, *) { self.hoverEffectDisabled() } else { self }
    }

    /// Re-apply at each presented surface's root; sheets get a fresh safe-area context that doesn't inherit it.
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

/// Replaces the system nav bar with one row so the title can sit leading without the bar squeezing it; `dismiss` drives the back chevron.
private struct ModalTopBar<Trailing: View>: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let trailing: Trailing

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color(uiColor: .systemBackground))
                                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 1)
                        )
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .disableHoverEffect()
                .accessibilityIdentifier("ModalBackButtonIdentifier")

                Text(title)
                    .font(.headline.bold())
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer(minLength: 12)

                trailing
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            content
        }
        .navigationBarHidden(true)
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
