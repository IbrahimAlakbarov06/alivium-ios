//
//  Review.swift
//  alivium
//

import Foundation

struct Review: Identifiable, Equatable {
    let id: String
    let reviewerName: String
    let rating: Int
    let text: String
    let date: Date
}
