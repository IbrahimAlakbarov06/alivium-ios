//
//  CartRepository.swift
//  alivium
//

protocol CartRepository {
    func fetchCartItems() async throws -> [CartItem]
    /// Adding a product/variant combination already in the cart increments its quantity rather
    /// than creating a duplicate line item — matches real cart semantics.
    func addItem(product: Product, variant: ProductVariant?, quantity: Int) async throws -> CartItem
    func updateQuantity(itemId: String, quantity: Int) async throws
    func removeItem(itemId: String) async throws
    /// Empties the cart entirely — called once Checkout successfully places an order.
    func clearCart() async throws
}
