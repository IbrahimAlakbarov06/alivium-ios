//
//  ReviewRepository.swift
//  alivium
//

import Foundation

protocol ReviewRepository {
    func fetchReviews(productId: String) async throws -> [Review]
    /// `reviewerName` is passed in rather than resolved from a session inside the repository —
    /// keeps the repository layer free of session/auth concerns, matching how `CheckoutViewModel`
    /// passes an already-resolved address/payment method rather than having its repository reach
    /// into `UserSession` itself.
    func submitReview(productId: String, reviewerName: String, rating: Int, text: String, photos: [Data]) async throws -> Review
    /// Lets Order Detail show "Rate Product" vs. an already-rated indicator per line item without
    /// conflating it with `fetchReviews`, which always includes Phase 1's generic sample reviews
    /// regardless of whether the current shopper has actually rated anything.
    func hasSubmittedReview(productId: String) async throws -> Bool
}
