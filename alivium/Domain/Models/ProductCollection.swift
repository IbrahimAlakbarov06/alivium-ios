//
//  ProductCollection.swift
//  alivium
//

/// A curated grouping of products (e.g. a seasonal drop) — what Home's "Top Collections"
/// section and Discover's large tappable category banners both point into. Named
/// `ProductCollection` rather than `Collection` to avoid shadowing Swift's own stdlib
/// `Collection` protocol.
struct ProductCollection: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let imageName: String
    let productCount: Int
    /// Short editorial tagline shown on Collection Detail's header (e.g. "Considered pieces for
    /// the new season") — `CollectionCard` itself doesn't use this, only the detail screen does.
    let description: String
}
