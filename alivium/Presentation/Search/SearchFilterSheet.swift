//
//  SearchFilterSheet.swift
//  alivium
//

import SwiftUI

/// Presented from Search's filter icon. Filters/sorts live on the `SearchViewModel` itself and
/// take effect immediately as their controls move — this sheet is just a focused place to adjust
/// them, not a separate draft/apply-later state, keeping the model to one source of truth.
struct SearchFilterSheet: View {
    @Environment(LocalizationManager.self) private var localization
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: SearchViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section(localization.string(.sortLabel)) {
                    Picker(localization.string(.sortLabel), selection: $viewModel.sortOption) {
                        ForEach(ProductSortOption.allCases, id: \.self) { option in
                            Text(localization.string(forSort: option)).tag(option)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section(localization.string(.priceRangeLabel)) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(localization.string(.minPriceLabel))
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColor.textSecondary)
                        HStack {
                            Slider(value: $viewModel.minPrice, in: SearchViewModel.priceBounds, step: 10)
                                .tint(AppColor.primary)
                            Text(Money(viewModel.minPrice).formatted)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColor.textPrimary)
                                .frame(width: 64, alignment: .trailing)
                        }
                    }
                    .padding(.vertical, AppSpacing.xxs)

                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(localization.string(.maxPriceLabel))
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColor.textSecondary)
                        HStack {
                            Slider(value: $viewModel.maxPrice, in: SearchViewModel.priceBounds, step: 10)
                                .tint(AppColor.primary)
                            Text(Money(viewModel.maxPrice).formatted)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColor.textPrimary)
                                .frame(width: 64, alignment: .trailing)
                        }
                    }
                    .padding(.vertical, AppSpacing.xxs)
                }

                Section(localization.string(.categoryFilterLabel)) {
                    Picker(localization.string(.categoryFilterLabel), selection: $viewModel.filterCategoryId) {
                        Text(localization.string(.allCategories)).tag(String?.none)
                        ForEach(viewModel.availableFilterCategoryIds, id: \.self) { categoryId in
                            Text(categoryName(forId: categoryId)).tag(String?.some(categoryId))
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .navigationTitle(localization.string(.filtersTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localization.string(.resetFilters)) { viewModel.resetFilters() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.string(.apply)) { dismiss() }
                }
            }
        }
    }

    /// Same fallback shape as `LocalizationManager.string(forCategory:)`, but resolving from a
    /// bare id (the distinct `categoryId`s in the current results) rather than a `Category` value.
    private func categoryName(forId id: String) -> String {
        guard let key = LocalizedKey.categoryName(forId: id) else { return id.capitalized }
        return localization.string(key)
    }
}

#Preview {
    SearchFilterSheet(
        viewModel: SearchViewModel(
            categoryRepository: MockCategoryRepository(),
            productRepository: MockProductRepository(),
            wishlistRepository: MockWishlistRepository(),
            userSession: UserSession()
        )
    )
    .environment(LocalizationManager())
}
