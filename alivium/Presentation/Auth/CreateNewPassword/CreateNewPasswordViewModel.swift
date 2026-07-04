//
//  CreateNewPasswordViewModel.swift
//  alivium
//

import Observation

@Observable
final class CreateNewPasswordViewModel {
    var newPassword: String = ""
    var confirmPassword: String = ""
    private(set) var state: AuthViewState = .idle

    var isLoading: Bool { state == .loading }

    /// A real usability check (an easy typo to miss), not full password-strength validation —
    /// consistent with this app deliberately deferring cosmetic field validation elsewhere.
    /// Empty confirmation reads as "not yet answered" rather than "wrong", so the mismatch
    /// warning only appears once the user has actually typed something to compare.
    var passwordsMatch: Bool {
        confirmPassword.isEmpty || newPassword == confirmPassword
    }

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    /// Awaitable, matching the rest of Auth (Register/ForgotPassword/VerificationCode) — the
    /// view only navigates once the save actually completes, and only on a call that actually
    /// ran (guards the same rapid-double-tap race fixed elsewhere in this flow).
    @discardableResult
    func savePassword() async -> Bool {
        guard state != .loading else { return false }
        guard !newPassword.isEmpty, newPassword == confirmPassword else { return false }
        state = .loading
        defer { state = .idle }
        do {
            try await authRepository.resetPassword(newPassword: newPassword)
            return true
        } catch {
            // Error handling comes later, consistent with the rest of Auth.
            return false
        }
    }
}
