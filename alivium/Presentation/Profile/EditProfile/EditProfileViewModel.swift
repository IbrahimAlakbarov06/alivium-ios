//
//  EditProfileViewModel.swift
//  alivium
//

import Foundation
import Observation

@Observable
final class EditProfileViewModel {
    var fullName: String
    var email: String
    /// Local digits only — the "+994" country code is a fixed prefix shown by `BaseTextField`,
    /// never part of what's typed or stored here (matches `AddAddressView`'s identical pattern).
    var phone: String

    private(set) var isProcessing = false

    private let userId: String
    private let originalFullName: String
    private let originalEmail: String
    private let originalPhone: String

    private let authRepository: AuthRepository
    private let userSession: UserSession

    /// Gates the Save button — saving with nothing actually changed would be a no-op round trip.
    var hasChanges: Bool {
        fullName != originalFullName || email != originalEmail || phone != originalPhone
    }

    var canSave: Bool {
        hasChanges
            && !fullName.trimmingCharacters(in: .whitespaces).isEmpty
            && !email.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(userSession: UserSession, authRepository: AuthRepository) {
        self.userSession = userSession
        self.authRepository = authRepository

        let currentUser: User?
        if case .authenticated(let user) = userSession.state {
            currentUser = user
        } else {
            currentUser = nil
        }

        let initialFullName = currentUser?.fullName ?? ""
        let initialEmail = currentUser?.email ?? ""
        let initialPhone = Self.localDigits(from: currentUser?.phone)

        self.userId = currentUser?.id ?? ""
        self.fullName = initialFullName
        self.email = initialEmail
        self.phone = initialPhone
        self.originalFullName = initialFullName
        self.originalEmail = initialEmail
        self.originalPhone = initialPhone
    }

    /// Awaitable, matching Profile's own `logOut`/`deleteAccount` — the view only navigates back
    /// once the save actually completes, and only on the call that actually ran (guards a rapid
    /// double-tap on Save).
    @discardableResult
    func saveChanges() async -> Bool {
        guard !isProcessing, canSave else { return false }
        isProcessing = true
        defer { isProcessing = false }
        let trimmedPhone = phone.trimmingCharacters(in: .whitespaces)
        let fullPhone = trimmedPhone.isEmpty ? "" : "+994 \(trimmedPhone)"
        do {
            let updatedUser = try await authRepository.updateProfile(
                id: userId,
                fullName: fullName,
                email: email,
                phone: fullPhone
            )
            userSession.updateUser(updatedUser)
            return true
        } catch {
            return false
        }
    }

    private static func localDigits(from fullPhone: String?) -> String {
        guard let fullPhone else { return "" }
        return fullPhone.replacingOccurrences(of: "+994", with: "").trimmingCharacters(in: .whitespaces)
    }
}
