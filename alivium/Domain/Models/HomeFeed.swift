//
//  HomeFeed.swift
//  alivium
//

/// The assembled result of `FetchHomeFeedUseCase` — every section Home needs, fetched together
/// so the view only has one loading/error state to manage instead of five independent ones.
struct HomeFeed: Equatable {
    let categories: [Category]
    let heroBanners: [HeroBanner]
    let featuredProducts: [Product]
    let recommendedProducts: [Product]
    let topCollections: [ProductCollection]
}
