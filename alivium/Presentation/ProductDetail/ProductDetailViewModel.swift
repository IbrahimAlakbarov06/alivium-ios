//
//  ProductDetailViewModel.swift
//  alivium
//

import Observation

@Observable
final class ProductDetailViewModel {
    let product: Product
    private(set) var state: ProductDetailViewState = .idle
    private(set) var reviews: [Review] = []
    private(set) var relatedProducts: [Product] = []

    var selectedSize: String?
    var selectedColor: String?
    private(set) var isWishlisted = false
    private(set) var isAddingToCart = false
    private(set) var didAddToCart = false
    /// Set when a Guest taps the wishlist heart — the View shows a sign-in prompt instead of
    /// toggling the wishlist.
    var needsSignInForWishlist = false

    private let productRepository: ProductRepository
    private let reviewRepository: ReviewRepository
    private let cartRepository: CartRepository
    private let wishlistRepository: WishlistRepository
    private let cartBadgeStore: CartBadgeStore
    private let userSession: UserSession

    /// In real-world display order (numeric for shoes, XS-XXL for clothing), not just whatever
    /// order the mock data happens to list.
    var availableSizes: [String] {
        ProductVariant.sortedSizes(in: product.variants)
    }

    var availableColors: [String] {
        var seen: [String] = []
        for variant in product.variants where !seen.contains(variant.color) {
            seen.append(variant.color)
        }
        return seen
    }

    /// Size is the real variant dimension for this boutique (mostly one color per product) —
    /// color is descriptive metadata for browsing/filtering, not something the shopper must
    /// deliberately choose. So once a size is picked, resolve a variant by size alone when no
    /// color has been (or needs to be) chosen, rather than requiring an exact size+color match.
    var selectedVariant: ProductVariant? {
        guard let selectedSize else { return product.variants.first }
        if let selectedColor {
            return product.variants.first { $0.size == selectedSize && $0.color == selectedColor }
        }
        return product.variants.first { $0.size == selectedSize }
    }

    /// Only size gates the button — products with no variants at all (e.g. earrings) skip the
    /// requirement entirely, and color (even when a product has more than one) stays optional.
    var canAddToCart: Bool {
        guard !isAddingToCart else { return false }
        return availableSizes.isEmpty || selectedSize != nil
    }

    init(
        product: Product,
        productRepository: ProductRepository,
        reviewRepository: ReviewRepository,
        cartRepository: CartRepository,
        wishlistRepository: WishlistRepository,
        cartBadgeStore: CartBadgeStore,
        userSession: UserSession
    ) {
        self.product = product
        self.productRepository = productRepository
        self.reviewRepository = reviewRepository
        self.cartRepository = cartRepository
        self.wishlistRepository = wishlistRepository
        self.cartBadgeStore = cartBadgeStore
        self.userSession = userSession

        // No forced choice when there's nothing to choose.
        if availableSizes.count == 1 { selectedSize = availableSizes.first }
        if availableColors.count == 1 { selectedColor = availableColors.first }
    }

    func onAppear() {
        guard state == .idle else { return }
        Task {
            await loadWishlistStatus()
            await loadDetails()
        }
    }

    func loadDetails() async {
        state = .loading
        do {
            async let reviewsResult = reviewRepository.fetchReviews(productId: product.id)
            async let relatedResult = loadRelatedProducts()
            reviews = try await reviewsResult
            relatedProducts = try await relatedResult
            state = .loaded
        } catch {
            state = .error(.somethingWentWrong)
        }
    }

    private func loadRelatedProducts() async throws -> [Product] {
        async let featured = productRepository.fetchFeaturedProducts()
        async let recommended = productRepository.fetchRecommendedProducts()
        let all = try await featured + (try await recommended)
        let sameCategory = all.filter { $0.categoryId == product.categoryId && $0.id != product.id }
        return sameCategory.isEmpty ? Array(all.filter { $0.id != product.id }.prefix(6)) : sameCategory
    }

    private func loadWishlistStatus() async {
        if let items = try? await wishlistRepository.fetchWishlistItems() {
            isWishlisted = items.contains { $0.id == product.id }
        }
    }

    func selectSize(_ size: String) {
        selectedSize = size
    }

    func selectColor(_ color: String) {
        selectedColor = color
    }

    @discardableResult
    func toggleWishlist() async -> Bool {
        guard case .authenticated = userSession.state else {
            needsSignInForWishlist = true
            return false
        }
        do {
            if isWishlisted {
                try await wishlistRepository.removeFromWishlist(productId: product.id)
            } else {
                try await wishlistRepository.addToWishlist(productId: product.id)
            }
            isWishlisted.toggle()
            return true
        } catch {
            return false
        }
    }

    @discardableResult
    func addToCart() async -> Bool {
        guard canAddToCart else { return false }
        isAddingToCart = true
        defer { isAddingToCart = false }
        do {
            _ = try await cartRepository.addItem(product: product, variant: selectedVariant, quantity: 1)
            didAddToCart = true
            cartBadgeStore.increment(by: 1)
            return true
        } catch {
            return false
        }
    }
}
