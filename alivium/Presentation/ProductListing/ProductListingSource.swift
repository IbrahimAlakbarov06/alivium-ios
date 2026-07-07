//
//  ProductListingSource.swift
//  alivium
//

/// What Category/Product Listing was pushed to show — carried as a value (not resolved title
/// strings) so the screen can be pushed imperatively via `.navigationDestination(item:)` from
/// Home's "Show all" and Search's category taps alike, and re-localize itself like every other
/// screen's `ViewState` does.
enum ProductListingSource: Hashable {
    /// A Discover category tap — the repository fetches by `category.id`.
    case category(Category)
    /// A Home rail's "Show all" — the products are already in memory from the home feed, so
    /// there's no reason to refetch them.
    case curated(titleKey: LocalizedKey, products: [Product])
    /// A `CollectionCard` tap — the repository fetches by `collection.id`. `ProductListingView`
    /// itself never actually renders this case (Collection Detail owns its own screen/header and
    /// only reuses `ProductListingViewModel`'s fetch/sort/filter logic by composition), but it's
    /// still a case here rather than a second parallel enum, since one enum-driven source for
    /// "how does this screen's product set get fetched" is simpler than two.
    case collection(ProductCollection)
}
