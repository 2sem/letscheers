//
//  Color+Theme.swift
//  letscheers
//

import SwiftUI
import UIKit

extension Color {
    // MARK: - UIKit-backed (safe for UIKit APIs like toolbarBackground)
    static var navBar: Color { Color(UIColor(named: "NavBar") ?? .systemPurple) }

    // MARK: - Explicit ColorScheme variants
    // Using @Environment(\.colorScheme) in views + these functions is the
    // guaranteed path — Color(UIColor) may snapshot before the SwiftUI
    // environment propagates, but explicit scheme-switch always reflects it.

    static func appBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.102, green: 0.059, blue: 0.157)   // #1A0F28
            : Color(red: 0.847, green: 0.834, blue: 0.886)   // #D8D5E2
    }

    static func iconContainer(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.165, green: 0.102, blue: 0.282)   // #2A1A48
            : Color(red: 0.938, green: 0.924, blue: 0.980)   // #EFE8FA
    }

    static func accentPurple(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.816, green: 0.627, blue: 1.000)   // #D0A0FF
            : Color(red: 0.479, green: 0.262, blue: 0.871)   // #7A43DE
    }

    static func cardBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.110, green: 0.110, blue: 0.118)   // #1C1C1E
            : Color(UIColor.systemBackground)
    }
}
