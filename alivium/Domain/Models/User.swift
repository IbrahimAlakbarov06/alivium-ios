//
//  User.swift
//  alivium
//

struct User: Identifiable, Equatable {
    let id: String
    let fullName: String
    let email: String
    /// Defaults to empty rather than `nil` — no mock login flow populates this except the direct
    /// email/password one, and Edit Profile treats an empty phone the same as any other
    /// not-yet-filled-in field rather than needing to unwrap an optional everywhere.
    let phone: String

    /// A hand-written (not synthesized) memberwise init — a stored property given a default
    /// value is excluded from Swift's synthesized memberwise init entirely rather than made
    /// optional-to-pass, so this exists purely to give `phone` a default without updating every
    /// existing call site that has nothing to do with a phone number (matches `Product.init`'s
    /// identical reasoning for `collectionId`).
    init(id: String, fullName: String, email: String, phone: String = "") {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.phone = phone
    }
}
