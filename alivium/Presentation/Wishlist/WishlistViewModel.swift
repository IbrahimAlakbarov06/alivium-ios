//
//  WishlistViewModel.swift
//  alivium
//

import Observation

@Observable
final class WishlistViewModel {
    private(set) var state: WishlistViewState = .idle
    /// Product ids currently mid-flight/just-added, so each row's own Add to Cart button can show
    /// its own loading/confirmation state without affecting the others.
    private(set) var addingToCartProductIds: Set<String> = []
    private(set) var addedToCartProductIds: Set<String> = []
    /// Keyed by product id — each row owns an inline size dropdown (not a shared sheet/dialog),
    /// so more than one row's selection can coexist independently.
    private(set) var selectedSizes: [String: String] = [:]

    private let wishlistRepository: WishlistRepository
    private let cartRepository: CartRepository
    private let userSession: UserSession
    private let cartBadgeStore: CartBadgeStore

    var sessionState: UserSessionState {
        userSession.state
    }

    init(
        wishlistRepository: WishlistRepository,
        cartRepository: CartRepository,
        userSession: UserSession,
        cartBadgeStore: CartBadgeStore
    ) {
        self.wishlistRepository = wishlistRepository
        self.cartRepository = cartRepository
        self.userSession = userSession
        self.cartBadgeStore = cartBadgeStore
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

    /// In display order (S/M/L), matching `ProductDetailViewModel.availableSizes`.
    func availableSizes(for product: Product) -> [String] {
        let order = ["S", "M", "L"]
        let present = Set(product.variants.map(\.size))
        return order.filter { present.contains($0) }
    }

    func selectedSize(for product: Product) -> String? {
        selectedSizes[product.id]
    }

    /// Inline dropdown selection (Trendyol-style row control) — replaces the size, not toggles
    /// it, since only one size makes sense selected at a time per row.
    func selectSize(_ size: String, for product: Product) {
        selectedSizes[product.id] = size
    }

    /// A product with 0 or exactly 1 variant has nothing to choose between; a product with more
    /// than one variant needs a real size choice first — matches Product Detail's own gating,
    /// and avoids the earlier bug of silently guessing a variant.
    func canAddToCart(_ product: Product) -> Bool {
        product.variants.count <= 1 || selectedSizes[product.id] != nil
    }

    /// Entry point for the row's Add to Cart button — the row itself only enables the button
    /// once `canAddToCart` is true, so this can resolve the variant directly rather than
    /// re-checking or presenting anything.
    func addToCart(_ product: Product) {
        guard canAddToCart(product) else { return }
        let variant: ProductVariant?
        if product.variants.count <= 1 {
            variant = product.variants.first
        } else {
            variant = product.variants.first { $0.size == selectedSizes[product.id] }
        }
        Task { await performAddToCart(product, variant: variant) }
    }

    @discardableResult
    private func performAddToCart(_ product: Product, variant: ProductVariant?) async -> Bool {
        addingToCartProductIds.insert(product.id)
        defer { addingToCartProductIds.remove(product.id) }
        do {
            _ = try await cartRepository.addItem(product: product, variant: variant, quantity: 1)
            addedToCartProductIds.insert(product.id)
            cartBadgeStore.increment(by: 1)
            return true
        } catch {
            return false
        }
    }
}
