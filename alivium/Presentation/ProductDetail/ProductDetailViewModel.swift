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

    private let productRepository: ProductRepository
    private let reviewRepository: ReviewRepository
    private let cartRepository: CartRepository
    private let wishlistRepository: WishlistRepository

    /// In display order (S/M/L), not just whatever order the mock data happens to list.
    var availableSizes: [String] {
        let order = ["S", "M", "L"]
        let present = Set(product.variants.map(\.size))
        return order.filter { present.contains($0) }
    }

    var availableColors: [String] {
        var seen: [String] = []
        for variant in product.variants where !seen.contains(variant.color) {
            seen.append(variant.color)
        }
        return seen
    }

    var selectedVariant: ProductVariant? {
        guard let selectedSize, let selectedColor else { return nil }
        return product.variants.first { $0.size == selectedSize && $0.color == selectedColor }
    }

    /// Products with no variants at all (e.g. earrings) skip the selection requirement entirely.
    var canAddToCart: Bool {
        (product.variants.isEmpty || selectedVariant != nil) && !isAddingToCart
    }

    init(
        product: Product,
        productRepository: ProductRepository,
        reviewRepository: ReviewRepository,
        cartRepository: CartRepository,
        wishlistRepository: WishlistRepository
    ) {
        self.product = product
        self.productRepository = productRepository
        self.reviewRepository = reviewRepository
        self.cartRepository = cartRepository
        self.wishlistRepository = wishlistRepository

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
            return true
        } catch {
            return false
        }
    }
}
