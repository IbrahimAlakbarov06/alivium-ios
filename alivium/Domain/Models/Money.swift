//
//  Money.swift
//  alivium
//

import Foundation

/// Stores currency amounts as integer minor units (e.g. cents) rather than `Double`, so
/// summing/comparing prices can never accumulate floating-point rounding error.
struct Money: Equatable, Comparable, Hashable {
    let minorUnits: Int
    let currencyCode: String

    init(minorUnits: Int, currencyCode: String = "USD") {
        self.minorUnits = minorUnits
        self.currencyCode = currencyCode
    }

    /// Convenience for sample/mock data and literals, e.g. `Money(129.99)`.
    init(_ majorUnits: Double, currencyCode: String = "USD") {
        self.init(minorUnits: Int((majorUnits * 100).rounded()), currencyCode: currencyCode)
    }

    var majorUnits: Double {
        Double(minorUnits) / 100
    }

    var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: majorUnits)) ?? "\(majorUnits)"
    }

    static func < (lhs: Money, rhs: Money) -> Bool {
        lhs.minorUnits < rhs.minorUnits
    }
}
