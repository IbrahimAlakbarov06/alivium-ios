//
//  HomeView.swift
//  alivium
//

import SwiftUI

struct HomeView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: HomeViewModel
    let makeProductDetailViewModel: (Product) -> ProductDetailViewModel

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
                makeProductDetailViewModel: makeProductDetailViewModel
            )
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
                title: localization.string(.featuredProducts),
                products: feed.featuredProducts,
                layout: .rail
            )
            .padding(.horizontal, AppSpacing.md)

            if let spotlight = feed.topCollections.first {
                CollectionCard(collection: spotlight, aspectRatio: 16.0 / 9.0) {
                    // TODO: navigate to Collection detail once it exists.
                }
                .padding(.horizontal, AppSpacing.md)
            }

            productRail(
                title: localization.string(.recommended),
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

    private func productRail(title: String, products: [Product], layout: ProductCardLayout) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: title, actionTitle: localization.string(.showAll)) {
                // TODO: navigate to Category/Product Listing once it exists.
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: AppSpacing.md) {
                    ForEach(products) { product in
                        // A hidden background link, not a wrapping one — the heart stays a
                        // plain, un-nested `Button` instead of racing the NavigationLink's own
                        // tap gesture for taps landing on it (see ProductCard's heart comment).
                        ProductCard(product: product, layout: layout) {
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
                        // TODO: navigate to Collection detail once it exists.
                    }
                }
            }

            ForEach(fullWidthRest) { collection in
                CollectionCard(collection: collection, aspectRatio: 16.0 / 9.0) {
                    // TODO: navigate to Collection detail once it exists.
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

#Preview {
    NavigationStack {
        HomeView(
            viewModel: HomeViewModel(
                fetchHomeFeedUseCase: DefaultFetchHomeFeedUseCase(
                    productRepository: MockProductRepository(),
                    categoryRepository: MockCategoryRepository()
                )
            ),
            makeProductDetailViewModel: { product in
                ProductDetailViewModel(
                    product: product,
                    productRepository: MockProductRepository(),
                    reviewRepository: MockReviewRepository(),
                    cartRepository: MockCartRepository(),
                    wishlistRepository: MockWishlistRepository()
                )
            }
        )
    }
    .environment(LocalizationManager())
}
