//
//  ForgotPasswordViewModel.swift
//  alivium
//

import Observation

@Observable
final class ForgotPasswordViewModel {
    var email: String = ""
    private(set) var state: AuthViewState = .idle

    var isLoading: Bool { state == .loading }

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    /// Awaitable — unlike Login/Register's fire-and-forget internal `Task { ... }` — so the
    /// view can navigate to the next screen only once the send actually completes.
    ///
    /// Returns whether this call actually sent the reset link (vs. short-circuiting on the
    /// `isLoading` guard) — a rapid double-tap can fire two `Task { await sendResetLink() }`
    /// calls before the first one's `state = .loading` has taken effect, so the caller must
    /// only navigate on the call that actually ran, not on every call that merely returned.
    @discardableResult
    func sendResetLink() async -> Bool {
        guard state != .loading else { return false }
        state = .loading
        defer { state = .idle }
        do {
            try await authRepository.forgotPassword(email: email)
            return true
        } catch {
            // Error handling comes later, consistent with Login/Register.
            return false
        }
    }
}
