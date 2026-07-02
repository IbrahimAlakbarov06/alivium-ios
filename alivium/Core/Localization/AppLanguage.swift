//
//  AppLanguage.swift
//  alivium
//

import Foundation

/// The app's in-app content language — independent of the device's system locale, since the
/// AZ/EN toggle needs to switch content live without relying on `Localizable.xcstrings`
/// (which only resolves at launch, bound to the system language).
enum AppLanguage: String, CaseIterable {
    case az
    case en
}
