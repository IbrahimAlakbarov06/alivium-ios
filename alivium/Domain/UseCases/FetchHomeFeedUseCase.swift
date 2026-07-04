//
//  FetchHomeFeedUseCase.swift
//  alivium
//

/// Assembling Home's feed is real orchestration — five independent fetches combined into one
/// result the view renders as a single loading/loaded/error state — so this earns a UseCase
/// rather than having `HomeViewModel` call both repositories directly (CLAUDE.md 9.1: UseCases
/// exist where there's real logic, not as ceremony around trivial pass-throughs).
protocol FetchHomeFeedUseCase {
    func execute() async throws -> HomeFeed
}

final class DefaultFetchHomeFeedUseCase: FetchHomeFeedUseCase {
    private let productRepository: ProductRepository
    private let categoryRepository: CategoryRepository

    init(productRepository: ProductRepository, categoryRepository: CategoryRepository) {
        self.productRepository = productRepository
        self.categoryRepository = categoryRepository
    }

    func execute() async throws -> HomeFeed {
        async let categories = categoryRepository.fetchTopLevelCategories()
        async let heroBanners = productRepository.fetchHeroBanners()
        async let featuredProducts = productRepository.fetchFeaturedProducts()
        async let recommendedProducts = productRepository.fetchRecommendedProducts()
        async let topCollections = productRepository.fetchCollections()

        return try await HomeFeed(
            categories: categories,
            heroBanners: heroBanners,
            featuredProducts: featuredProducts,
            recommendedProducts: recommendedProducts,
            topCollections: topCollections
        )
    }
}
