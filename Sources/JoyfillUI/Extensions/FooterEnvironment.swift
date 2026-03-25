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
            VStack(spacing: 0) {
                content
                footer
            }
        } else {
            content
        }
    }
}
