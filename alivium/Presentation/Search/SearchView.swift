//
//  SearchView.swift
//  alivium
//

import SwiftUI

struct SearchView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: SearchViewModel
    let makeProductDetailViewModel: (Product) -> ProductDetailViewModel
    let makeProductListingViewModel: (ProductListingSource) -> ProductListingViewModel
    /// Wired the same way as Profile/Wishlist's Guest CTA — drops back to the Auth flow.
    let onRequestAuthFlow: () -> Void
    /// Pushed imperatively from a category banner/subcategory row tap — see HomeView's identical
    /// property for why `.navigationDestination(item:)` fits better than a `NavigationLink` value
    /// here (both are plain `Button` actions, not link-wrapped rows).
    @State private var pushedListingSource: ProductListingSource?

    /// Top-level categories with a big banner — leaf categories that also work as full-width
    /// browse entry points. Ids, not names, so this stays correct if copy changes.
    private static let bannerCategoryIds: [String] = ["clothing", "shoes", "bags", "accessories"]
    private static let bannerImages = ["Onboarding1", "Onboarding2", "Onboarding3"]
    private static let bannerTints: [Color] = [AppColor.primary, AppColor.accent, AppColor.primarySoft, AppColor.accentDeep]

    var body: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.xs)
                .padding(.bottom, AppSpacing.sm)

            searchBar
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.sm)

            content
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
        .navigationDestination(item: $pushedListingSource) { source in
            ProductListingView(
                viewModel: makeProductListingViewModel(source),
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

    private var topBar: some View {
        HStack {
            Text(localization.string(.discoverTitle))
                .font(AppTypography.title)
                .foregroundStyle(AppColor.textPrimary)

            Spacer()

            Image(systemName: "bell")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(AppColor.textPrimary)
        }
    }

    private var searchBar: some View {
        HStack(spacing: AppSpacing.sm) {
            BaseTextField(
                placeholder: localization.string(.searchPlaceholder),
                text: $viewModel.query,
                style: .search
            )

            Button {
                // TODO: present a real filter sheet once filtering criteria exist.
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(AppColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isSearchActive {
            searchResultsContent
        } else {
            browsingContent
        }
    }

    // MARK: - Browsing

    @ViewBuilder
    private var browsingContent: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .tint(AppColor.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded:
            ScrollView {
                categoryBanners
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.sm)
                    .padding(.bottom, AppSpacing.xl)
            }
        case .error(let key):
            errorState(key)
        }
    }

    private var categoryBanners: some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(Array(bannerCategories.enumerated()), id: \.element.id) { index, category in
                let isExpandable = !category.subcategories.isEmpty
                let isExpanded = viewModel.expandedCategoryId == category.id

                VStack(spacing: AppSpacing.sm) {
                    CategoryBanner(
                        title: localization.string(forCategory: category),
                        imageName: Self.bannerImages[index % Self.bannerImages.count],
                        tint: Self.bannerTints[index % Self.bannerTints.count],
                        imageLeading: index % 2 == 1,
                        isExpandable: isExpandable,
                        isExpanded: isExpanded
                    ) {
                        if isExpandable {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.toggleCategoryExpansion(category)
                            }
                        } else {
                            pushedListingSource = .category(category)
                        }
                    }

                    if isExpanded {
                        SubcategoryList(subcategories: category.subcategories) { subcategory in
                            pushedListingSource = .category(subcategory)
                        }
                    }
                }
            }
        }
    }

    private var bannerCategories: [Category] {
        Self.bannerCategoryIds.compactMap { id in
            viewModel.categories.first { $0.id == id }
        }
    }

    private func errorState(_ key: LocalizedKey) -> some View {
        VStack(spacing: AppSpacing.md) {
            Text(localization.string(key))
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)

            BaseButton(title: localization.string(.tryAgain), kind: .primary, size: .medium) {
                Task { await viewModel.loadCategories() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppSpacing.xl)
    }

    // MARK: - Search results

    @ViewBuilder
    private var searchResultsContent: some View {
        if viewModel.isSearchLoading && viewModel.searchResults.isEmpty {
            ProgressView()
                .tint(AppColor.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.searchResults.isEmpty {
            emptyResultsState
        } else {
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: AppSpacing.md), GridItem(.flexible())],
                    spacing: AppSpacing.lg
                ) {
                    ForEach(viewModel.searchResults) { product in
                        NavigationLink(value: product) {
                            ProductCard(product: product, layout: .grid, isWishlisted: viewModel.isWishlisted(product)) {
                                viewModel.toggleWishlist(for: product)
                            }
                                // `CatalogImage` opts out of hit-testing (elsewhere, that lets a
                                // hidden background NavigationLink receive the tap instead) —
                                // here the Link wraps the card directly, so without an explicit
                                // content shape its tappable region would shrink to just the
                                // name/price text, since the image no longer contributes one.
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(AppSpacing.md)
            }
        }
    }

    private var emptyResultsState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(AppColor.textSecondary.opacity(0.5))
            Text(localization.string(.noResultsFound))
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack {
        SearchView(
            viewModel: SearchViewModel(
                categoryRepository: MockCategoryRepository(),
                productRepository: MockProductRepository(),
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
            onRequestAuthFlow: {}
        )
    }
    .environment(LocalizationManager())
}
