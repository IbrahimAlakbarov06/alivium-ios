//
//  ChangePasswordViewModel.swift
//  alivium
//

import Observation

enum ChangePasswordViewState: Equatable {
    case idle
    case loading
    /// Specifically "current password was wrong" — the one realistic failure path this mock
    /// models (see `AuthRepository.changePassword`'s doc comment).
    case error(LocalizedKey)
}

@Observable
final class ChangePasswordViewModel {
    var currentPassword: String = "" {
        didSet { clearErrorOnEdit() }
    }
    var newPassword: String = ""
    var confirmPassword: String = ""
    private(set) var state: ChangePasswordViewState = .idle

    var isLoading: Bool { state == .loading }

    /// Same reasoning as `CreateNewPasswordViewModel.passwordsMatch` — empty confirmation reads
    /// as "not yet answered" rather than "wrong", so the mismatch warning only appears once the
    /// shopper has actually typed something to compare.
    var passwordsMatch: Bool {
        confirmPassword.isEmpty || newPassword == confirmPassword
    }

    var currentPasswordErrorMessage: LocalizedKey? {
        if case .error(let key) = state { return key }
        return nil
    }

    var canSubmit: Bool {
        !currentPassword.isEmpty && !newPassword.isEmpty && newPassword == confirmPassword
    }

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    @discardableResult
    func updatePassword() async -> Bool {
        guard state != .loading, canSubmit else { return false }
        state = .loading
        do {
            try await authRepository.changePassword(currentPassword: currentPassword, newPassword: newPassword)
            state = .idle
            return true
        } catch {
            state = .error(.incorrectCurrentPassword)
            return false
        }
    }

    private func clearErrorOnEdit() {
        if case .error = state {
            state = .idle
        }
    }
}
