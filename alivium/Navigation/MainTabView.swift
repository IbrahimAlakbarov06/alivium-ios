//
//  MainTabView.swift
//  alivium
//

import SwiftUI

/// The 5-tab shell (CLAUDE.md 9.4) — Home is fully built; Search/Wishlist/Cart/Profile are
/// `ComingSoonView` placeholders until those screens exist. Active tab renders filled
/// (`AppColor.primary` via `.tint`); SF Symbols already ship outline/filled variants for free.
struct MainTabView: View {
    @Environment(LocalizationManager.self) private var localization
    @State private var homeViewModel: HomeViewModel

    init(container: AppContainer) {
        _homeViewModel = State(initialValue: container.makeHomeViewModel())
    }

    var body: some View {
        TabView {
            HomeView(viewModel: homeViewModel)
                .tabItem { Label(localization.string(.homeTab), systemImage: "house.fill") }

            ComingSoonView(title: localization.string(.searchTab), systemImage: "magnifyingglass")
                .tabItem { Label(localization.string(.searchTab), systemImage: "magnifyingglass") }

            ComingSoonView(title: localization.string(.wishlistTab), systemImage: "heart")
                .tabItem { Label(localization.string(.wishlistTab), systemImage: "heart") }

            ComingSoonView(title: localization.string(.cartTab), systemImage: "bag")
                .tabItem { Label(localization.string(.cartTab), systemImage: "bag") }

            ComingSoonView(title: localization.string(.profileTab), systemImage: "person")
                .tabItem { Label(localization.string(.profileTab), systemImage: "person") }
        }
        .tint(AppColor.primary)
    }
}

#Preview {
    let container = AppContainer()
    MainTabView(container: container)
        .environment(container.localizationManager)
}
