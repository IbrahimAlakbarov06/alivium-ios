//
//  VerificationCodeView.swift
//  alivium
//

import SwiftUI

/// Shared by two flows — email verification right after Register, and the reset-code step
/// after Forgot Password — configured by `purpose` rather than duplicated per flow, matching
/// the enum-driven pattern used by `BaseButton(kind:)` elsewhere in the design system.
struct VerificationCodeView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: VerificationCodeViewModel
    let purpose: VerificationPurpose
    let email: String
    let onNavigateBack: () -> Void
    let onSuccess: () -> Void

    @State private var isResendCoolingDown = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                backButton
                    .padding(.bottom, AppSpacing.xl)

                iconBadge
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, AppSpacing.lg)

                Text(localization.string(headlineKey))
                    .font(AppTypography.display)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(subtitleText)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, AppSpacing.xs)

                OTPCodeField(code: $viewModel.code)
                    .padding(.top, AppSpacing.xl)

                BaseButton(
                    title: localization.string(.verify),
                    kind: .primary,
                    size: .large,
                    isLoading: viewModel.isLoading
                ) {
                    Task {
                        await viewModel.verify()
                        onSuccess()
                    }
                }
                .padding(.top, AppSpacing.xl)

                resendFooter
                    .padding(.top, AppSpacing.lg)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AuthBackground())
        .scrollDismissesKeyboard(.interactively)
    }

    private var backButton: some View {
        HStack {
            Button(action: onNavigateBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
            }
            .accessibilityLabel(localization.string(.back))
            Spacer()
        }
    }

    private var iconBadge: some View {
        ZStack {
            Circle()
                .fill(AppColor.accentSoft.opacity(0.5))
                .frame(width: 72, height: 72)

            Image(systemName: iconName)
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(AppColor.accent)
        }
    }

    private var iconName: String {
        switch purpose {
        case .emailVerification: return "envelope.fill"
        case .passwordReset: return "lock.shield.fill"
        }
    }

    private var headlineKey: LocalizedKey {
        switch purpose {
        case .emailVerification: return .verifyYourEmail
        case .passwordReset: return .enterResetCode
        }
    }

    private var subtitleText: String {
        let key: LocalizedKey = purpose == .emailVerification ? .verifyEmailSubtitle : .resetCodeSubtitle
        return localization.string(key).replacingOccurrences(of: "{email}", with: email)
    }

    private var resendFooter: some View {
        HStack(spacing: AppSpacing.xxs) {
            Text(localization.string(.didntReceiveCode))
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)

            Button {
                viewModel.resend()
                startResendCooldown()
            } label: {
                Text(localization.string(.resend))
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(isResendCoolingDown ? AppColor.textSecondary : AppColor.accent)
            }
            .disabled(isResendCoolingDown)
        }
        .frame(maxWidth: .infinity)
    }

    private func startResendCooldown() {
        isResendCoolingDown = true
        Task {
            try? await Task.sleep(for: .seconds(30))
            isResendCoolingDown = false
        }
    }
}

#Preview("Email Verification") {
    VerificationCodeView(
        viewModel: VerificationCodeViewModel(authRepository: MockAuthRepository()),
        purpose: .emailVerification,
        email: "member@alivium.com",
        onNavigateBack: {},
        onSuccess: {}
    )
    .environment(LocalizationManager())
}

#Preview("Password Reset") {
    VerificationCodeView(
        viewModel: VerificationCodeViewModel(authRepository: MockAuthRepository()),
        purpose: .passwordReset,
        email: "member@alivium.com",
        onNavigateBack: {},
        onSuccess: {}
    )
    .environment(LocalizationManager())
}
