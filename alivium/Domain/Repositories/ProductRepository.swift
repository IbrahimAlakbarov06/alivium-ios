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
    /// Simple substring match on product name in Phase 1 (Discover's search-as-you-type);
    /// becomes a real search endpoint call in Phase 2.
    func searchProducts(query: String) async throws -> [Product]
    /// Backs the Category/Product Listing screen reached from a Discover category tap.
    func fetchProducts(byCategory categoryId: String) async throws -> [Product]
    /// Backs Collection Detail, reached from a `CollectionCard` tap.
    func fetchProducts(collectionId: String) async throws -> [Product]
}
