//
//  File.swift
//  
//
//  Created by Nand Kishore on 04/03/24.
//

import Foundation
import SwiftUI

extension View {
    /// iOS 16+ glass toolbar: separate capsules + a scrollable title + a solid (non-see-through) bar.
    @available(iOS 16.0, *)
    func modalTopBarGlass<Trailing: ToolbarContent>(
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
            .opaqueNavBar()
    }

    /// iOS 15 plain toolbar (no iOS 16-only toolbar APIs); `trailing` must have no toolbar-level conditionals.
    func modalTopBarLegacy<Trailing: ToolbarContent>(
        title: String,
        @ToolbarContentBuilder trailing: () -> Trailing
    ) -> some View {
        self.navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { trailing() }
    }

    /// Table modal nav bar: glass on iOS 16+, plain on iOS 15. The `if #available` encloses the iOS-16 types so iOS 15 compiles.
    @ViewBuilder
    func tableModalTopBar(title: String, viewModel: TableViewModel, onEditTap: @escaping () -> Void) -> some View {
        if #available(iOS 16.0, *) {
            modalTopBarGlass(title: title) {
                TableModalTopNavigationView(viewModel: viewModel, onEditTap: onEditTap)
            }
        } else {
            modalTopBarLegacy(title: title) {
                TableModalTopNavigationLegacy(viewModel: viewModel, onEditTap: onEditTap)
            }
        }
    }

    /// Collection modal nav bar: glass on iOS 16+, plain on iOS 15.
    @ViewBuilder
    func collectionModalTopBar(title: String, viewModel: CollectionViewModel, onEditTap: @escaping () -> Void, onFilterTap: @escaping () -> Void) -> some View {
        if #available(iOS 16.0, *) {
            modalTopBarGlass(title: title) {
                CollectionModalTopNavigationView(viewModel: viewModel, onEditTap: onEditTap, onFilterTap: onFilterTap)
            }
        } else {
            modalTopBarLegacy(title: title) {
                CollectionModalTopNavigationLegacy(viewModel: viewModel, onEditTap: onEditTap, onFilterTap: onFilterTap)
            }
        }
    }

    /// Solid system-background bar so scrolled grid content can't show through the (translucent/glass) nav bar; adapts to light/dark. Button capsules keep their own glass.
    @ViewBuilder
    func opaqueNavBar() -> some View {
        if #available(iOS 16.0, *) {
            self.toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        } else {
            self
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

/// Observes the editor so a runtime `fullWidthGrid` change re-lays out the surface.
private struct FullWidthModifier: ViewModifier {
    @ObservedObject var documentEditor: DocumentEditor

    func body(content: Content) -> some View {
        content.ignoresSafeArea(.container, edges: documentEditor.fullWidthGrid ? .horizontal : [])
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
