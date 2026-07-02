//
//  AuthHeaderView.swift
//  alivium
//

import SwiftUI

/// Shared top bar for the Auth screens: brand mark + wordmark on the leading edge, an AZ/EN
/// language toggle on the trailing edge. Identical on Login and Register.
struct AuthHeaderView: View {
    @State private var isAzerbaijani: Bool = true

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

            languageSwitch
        }
    }

    private var languageSwitch: some View {
        HStack(spacing: 0) {
            languageOption(title: "AZ", isSelected: isAzerbaijani) {
                isAzerbaijani = true
            }
            languageOption(title: "EN", isSelected: !isAzerbaijani) {
                isAzerbaijani = false
            }
        }
        .padding(3)
        .background(AppColor.surface)
        .clipShape(Capsule())
    }

    private func languageOption(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? AppColor.background : AppColor.textSecondary)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xxs)
                .background(isSelected ? AppColor.primary : Color.clear)
                .clipShape(Capsule())
        }
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}

#Preview {
    AuthHeaderView()
        .padding()
}
