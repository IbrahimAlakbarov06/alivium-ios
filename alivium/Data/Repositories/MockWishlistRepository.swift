//
//  MockWishlistRepository.swift
//  alivium
//

/// Phase 1 stand-in — swapped for a real APIClient-backed implementation once the backend
/// Wishlist endpoints are wired (CLAUDE.md Phase 2). Seeded from `MockProductRepository`'s real
/// product data rather than inventing unrelated sample items, and keeps add/remove in memory so
/// the heart-toggle interaction persists for the rest of the session.
final class MockWishlistRepository: WishlistRepository {
    private var wishlistedProductIds: Set<String> = ["p-1", "p-5", "p-9", "p-11"]

    func fetchWishlistItems() async throws -> [Product] {
        try await Task.sleep(for: .seconds(0.6))
        let all = MockProductRepository.featuredProducts + MockProductRepository.recommendedProducts
        return all.filter { wishlistedProductIds.contains($0.id) }
    }

    func addToWishlist(productId: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
        wishlistedProductIds.insert(productId)
    }

    func removeFromWishlist(productId: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
        wishlistedProductIds.remove(productId)
    }
}
