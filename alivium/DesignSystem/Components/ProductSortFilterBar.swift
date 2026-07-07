//
//  ProductSortFilterBar.swift
//  alivium
//

import SwiftUI

/// The sort menu + on-sale toggle + result count row shared by Category/Product Listing and
/// Collection Detail's grid — extracted so both reuse one implementation instead of each
/// rebuilding the same pill-and-menu row (CLAUDE.md 9.6). Takes pre-resolved strings/closures
/// rather than reading `LocalizationManager` itself, matching every other DesignSystem
/// component's "dumb, localization-agnostic" convention.
struct ProductSortFilterBar: View {
    @Binding var sortOption: ProductSortOption
    @Binding var isOnSaleOnly: Bool
    /// `nil` while the result count isn't known yet (still loading).
    let resultCount: Int?
    let itemsSuffix: String
    let onSaleLabel: String
    let sortOptionLabel: (ProductSortOption) -> String

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Menu {
                Picker("", selection: $sortOption) {
                    ForEach(ProductSortOption.allCases, id: \.self) { option in
                        Text(sortOptionLabel(option)).tag(option)
                    }
                }
            } label: {
                pill(icon: "arrow.up.arrow.down", title: sortOptionLabel(sortOption), isActive: false)
            }

            Button {
                isOnSaleOnly.toggle()
            } label: {
                pill(icon: "tag", title: onSaleLabel, isActive: isOnSaleOnly)
            }

            Spacer()

            if let resultCount {
                Text("\(resultCount) \(itemsSuffix)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
    }

    private func pill(icon: String, title: String, isActive: Bool) -> some View {
        HStack(spacing: AppSpacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(title)
                .font(AppTypography.caption)
                .lineLimit(1)
        }
        .foregroundStyle(isActive ? AppColor.background : AppColor.textPrimary)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(isActive ? AppColor.primary : AppColor.surface)
        .clipShape(Capsule())
    }
}

private struct ProductSortFilterBarPreviewContainer: View {
    @State private var sortOption: ProductSortOption = .featured
    @State private var isOnSaleOnly = false

    var body: some View {
        ProductSortFilterBar(
            sortOption: $sortOption,
            isOnSaleOnly: $isOnSaleOnly,
            resultCount: 6,
            itemsSuffix: "Items",
            onSaleLabel: "On Sale",
            sortOptionLabel: { $0.rawValue.capitalized }
        )
        .padding()
    }
}

#Preview {
    ProductSortFilterBarPreviewContainer()
}
