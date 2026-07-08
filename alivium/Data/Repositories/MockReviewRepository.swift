//
//  MockReviewRepository.swift
//  alivium
//

import Foundation

/// Phase 1 stand-in — swapped for a real APIClient-backed implementation once the backend
/// Review endpoints are wired (CLAUDE.md Phase 2). `fetchReviews` returns the same small sample
/// regardless of `productId` (Product Detail's rating *summary* comes from `Product` itself and
/// represents the full review volume; this is just a handful of full review cards to show
/// underneath it) plus whatever's actually been submitted for that product in this session, so a
/// just-submitted review really does show up if the shopper goes back to view it.
final class MockReviewRepository: ReviewRepository {
    private var submittedReviews: [String: [Review]] = [:]

    private func sampleReviews(for productId: String) -> [Review] {
        [
            Review(
                id: "review-1", productId: productId, reviewerName: "Aysel M.", rating: 5,
                text: "The fabric feels so much more expensive than the price — fits true to size and photographs beautifully.",
                date: Calendar.current.date(byAdding: .day, value: -6, to: .now) ?? .now
            ),
            Review(
                id: "review-2", productId: productId, reviewerName: "Günel R.", rating: 4,
                text: "Lovely piece, exactly as pictured. Shipping took a couple of days longer than expected.",
                date: Calendar.current.date(byAdding: .day, value: -19, to: .now) ?? .now
            ),
            Review(
                id: "review-3", productId: productId, reviewerName: "Leyla H.", rating: 5,
                text: "Bought this for a wedding and got so many compliments. Already eyeing my next Alivium order.",
                date: Calendar.current.date(byAdding: .day, value: -34, to: .now) ?? .now
            )
        ]
    }

    func fetchReviews(productId: String) async throws -> [Review] {
        try await Task.sleep(for: .milliseconds(500))
        return (submittedReviews[productId] ?? []) + sampleReviews(for: productId)
    }

    func submitReview(productId: String, reviewerName: String, rating: Int, text: String, photos: [Data]) async throws -> Review {
        try await Task.sleep(for: .seconds(1))
        let review = Review(
            id: UUID().uuidString,
            productId: productId,
            reviewerName: reviewerName,
            rating: rating,
            text: text,
            photos: photos,
            date: .now
        )
        submittedReviews[productId, default: []].insert(review, at: 0)
        return review
    }

    func hasSubmittedReview(productId: String) async throws -> Bool {
        try await Task.sleep(for: .milliseconds(200))
        return !(submittedReviews[productId]?.isEmpty ?? true)
    }
}
