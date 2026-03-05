import SwiftUI
import JoyfillModel

// MARK: - Decorator Icon Mapping

enum DecoratorIcon {
    static func sfSymbol(for iconName: String?) -> String {
        guard let iconName = iconName?.lowercased() else { return "photo" }
        switch iconName {
        case "camera":       return "camera.fill"
        case "import":       return "doc.badge.arrow.up.fill"
        case "paperclip":    return "paperclip"
        case "image":        return "photo"
        case "file":         return "doc.fill"
        case "comment":      return "bubble.left.fill"
        case "comments":     return "bubble.left.and.bubble.right.fill"
        case "upload":       return "arrow.up.square.fill"
        case "download":     return "arrow.down.square.fill"
        case "rotate":       return "arrow.triangle.2.circlepath"
        case "cloud":        return "cloud.fill"
        case "filter":       return "line.3.horizontal.decrease"
        case "share":        return "square.and.arrow.up"
        case "paper-plane":  return "paperplane.fill"
        case "folder":       return "folder.fill"
        case "folder-open":  return "folder.badge.minus"
        case "magnet":       return "minus.magnifyingglass"
        case "eye":          return "eye.fill"
        case "circle-info":  return "info.circle.fill"
        case "add":          return "plus.circle.fill"
        case "print":        return "printer.fill"
        default:             return "photo"
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
                    Image(systemName: DecoratorIcon.sfSymbol(for: icon))
                        .font(.system(size: 14, weight: .medium))
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
    }
}

// MARK: - Field-Level Decorators (inline next to title)

struct FieldDecoratorsView: View {
    let decorators: [DecoratorLocal]
    let onDecoratorTap: (DecoratorLocal) -> Void

    var displayable: [DecoratorLocal] {
        decorators.filter { $0.isDisplayable }
    }

    var body: some View {
        if !displayable.isEmpty {
            HStack(spacing: 4) {
                ForEach(Array(displayable.enumerated()), id: \.offset) { _, decorator in
                    DecoratorButton(decorator: decorator, onTap: onDecoratorTap)
                }
            }
        }
    }
}

// MARK: - Row Decorator Hamburger Menu

struct RowDecoratorMenuView: View {
    let decorators: [DecoratorLocal]
    let onDecoratorTap: (DecoratorLocal) -> Void
    @State private var showingPopover = false

    private var displayable: [DecoratorLocal] {
        decorators.filter { $0.isDisplayable }
    }

    private var dominantDecorator: DecoratorLocal? {
        displayable.first
    }

    private var dominantColor: Color {
        if let hex = dominantDecorator?.color, !hex.isEmpty {
            return Color(hex: hex)
        }
        return .secondary
    }

    var body: some View {
        if displayable.count == 1, let decorator = displayable.first {
            singleDecoratorButton(decorator)
        } else if displayable.count > 1 {
            Button {
                showingPopover = true
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 60)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingPopover) {
                if #available(iOS 16.4, *) {
                    popoverContent
                        .presentationCompactAdaptation(.popover)
                } else {
                    popoverContent
                }
            }
        }
    }

    private func singleDecoratorButton(_ decorator: DecoratorLocal) -> some View {
        let tint: Color = decorator.color.map { Color(hex: $0) } ?? .secondary
        return Button {
            onDecoratorTap(decorator)
        } label: {
            HStack(spacing: 4) {
                if let icon = decorator.icon, !icon.isEmpty {
                    Image(systemName: DecoratorIcon.sfSymbol(for: icon))
                        .font(.system(size: 14, weight: .medium))
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
                            Image(systemName: DecoratorIcon.sfSymbol(for: icon))
                                .font(.system(size: 14, weight: .medium))
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
