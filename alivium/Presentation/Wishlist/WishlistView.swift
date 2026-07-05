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
                makeProductDetailViewModel: makeProductDetailViewModel,
                onRequestAuthFlow: onRequestAuthFlow
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
                list(products)
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

    /// Horizontal rows (image + name/price + a direct Add to Cart action) rather than a 2-column
    /// grid — a saved item is something the shopper is already sold on, so the priority is
    /// getting it into the cart in one tap, not another round of browsing-style thumbnails.
    private func list(_ products: [Product]) -> some View {
        ScrollView {
            // A plain VStack, not `LazyVStack` — a saved-items list is always small (a handful
            // of products at most), so laziness buys nothing here, and `LazyVStack` cell reuse
            // was observed to occasionally misattribute a row's accessibility frame to a
            // different row after scrolling, making a specific row's controls untappable by UI
            // tests.
            VStack(spacing: AppSpacing.md) {
                ForEach(products) { product in
                    NavigationLink(value: product) {
                        WishlistRow(
                            product: product,
                            availableSizes: viewModel.availableSizes(for: product),
                            selectedSize: viewModel.selectedSize(for: product),
                            canAddToCart: viewModel.canAddToCart(product),
                            isAddingToCart: viewModel.addingToCartProductIds.contains(product.id),
                            didAddToCart: viewModel.addedToCartProductIds.contains(product.id),
                            onRemove: { Task { await viewModel.remove(product) } },
                            onSelectSize: { size in viewModel.selectSize(size, for: product) },
                            onAddToCart: { viewModel.addToCart(product) }
                        )
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity)
                }
            }
            // Watching the id list (not just count) means removals animate out instead of an
            // instant reflow.
            .animation(.easeOut(duration: 0.25), value: products.map(\.id))
            .padding(AppSpacing.md)
        }
        .accessibilityIdentifier("wishlistScrollView")
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
        wishlistRepository: MockWishlistRepository(),
        cartBadgeStore: CartBadgeStore(),
        userSession: UserSession()
    )
}

#Preview("Authenticated, loaded") {
    let session = UserSession()
    session.signIn(User(id: "1", fullName: "Aysel Məmmədova", email: "aysel@alivium.com"))
    return NavigationStack {
        WishlistView(
            viewModel: WishlistViewModel(wishlistRepository: MockWishlistRepository(), cartRepository: MockCartRepository(), userSession: session, cartBadgeStore: CartBadgeStore()),
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
            viewModel: WishlistViewModel(wishlistRepository: MockWishlistRepository(), cartRepository: MockCartRepository(), userSession: UserSession(), cartBadgeStore: CartBadgeStore()),
            makeProductDetailViewModel: previewMakeProductDetailViewModel,
            onBrowseHome: {},
            onRequestAuthFlow: {}
        )
    }
    .environment(LocalizationManager())
}
