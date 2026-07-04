//
//  AuthHeaderView.swift
//  alivium
//

import SwiftUI

/// Shared top bar for the Auth screens: brand mark + wordmark on the leading edge, an AZ/EN
/// language toggle on the trailing edge. Identical on Login and Register.
struct AuthHeaderView: View {
    var body: some View {
        HStack {
            HStack(spacing: AppSpacing.xs) {
                Image("LogoMark")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())

                Text("ALIVIUM")
                    .font(.system(size: 24, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(AppColor.primary)
            }

            Spacer()

            LanguageToggle()
        }
    }
}

#Preview {
    AuthHeaderView()
        .padding()
        .environment(LocalizationManager())
}
