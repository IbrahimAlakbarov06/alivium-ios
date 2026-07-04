//
//  ComingSoonView.swift
//  alivium
//

import SwiftUI

/// Lightweight placeholder for tabs that don't have real content yet (Search/Wishlist/Cart/
/// Profile) — parametrized rather than four nearly-identical stub files.
struct ComingSoonView: View {
    @Environment(LocalizationManager.self) private var localization
    let title: String
    let systemImage: String

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(AppColor.accent)

            Text(title)
                .font(AppTypography.headline)
                .foregroundStyle(AppColor.textPrimary)

            Text(localization.string(.comingSoon))
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.backgroundOffWhite)
    }
}

#Preview {
    ComingSoonView(title: "Search", systemImage: "magnifyingglass")
        .environment(LocalizationManager())
}
