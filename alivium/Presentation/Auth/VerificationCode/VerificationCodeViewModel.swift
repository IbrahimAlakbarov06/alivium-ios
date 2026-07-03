//
//  VerificationCodeViewModel.swift
//  alivium
//

import Observation

@Observable
final class VerificationCodeViewModel {
    var code: String = ""
    private(set) var state: AuthViewState = .idle

    var isLoading: Bool { state == .loading }

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    /// Awaitable, matching `ForgotPasswordViewModel.sendResetLink()` — the view chains
    /// navigation to the next screen only once verification actually completes.
    func verify() async {
        guard state != .loading else { return }
        state = .loading
        defer { state = .idle }
        do {
            try await authRepository.verifyCode(code)
        } catch {
            // Error handling comes later, consistent with Login/Register/ForgotPassword.
        }
    }

    func resend() {
        // Mock/no-op for now, matching the rest of Phase 1 auth.
    }
}
