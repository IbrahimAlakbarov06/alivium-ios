//
//  HomeView.swift
//  alivium
//

import SwiftUI

struct HomeView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: HomeViewModel
    let makeProductDetailViewModel: (Product) -> ProductDetailViewModel
    let makeProductListingViewModel: (ProductListingSource) -> ProductListingViewModel
    let makeCollectionDetailViewModel: (ProductCollection) -> CollectionDetailViewModel
    /// Wired the same way as Profile/Wishlist's Guest CTA — drops back to the Auth flow.
    let onRequestAuthFlow: () -> Void
    /// Owned by the tab shell and bound to this tab's `NavigationStack`, so a rail's "Show all"
    /// tap can push a `ProductListingSource` with `path.append(_:)` onto the SAME path that
    /// `NavigationLink(value:)` pushes products onto. An `.navigationDestination(item:)` bound to
    /// its own private `@State` optional was tried first, but it maintains its own "this
    /// destination is on the path whenever the item is non-nil" invariant — once a *second* push
    /// (Product Detail) landed on top, the stack re-asserted that invariant and shoved a
    /// duplicate listing screen on top of Product Detail. A single shared `NavigationPath` has
    /// no such invariant to re-assert.
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.xs)
                    .padding(.bottom, AppSpacing.sm)

                content
            }
        }
        .background(AppColor.backgroundOffWhite)
        .task { viewModel.onAppear() }
        .navigationDestination(for: Product.self) { product in
            ProductDetailView(
                viewModel: makeProductDetailViewModel(product),
                makeProductDetailViewModel: makeProductDetailViewModel,
                onRequestAuthFlow: onRequestAuthFlow
            )
        }
        .navigationDestination(for: ProductListingSource.self) { source in
            ProductListingView(
                viewModel: makeProductListingViewModel(source),
                makeProductDetailViewModel: makeProductDetailViewModel,
                onRequestAuthFlow: onRequestAuthFlow
            )
        }
        .navigationDestination(for: ProductCollection.self) { collection in
            CollectionDetailView(
                viewModel: makeCollectionDetailViewModel(collection),
                makeProductDetailViewModel: makeProductDetailViewModel,
                onRequestAuthFlow: onRequestAuthFlow
            )
        }
        .alert(localization.string(.wishlistGuestTitle), isPresented: $viewModel.needsSignInForWishlist) {
            Button(localization.string(.logInOrSignUp)) { onRequestAuthFlow() }
            Button(localization.string(.cancel), role: .cancel) {}
        } message: {
            Text(localization.string(.wishlistGuestSubtitle))
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            HomeSkeletonView()
        case .loaded(let feed):
            loadedContent(feed)
        case .error(let key):
            errorState(key)
        }
    }

    private var topBar: some View {
        HStack {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(AppColor.textPrimary)

            Spacer()

            Text("ALIVIUM")
                .font(.system(size: 20, weight: .bold))
                .tracking(2)
                .foregroundStyle(AppColor.primary)

            Spacer()

            Image(systemName: "bell")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(AppColor.textPrimary)
        }
    }

    private func loadedContent(_ feed: HomeFeed) -> some View {
        VStack(spacing: AppSpacing.xxl) {
            HeroBannerCarousel(banners: feed.heroBanners)

            categoryChips(feed.categories)
                .padding(.horizontal, AppSpacing.md)

            productRail(
                titleKey: .featuredProducts,
                products: feed.featuredProducts,
                layout: .rail
            )
            .padding(.horizontal, AppSpacing.md)

            if let spotlight = feed.topCollections.first {
                CollectionCard(collection: spotlight, aspectRatio: 16.0 / 9.0) {
                    path.append(spotlight)
                }
                .padding(.horizontal, AppSpacing.md)
            }

            productRail(
                titleKey: .recommended,
                products: feed.recommendedProducts,
                layout: .wide
            )
            .padding(.horizontal, AppSpacing.md)

            collectionsGrid(Array(feed.topCollections.dropFirst()))
                .padding(.horizontal, AppSpacing.md)
        }
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.xl)
    }

    private func categoryChips(_ categories: [Category]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                ForEach(categories) { category in
                    CategoryChip(
                        title: localization.string(forCategory: category),
                        isSelected: viewModel.selectedCategoryId == category.id
                    ) {
                        viewModel.selectCategory(category.id)
                    }
                }
            }
        }
    }

    private func productRail(titleKey: LocalizedKey, products: [Product], layout: ProductCardLayout) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: localization.string(titleKey), actionTitle: localization.string(.showAll)) {
                path.append(ProductListingSource.curated(titleKey: titleKey, products: products))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: AppSpacing.md) {
                    ForEach(products) { product in
                        // A hidden background link, not a wrapping one — the heart stays a
                        // plain, un-nested `Button` instead of racing the NavigationLink's own
                        // tap gesture for taps landing on it (see ProductCard's heart comment).
                        ProductCard(product: product, layout: layout, isWishlisted: viewModel.isWishlisted(product)) {
                            viewModel.toggleWishlist(for: product)
                        }
                        .background {
                            // `Color.clear`, not `EmptyView()` — EmptyView has zero intrinsic
                            // size, so the link had no actual tappable area at all despite
                            // sitting in `.background`.
                            NavigationLink(value: product) { Color.clear }
                        }
                    }
                }
            }
        }
    }

    private func collectionsGrid(_ collections: [ProductCollection]) -> some View {
        let gridPair = Array(collections.prefix(2))
        let fullWidthRest = Array(collections.dropFirst(2))
        let columns = [GridItem(.flexible(), spacing: AppSpacing.md), GridItem(.flexible())]

        return VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: localization.string(.topCollections))

            LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                ForEach(gridPair) { collection in
                    CollectionCard(collection: collection) {
                        path.append(collection)
                    }
                }
            }

            ForEach(fullWidthRest) { collection in
                CollectionCard(collection: collection, aspectRatio: 16.0 / 9.0) {
                    path.append(collection)
                }
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
                Task { await viewModel.loadFeed() }
            }
        }
        .padding(AppSpacing.xl)
    }
}

private struct HomePreviewContainer: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
                viewModel: HomeViewModel(
                    fetchHomeFeedUseCase: DefaultFetchHomeFeedUseCase(
                        productRepository: MockProductRepository(),
                        categoryRepository: MockCategoryRepository()
                    ),
                    wishlistRepository: MockWishlistRepository(),
                    userSession: UserSession()
                ),
                makeProductDetailViewModel: { product in
                    ProductDetailViewModel(
                        product: product,
                        productRepository: MockProductRepository(),
                        reviewRepository: MockReviewRepository(),
                        cartRepository: MockCartRepository(),
                        wishlistRepository: MockWishlistRepository(),
                        cartBadgeStore: CartBadgeStore(),
                        userSession: UserSession()
                    )
                },
                makeProductListingViewModel: { source in
                    ProductListingViewModel(
                        source: source,
                        productRepository: MockProductRepository(),
                        wishlistRepository: MockWishlistRepository(),
                        userSession: UserSession()
                    )
                },
                makeCollectionDetailViewModel: { collection in
                    CollectionDetailViewModel(
                        collection: collection,
                        productRepository: MockProductRepository(),
                        wishlistRepository: MockWishlistRepository(),
                        userSession: UserSession()
                    )
                },
                onRequestAuthFlow: {},
                path: $path
            )
        }
        .environment(LocalizationManager())
    }
}

#Preview {
    HomePreviewContainer()
}
