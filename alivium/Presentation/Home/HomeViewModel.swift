//
//  HomeViewModel.swift
//  alivium
//

import Observation

@Observable
final class HomeViewModel {
    private(set) var state: HomeViewState = .idle
    var selectedCategoryId: String?
    private(set) var wishlistedProductIds: Set<String> = []
    /// Set when a Guest taps a product card's heart — the View shows a sign-in prompt instead
    /// of toggling the wishlist.
    var needsSignInForWishlist = false

    private let fetchHomeFeedUseCase: FetchHomeFeedUseCase
    private let wishlistRepository: WishlistRepository
    private let userSession: UserSession

    init(fetchHomeFeedUseCase: FetchHomeFeedUseCase, wishlistRepository: WishlistRepository, userSession: UserSession) {
        self.fetchHomeFeedUseCase = fetchHomeFeedUseCase
        self.wishlistRepository = wishlistRepository
        self.userSession = userSession
    }

    func onAppear() {
        guard state == .idle else { return }
        Task {
            await loadWishlistedIds()
            await loadFeed()
        }
    }

    func loadFeed() async {
        state = .loading
        do {
            let feed = try await fetchHomeFeedUseCase.execute()
            state = .loaded(feed)
        } catch {
            state = .error(.somethingWentWrong)
        }
    }

    private func loadWishlistedIds() async {
        guard case .authenticated = userSession.state else { return }
        if let items = try? await wishlistRepository.fetchWishlistItems() {
            wishlistedProductIds = Set(items.map(\.id))
        }
    }

    func selectCategory(_ id: String) {
        selectedCategoryId = (selectedCategoryId == id) ? nil : id
    }

    func isWishlisted(_ product: Product) -> Bool {
        wishlistedProductIds.contains(product.id)
    }

    func toggleWishlist(for product: Product) {
        guard case .authenticated = userSession.state else {
            needsSignInForWishlist = true
            return
        }
        Task {
            do {
                if wishlistedProductIds.contains(product.id) {
                    try await wishlistRepository.removeFromWishlist(productId: product.id)
                    wishlistedProductIds.remove(product.id)
                } else {
                    try await wishlistRepository.addToWishlist(productId: product.id)
                    wishlistedProductIds.insert(product.id)
                }
            } catch {
                // Phase 1 mock never actually throws here.
            }
        }
    }
}
