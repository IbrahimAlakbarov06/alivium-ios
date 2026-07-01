//
//  AuthPlaceholderView.swift
//  alivium
//

import SwiftUI

/// Temporary stub for where Login/Register/ForgotPassword will live (CLAUDE.md Phase 1, item 3).
struct AuthPlaceholderView: View {
    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            VStack(spacing: AppSpacing.sm) {
                Text("Auth flow coming soon")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColor.textPrimary)

                Text("Login, Register and Forgot Password will live here.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.lg)
            }
        }
    }
}

#Preview {
    AuthPlaceholderView()
}
