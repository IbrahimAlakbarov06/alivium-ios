//
//  AppContainer.swift
//  alivium
//

import Foundation

/// DI composition root (CLAUDE.md 9.5). Phase 1: wires Mock* repositories; Phase 2 swaps them
/// for Default* (API-backed) implementations without touching any ViewModel or View.
@MainActor
final class AppContainer {
    let authRepository: AuthRepository
    let productRepository: ProductRepository
    let categoryRepository: CategoryRepository
    let chatRepository: ChatRepository
    let wishlistRepository: WishlistRepository
    let cartRepository: CartRepository
    let reviewRepository: ReviewRepository
    let localizationManager: LocalizationManager
    let userSession: UserSession
    let cartBadgeStore: CartBadgeStore

    init() {
        self.authRepository = MockAuthRepository()
        self.productRepository = MockProductRepository()
        self.categoryRepository = MockCategoryRepository()
        self.chatRepository = MockChatRepository()
        self.wishlistRepository = MockWishlistRepository()
        self.cartRepository = MockCartRepository()
        self.reviewRepository = MockReviewRepository()
        self.localizationManager = LocalizationManager()
        self.userSession = UserSession()
        self.cartBadgeStore = CartBadgeStore()
    }

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(authRepository: authRepository, userSession: userSession)
    }

    func makeRegisterViewModel() -> RegisterViewModel {
        RegisterViewModel(authRepository: authRepository, userSession: userSession)
    }

    func makeForgotPasswordViewModel() -> ForgotPasswordViewModel {
        ForgotPasswordViewModel(authRepository: authRepository)
    }

    func makeVerificationCodeViewModel() -> VerificationCodeViewModel {
        VerificationCodeViewModel(authRepository: authRepository)
    }

    func makeCreateNewPasswordViewModel() -> CreateNewPasswordViewModel {
        CreateNewPasswordViewModel(authRepository: authRepository)
    }

    func makeHomeViewModel() -> HomeViewModel {
        let useCase = DefaultFetchHomeFeedUseCase(
            productRepository: productRepository,
            categoryRepository: categoryRepository
        )
        return HomeViewModel(fetchHomeFeedUseCase: useCase, wishlistRepository: wishlistRepository, userSession: userSession)
    }

    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(authRepository: authRepository, userSession: userSession)
    }

    func makeChatViewModel() -> ChatViewModel {
        ChatViewModel(chatRepository: chatRepository)
    }

    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(
            categoryRepository: categoryRepository,
            productRepository: productRepository,
            wishlistRepository: wishlistRepository,
            userSession: userSession
        )
    }

    func makeWishlistViewModel() -> WishlistViewModel {
        WishlistViewModel(
            wishlistRepository: wishlistRepository,
            cartRepository: cartRepository,
            userSession: userSession,
            cartBadgeStore: cartBadgeStore
        )
    }

    func makeCartViewModel() -> CartViewModel {
        CartViewModel(cartRepository: cartRepository, cartBadgeStore: cartBadgeStore)
    }

    func makeProductDetailViewModel(for product: Product) -> ProductDetailViewModel {
        ProductDetailViewModel(
            product: product,
            productRepository: productRepository,
            reviewRepository: reviewRepository,
            cartRepository: cartRepository,
            wishlistRepository: wishlistRepository,
            cartBadgeStore: cartBadgeStore,
            userSession: userSession
        )
    }
}
