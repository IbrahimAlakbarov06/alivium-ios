//
//  MockProductRepository.swift
//  alivium
//

import Foundation

/// Phase 1 stand-in — swapped for a real APIClient-backed implementation once the backend
/// Product/Collection endpoints are wired (CLAUDE.md Phase 2). Image names below reuse the
/// three real Onboarding photos already in Assets.xcassets, cycling through them repeatedly;
/// real per-product photography arrives from the backend in Phase 2.
final class MockProductRepository: ProductRepository {
    /// The only real photos available in Phase 1 — cycled across every image slot below.
    private static let stockPhotos = ["Onboarding1", "Onboarding2", "Onboarding3"]

    private static func stockPhoto(_ index: Int) -> String {
        stockPhotos[index % stockPhotos.count]
    }

    private static func variants(color: String) -> [ProductVariant] {
        ["S", "M", "L"].map { size in
            ProductVariant(id: "\(color)-\(size)", size: size, color: color, stockQuantity: 8)
        }
    }

    /// Built once and reused by `fetchFeaturedProducts`/`fetchRecommendedProducts` (each with
    /// their own simulated network delay) and by `searchProducts` (its own, shorter delay) —
    /// so search-as-you-type isn't stacked behind two separate 1-second fetch delays.
    private static let featuredProducts: [Product] = [
        Product(
            id: "p-1", name: "Silk Wrap Midi Dress", price: Money(189.00), discountPrice: nil,
            imageNames: [stockPhoto(0)], categoryId: "dresses",
            variants: variants(color: "Ivory")
        ),
        Product(
            id: "p-2", name: "Tailored Wool Coat", price: Money(349.00), discountPrice: Money(279.00),
            imageNames: [stockPhoto(1)], categoryId: "new-in",
            variants: variants(color: "Camel")
        ),
        Product(
            id: "p-3", name: "Cashmere Blend Sweater", price: Money(159.00), discountPrice: nil,
            imageNames: [stockPhoto(2)], categoryId: "sweaters",
            variants: variants(color: "Oatmeal")
        ),
        Product(
            id: "p-4", name: "Pleated Satin Skirt", price: Money(129.00), discountPrice: nil,
            imageNames: [stockPhoto(3)], categoryId: "skirts",
            variants: variants(color: "Champagne")
        ),
        Product(
            id: "p-5", name: "Structured Leather Tote", price: Money(259.00), discountPrice: nil,
            imageNames: [stockPhoto(4)], categoryId: "bags",
            variants: variants(color: "Cognac")
        ),
        Product(
            id: "p-6", name: "Linen Wide-Leg Trousers", price: Money(139.00), discountPrice: nil,
            imageNames: [stockPhoto(5)], categoryId: "pants",
            variants: variants(color: "Sand")
        )
    ]

    private static let recommendedProducts: [Product] = [
        Product(
            id: "p-7", name: "Belted Trench Coat", price: Money(299.00), discountPrice: nil,
            imageNames: [stockPhoto(0)], categoryId: "new-in",
            variants: variants(color: "Stone")
        ),
        Product(
            id: "p-8", name: "Ribbed Knit Turtleneck", price: Money(89.00), discountPrice: nil,
            imageNames: [stockPhoto(1)], categoryId: "sweaters",
            variants: variants(color: "Charcoal")
        ),
        Product(
            id: "p-9", name: "Suede Ankle Boots", price: Money(219.00), discountPrice: Money(175.00),
            imageNames: [stockPhoto(2)], categoryId: "shoes",
            variants: variants(color: "Taupe")
        ),
        Product(
            id: "p-10", name: "Silk Blouse", price: Money(149.00), discountPrice: nil,
            imageNames: [stockPhoto(3)], categoryId: "t-shirts",
            variants: variants(color: "Blush")
        ),
        Product(
            id: "p-11", name: "Wide Brim Felt Hat", price: Money(79.00), discountPrice: nil,
            imageNames: [stockPhoto(4)], categoryId: "accessories",
            variants: variants(color: "Black")
        ),
        Product(
            id: "p-12", name: "Gold-Tone Hoop Earrings", price: Money(59.00), discountPrice: nil,
            imageNames: [stockPhoto(5)], categoryId: "accessories",
            variants: []
        )
    ]

    func fetchHeroBanners() async throws -> [HeroBanner] {
        try await Task.sleep(for: .seconds(1))
        return [
            HeroBanner(id: "hero-1", imageName: Self.stockPhoto(0), kicker: "NEW SEASON", title: "The Autumn Edit", ctaTitle: "Shop the Edit"),
            HeroBanner(id: "hero-2", imageName: Self.stockPhoto(1), kicker: "LIMITED DROP", title: "Evening, Elevated", ctaTitle: "Discover More"),
            HeroBanner(id: "hero-3", imageName: Self.stockPhoto(2), kicker: "BOUTIQUE FAVORITES", title: "Timeless Essentials", ctaTitle: "Shop Now")
        ]
    }

    func fetchFeaturedProducts() async throws -> [Product] {
        try await Task.sleep(for: .seconds(1))
        return Self.featuredProducts
    }

    func fetchRecommendedProducts() async throws -> [Product] {
        try await Task.sleep(for: .seconds(1))
        return Self.recommendedProducts
    }

    func fetchCollections() async throws -> [ProductCollection] {
        try await Task.sleep(for: .seconds(1))
        return [
            ProductCollection(id: "c-1", name: "The Autumn Edit", imageName: Self.stockPhoto(0), productCount: 24),
            ProductCollection(id: "c-2", name: "Evening Elegance", imageName: Self.stockPhoto(1), productCount: 18),
            ProductCollection(id: "c-3", name: "Workwear Essentials", imageName: Self.stockPhoto(2), productCount: 32),
            ProductCollection(id: "c-4", name: "Accessories Edit", imageName: Self.stockPhoto(3), productCount: 27)
        ]
    }

    func searchProducts(query: String) async throws -> [Product] {
        try await Task.sleep(for: .milliseconds(300))
        let all = Self.featuredProducts + Self.recommendedProducts
        return all.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
}
