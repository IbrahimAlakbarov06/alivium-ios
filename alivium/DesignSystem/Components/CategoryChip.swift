//
//  CategoryChip.swift
//  alivium
//

import SwiftUI

/// Horizontal-scroll pill used for Home's category bar (and Discover's filter list later).
/// Selected/unselected styling matches AuthHeaderView's AZ/EN toggle language — dark-green fill
/// + white text when selected, beige surface otherwise — so it reads as the same app.
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(isSelected ? AppColor.background : AppColor.textPrimary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
                .background(isSelected ? AppColor.primary : AppColor.surface)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    HStack(spacing: AppSpacing.xs) {
        CategoryChip(title: "New In", isSelected: true) {}
        CategoryChip(title: "Dresses", isSelected: false) {}
        CategoryChip(title: "Shoes", isSelected: false) {}
    }
    .padding()
}
