//
//  WishlistRepository.swift
//  alivium
//

protocol WishlistRepository {
    func fetchWishlistItems() async throws -> [Product]
    func addToWishlist(productId: String) async throws
    func removeFromWishlist(productId: String) async throws
}
