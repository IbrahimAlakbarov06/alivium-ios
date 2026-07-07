//
//  ProductListingView.swift
//  alivium
//

import SwiftUI

/// Item #6 in CLAUDE.md's Phase 1 build order — the 2-column grid + filter/sort bar reached from
/// Home's "Show all" and Search's category taps. Doesn't register its own
/// `.navigationDestination(for: Product.self)` for the same reason `ProductDetailView` doesn't:
/// each tab's root screen (Home/Search) already owns one registration per `NavigationStack`.
struct ProductListingView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: ProductListingViewModel
    let makeProductDetailViewModel: (Product) -> ProductDetailViewModel
    /// Wired the same way as Home/Search's Guest CTA — drops back to the Auth flow.
    let onRequestAuthFlow: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            filterSortBar
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.xs)

            content
        }
        .background(AppColor.backgroundOffWhite)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task { viewModel.onAppear() }
        .alert(localization.string(.wishlistGuestTitle), isPresented: $viewModel.needsSignInForWishlist) {
            Button(localization.string(.logInOrSignUp)) { onRequestAuthFlow() }
            Button(localization.string(.cancel), role: .cancel) {}
        } message: {
            Text(localization.string(.wishlistGuestSubtitle))
        }
    }

    private var title: String {
        switch viewModel.source {
        case .category(let category):
            return localization.string(forCategory: category)
        case .curated(let titleKey, _):
            return localization.string(titleKey)
        }
    }

    private var filterSortBar: some View {
        HStack(spacing: AppSpacing.sm) {
            Menu {
                Picker("", selection: $viewModel.sortOption) {
                    ForEach(ProductSortOption.allCases, id: \.self) { option in
                        Text(localization.string(forSort: option)).tag(option)
                    }
                }
            } label: {
                pill(icon: "arrow.up.arrow.down", title: localization.string(forSort: viewModel.sortOption), isActive: false)
            }

            Button {
                viewModel.isOnSaleOnly.toggle()
            } label: {
                pill(icon: "tag", title: localization.string(.onSaleFilter), isActive: viewModel.isOnSaleOnly)
            }

            Spacer()

            if viewModel.state == .loaded {
                Text("\(viewModel.displayedProducts.count) \(localization.string(.items))")
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

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .tint(AppColor.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded:
            grid
        case .empty:
            EmptyStateView(
                icon: "bag",
                title: localization.string(.categoryEmptyTitle),
                subtitle: localization.string(.categoryEmptySubtitle)
            )
        case .error(let key):
            errorState(key)
        }
    }

    private var grid: some View {
        ScrollView {
            if viewModel.displayedProducts.isEmpty {
                Text(localization.string(.noProductsMatchFilters))
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppSpacing.xxl)
            } else {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: AppSpacing.md), GridItem(.flexible())],
                    spacing: AppSpacing.lg
                ) {
                    ForEach(viewModel.displayedProducts) { product in
                        // A hidden background link, not a wrapping one — matching Home's rail.
                        // Wrapping `NavigationLink` around a `ProductCard` that contains its own
                        // real wishlist `Button` lets the two gestures race, so a tap only opens
                        // Product Detail intermittently instead of reliably on the first tap.
                        ProductCard(product: product, layout: .grid, isWishlisted: viewModel.isWishlisted(product)) {
                            viewModel.toggleWishlist(for: product)
                        }
                        .background {
                            NavigationLink(value: product) { Color.clear }
                        }
                    }
                }
                .padding(AppSpacing.md)
            }
        }
    }

    private func errorState(_ key: LocalizedKey) -> some View {
        VStack(spacing: AppSpacing.md) {
            Text(localization.string(key))
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)

            BaseButton(title: localization.string(.tryAgain), kind: .primary, size: .medium) {
                Task { await viewModel.load() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppSpacing.xl)
    }
}

private func previewMakeProductDetailViewModel(_ product: Product) -> ProductDetailViewModel {
    ProductDetailViewModel(
        product: product,
        productRepository: MockProductRepository(),
        reviewRepository: MockReviewRepository(),
        cartRepository: MockCartRepository(),
        wishlistRepository: MockWishlistRepository(),
        cartBadgeStore: CartBadgeStore(),
        userSession: UserSession()
    )
}

#Preview("Category") {
    NavigationStack {
        ProductListingView(
            viewModel: ProductListingViewModel(
                source: .category(Category(id: "dresses", name: "Dresses", parentId: "clothing", subcategories: [], itemCount: 36)),
                productRepository: MockProductRepository(),
                wishlistRepository: MockWishlistRepository(),
                userSession: UserSession()
            ),
            makeProductDetailViewModel: previewMakeProductDetailViewModel,
            onRequestAuthFlow: {}
        )
    }
    .environment(LocalizationManager())
}

#Preview("Curated — Show all") {
    NavigationStack {
        ProductListingView(
            viewModel: ProductListingViewModel(
                source: .curated(titleKey: .featuredProducts, products: MockProductRepository.featuredProducts),
                productRepository: MockProductRepository(),
                wishlistRepository: MockWishlistRepository(),
                userSession: UserSession()
            ),
            makeProductDetailViewModel: previewMakeProductDetailViewModel,
            onRequestAuthFlow: {}
        )
    }
    .environment(LocalizationManager())
}
