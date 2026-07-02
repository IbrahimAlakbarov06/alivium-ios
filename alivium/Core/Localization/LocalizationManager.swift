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
}
