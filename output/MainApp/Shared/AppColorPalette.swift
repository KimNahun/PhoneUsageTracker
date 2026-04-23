import SwiftUI
import PersonalColorDesignSystem

extension Color {
    static let chartPalette: [Color] = [
        .pAccentPrimary,
        .pAccentSecondary,
        .pSuccess,
        .pWarning,
        .pDestructive,
        Color.pAccentPrimary.opacity(0.6),
        Color.pAccentSecondary.opacity(0.6),
        Color.pSuccess.opacity(0.6),
    ]
}
