//
//  Color+Theme.swift
//  letscheers
//

import SwiftUI

// Named color assets in Assets.xcassets/Colors/ — each has Light and Dark
// variants. SwiftUI resolves the correct variant automatically via the
// environment color scheme that LetsCheersApp bridges from the system.
extension Color {
    static let appBackground  = Color("AppBackground")
    static let iconContainer  = Color("IconContainer")
    static let accentPurple   = Color("AccentPurple")
    static let navBar         = Color("NavBar")
    static let cardBackground = Color("CardBackground")
}
