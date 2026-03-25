import SwiftUI

private struct JoyfillFooterKey: EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

extension EnvironmentValues {
    var joyfillFooter: AnyView? {
        get { self[JoyfillFooterKey.self] }
        set { self[JoyfillFooterKey.self] = newValue }
    }
}

struct JoyfillFooterModifier: ViewModifier {
    @Environment(\.joyfillFooter) private var footer

    func body(content: Content) -> some View {
        if let footer = footer {
            content.safeAreaInset(edge: .bottom, spacing: 0) {
                footer
            }
        } else {
            content
        }
    }
}
