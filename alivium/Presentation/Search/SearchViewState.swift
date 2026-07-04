//
//  SearchViewState.swift
//  alivium
//

/// Covers only the category-browsing load — search query/results are separate reactive
/// properties on `SearchViewModel` (see its doc comment for why they're split).
enum SearchViewState: Equatable {
    case idle
    case loading
    case loaded
    case error(LocalizedKey)
}
