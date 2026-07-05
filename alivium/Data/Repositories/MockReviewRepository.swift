//
//  MockReviewRepository.swift
//  alivium
//

import Foundation

/// Phase 1 stand-in — swapped for a real APIClient-backed implementation once the backend
/// Review endpoints are wired (CLAUDE.md Phase 2). Returns the same small sample regardless of
/// `productId` — Product Detail's rating *summary* (average/count) comes from `Product` itself
/// and represents the full review volume; this is just a handful of full review cards to show
/// underneath it, which is all Phase 1 needs.
final class MockReviewRepository: ReviewRepository {
    func fetchReviews(productId: String) async throws -> [Review] {
        try await Task.sleep(for: .milliseconds(500))
        return [
            Review(
                id: "review-1", reviewerName: "Aysel M.", rating: 5,
                text: "The fabric feels so much more expensive than the price — fits true to size and photographs beautifully.",
                date: Calendar.current.date(byAdding: .day, value: -6, to: .now) ?? .now
            ),
            Review(
                id: "review-2", reviewerName: "Günel R.", rating: 4,
                text: "Lovely piece, exactly as pictured. Shipping took a couple of days longer than expected.",
                date: Calendar.current.date(byAdding: .day, value: -19, to: .now) ?? .now
            ),
            Review(
                id: "review-3", reviewerName: "Leyla H.", rating: 5,
                text: "Bought this for a wedding and got so many compliments. Already eyeing my next Alivium order.",
                date: Calendar.current.date(byAdding: .day, value: -34, to: .now) ?? .now
            )
        ]
    }
}
