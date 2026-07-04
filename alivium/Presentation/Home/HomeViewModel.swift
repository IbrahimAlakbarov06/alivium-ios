//
//  HomeViewModel.swift
//  alivium
//

import Observation

@Observable
final class HomeViewModel {
    private(set) var state: HomeViewState = .idle
    var selectedCategoryId: String?

    private let fetchHomeFeedUseCase: FetchHomeFeedUseCase

    init(fetchHomeFeedUseCase: FetchHomeFeedUseCase) {
        self.fetchHomeFeedUseCase = fetchHomeFeedUseCase
    }

    func onAppear() {
        guard state == .idle else { return }
        Task { await loadFeed() }
    }

    func loadFeed() async {
        state = .loading
        do {
            let feed = try await fetchHomeFeedUseCase.execute()
            state = .loaded(feed)
        } catch {
            state = .error(.somethingWentWrong)
        }
    }

    func selectCategory(_ id: String) {
        selectedCategoryId = (selectedCategoryId == id) ? nil : id
    }

    func toggleWishlist(for product: Product) {
        // Phase 1 stub — Wishlist screen/repository comes later.
        print("Toggled wishlist for \(product.name) — TODO: wire WishlistRepository")
    }
}
