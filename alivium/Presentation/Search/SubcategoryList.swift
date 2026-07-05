//
//  SubcategoryList.swift
//  alivium
//

import SwiftUI

/// The rows revealed directly beneath an expanded `CategoryBanner` (e.g. Clothing -> Dresses,
/// Skirts, Jackets...) — a pure list, no header/toggle of its own; the banner above owns the
/// expand/collapse state so there's exactly one source of truth for "which category is open."
struct SubcategoryList: View {
    @Environment(LocalizationManager.self) private var localization
    let subcategories: [Category]
    let onSelect: (Category) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(subcategories.enumerated()), id: \.element.id) { index, subcategory in
                if index > 0 { Divider() }

                Button {
                    onSelect(subcategory)
                } label: {
                    HStack(spacing: AppSpacing.sm) {
                        Text(localization.string(forCategory: subcategory))
                            .font(AppTypography.body)
                            .foregroundStyle(AppColor.textPrimary)

                        Spacer()

                        Text("\(subcategory.itemCount) \(localization.string(.items))")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColor.textSecondary)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppColor.textSecondary.opacity(0.6))
                    }
                    .padding(.vertical, AppSpacing.sm)
                    .padding(.horizontal, AppSpacing.md)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }
}

#Preview {
    SubcategoryList(
        subcategories: [
            Category(id: "dresses", name: "Dresses", parentId: "clothing", subcategories: [], itemCount: 36),
            Category(id: "skirts", name: "Skirts", parentId: "clothing", subcategories: [], itemCount: 40)
        ],
        onSelect: { _ in }
    )
    .padding()
    .environment(LocalizationManager())
}
