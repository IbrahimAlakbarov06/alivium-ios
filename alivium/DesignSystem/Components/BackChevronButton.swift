//
//  BackChevronButton.swift
//  alivium
//

import SwiftUI

/// Shared lightweight back-navigation control for sub-flow screens (Forgot Password,
/// Verification Code, Create New Password) — a bare chevron, no AuthHeaderView/logo/toggle,
/// consistent with how a simple sub-flow screen should feel lighter than Login/Register.
/// Extracted from what used to be three identical `backButton` copies.
struct BackChevronButton: View {
    @Environment(LocalizationManager.self) private var localization
    let action: () -> Void

    var body: some View {
        HStack {
            Button(action: action) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
            }
            .accessibilityLabel(localization.string(.back))
            Spacer()
        }
    }
}

#Preview {
    BackChevronButton(action: {})
        .padding()
        .environment(LocalizationManager())
}
