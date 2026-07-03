//
//  VerificationPurpose.swift
//  alivium
//

import Foundation

/// Which flow `VerificationCodeView` is completing — drives its icon, headline, and subtitle,
/// and tells whoever presents it where a successful verify should lead. One shared screen
/// configured by this enum, rather than two near-duplicate screens.
enum VerificationPurpose: Equatable {
    case emailVerification
    case passwordReset
}
