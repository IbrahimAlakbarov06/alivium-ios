//
//  UserSession.swift
//  alivium
//

import Observation

enum UserSessionState: Equatable {
    case guest
    case authenticated(User)
}

/// Single source of truth for who's currently signed in. Owned by `AppContainer` and injected
/// by constructor into any ViewModel that needs to read or change it (Login/Register write on
/// success, Profile reads it and clears it on log out) — mirrors `LocalizationManager`'s shape,
/// but this is app/domain state rather than a presentation concern, so ViewModels may depend on
/// it directly.
@Observable
final class UserSession {
    private(set) var state: UserSessionState = .guest

    func signIn(_ user: User) {
        state = .authenticated(user)
    }

    /// Distinct from `signIn(_:)` in intent (not a fresh login, just replacing the stored user
    /// after an Edit Profile save) even though the underlying assignment is identical — Edit
    /// Profile calls this rather than `signIn(_:)` so the call site itself reads correctly.
    func updateUser(_ user: User) {
        state = .authenticated(user)
    }

    func signOut() {
        state = .guest
    }
}
