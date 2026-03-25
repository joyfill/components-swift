import SwiftUI

// MARK: - FooterContainer
// Reference type so already-pushed NavigationLink destinations react to show/hide changes.

@MainActor
final class FooterContainer: ObservableObject {
    @Published var content: AnyView? = nil
}

// MARK: - Environment key

private struct FooterContainerKey: EnvironmentKey {
    // Non-nil default prevents crashes when FormFooterView is used without a Form ancestor
    static let defaultValue = FooterContainer()
}

extension EnvironmentValues {
    var footerContainer: FooterContainer {
        get { self[FooterContainerKey.self] }
        set { self[FooterContainerKey.self] = newValue }
    }
}

// MARK: - formFooter modifier (public API)

// renderID is a new UUID on every parent re-render, giving onChange something to
// track without exposing any visibility parameter in the public API.
private struct FormFooterModifier<Footer: View>: ViewModifier {
    @StateObject private var container = FooterContainer()
    let footer: () -> Footer
    let renderID = UUID()

    func body(content: Content) -> some View {
        content
            .environment(\.footerContainer, container)
            .onAppear { container.content = AnyView(footer()) }
            .onChange(of: renderID) { _ in
                container.content = AnyView(footer())
            }
    }
}

public extension View {
    func formFooter<V: View>(@ViewBuilder _ footer: @escaping () -> V) -> some View {
        modifier(FormFooterModifier(footer: footer))
    }
}

// MARK: - FormFooterView
// Used via safeAreaInset in Form and all inner SDK screens (Table, Collection, Signature, Chart, Image).
// Two-layer design: FormFooterView reads env, FooterRenderer subscribes via @ObservedObject.
// (@ObservedObject must be a stored property, so it can't live in the same struct that reads env.)

struct FormFooterView: View {
    @Environment(\.footerContainer) private var container

    var body: some View {
        FooterRenderer(container: container)
    }
}

private struct FooterRenderer: View {
    @ObservedObject var container: FooterContainer

    var body: some View {
        if let footer = container.content { footer }
    }
}
