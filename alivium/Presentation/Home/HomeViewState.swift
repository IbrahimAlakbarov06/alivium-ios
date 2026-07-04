//
//  HomeViewState.swift
//  alivium
//

enum HomeViewState: Equatable {
    case idle
    case loading
    case loaded(HomeFeed)
    /// Carries the key, not a resolved string — the ViewModel has no access to the current
    /// language (only Views read `LocalizationManager`), and this stays reactive if the user
    /// switches language while an error is showing.
    case error(LocalizedKey)
}
