//
//  ShareCardView.swift
//  letscheers
//

import SwiftUI

/// Branded 4:5 card rendered to PNG for sharing. Fixed size and fixed fonts so
/// the exported image never depends on the viewer's Dynamic Type setting.
struct ShareCardView: View {
    static let size = CGSize(width: 360, height: 450)

    let toast: Toast

    private var presentation: ToastPresentation { ToastPresentation(title: toast.title, contents: toast.contents) }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.shareCardTop, .appBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 0) {
                header
                Spacer(minLength: 8)
                titleBlock
                Spacer(minLength: 8)
                bodyBlock
                Spacer(minLength: 12)
                footer
            }
            .padding(28)
        }
        .frame(width: Self.size.width, height: Self.size.height)
        .environment(\.dynamicTypeSize, .large)
        .environment(\.colorScheme, .dark)
    }

    // MARK: - Sections

    private var header: some View {
        HStack {
            Text("🍻")
                .font(.system(size: 28))
            Spacer()
            Image(systemName: "quote.opening")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.accentPurple.opacity(0.4))
        }
    }

    @ViewBuilder
    private var titleBlock: some View {
        if presentation.hasTitleCallAndResponse {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(presentation.titleLines) { line in
                    VStack(alignment: .leading, spacing: 6) {
                        RoleLabel(role: line.role, fontSize: 12)
                        Text(line.text)
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.6)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(presentation.titleAccessibilityLabel)
        } else {
            plainTitle
        }
    }

    private var plainTitle: some View {
        Text(toast.title)
            .font(.system(size: 34, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .minimumScaleFactor(0.6)
            .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var bodyBlock: some View {
        if presentation.hasCallAndResponse {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(presentation.lines.prefix(4)) { line in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        RoleLabel(role: line.role, fontSize: 12)
                        Text(line.text)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else if !presentation.meaning.isEmpty {
            Text(presentation.meaning)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(6)
                .frame(maxWidth: .infinity)
        }
    }

    private var footer: some View {
        VStack(spacing: 12) {
            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(height: 1)

            HStack(spacing: 10) {
                Image(systemName: "wineglass.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.onGold)
                    .frame(width: 28, height: 28)
                    .background(Color.accentGold, in: RoundedRectangle(cornerRadius: 7, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text("술마셔 건배사")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))
                    Text("App Store에서 '술마셔 건배사' 검색")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer()
            }
        }
    }
}

// MARK: - Role Label

/// 선창 / 후창 / 제창 capsule shared by the detail screen and the share card.
struct RoleLabel: View {
    let role: ToastPresentation.Role
    var fontSize: CGFloat?

    private var foreground: Color {
        switch role {
        case .lead: return .accentPurple
        case .response: return .onGold
        case .together, .cheers: return .white
        }
    }

    private var fill: Color {
        switch role {
        case .response: return .accentGold
        default: return .surfaceElevated
        }
    }

    var body: some View {
        Group {
            if let fontSize {
                Text(role.rawValue).font(.system(size: fontSize, weight: .bold))
            } else {
                Text(role.rawValue).font(.subheadline.weight(.bold))
            }
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Capsule().fill(fill))
    }
}
