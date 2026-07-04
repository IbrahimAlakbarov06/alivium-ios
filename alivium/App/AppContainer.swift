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
    let localizationManager: LocalizationManager
    let userSession: UserSession

    init() {
        self.authRepository = MockAuthRepository()
        self.productRepository = MockProductRepository()
        self.categoryRepository = MockCategoryRepository()
        self.chatRepository = MockChatRepository()
        self.localizationManager = LocalizationManager()
        self.userSession = UserSession()
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
        return HomeViewModel(fetchHomeFeedUseCase: useCase)
    }

    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(authRepository: authRepository, userSession: userSession)
    }

    func makeChatViewModel() -> ChatViewModel {
        ChatViewModel(chatRepository: chatRepository)
    }
}
