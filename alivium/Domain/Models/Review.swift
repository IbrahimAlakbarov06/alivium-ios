//
//  Review.swift
//  alivium
//

import Foundation

struct Review: Identifiable, Equatable {
    let id: String
    let productId: String
    let reviewerName: String
    let rating: Int
    let text: String
    /// Raw image data for any attached photos — `Data` rather than `UIImage` so the Domain layer
    /// stays framework-agnostic (CLAUDE.md 9.1: "Domain: pure Swift, zero framework imports").
    /// Empty for the vast majority of reviews, so it's defaulted rather than required at every
    /// call site that has nothing to do with photos.
    let photos: [Data]
    let date: Date

    init(id: String, productId: String, reviewerName: String, rating: Int, text: String, photos: [Data] = [], date: Date) {
        self.id = id
        self.productId = productId
        self.reviewerName = reviewerName
        self.rating = rating
        self.text = text
        self.photos = photos
        self.date = date
    }
}
