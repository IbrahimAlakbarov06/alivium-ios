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

    var query: String = "" {
        didSet { scheduleSearch(for: query) }
    }
    private(set) var searchResults: [Product] = []
    private(set) var isSearchLoading = false

    /// Non-empty, non-whitespace query — the View switches from category browsing to search
    /// results the moment this flips, without waiting on the debounce below.
    var isSearchActive: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var searchTask: Task<Void, Never>?
    private let categoryRepository: CategoryRepository
    private let productRepository: ProductRepository

    init(categoryRepository: CategoryRepository, productRepository: ProductRepository) {
        self.categoryRepository = categoryRepository
        self.productRepository = productRepository
    }

    func onAppear() {
        guard state == .idle else { return }
        Task { await loadCategories() }
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
