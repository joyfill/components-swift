import SwiftUI

struct InlinePopupHostModifier<PopupContent: View>: ViewModifier {
    let isPresented: Bool
    let colorScheme: ColorScheme
    @ViewBuilder let popupContent: () -> PopupContent
    
    func body(content: Content) -> some View {
        content
            .allowsHitTesting(!isPresented)
            .accessibilityHidden(isPresented)
            .overlay(alignment: .topLeading) {
                if isPresented {
                    (colorScheme == .dark ? Color.black : Color.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(alignment: .topLeading) {
                            popupContent()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
    }
}
