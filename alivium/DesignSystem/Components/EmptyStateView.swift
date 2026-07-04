//
//  EmptyStateView.swift
//  alivium
//

import SwiftUI

/// Icon + headline + supporting text + optional CTA — the shared shape behind Wishlist's
/// empty/guest states and Cart's empty state (CLAUDE.md 9.3 names this component explicitly).
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(AppColor.accent)

            Text(title)
                .font(AppTypography.headline)
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                BaseButton(title: actionTitle, kind: .primary, size: .medium, action: action)
                    .padding(.top, AppSpacing.sm)
            }
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        icon: "heart",
        title: "Your Wishlist is Empty",
        subtitle: "Save the pieces you love and find them here anytime.",
        actionTitle: "Start Browsing",
        action: {}
    )
}
