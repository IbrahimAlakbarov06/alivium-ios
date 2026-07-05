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

    /// Two colors x three sizes per product — gives Product Detail's variant selector a real
    /// second axis to choose from, rather than a color "choice" of exactly one option.
    private static func variants(colors: [String]) -> [ProductVariant] {
        colors.flatMap { color in
            ["S", "M", "L"].map { size in
                ProductVariant(id: "\(color)-\(size)", size: size, color: color, stockQuantity: 8)
            }
        }
    }

    /// Built once and reused by `fetchFeaturedProducts`/`fetchRecommendedProducts` (each with
    /// their own simulated network delay) and by `searchProducts` (its own, shorter delay) —
    /// so search-as-you-type isn't stacked behind two separate 1-second fetch delays. Not
    /// `private` so Mock{Wishlist,Cart}Repository can seed from the same real product data
    /// rather than inventing unrelated sample items.
    static let featuredProducts: [Product] = [
        Product(
            id: "p-1", name: "Silk Wrap Midi Dress", price: Money(189.00), discountPrice: nil,
            // Three images (reusing the Onboarding stock photos) so this product's gallery can
            // actually be tested with real multi-image paging/dot-pagination.
            imageNames: ["Onboarding1", "Onboarding2", "Onboarding3"], categoryId: "dresses",
            variants: variants(colors: ["Ivory", "Blush"]),
            description: "Cut from fluid silk with a self-tie waist, this wrap dress moves beautifully from day into evening. Fully lined.",
            averageRating: 4.7, reviewCount: 132
        ),
        Product(
            id: "p-2", name: "Tailored Wool Coat", price: Money(349.00), discountPrice: Money(279.00),
            imageNames: [stockPhoto(1)], categoryId: "new-in",
            variants: variants(colors: ["Camel", "Charcoal"]),
            description: "A structured, wool-blend coat with a clean lapel and horn-style buttons — built to be the one coat you reach for all season.",
            averageRating: 4.8, reviewCount: 96
        ),
        Product(
            id: "p-3", name: "Cashmere Blend Sweater", price: Money(159.00), discountPrice: nil,
            imageNames: [stockPhoto(2)], categoryId: "sweaters",
            variants: variants(colors: ["Oatmeal", "Black"]),
            description: "Soft cashmere-blend knit with a relaxed fit and ribbed trim — an everyday layer that still feels a little special.",
            averageRating: 4.6, reviewCount: 84
        ),
        Product(
            id: "p-4", name: "Pleated Satin Skirt", price: Money(129.00), discountPrice: nil,
            imageNames: [stockPhoto(3)], categoryId: "skirts",
            variants: variants(colors: ["Champagne", "Ivory"]),
            description: "Fine knife pleats in a fluid satin finish, finished with a hidden side zip for a clean silhouette.",
            averageRating: 4.5, reviewCount: 58
        ),
        Product(
            id: "p-5", name: "Structured Leather Tote", price: Money(259.00), discountPrice: nil,
            imageNames: [stockPhoto(4)], categoryId: "bags",
            variants: variants(colors: ["Cognac", "Black"]),
            description: "Full-grain leather tote with a structured base, interior zip pocket, and room for a 13\" laptop.",
            averageRating: 4.9, reviewCount: 211
        ),
        Product(
            id: "p-6", name: "Linen Wide-Leg Trousers", price: Money(139.00), discountPrice: nil,
            imageNames: [stockPhoto(5)], categoryId: "pants",
            variants: variants(colors: ["Sand", "White"]),
            description: "Breathable linen-blend trousers with a high rise and wide leg — dresses up or down with equal ease.",
            averageRating: 4.4, reviewCount: 47
        )
    ]

    static let recommendedProducts: [Product] = [
        Product(
            id: "p-7", name: "Belted Trench Coat", price: Money(299.00), discountPrice: nil,
            imageNames: [stockPhoto(0)], categoryId: "new-in",
            variants: variants(colors: ["Stone", "Camel"]),
            description: "A classic double-breasted trench in water-resistant cotton twill, with a fully adjustable belt.",
            averageRating: 4.7, reviewCount: 103
        ),
        Product(
            id: "p-8", name: "Ribbed Knit Turtleneck", price: Money(89.00), discountPrice: nil,
            imageNames: [stockPhoto(1)], categoryId: "sweaters",
            variants: variants(colors: ["Charcoal", "Ivory"]),
            description: "A close-fitting ribbed turtleneck in a soft mid-weight knit — the layer every capsule wardrobe needs.",
            averageRating: 4.5, reviewCount: 66
        ),
        Product(
            id: "p-9", name: "Suede Ankle Boots", price: Money(219.00), discountPrice: Money(175.00),
            imageNames: [stockPhoto(2)], categoryId: "shoes",
            variants: variants(colors: ["Taupe", "Black"]),
            description: "Soft suede ankle boots on a stacked block heel, with a cushioned footbed built for all-day wear.",
            averageRating: 4.6, reviewCount: 178
        ),
        Product(
            id: "p-10", name: "Silk Blouse", price: Money(149.00), discountPrice: nil,
            imageNames: [stockPhoto(3)], categoryId: "t-shirts",
            variants: variants(colors: ["Blush", "White"]),
            description: "A relaxed silk blouse with mother-of-pearl buttons and a soft drape — equally at home at a desk or dinner.",
            averageRating: 4.6, reviewCount: 72
        ),
        Product(
            id: "p-11", name: "Wide Brim Felt Hat", price: Money(79.00), discountPrice: nil,
            imageNames: [stockPhoto(4)], categoryId: "accessories",
            variants: variants(colors: ["Black", "Camel"]),
            description: "A wide-brim wool felt hat with a grosgrain band — the finishing touch for cooler-weather styling.",
            averageRating: 4.3, reviewCount: 29
        ),
        Product(
            id: "p-12", name: "Gold-Tone Hoop Earrings", price: Money(59.00), discountPrice: nil,
            imageNames: [stockPhoto(5)], categoryId: "accessories",
            variants: [],
            description: "Lightweight gold-tone hoops with a polished finish — a everyday staple that layers well with other pieces.",
            averageRating: 4.7, reviewCount: 154
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
