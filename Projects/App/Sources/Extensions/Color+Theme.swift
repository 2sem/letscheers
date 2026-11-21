//
//  Color+Theme.swift
//  letscheers
//

import SwiftUI

// Named color assets in Assets.xcassets/Colors/. The app is dark-only
// (`UIUserInterfaceStyle: Dark`), so every token carries a single value.
extension Color {
    // MARK: Backgrounds & surfaces
    static let appBackground    = Color("AppBackground")
    static let appBackgroundTop = Color("AppBackgroundTop")
    static let cardBackground   = Color("CardBackground")       // Surface
    static let surfaceElevated  = Color("SurfaceElevated")
    static let iconContainer    = Color("IconContainer")
    static let navBar           = Color("NavBar")
    static let stroke           = Color("Stroke")

    // MARK: Accents
    static let accentPurple     = Color("AccentPurple")
    static let accentGold       = Color("AccentGold")
    static let onGold           = Color("OnGold")

    // MARK: Text
    static let textSecondary    = Color("TextSecondary")
    static let textTertiary     = Color("TextTertiary")

    // MARK: Share card
    static let shareCardTop     = Color("ShareCardTop")

    /// Icon / chip tint per category. Never used as a background tint.
    static func categoryTint(for categoryName: String?) -> Color {
        switch categoryName {
        case "선창!후창~!": return Color("TintFollow")
        case "모임":       return Color("TintMeeting")
        case "회식":       return Color("TintDining")
        case "건강":       return Color("TintHealth")
        default:          return .accentPurple
        }
    }
}

// MARK: - Backgrounds

extension LinearGradient {
    /// Screen background: `AppBackgroundTop` fading into `AppBackground`.
    static let appScreen = LinearGradient(
        colors: [.appBackgroundTop, .appBackground],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Layout constants

enum Theme {
    static let cardRadius: CGFloat = 20
    static let readableWidth: CGFloat = 720
}

extension View {
    /// Standard card chrome: surface fill, 1pt stroke, radius 20.
    func cardSurface(fill: Color = .cardBackground, radius: CGFloat = Theme.cardRadius) -> some View {
        background(fill, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Color.stroke, lineWidth: 1)
            )
    }

    /// Centers content in a readable column on iPad.
    func readableColumn(maxWidth: CGFloat = Theme.readableWidth) -> some View {
        frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity)
    }
}
