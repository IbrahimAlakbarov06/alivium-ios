//
//  Product.swift
//  alivium
//

struct Product: Identifiable, Equatable {
    let id: String
    let name: String
    let price: Money
    /// Nil when the product isn't currently discounted.
    let discountPrice: Money?
    /// Image references — local asset names in Phase 1 mock data, remote URLs once Phase 2
    /// wires the real `imageUrl` field from the backend's `ProductResponse.images`.
    let imageNames: [String]
    let categoryId: String
    let variants: [ProductVariant]

    var isOnSale: Bool { discountPrice != nil }
    var primaryImageName: String? { imageNames.first }
}
