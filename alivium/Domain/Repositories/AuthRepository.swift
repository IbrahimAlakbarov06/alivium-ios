//
//  AuthRepository.swift
//  alivium
//

protocol AuthRepository {
    func login(email: String, password: String) async throws -> User
    func register(fullName: String, email: String, password: String) async throws -> User
    func loginWithGoogle() async throws -> User
    func loginWithApple() async throws -> User
    func forgotPassword(email: String) async throws
    func verifyCode(_ code: String) async throws
    func resetPassword(newPassword: String) async throws
    func logOut() async throws
    func deleteAccount() async throws
    /// `id` is passed back through rather than left to the repository to invent, so an edit can
    /// never appear to change the signed-in user's identity — a real backend would resolve it
    /// from the auth token, but the mock has no server-side user record to resolve it against.
    func updateProfile(id: String, fullName: String, email: String, phone: String) async throws -> User
    func changePassword(currentPassword: String, newPassword: String) async throws
}

/// Thrown by `AuthRepository.changePassword` when `currentPassword` doesn't match — the one
/// realistic failure path modeled in Phase 1's otherwise always-succeeds mock layer, since a
/// wrong current password is common enough that Change Password shouldn't silently pretend it
/// never happens.
enum AuthError: Error {
    case incorrectCurrentPassword
}
