//
//  SearchViewModel.swift
//  alivium
//

import Foundation
import Observation

@Observable
final class SearchViewModel {
    private(set) var state: SearchViewState = .idle
    private(set) var categories: [Category] = []
    /// Which top-level category's subcategory list is currently expanded — accordion-style,
    /// so opening one closes any other. `nil` when none is expanded, or for leaf categories
    /// that navigate directly instead of expanding.
    private(set) var expandedCategoryId: String?

    var query: String = "" {
        didSet { scheduleSearch(for: query) }
    }
    /// Raw, unfiltered/unsorted results straight from the repository — `displayedResults` is
    /// always derived from this so adjusting a filter never needs a re-search.
    private(set) var searchResults: [Product] = []
    private(set) var isSearchLoading = false
    private(set) var wishlistedProductIds: Set<String> = []
    /// Set when a Guest taps a result card's heart — the View shows a sign-in prompt instead of
    /// toggling the wishlist.
    var needsSignInForWishlist = false

    // MARK: - Filters

    static let priceBounds: ClosedRange<Double> = 0...400

    var isFilterSheetPresented = false
    var sortOption: ProductSortOption = .featured
    /// `nil` means "every category" — set from the distinct `categoryId`s actually present in
    /// `searchResults` (see `availableFilterCategoryIds`), not the full nav category tree, so the
    /// picker never offers a category with zero matching results.
    var filterCategoryId: String?
    var minPrice: Double = SearchViewModel.priceBounds.lowerBound {
        didSet { if minPrice > maxPrice { maxPrice = minPrice } }
    }
    var maxPrice: Double = SearchViewModel.priceBounds.upperBound {
        didSet { if maxPrice < minPrice { minPrice = maxPrice } }
    }

    var hasActiveFilters: Bool {
        filterCategoryId != nil
            || sortOption != .featured
            || minPrice > Self.priceBounds.lowerBound
            || maxPrice < Self.priceBounds.upperBound
    }

    /// Distinct categories actually present in the current raw results, not the full Discover
    /// category tree — filtering to a category with nothing in it would just show empty results.
    var availableFilterCategoryIds: [String] {
        Array(Set(searchResults.map(\.categoryId))).sorted()
    }

    /// What the results grid actually renders — `searchResults` filtered by category/price and
    /// sorted, recomputed live as the filter sheet's controls change.
    var displayedResults: [Product] {
        var items = searchResults
        if let filterCategoryId {
            items = items.filter { $0.categoryId == filterCategoryId }
        }
        items = items.filter { $0.effectivePrice.majorUnits >= minPrice && $0.effectivePrice.majorUnits <= maxPrice }
        switch sortOption {
        case .featured:
            break
        case .priceLowToHigh:
            items.sort { $0.effectivePrice < $1.effectivePrice }
        case .priceHighToLow:
            items.sort { $0.effectivePrice > $1.effectivePrice }
        case .topRated:
            items.sort { $0.averageRating > $1.averageRating }
        }
        return items
    }

    func resetFilters() {
        filterCategoryId = nil
        sortOption = .featured
        minPrice = Self.priceBounds.lowerBound
        maxPrice = Self.priceBounds.upperBound
    }

    /// Non-empty, non-whitespace query — the View switches from category browsing to search
    /// results the moment this flips, without waiting on the debounce below.
    var isSearchActive: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var searchTask: Task<Void, Never>?
    private let categoryRepository: CategoryRepository
    private let productRepository: ProductRepository
    private let wishlistRepository: WishlistRepository
    private let userSession: UserSession

    init(
        categoryRepository: CategoryRepository,
        productRepository: ProductRepository,
        wishlistRepository: WishlistRepository,
        userSession: UserSession
    ) {
        self.categoryRepository = categoryRepository
        self.productRepository = productRepository
        self.wishlistRepository = wishlistRepository
        self.userSession = userSession
    }

    func onAppear() {
        guard state == .idle else { return }
        Task {
            await loadWishlistedIds()
            await loadCategories()
        }
    }

    private func loadWishlistedIds() async {
        guard case .authenticated = userSession.state else { return }
        if let items = try? await wishlistRepository.fetchWishlistItems() {
            wishlistedProductIds = Set(items.map(\.id))
        }
    }

    func isWishlisted(_ product: Product) -> Bool {
        wishlistedProductIds.contains(product.id)
    }

    func toggleWishlist(for product: Product) {
        guard case .authenticated = userSession.state else {
            needsSignInForWishlist = true
            return
        }
        Task {
            do {
                if wishlistedProductIds.contains(product.id) {
                    try await wishlistRepository.removeFromWishlist(productId: product.id)
                    wishlistedProductIds.remove(product.id)
                } else {
                    try await wishlistRepository.addToWishlist(productId: product.id)
                    wishlistedProductIds.insert(product.id)
                }
            } catch {
                // Phase 1 mock never actually throws here.
            }
        }
    }

    func loadCategories() async {
        state = .loading
        do {
            categories = try await categoryRepository.fetchTopLevelCategories()
            state = .loaded
        } catch {
            state = .error(.somethingWentWrong)
        }
    }

    /// Leaf categories (no subcategories) have nothing to expand — the View routes those taps
    /// to navigation instead of calling this.
    func toggleCategoryExpansion(_ category: Category) {
        guard !category.subcategories.isEmpty else { return }
        expandedCategoryId = (expandedCategoryId == category.id) ? nil : category.id
    }

    /// Simple `Task` + `Task.sleep` debounce — cancels any in-flight wait/search when the query
    /// changes again before it fires, so search-as-you-type doesn't hammer the repository (or
    /// flash stale results) on every keystroke. First reusable debounce pattern in the app;
    /// promote to a shared utility if a second screen needs one.
    private func scheduleSearch(for query: String) {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchTask = nil
            searchResults = []
            isSearchLoading = false
            return
        }
        isSearchLoading = true
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            do {
                let results = try await productRepository.searchProducts(query: trimmed)
                guard !Task.isCancelled else { return }
                searchResults = results
            } catch {
                // Error handling comes later, matching other ViewModels' Phase 1 posture.
            }
            isSearchLoading = false
        }
    }
}
