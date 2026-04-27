import SwiftUI
import JoyfillModel

private extension View {
    func decoratorOverflowPopover<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.popover(isPresented: isPresented) {
            Group {
                if #available(iOS 16.4, *) {
                    content()
                        .presentationCompactAdaptation(.popover)
                } else {
                    content()
                }
            }
        }
    }
}

// MARK: - Decorator Icon Mapping

enum DecoratorIcon {
    /// Asset catalog name for bundled Font Awesome icon (Resources/Assets.xcassets).
    static func bundledAssetName(for iconName: String?) -> String? {
        guard let iconName = iconName?.lowercased(), !iconName.isEmpty else { return nil }
        switch iconName {
        case "camera":       return "decorator_camera"
        case "import":       return "decorator_import"
        case "paperclip":    return "decorator_paperclip"
        case "image":        return "decorator_image"
        case "file":         return "decorator_file"
        case "comment":      return "decorator_comment"
        case "comments":     return "decorator_comments"
        case "upload":       return "decorator_upload"
        case "download":     return "decorator_download"
        case "rotate":       return "decorator_rotate"
        case "cloud":        return "decorator_cloud"
        case "filter":       return "decorator_filter"
        case "share":        return "decorator_share"
        case "paper-plane":  return "decorator_paper_plane"
        case "folder":       return "decorator_folder"
        case "folder-open":  return "decorator_folder_open"
        case "magnet":       return "decorator_magnet"
        case "eye":          return "decorator_eye"
        case "circle-info":  return "decorator_circle_info"
        case "add":          return "decorator_add"
        case "plus":         return "decorator_plus"
        case "print":        return "decorator_print"
        case "flag":         return "decorator_flag"
        default:             return nil
        }
    }

    /// SF Symbol name (fallback when bundled asset not used).
    static func sfSymbol(for iconName: String?) -> String {
        guard let iconName = iconName?.lowercased() else { return "photo" }
        switch iconName {
        case "camera":       return "camera.fill"
        case "import":       return "doc.badge.arrow.up.fill"
        case "paperclip":    return "paperclip"
        case "image":        return "photo.fill"
        case "file":         return "doc.fill"
        case "comment":      return "message.fill"
        case "comments":     return "bubble.left.and.bubble.right.fill"
        case "upload":       return "arrow.up.square.fill"
        case "download":     return "arrow.down.square.fill"
        case "rotate":       return "arrow.trianglehead.2.clockwise.rotate.90"
        case "cloud":        return "cloud.fill"
        case "filter":       return "line.3.horizontal.decrease"
        case "share":        return "arrowshape.turn.up.forward.fill"
        case "paper-plane":  return "paperplane.fill"
        case "folder":       return "folder.fill"
        case "folder-open":  return "folder.badge.minus"
        case "magnet":       return "minus.magnifyingglass"
        case "eye":          return "eye.fill"
        case "circle-info":  return "info.circle.fill"
        case "add":          return "plus"
        case "plus":         return "plus"
        case "print":        return "printer.fill"
        case "flag":         return "flag.fill"
        default:             return "photo"
        }
    }
}

// MARK: - Decorator icon image (bundled asset or SF Symbol fallback)

private struct DecoratorIconImage: View {
    let iconName: String?
    let size: CGFloat

    var body: some View {
        Group {
            if let assetName = DecoratorIcon.bundledAssetName(for: iconName) {
                Image(assetName, bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            } else {
                Image(systemName: DecoratorIcon.sfSymbol(for: iconName))
                    .font(.system(size: size, weight: .medium))
            }
        }
    }
}

// MARK: - Single Decorator Button

struct DecoratorButton: View {
    let decorator: DecoratorLocal
    let onTap: (DecoratorLocal) -> Void

    private var tintColor: Color {
        if let hex = decorator.color, !hex.isEmpty {
            return Color(hex: hex)
        }
        return .accentColor
    }

    var body: some View {
        Button {
            onTap(decorator)
        } label: {
            HStack(spacing: 5) {
                if let icon = decorator.icon, !icon.isEmpty {
                    DecoratorIconImage(iconName: icon, size: 16)
                }
                if let label = decorator.label, !label.isEmpty {
                    Text(label)
                        .font(.system(size: 13, weight: .medium))
                        .lineLimit(1)
                }
            }
            .foregroundColor(tintColor)
            .padding(.horizontal, 10)
            .frame(minHeight: 32)
            .background(tintColor.opacity(0.12))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("decorator_button_\(decorator.action ?? "unknown")")
    }
}

// MARK: - Shared Kebab Button

private struct DecoratorKebabButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.blue)
        }
        .contentShape(Rectangle())
        .buttonStyle(.plain)
    }
}

// MARK: - Field-Level Decorators (inline next to title)

struct FieldDecoratorsView: View {
    let decorators: [DecoratorLocal]
    let visibleLimit: Int
    let onDecoratorTap: (DecoratorLocal) -> Void
    @State private var showingOverflow = false

    var displayable: [DecoratorLocal] { decorators.filter { $0.isDisplayable } }
    var exceedsLimit: Bool { displayable.count > visibleLimit }

    var body: some View {
        if !displayable.isEmpty {
            if exceedsLimit {
                DecoratorKebabButton { showingOverflow = true }
                    .padding(.horizontal, 10)
                    .frame(minHeight: 32)
                    .background(Color.blue.opacity(0.12))
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                    .accessibilityIdentifier("field_decorator_overflow_menu")
                    .decoratorOverflowPopover(isPresented: $showingOverflow) {
                        decoratorPopover
                    }
            } else {
                HStack(spacing: 4) {
                    ForEach(Array(displayable.enumerated()), id: \.offset) { _, decorator in
                        DecoratorButton(decorator: decorator, onTap: onDecoratorTap)
                    }
                }
            }
        }
    }

    private var decoratorPopover: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(displayable.enumerated()), id: \.offset) { index, decorator in
                let tint: Color = decorator.color.map { Color(hex: $0) } ?? .primary
                Button {
                    showingOverflow = false
                    onDecoratorTap(decorator)
                } label: {
                    HStack(spacing: 8) {
                        if let icon = decorator.icon, !icon.isEmpty {
                            DecoratorIconImage(iconName: icon, size: 14)
                                .foregroundColor(tint)
                                .frame(width: 20)
                        }
                        if let label = decorator.label, !label.isEmpty {
                            Text(label)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(tint)
                        }
                    }
                    .frame(height: 27)
                }
                .padding(.horizontal, 16)
                .padding(.top, index == 0 ? 12 : 4)
                .padding(.bottom, index == displayable.count - 1 ? 12 : 4)
            }
        }
        .frame(minWidth: 160)
    }
}

// MARK: - Row Decorator Hamburger Menu

struct RowDecoratorMenuView: View {
    let decorators: [DecoratorLocal]
    let visibleLimit: Int
    let onDecoratorTap: (DecoratorLocal) -> Void
    @State private var showingPopover = false

    private var displayable: [DecoratorLocal] { decorators.filter { $0.isDisplayable } }
    private var exceedsLimit: Bool { displayable.count > visibleLimit }

    var body: some View {
        if displayable.isEmpty {
            Color.clear.frame(width: 40, height: 60)
        } else if exceedsLimit {
            kebabButton.frame(width: 40, height: 60)
        } else if displayable.count == 1, let decorator = displayable.first {
            singleDecoratorButton(decorator)
        } else {
            VStack(spacing: 0) {
                ForEach(Array(displayable.enumerated()), id: \.offset) { _, decorator in
                    singleDecoratorButton(decorator)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 40, height: 60)
        }
    }

    private func singleDecoratorButton(_ decorator: DecoratorLocal) -> some View {
        let tint: Color = decorator.color.map { Color(hex: $0) } ?? .secondary
        return Button {
            onDecoratorTap(decorator)
        } label: {
            HStack(spacing: 4) {
                if let icon = decorator.icon, !icon.isEmpty {
                    DecoratorIconImage(iconName: icon, size: 14)
                }
                if let label = decorator.label, !label.isEmpty {
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                }
            }
            .foregroundColor(tint)
            .frame(width: 40, height: 60)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("row_decorator_\(decorator.action ?? "unknown")")
    }

    private var kebabButton: some View {
        DecoratorKebabButton { showingPopover = true }
            .frame(width: 40, height: 60)
            .contentShape(Rectangle())
            .accessibilityIdentifier("row_decorator_menu")
            .decoratorOverflowPopover(isPresented: $showingPopover) {
                popoverContent
            }
    }

    private var popoverContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(displayable.enumerated()), id: \.offset) { index, decorator in
                let tint: Color = decorator.color.map { Color(hex: $0) } ?? .primary

                Button {
                    showingPopover = false
                    onDecoratorTap(decorator)
                } label: {
                    HStack(spacing: 8) {
                        if let icon = decorator.icon, !icon.isEmpty {
                            DecoratorIconImage(iconName: icon, size: 14)
                                .foregroundColor(tint)
                                .frame(width: 20)
                        }
                        if let label = decorator.label, !label.isEmpty {
                            Text(label)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(tint)
                        }
                    }
                    .frame(height: 27)
                }
                .padding(.horizontal, 16)
                .padding(.top, index == 0 ? 12 : 4)
                .padding(.bottom, index == displayable.count - 1 ? 12 : 4)
            }
        }
        .frame(minWidth: 160)
    }
}
