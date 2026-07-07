//
//  MainTabView.swift
//  alivium
//

import SwiftUI

/// The 5-tab shell (CLAUDE.md 9.4). Active tab renders filled (`AppColor.primary` via `.tint`);
/// SF Symbols already ship outline/filled variants for free.
struct MainTabView: View {
    @Environment(LocalizationManager.self) private var localization
    @State private var selectedTab: AppTab = .home
    @State private var homeViewModel: HomeViewModel
    @State private var searchViewModel: SearchViewModel
    @State private var wishlistViewModel: WishlistViewModel
    @State private var cartViewModel: CartViewModel
    @State private var profileViewModel: ProfileViewModel
    @State private var chatViewModel: ChatViewModel
    let onLogOut: () -> Void
    private let makeProductDetailViewModel: (Product) -> ProductDetailViewModel
    private let makeProductListingViewModel: (ProductListingSource) -> ProductListingViewModel
    private let cartBadgeStore: CartBadgeStore

    init(container: AppContainer, onLogOut: @escaping () -> Void) {
        _homeViewModel = State(initialValue: container.makeHomeViewModel())
        _searchViewModel = State(initialValue: container.makeSearchViewModel())
        _wishlistViewModel = State(initialValue: container.makeWishlistViewModel())
        _cartViewModel = State(initialValue: container.makeCartViewModel())
        _profileViewModel = State(initialValue: container.makeProfileViewModel())
        _chatViewModel = State(initialValue: container.makeChatViewModel())
        self.onLogOut = onLogOut
        self.makeProductDetailViewModel = { container.makeProductDetailViewModel(for: $0) }
        self.makeProductListingViewModel = { container.makeProductListingViewModel(source: $0) }
        self.cartBadgeStore = container.cartBadgeStore
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(
                    viewModel: homeViewModel,
                    makeProductDetailViewModel: makeProductDetailViewModel,
                    makeProductListingViewModel: makeProductListingViewModel,
                    onRequestAuthFlow: onLogOut
                )
            }
            .tabItem { Label(localization.string(.homeTab), systemImage: "house.fill") }
            .tag(AppTab.home)

            NavigationStack {
                SearchView(
                    viewModel: searchViewModel,
                    makeProductDetailViewModel: makeProductDetailViewModel,
                    makeProductListingViewModel: makeProductListingViewModel,
                    onRequestAuthFlow: onLogOut
                )
            }
            .tabItem { Label(localization.string(.searchTab), systemImage: "magnifyingglass") }
            .tag(AppTab.search)

            NavigationStack {
                WishlistView(
                    viewModel: wishlistViewModel,
                    makeProductDetailViewModel: makeProductDetailViewModel,
                    onBrowseHome: { selectedTab = .home },
                    onRequestAuthFlow: onLogOut
                )
            }
            .tabItem { Label(localization.string(.wishlistTab), systemImage: "heart") }
            .tag(AppTab.wishlist)

            NavigationStack {
                CartView(
                    viewModel: cartViewModel,
                    makeProductDetailViewModel: makeProductDetailViewModel,
                    onBrowseHome: { selectedTab = .home },
                    onRequestAuthFlow: onLogOut
                )
            }
            .tabItem { Label(localization.string(.cartTab), systemImage: "bag") }
            .tag(AppTab.cart)
            .badge(cartBadgeStore.itemCount)
            // A quick spring "bump" whenever the count changes (matches PageIndicator's own
            // spring-driven dot transition) rather than an instant static number swap.
            .animation(.spring(response: 0.35, dampingFraction: 0.55), value: cartBadgeStore.itemCount)

            ProfileView(viewModel: profileViewModel, chatViewModel: chatViewModel, onRequestAuthFlow: onLogOut)
                .tabItem { Label(localization.string(.profileTab), systemImage: "person") }
                .tag(AppTab.profile)
        }
        .tint(AppColor.primary)
        // Loaded proactively (not just on first tab appearance) so the badge above is correct
        // the moment the tab shell shows, regardless of which tab the user visits first.
        .task { cartViewModel.onAppear() }
        // TabView keeps every tab's view alive after its first appearance, so Cart's `.task`
        // only fires once — without this, adding an item from Product Detail and switching to
        // Cart wouldn't show it until the next cold launch.
        .onChange(of: selectedTab) { _, newValue in
            if newValue == .cart {
                Task { await cartViewModel.loadCart() }
            }
        }
    }
}

#Preview {
    let container = AppContainer()
    MainTabView(container: container, onLogOut: {})
        .environment(container.localizationManager)
}
