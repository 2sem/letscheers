//
//  Color+Theme.swift
//  letscheers
//

import SwiftUI
import UIKit

extension Color {
    /// Accesses named color assets via UIColor so UIKit's trait collection
    /// is used for dark/light resolution — guarantees correct adaptation.
    static var appBackground: Color { Color(UIColor(named: "AppBackground") ?? .systemBackground) }
    static var iconContainer: Color { Color(UIColor(named: "IconContainer") ?? .secondarySystemBackground) }
    static var accentPurple:  Color { Color(UIColor(named: "AccentPurple") ?? .systemPurple) }
    static var navBar:        Color { Color(UIColor(named: "NavBar")        ?? .systemPurple) }
}
