//
//  Product.swift
//  alivium
//

struct Product: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let price: Money
    /// Nil when the product isn't currently discounted.
    let discountPrice: Money?
    /// Image references — local asset names in Phase 1 mock data, remote URLs once Phase 2
    /// wires the real `imageUrl` field from the backend's `ProductResponse.images`.
    let imageNames: [String]
    let categoryId: String
    /// `nil` for products that aren't part of any curated collection.
    let collectionId: String?
    let variants: [ProductVariant]
    let description: String
    /// Aggregate rating shown in Product Detail's summary line (e.g. "4.6 (128 reviews)") —
    /// distinct from the handful of individual `Review`s actually fetched/displayed, matching
    /// how most storefronts show a total count alongside only a sample of full reviews.
    let averageRating: Double
    let reviewCount: Int

    /// A hand-written (not synthesized) memberwise init — a stored property given a default value
    /// directly (`= nil`) is excluded from Swift's synthesized memberwise init entirely rather
    /// than made optional-to-pass, so this exists purely to give `collectionId` a default without
    /// updating every existing call site that has nothing to do with collections.
    init(
        id: String, name: String, price: Money, discountPrice: Money?, imageNames: [String],
        categoryId: String, collectionId: String? = nil, variants: [ProductVariant],
        description: String, averageRating: Double, reviewCount: Int
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.discountPrice = discountPrice
        self.imageNames = imageNames
        self.categoryId = categoryId
        self.collectionId = collectionId
        self.variants = variants
        self.description = description
        self.averageRating = averageRating
        self.reviewCount = reviewCount
    }

    var isOnSale: Bool { discountPrice != nil }
    var primaryImageName: String? { imageNames.first }
    /// The price that actually applies (discounted if on sale) — used anywhere math is done
    /// on price, like Cart's subtotal, so that logic isn't repeated as `discountPrice ?? price`.
    var effectivePrice: Money { discountPrice ?? price }
}
