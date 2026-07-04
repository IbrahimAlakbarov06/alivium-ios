//
//  ExpandableCategoryRow.swift
//  alivium
//

import SwiftUI

/// One entry in Discover's subcategory list — a parent category (e.g. "Clothing") that expands
/// in place to reveal its children with item counts and chevrons. Kept local to Search since
/// its expand/collapse interaction isn't needed elsewhere yet.
struct ExpandableCategoryRow: View {
    @Environment(LocalizationManager.self) private var localization
    let category: Category
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    Text(category.name)
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColor.textPrimary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColor.textSecondary)
                }
                .padding(.vertical, AppSpacing.sm)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(category.subcategories) { subcategory in
                        Button {
                            // TODO: navigate to Category/Product Listing once it exists.
                        } label: {
                            HStack(spacing: AppSpacing.sm) {
                                Text(subcategory.name)
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
                            .padding(.leading, AppSpacing.lg)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#Preview {
    ExpandableCategoryRow(
        category: Category(
            id: "clothing", name: "Clothing", parentId: nil,
            subcategories: [
                Category(id: "dresses", name: "Dresses", parentId: "clothing", subcategories: [], itemCount: 36),
                Category(id: "skirts", name: "Skirts", parentId: "clothing", subcategories: [], itemCount: 40)
            ],
            itemCount: 0
        )
    )
    .padding()
    .environment(LocalizationManager())
}
