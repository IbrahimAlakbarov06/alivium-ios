//
//  HeroBanner.swift
//  alivium
//

/// A single slide in Home's hero carousel. Kept distinct from `Collection` — a hero slide
/// carries marketing copy (kicker/title/CTA) that a plain collection card doesn't need, and not
/// every hero slide necessarily points at a shoppable collection.
struct HeroBanner: Identifiable, Equatable {
    let id: String
    let imageName: String
    let kicker: String
    let title: String
    let ctaTitle: String
}
