//
//  ProductRepository.swift
//  alivium
//

/// Owns product-adjacent merchandising content broadly (products, collections, hero banners)
/// rather than splitting each into its own single-method repository — a pragmatic Phase 1
/// grouping; nothing here depends on how any one of these is fetched.
protocol ProductRepository {
    func fetchHeroBanners() async throws -> [HeroBanner]
    func fetchFeaturedProducts() async throws -> [Product]
    func fetchRecommendedProducts() async throws -> [Product]
    func fetchCollections() async throws -> [ProductCollection]
}
