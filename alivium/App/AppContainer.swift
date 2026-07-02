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
    let localizationManager: LocalizationManager

    init() {
        self.authRepository = MockAuthRepository()
        self.localizationManager = LocalizationManager()
    }

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(authRepository: authRepository)
    }

    func makeRegisterViewModel() -> RegisterViewModel {
        RegisterViewModel(authRepository: authRepository)
    }
}
