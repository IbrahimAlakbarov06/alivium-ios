//
//  CollectionDetailView.swift
//  alivium
//

import SwiftUI

/// Reached from a `CollectionCard` tap on Home. An editorial hero gallery (matching
/// `HeroBannerCarousel`'s own image + gradient + overlaid text recipe, so this doesn't invent a
/// second visual language for hero imagery) sits above the same sort/filter bar + grid used by
/// Category/Product Listing.
struct CollectionDetailView: View {
    @Environment(LocalizationManager.self) private var localization
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: CollectionDetailViewModel
    @State private var galleryPage = 0
    let makeProductDetailViewModel: (Product) -> ProductDetailViewModel
    /// Wired the same way as every other product-listing screen's Guest CTA — drops back to the
    /// Auth flow.
    let onRequestAuthFlow: () -> Void

    /// Two-image editorial gallery cycling through the same Onboarding stock photos used
    /// elsewhere in Phase 1 — the collection's own `imageName` first, then the next one in the
    /// cycle for visual variety, since `ProductCollection` only carries a single image name.
    private var galleryImageNames: [String] {
        let stockPhotos = ["Onboarding1", "Onboarding2", "Onboarding3"]
        guard let index = stockPhotos.firstIndex(of: viewModel.collection.imageName) else {
            return [viewModel.collection.imageName]
        }
        return [viewModel.collection.imageName, stockPhotos[(index + 1) % stockPhotos.count]]
    }

    var body: some View {
        // A local `@Bindable` off the nested (reference-type, already `@Observable`)
        // `productListing` — `viewModel.productListing` is a `let`, so `$viewModel.productListing.x`
        // can't derive a binding through it directly; this is the standard way to bind into a
        // child observable object owned by a parent view model.
        @Bindable var productListing = viewModel.productListing

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                gallery

                filterSortBar($productListing)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xs)

                content
            }
        }
        .background(AppColor.backgroundOffWhite)
        .toolbar(.hidden, for: .navigationBar)
        // Restores the native edge-swipe-to-pop gesture — hiding the nav bar above also disables
        // it as a side effect (see ProductDetailView's identical use of this modifier).
        .restoresSwipeBackGesture()
        .task { viewModel.onAppear() }
        .alert(localization.string(.wishlistGuestTitle), isPresented: $productListing.needsSignInForWishlist) {
            Button(localization.string(.logInOrSignUp)) { onRequestAuthFlow() }
            Button(localization.string(.cancel), role: .cancel) {}
        } message: {
            Text(localization.string(.wishlistGuestSubtitle))
        }
    }

    // MARK: - Editorial hero gallery

    private var gallery: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $galleryPage) {
                ForEach(Array(galleryImageNames.enumerated()), id: \.offset) { index, imageName in
                    CatalogImage(name: imageName)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .aspectRatio(4.0 / 5.0, contentMode: .fit)

            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .center,
                endPoint: .bottom
            )
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                if galleryImageNames.count > 1 {
                    PageIndicator(numberOfPages: galleryImageNames.count, currentPage: galleryPage)
                }

                Text(viewModel.collection.name)
                    .font(AppTypography.display)
                    .foregroundStyle(.white)

                Text(viewModel.collection.description)
                    .font(AppTypography.body)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(AppSpacing.lg)
        }
        .overlay(alignment: .top) {
            HStack {
                circleButton(icon: "chevron.left") { dismiss() }
                    .accessibilityIdentifier("collectionDetailBackButton")
                Spacer()
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.sm)
        }
    }

    private func circleButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: 38, height: 38)
                .background(.white.opacity(0.9))
                .clipShape(Circle())
        }
    }

    // MARK: - Sort/filter + grid

    /// Takes the caller's `@Bindable` projection directly (rather than re-deriving one from
    /// `viewModel.productListing`, a `let`) so `$productListing.sortOption`/`isOnSaleOnly` actually
    /// write back to the underlying `ProductListingViewModel`.
    private func filterSortBar(_ productListing: Bindable<ProductListingViewModel>) -> some View {
        ProductSortFilterBar(
            sortOption: productListing.sortOption,
            isOnSaleOnly: productListing.isOnSaleOnly,
            resultCount: viewModel.productListing.state == .loaded ? viewModel.productListing.displayedProducts.count : nil,
            itemsSuffix: localization.string(.items),
            onSaleLabel: localization.string(.onSaleFilter),
            sortOptionLabel: { localization.string(forSort: $0) }
        )
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.productListing.state {
        case .idle, .loading:
            ProgressView()
                .tint(AppColor.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 240)
        case .loaded:
            ProductGrid(
                products: viewModel.productListing.displayedProducts,
                isWishlisted: viewModel.productListing.isWishlisted,
                onToggleWishlist: viewModel.productListing.toggleWishlist,
                noMatchesText: localization.string(.noProductsMatchFilters)
            )
        case .empty:
            EmptyStateView(
                icon: "bag",
                title: localization.string(.categoryEmptyTitle),
                subtitle: localization.string(.categoryEmptySubtitle)
            )
            .frame(height: 300)
        case .error(let key):
            errorState(key)
        }
    }

    private func errorState(_ key: LocalizedKey) -> some View {
        VStack(spacing: AppSpacing.md) {
            Text(localization.string(key))
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)

            BaseButton(title: localization.string(.tryAgain), kind: .primary, size: .medium) {
                Task { await viewModel.productListing.load() }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 240)
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

#Preview {
    NavigationStack {
        CollectionDetailView(
            viewModel: CollectionDetailViewModel(
                collection: ProductCollection(
                    id: "c-1", name: "The Autumn Edit", imageName: "Onboarding1", productCount: 4,
                    description: "Considered outerwear and knitwear for the season's first chill — pieces built to layer."
                ),
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
