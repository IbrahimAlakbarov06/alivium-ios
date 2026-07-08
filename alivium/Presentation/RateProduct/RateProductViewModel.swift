//
//  RateProductViewModel.swift
//  alivium
//

import Foundation
import Observation

@Observable
final class RateProductViewModel {
    let product: Product
    var rating: Int = 0
    var reviewText: String = ""
    private(set) var photos: [Data] = []
    private(set) var isSubmitting = false

    private let reviewRepository: ReviewRepository
    private let userSession: UserSession

    /// Text and photos are optional — only a star rating is actually required to submit.
    var canSubmit: Bool { rating > 0 }

    private static let maxPhotoCount = 5

    var canAddMorePhotos: Bool { photos.count < Self.maxPhotoCount }

    init(product: Product, reviewRepository: ReviewRepository, userSession: UserSession) {
        self.product = product
        self.reviewRepository = reviewRepository
        self.userSession = userSession
    }

    func addPhoto(_ data: Data) {
        guard canAddMorePhotos else { return }
        photos.append(data)
    }

    func removePhoto(at index: Int) {
        guard photos.indices.contains(index) else { return }
        photos.remove(at: index)
    }

    /// Awaitable, matching the rest of the app's submit actions — the view only navigates back
    /// once the submission actually completes, and only on the call that actually ran (guards a
    /// rapid double-tap on Submit).
    @discardableResult
    func submitReview() async -> Bool {
        guard !isSubmitting, canSubmit else { return false }
        isSubmitting = true
        defer { isSubmitting = false }
        let reviewerName: String
        if case .authenticated(let user) = userSession.state {
            reviewerName = user.fullName
        } else {
            reviewerName = "Guest"
        }
        do {
            try await reviewRepository.submitReview(
                productId: product.id,
                reviewerName: reviewerName,
                rating: rating,
                text: reviewText.trimmingCharacters(in: .whitespacesAndNewlines),
                photos: photos
            )
            return true
        } catch {
            return false
        }
    }
}
