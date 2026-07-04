//
//  WishlistView.swift
//  alivium
//

import SwiftUI

struct WishlistView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: WishlistViewModel

    /// Wired to the tab shell's Home tab — "Start Browsing" from the truly-empty state.
    let onBrowseHome: () -> Void
    /// Wired the same way as Profile's Guest CTA — drops back to the Auth flow.
    let onRequestAuthFlow: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.xs)
                .padding(.bottom, AppSpacing.sm)

            content
        }
        .background(AppColor.backgroundOffWhite)
        .task { viewModel.onAppear() }
    }

    private var topBar: some View {
        HStack {
            Text(localization.string(.wishlistTab))
                .font(AppTypography.title)
                .foregroundStyle(AppColor.textPrimary)
            Spacer()
        }
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
                columns: [GridItem(.flexible(), spacing: AppSpacing.md), GridItem(.flexible())],
                spacing: AppSpacing.lg
            ) {
                ForEach(products) { product in
                    ProductCard(product: product, layout: .grid, isWishlisted: true) {
                        Task { await viewModel.remove(product) }
                    }
                }
            }
            .padding(AppSpacing.md)
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

#Preview("Authenticated, loaded") {
    let session = UserSession()
    session.signIn(User(id: "1", fullName: "Aysel Məmmədova", email: "aysel@alivium.com"))
    return WishlistView(
        viewModel: WishlistViewModel(wishlistRepository: MockWishlistRepository(), userSession: session),
        onBrowseHome: {},
        onRequestAuthFlow: {}
    )
    .environment(LocalizationManager())
}

#Preview("Guest") {
    WishlistView(
        viewModel: WishlistViewModel(wishlistRepository: MockWishlistRepository(), userSession: UserSession()),
        onBrowseHome: {},
        onRequestAuthFlow: {}
    )
    .environment(LocalizationManager())
}
