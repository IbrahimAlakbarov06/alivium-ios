//
//  ShippingMethod.swift
//  alivium
//

/// Mirrors the backend's `ShippingMethod` enum (CLAUDE.md 6) — already defined there, so this
/// shape is ready to wire to the real value once Checkout/Order networking lands in Phase 2.
enum ShippingMethod: String, CaseIterable, Identifiable, Equatable, Hashable {
    case free
    case standard
    case fast

    var id: String { rawValue }

    var days: Int {
        switch self {
        case .free: return 7
        case .standard: return 5
        case .fast: return 3
        }
    }

    var price: Money {
        switch self {
        case .free: return Money(0)
        case .standard: return Money(4.90)
        case .fast: return Money(9.90)
        }
    }
}
