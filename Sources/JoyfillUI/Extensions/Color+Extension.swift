//
//  File.swift
//  
//
//  Created by Nand Kishore on 04/03/24.
//

import Foundation
import SwiftUI

extension Color {
    static let tableBorderBgColor = Color(hex: "#CACACF")
    static let tableColumnBgColor = Color(hex: "#F3F4F8")
    static let tableCellBorderColor = Color(hex: "#E6E7EA")
    static let buttonBorderColor = Color(hex: "#E2E3E7")
    static let tableDropdownBorderColor = Color(hex: "#D1D1D6")
    static let allFieldBorderColor = Color(hex: "#AAAAAE")
    static let focusedFieldBorderColor = Color(hex: "#2563EB")
    static func rowSelectionBackground(isSelected: Bool, colorScheme: ColorScheme) -> Color {
        guard isSelected else { return .clear }
        return colorScheme == .dark ? Color.blue.opacity(0.35) : Color.blue.opacity(0.1)
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // RGBA (32-bit)
            (a, r, g, b) = (int & 0xFF, int >> 24 & 0xFF, int >> 16 & 0xFF, int >> 8 & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

private struct NavigationFocusFieldIdKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var navigationFocusFieldId: String? {
        get { self[NavigationFocusFieldIdKey.self] }
        set { self[NavigationFocusFieldIdKey.self] = newValue }
    }
}

private struct NavigationFocusColumnIdKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var navigationFocusColumnId: String? {
        get { self[NavigationFocusColumnIdKey.self] }
        set { self[NavigationFocusColumnIdKey.self] = newValue }
    }
}

struct DarkLightThemeColor: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content.foregroundColor(colorScheme == .dark ? Color.white : Color.black)
    }
}

struct GrayLightThemeColor: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content.foregroundColor(colorScheme == .dark ? Color.white : Color.gray)
    }
}

extension View {
    func darkLightThemeColor() -> some View {
        self.modifier(DarkLightThemeColor())
    }
    
    func grayLightThemeColor() -> some View {
        self.modifier(GrayLightThemeColor())
    }

    func fieldBorder(isFocused: Bool, cornerRadius: CGFloat = 10) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(isFocused ? Color.focusedFieldBorderColor : Color.allFieldBorderColor, lineWidth: 1)
        )
    }

    func cellBorder(isFocused: Bool) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isFocused ? Color.focusedFieldBorderColor : Color.allFieldBorderColor, lineWidth: 1)
        )
    }
}
struct HorizontalBorderModifier: ViewModifier {
    var color: Color
    var width: CGFloat = 1

    func body(content: Content) -> some View {
        content
            .overlay(
                VStack {
                    Rectangle() // Top border
                        .frame(height: width)
                        .foregroundColor(color)
                    Spacer()
                    Rectangle() // Bottom border
                        .frame(height: width)
                        .foregroundColor(color)
                }
            )
    }
}
extension View {
    func horizontalBorder(color: Color, width: CGFloat = 1) -> some View {
        self.modifier(HorizontalBorderModifier(color: color, width: width))
    }
    func verticalBorder(color: Color, width: CGFloat = 1, includeBottom: Bool = false) -> some View {
        self.modifier(VerticalBorderModifier(color: color, width: width, includeBottom: includeBottom))
    }
}

struct VerticalBorderModifier: ViewModifier {
    var color: Color
    var width: CGFloat = 1
    var includeBottom: Bool

    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    HStack { // Left and Right Borders
                        Rectangle()
                            .frame(width: width)
                            .foregroundColor(color)
                        Spacer()
                        Rectangle()
                            .frame(width: width)
                            .foregroundColor(color)
                    }
                    
                    if includeBottom {
                        VStack { // Bottom Border
                            Spacer()
                            Rectangle()
                                .frame(height: width)
                                .foregroundColor(color)
                        }
                    }
                }
            )
    }
}
