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

    init(container: AppContainer, onLogOut: @escaping () -> Void) {
        _homeViewModel = State(initialValue: container.makeHomeViewModel())
        _searchViewModel = State(initialValue: container.makeSearchViewModel())
        _wishlistViewModel = State(initialValue: container.makeWishlistViewModel())
        _cartViewModel = State(initialValue: container.makeCartViewModel())
        _profileViewModel = State(initialValue: container.makeProfileViewModel())
        _chatViewModel = State(initialValue: container.makeChatViewModel())
        self.onLogOut = onLogOut
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: homeViewModel)
                .tabItem { Label(localization.string(.homeTab), systemImage: "house.fill") }
                .tag(AppTab.home)

            SearchView(viewModel: searchViewModel)
                .tabItem { Label(localization.string(.searchTab), systemImage: "magnifyingglass") }
                .tag(AppTab.search)

            WishlistView(
                viewModel: wishlistViewModel,
                onBrowseHome: { selectedTab = .home },
                onRequestAuthFlow: onLogOut
            )
            .tabItem { Label(localization.string(.wishlistTab), systemImage: "heart") }
            .tag(AppTab.wishlist)

            CartView(viewModel: cartViewModel, onBrowseHome: { selectedTab = .home })
                .tabItem { Label(localization.string(.cartTab), systemImage: "bag") }
                .tag(AppTab.cart)
                .badge(cartViewModel.itemCount)

            ProfileView(viewModel: profileViewModel, chatViewModel: chatViewModel, onRequestAuthFlow: onLogOut)
                .tabItem { Label(localization.string(.profileTab), systemImage: "person") }
                .tag(AppTab.profile)
        }
        .tint(AppColor.primary)
        // Loaded proactively (not just on first tab appearance) so the badge above is correct
        // the moment the tab shell shows, regardless of which tab the user visits first.
        .task { cartViewModel.onAppear() }
    }
}

#Preview {
    let container = AppContainer()
    MainTabView(container: container, onLogOut: {})
        .environment(container.localizationManager)
}
