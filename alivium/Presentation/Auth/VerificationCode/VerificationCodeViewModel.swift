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
    ///
    /// Returns whether this call actually verified the code (vs. short-circuiting on the
    /// `isLoading` guard) — a rapid double-tap can fire two `Task { await verify() }` calls
    /// before the first one's `state = .loading` has taken effect, so the caller must only
    /// navigate on the call that actually ran, not on every call that merely returned.
    @discardableResult
    func verify() async -> Bool {
        guard state != .loading else { return false }
        state = .loading
        defer { state = .idle }
        do {
            try await authRepository.verifyCode(code)
            return true
        } catch {
            // Error handling comes later, consistent with Login/Register/ForgotPassword.
            return false
        }
    }

    func resend() {
        // Mock/no-op for now, matching the rest of Phase 1 auth.
    }
}
