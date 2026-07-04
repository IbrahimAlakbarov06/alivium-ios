//
//  WishlistViewModel.swift
//  alivium
//

import Observation

@Observable
final class WishlistViewModel {
    private(set) var state: WishlistViewState = .idle

    private let wishlistRepository: WishlistRepository
    private let userSession: UserSession

    var sessionState: UserSessionState {
        userSession.state
    }

    init(wishlistRepository: WishlistRepository, userSession: UserSession) {
        self.wishlistRepository = wishlistRepository
        self.userSession = userSession
    }

    func onAppear() {
        // A guest has no persisted wishlist yet — the View shows a sign-in prompt instead, so
        // there's nothing to fetch.
        guard case .authenticated = userSession.state else { return }
        guard state == .idle else { return }
        Task { await loadWishlist() }
    }

    func loadWishlist() async {
        state = .loading
        do {
            let products = try await wishlistRepository.fetchWishlistItems()
            state = products.isEmpty ? .empty : .loaded(products)
        } catch {
            state = .error(.somethingWentWrong)
        }
    }

    @discardableResult
    func remove(_ product: Product) async -> Bool {
        guard case .loaded(var products) = state else { return false }
        do {
            try await wishlistRepository.removeFromWishlist(productId: product.id)
            products.removeAll { $0.id == product.id }
            state = products.isEmpty ? .empty : .loaded(products)
            return true
        } catch {
            return false
        }
    }
}
