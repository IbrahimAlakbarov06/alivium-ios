//
//  ProductListingViewModel.swift
//  alivium
//

import Observation

@Observable
final class ProductListingViewModel {
    let source: ProductListingSource
    private(set) var state: ProductListingViewState = .idle
    var sortOption: ProductSortOption = .featured {
        didSet { applySortAndFilter() }
    }
    var isOnSaleOnly = false {
        didSet { applySortAndFilter() }
    }
    private(set) var displayedProducts: [Product] = []
    private(set) var wishlistedProductIds: Set<String> = []
    /// Set when a Guest taps a result card's heart — the View shows a sign-in prompt instead of
    /// toggling the wishlist, matching every other product-listing screen.
    var needsSignInForWishlist = false

    /// The unfiltered, unsorted fetch — `displayedProducts` is always derived from this so
    /// toggling sort/filter never needs a re-fetch.
    private var allProducts: [Product] = []
    private let productRepository: ProductRepository
    private let wishlistRepository: WishlistRepository
    private let userSession: UserSession

    init(
        source: ProductListingSource,
        productRepository: ProductRepository,
        wishlistRepository: WishlistRepository,
        userSession: UserSession
    ) {
        self.source = source
        self.productRepository = productRepository
        self.wishlistRepository = wishlistRepository
        self.userSession = userSession
    }

    func onAppear() {
        guard state == .idle else { return }
        Task {
            await loadWishlistedIds()
            await load()
        }
    }

    func load() async {
        state = .loading
        do {
            switch source {
            case .category(let category):
                allProducts = try await productRepository.fetchProducts(byCategory: category.id)
            case .curated(_, let products):
                allProducts = products
            case .collection(let collection):
                allProducts = try await productRepository.fetchProducts(collectionId: collection.id)
            }
            applySortAndFilter()
            state = allProducts.isEmpty ? .empty : .loaded
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

    private func applySortAndFilter() {
        var items = isOnSaleOnly ? allProducts.filter(\.isOnSale) : allProducts
        switch sortOption {
        case .featured:
            break
        case .priceLowToHigh:
            items.sort { $0.effectivePrice < $1.effectivePrice }
        case .priceHighToLow:
            items.sort { $0.effectivePrice > $1.effectivePrice }
        case .topRated:
            items.sort { $0.averageRating > $1.averageRating }
        }
        displayedProducts = items
    }
}
