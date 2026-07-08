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
    /// Owned here (not created per-push) so Home's bell badge and the pushed `NotificationsView`
    /// always agree on the same read/unread state — matches `homeViewModel`'s own lifetime.
    @State private var notificationsViewModel: NotificationsViewModel
    /// Owned here (not privately inside Home/Search) and bound into each tab's `NavigationStack`
    /// so a "Show all"/category tap can `path.append(_:)` a `ProductListingSource` onto the same
    /// path `NavigationLink(value:)` pushes products onto — see HomeView's doc comment for why an
    /// `.navigationDestination(item:)`-driven push doesn't compose safely with a second push on
    /// top of it.
    @State private var homePath = NavigationPath()
    @State private var searchPath = NavigationPath()
    let onLogOut: () -> Void
    private let makeProductDetailViewModel: (Product) -> ProductDetailViewModel
    private let makeProductListingViewModel: (ProductListingSource) -> ProductListingViewModel
    private let makeCollectionDetailViewModel: (ProductCollection) -> CollectionDetailViewModel
    private let makeCheckoutViewModel: ([CartItem], ShippingMethod) -> CheckoutViewModel
    private let makeOrderHistoryViewModel: () -> OrderHistoryViewModel
    private let makeOrderDetailViewModel: (Order) -> OrderDetailViewModel
    private let makeAddressesViewModel: () -> AddressesViewModel
    private let makeEditProfileViewModel: () -> EditProfileViewModel
    private let makeChangePasswordViewModel: () -> ChangePasswordViewModel
    private let makeRateProductViewModel: (Product) -> RateProductViewModel
    private let cartBadgeStore: CartBadgeStore

    init(container: AppContainer, onLogOut: @escaping () -> Void) {
        _homeViewModel = State(initialValue: container.makeHomeViewModel())
        _searchViewModel = State(initialValue: container.makeSearchViewModel())
        _wishlistViewModel = State(initialValue: container.makeWishlistViewModel())
        _cartViewModel = State(initialValue: container.makeCartViewModel())
        _profileViewModel = State(initialValue: container.makeProfileViewModel())
        _chatViewModel = State(initialValue: container.makeChatViewModel())
        _notificationsViewModel = State(initialValue: container.makeNotificationsViewModel())
        self.onLogOut = onLogOut
        self.makeProductDetailViewModel = { container.makeProductDetailViewModel(for: $0) }
        self.makeProductListingViewModel = { container.makeProductListingViewModel(source: $0) }
        self.makeCollectionDetailViewModel = { container.makeCollectionDetailViewModel(for: $0) }
        self.makeCheckoutViewModel = { items, shippingMethod in
            container.makeCheckoutViewModel(items: items, selectedShippingMethod: shippingMethod)
        }
        self.makeOrderHistoryViewModel = { container.makeOrderHistoryViewModel() }
        self.makeOrderDetailViewModel = { container.makeOrderDetailViewModel(for: $0) }
        self.makeAddressesViewModel = { container.makeAddressesViewModel() }
        self.makeEditProfileViewModel = { container.makeEditProfileViewModel() }
        self.makeChangePasswordViewModel = { container.makeChangePasswordViewModel() }
        self.makeRateProductViewModel = { container.makeRateProductViewModel(for: $0) }
        self.cartBadgeStore = container.cartBadgeStore
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homePath) {
                HomeView(
                    viewModel: homeViewModel,
                    notificationsViewModel: notificationsViewModel,
                    makeProductDetailViewModel: makeProductDetailViewModel,
                    makeProductListingViewModel: makeProductListingViewModel,
                    makeCollectionDetailViewModel: makeCollectionDetailViewModel,
                    onRequestAuthFlow: onLogOut,
                    path: $homePath
                )
            }
            .tabItem { Label(localization.string(.homeTab), systemImage: "house.fill") }
            .tag(AppTab.home)

            NavigationStack(path: $searchPath) {
                SearchView(
                    viewModel: searchViewModel,
                    makeProductDetailViewModel: makeProductDetailViewModel,
                    makeProductListingViewModel: makeProductListingViewModel,
                    onRequestAuthFlow: onLogOut,
                    path: $searchPath
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
                    makeCheckoutViewModel: makeCheckoutViewModel,
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

            ProfileView(
                viewModel: profileViewModel,
                chatViewModel: chatViewModel,
                makeOrderHistoryViewModel: makeOrderHistoryViewModel,
                makeOrderDetailViewModel: makeOrderDetailViewModel,
                makeAddressesViewModel: makeAddressesViewModel,
                makeEditProfileViewModel: makeEditProfileViewModel,
                makeChangePasswordViewModel: makeChangePasswordViewModel,
                makeRateProductViewModel: makeRateProductViewModel,
                makeProductDetailViewModel: makeProductDetailViewModel,
                onRequestAuthFlow: onLogOut,
                onBrowseHome: { selectedTab = .home }
            )
                .tabItem { Label(localization.string(.profileTab), systemImage: "person") }
                .tag(AppTab.profile)
        }
        .tint(AppColor.primary)
        // Loaded proactively (not just on first tab appearance) so the badge above is correct
        // the moment the tab shell shows, regardless of which tab the user visits first.
        .task { cartViewModel.onAppear() }
        // Same reasoning as Cart's badge above — Home's bell badge should already be correct
        // the moment Home shows, not just after the user opens Notifications once.
        .task { notificationsViewModel.onAppear() }
        // TabView keeps every tab's view alive after its first appearance, so Cart/Wishlist's own
        // `.task { onAppear() }` only fires once each — without this, favoriting a product from
        // Home/Search/Product Detail (or adding a cart item) wouldn't show up on that tab until
        // the next cold launch, since the ViewModel's cached `state` never got a reason to reload.
        .onChange(of: selectedTab) { _, newValue in
            if newValue == .cart {
                Task { await cartViewModel.loadCart() }
            } else if newValue == .wishlist {
                Task { await wishlistViewModel.loadWishlist() }
            }
        }
    }
}

#Preview {
    let container = AppContainer()
    MainTabView(container: container, onLogOut: {})
        .environment(container.localizationManager)
}
