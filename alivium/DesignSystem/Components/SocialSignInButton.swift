//
//  SocialSignInButton.swift
//  alivium
//

import SwiftUI

enum SocialProvider {
    case google
    case apple

    var title: String {
        switch self {
        case .google: return "Continue with Google"
        case .apple: return "Continue with Apple"
        }
    }
}

/// Social sign-in CTA shared by Login and Register. No real auth is wired yet — the backend
/// only supports Google today and Apple needs a paid developer account — so this just renders
/// functional-looking UI backed by a mock success handler in the ViewModel.
struct SocialSignInButton: View {
    let provider: SocialProvider
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(foregroundColor)
                } else {
                    icon
                    Text(provider.title)
                        .font(AppTypography.bodyEmphasis)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(borderColor, lineWidth: provider == .google ? 1 : 0)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }
        .disabled(isLoading)
    }

    @ViewBuilder
    private var icon: some View {
        switch provider {
        case .google:
            Image(systemName: "g.circle.fill")
                .font(.system(size: 19, weight: .medium))
        case .apple:
            Image(systemName: "applelogo")
                .font(.system(size: 17, weight: .medium))
        }
    }

    private var backgroundColor: Color {
        switch provider {
        case .google: return AppColor.background
        case .apple: return AppColor.textPrimary
        }
    }

    private var foregroundColor: Color {
        switch provider {
        case .google: return AppColor.textPrimary
        case .apple: return AppColor.background
        }
    }

    private var borderColor: Color {
        switch provider {
        case .google: return AppColor.textSecondary.opacity(0.25)
        case .apple: return .clear
        }
    }
}

#Preview {
    VStack(spacing: AppSpacing.sm) {
        SocialSignInButton(provider: .google) {}
        SocialSignInButton(provider: .apple) {}
        SocialSignInButton(provider: .google, isLoading: true) {}
    }
    .padding()
}
