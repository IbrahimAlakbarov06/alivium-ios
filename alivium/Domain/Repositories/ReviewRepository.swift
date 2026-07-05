//
//  ReviewRepository.swift
//  alivium
//

protocol ReviewRepository {
    func fetchReviews(productId: String) async throws -> [Review]
}
