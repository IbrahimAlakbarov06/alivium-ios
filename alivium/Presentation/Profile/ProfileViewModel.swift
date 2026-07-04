//
//  ProfileViewModel.swift
//  alivium
//

import Observation

@Observable
final class ProfileViewModel {
    private(set) var isProcessing = false

    private let authRepository: AuthRepository
    private let userSession: UserSession

    var sessionState: UserSessionState {
        userSession.state
    }

    init(authRepository: AuthRepository, userSession: UserSession) {
        self.authRepository = authRepository
        self.userSession = userSession
    }

    /// Awaitable, matching the rest of Auth's ViewModels — the view only fires its
    /// `onSignedOut` navigation once the repository call actually completes, and only on the
    /// call that actually ran (guards a rapid double-confirm on the dialog).
    @discardableResult
    func logOut() async -> Bool {
        guard !isProcessing else { return false }
        isProcessing = true
        defer { isProcessing = false }
        do {
            try await authRepository.logOut()
            userSession.signOut()
            return true
        } catch {
            return false
        }
    }

    @discardableResult
    func deleteAccount() async -> Bool {
        guard !isProcessing else { return false }
        isProcessing = true
        defer { isProcessing = false }
        do {
            try await authRepository.deleteAccount()
            userSession.signOut()
            return true
        } catch {
            return false
        }
    }
}
