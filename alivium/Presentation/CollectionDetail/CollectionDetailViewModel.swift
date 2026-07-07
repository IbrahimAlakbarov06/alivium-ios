//
//  CollectionDetailViewModel.swift
//  alivium
//

import Observation

/// Reached from a `CollectionCard` tap (Home's "Top Collections"). Composes a
/// `ProductListingViewModel` (source `.collection`) rather than re-implementing fetch/sort/filter/
/// wishlist logic a second time — see `ProductListingSource`'s doc comment for why that enum
/// carries a `.collection` case even though `ProductListingView` itself never renders it.
@Observable
final class CollectionDetailViewModel {
    let collection: ProductCollection
    let productListing: ProductListingViewModel

    init(
        collection: ProductCollection,
        productRepository: ProductRepository,
        wishlistRepository: WishlistRepository,
        userSession: UserSession
    ) {
        self.collection = collection
        self.productListing = ProductListingViewModel(
            source: .collection(collection),
            productRepository: productRepository,
            wishlistRepository: wishlistRepository,
            userSession: userSession
        )
    }

    func onAppear() {
        productListing.onAppear()
    }
}
