//
//  ProductVariant.swift
//  alivium
//

struct ProductVariant: Identifiable, Equatable, Hashable {
    let id: String
    let size: String
    let color: String
    let stockQuantity: Int

    var isInStock: Bool { stockQuantity > 0 }
}
