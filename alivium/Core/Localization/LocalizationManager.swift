//
//  LocalizationManager.swift
//  alivium
//

import Foundation
import Observation

/// Single source of truth for the app's current in-app language. Owned by `AppContainer` and
/// injected into the SwiftUI environment at the root, so any view can read `currentLanguage`
/// (and re-render on change, via `@Observable`) or resolve a `LocalizedKey` without threading
/// it through every initializer.
@Observable
final class LocalizationManager {
    private(set) var currentLanguage: AppLanguage

    private let defaults: UserDefaults
    private let storageKey = "appLanguage"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let raw = defaults.string(forKey: storageKey), let saved = AppLanguage(rawValue: raw) {
            currentLanguage = saved
        } else {
            currentLanguage = .az
        }
    }

    func setLanguage(_ language: AppLanguage) {
        guard language != currentLanguage else { return }
        currentLanguage = language
        defaults.set(language.rawValue, forKey: storageKey)
    }

    func string(_ key: LocalizedKey) -> String {
        key.value(for: currentLanguage)
    }

    /// Resolves a mock `Category`'s display name through the catalog when a matching key
    /// exists, falling back to the raw `name` field otherwise — so category chips/banners
    /// actually switch language instead of staying stuck in whatever the mock data hardcoded.
    func string(forCategory category: Category) -> String {
        guard let key = LocalizedKey.categoryName(forId: category.id) else { return category.name }
        return string(key)
    }

    /// Same fallback shape as `string(forCategory:)` — resolves through the catalog, defaulting
    /// to the raw case name if a future `ProductSortOption` case is added without copy yet.
    func string(forSort option: ProductSortOption) -> String {
        guard let key = LocalizedKey.sortOptionName(forId: option.rawValue) else { return option.rawValue }
        return string(key)
    }
}
