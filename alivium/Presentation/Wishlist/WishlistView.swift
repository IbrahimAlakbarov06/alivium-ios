//
//  WishlistView.swift
//  alivium
//

import SwiftUI

struct WishlistView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: WishlistViewModel
    let makeProductDetailViewModel: (Product) -> ProductDetailViewModel

    /// Wired to the tab shell's Home tab — "Start Browsing" from the truly-empty state.
    let onBrowseHome: () -> Void
    /// Wired the same way as Profile's Guest CTA — drops back to the Auth flow.
    let onRequestAuthFlow: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.xs)
                .padding(.bottom, AppSpacing.sm)

            content
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

    /// Editorial treatment: the tab title plus a saved-count subtitle when there's something to
    /// count, rather than a bare heading — the same "considered" bar as Home's top bar.
    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(localization.string(.wishlistTab))
                .font(AppTypography.title)
                .foregroundStyle(AppColor.textPrimary)

            if case .loaded(let products) = viewModel.state {
                Text("\(products.count) \(localization.string(.wishlistSavedCountSuffix))")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var content: some View {
        if case .guest = viewModel.sessionState {
            EmptyStateView(
                icon: "person.crop.circle",
                title: localization.string(.wishlistGuestTitle),
                subtitle: localization.string(.wishlistGuestSubtitle),
                actionTitle: localization.string(.logInOrSignUp),
                action: onRequestAuthFlow
            )
        } else {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
                    .tint(AppColor.primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let products):
                grid(products)
            case .empty:
                EmptyStateView(
                    icon: "heart",
                    title: localization.string(.wishlistEmptyTitle),
                    subtitle: localization.string(.wishlistEmptySubtitle),
                    actionTitle: localization.string(.startBrowsing),
                    action: onBrowseHome
                )
            case .error(let key):
                errorState(key)
            }
        }
    }

    private func grid(_ products: [Product]) -> some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: AppSpacing.lg), GridItem(.flexible())],
                spacing: AppSpacing.xl
            ) {
                ForEach(products) { product in
                    wishlistCard(product)
                        .transition(.scale(scale: 0.85).combined(with: .opacity))
                }
            }
            // Watching the id list (not just count) means additions/removals both animate
            // in/out via each card's `.transition`, instead of an instant reflow.
            .animation(.easeOut(duration: 0.25), value: products.map(\.id))
            .padding(AppSpacing.md)
        }
    }

    /// Gives each card its own soft, warm-toned elevation — a subtle lift off the off-white
    /// background rather than the bare grid `ProductCard` reads as on Home/Search. Navigation is
    /// a hidden background link, not a wrapping one, so the heart stays a plain, un-nested
    /// `Button` instead of racing the NavigationLink's own tap gesture (see ProductCard's heart).
    private func wishlistCard(_ product: Product) -> some View {
        ProductCard(product: product, layout: .grid, isWishlisted: true) {
            Task { await viewModel.remove(product) }
        }
        .padding(AppSpacing.sm)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.08), radius: 12, x: 0, y: 6)
        .background {
            // `Color.clear`, not `EmptyView()` — EmptyView has zero intrinsic size, so the link
            // had no actual tappable area at all despite sitting in `.background`.
            NavigationLink(value: product) { Color.clear }
        }
    }

    private func errorState(_ key: LocalizedKey) -> some View {
        VStack(spacing: AppSpacing.md) {
            Text(localization.string(key))
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)

            BaseButton(title: localization.string(.tryAgain), kind: .primary, size: .medium) {
                Task { await viewModel.loadWishlist() }
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
        wishlistRepository: MockWishlistRepository()
    )
}

#Preview("Authenticated, loaded") {
    let session = UserSession()
    session.signIn(User(id: "1", fullName: "Aysel Məmmədova", email: "aysel@alivium.com"))
    return NavigationStack {
        WishlistView(
            viewModel: WishlistViewModel(wishlistRepository: MockWishlistRepository(), userSession: session),
            makeProductDetailViewModel: previewMakeProductDetailViewModel,
            onBrowseHome: {},
            onRequestAuthFlow: {}
        )
    }
    .environment(LocalizationManager())
}

#Preview("Guest") {
    NavigationStack {
        WishlistView(
            viewModel: WishlistViewModel(wishlistRepository: MockWishlistRepository(), userSession: UserSession()),
            makeProductDetailViewModel: previewMakeProductDetailViewModel,
            onBrowseHome: {},
            onRequestAuthFlow: {}
        )
    }
    .environment(LocalizationManager())
}
