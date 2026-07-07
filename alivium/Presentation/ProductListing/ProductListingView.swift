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
        case .collection(let collection):
            // Unreached in practice — Collection Detail owns its own screen and never pushes
            // `ProductListingView` itself with this case (see `ProductListingSource`'s doc
            // comment) — but a real fallback here costs nothing and keeps the switch honest.
            return collection.name
        }
    }

    private var filterSortBar: some View {
        ProductSortFilterBar(
            sortOption: $viewModel.sortOption,
            isOnSaleOnly: $viewModel.isOnSaleOnly,
            resultCount: viewModel.state == .loaded ? viewModel.displayedProducts.count : nil,
            itemsSuffix: localization.string(.items),
            onSaleLabel: localization.string(.onSaleFilter),
            sortOptionLabel: { localization.string(forSort: $0) }
        )
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
            ProductGrid(
                products: viewModel.displayedProducts,
                isWishlisted: viewModel.isWishlisted,
                onToggleWishlist: viewModel.toggleWishlist,
                noMatchesText: localization.string(.noProductsMatchFilters)
            )
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
