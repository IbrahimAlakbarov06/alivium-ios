//
//  AppTab.swift
//  alivium
//

/// Identifies the 5 tabs so other screens can request a switch (e.g. Wishlist/Cart's empty
/// state "Start Browsing" button jumping to Home) rather than faking navigation.
enum AppTab: Hashable {
    case home
    case search
    case wishlist
    case cart
    case profile
}
