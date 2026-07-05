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
    /// Set while a multi-size product's Add to Cart is waiting on the shopper to pick a size —
    /// the View presents a size picker bound to this instead of guessing a variant.
    private(set) var productPendingSizeSelection: Product?

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

    /// Entry point for the row's Add to Cart button. A product with 0 or exactly 1 variant has
    /// nothing to choose between, so it adds directly; a product with more than one variant
    /// requires a real size choice (no compact row has a color/size picker built in, and
    /// silently guessing — the previous bug — could add the wrong size), so this instead sets
    /// `productPendingSizeSelection` and lets the View present a size picker.
    func requestAddToCart(_ product: Product) {
        guard product.variants.count > 1 else {
            Task { await addToCart(product, variant: product.variants.first) }
            return
        }
        productPendingSizeSelection = product
    }

    /// In display order (S/M/L), matching `ProductDetailViewModel.availableSizes`.
    func availableSizes(for product: Product) -> [String] {
        let order = ["S", "M", "L"]
        let present = Set(product.variants.map(\.size))
        return order.filter { present.contains($0) }
    }

    /// Color is descriptive metadata, not a shopper choice (CLAUDE.md/product notes) — the first
    /// variant matching the chosen size is used, same resolution Product Detail applies when no
    /// color has been picked.
    func confirmSizeSelection(_ size: String, for product: Product) {
        let variant = product.variants.first { $0.size == size }
        productPendingSizeSelection = nil
        Task { await addToCart(product, variant: variant) }
    }

    func cancelSizeSelection() {
        productPendingSizeSelection = nil
    }

    @discardableResult
    private func addToCart(_ product: Product, variant: ProductVariant?) async -> Bool {
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
