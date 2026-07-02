//
//  LoginView.swift
//  alivium
//

import SwiftUI

struct LoginView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: LoginViewModel
    let onNavigateToRegister: () -> Void
    let onNavigateToForgotPassword: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                AuthHeaderView()
                    .padding(.bottom, AppSpacing.xl)

                Text(localization.string(.welcomeBack))
                    .font(AppTypography.display)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                formSection
                    .padding(.top, AppSpacing.xl)

                BaseButton(
                    title: localization.string(.logIn),
                    kind: .primary,
                    size: .large,
                    isLoading: viewModel.isLoading
                ) {
                    viewModel.login()
                }
                .padding(.top, AppSpacing.lg)

                LabeledDivider(label: localization.string(.orContinueWith))
                    .padding(.top, AppSpacing.xxl)

                socialButtons
                    .padding(.top, AppSpacing.md)

                signUpFooter
                    .padding(.top, AppSpacing.xl)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AuthBackground())
        .scrollDismissesKeyboard(.interactively)
    }

    private var formSection: some View {
        VStack(spacing: 0) {
            BaseTextField(
                placeholder: localization.string(.emailAddress),
                text: $viewModel.email,
                keyboardType: .emailAddress,
                autocapitalization: .never,
                disablesAutocorrection: true
            )

            BaseTextField(
                placeholder: localization.string(.password),
                text: $viewModel.password,
                style: .secure
            )
            .padding(.top, AppSpacing.md)

            HStack {
                Spacer()
                Button(action: onNavigateToForgotPassword) {
                    Text(localization.string(.forgotPassword))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.accent)
                }
            }
            .padding(.top, AppSpacing.xs)
        }
    }

    private var socialButtons: some View {
        VStack(spacing: AppSpacing.md) {
            SocialSignInButton(
                provider: .google,
                title: localization.string(.continueWithGoogle),
                isLoading: viewModel.isLoading
            ) {
                viewModel.continueWithGoogle()
            }
            SocialSignInButton(
                provider: .apple,
                title: localization.string(.continueWithApple),
                isLoading: viewModel.isLoading
            ) {
                viewModel.continueWithApple()
            }
            guestButton
        }
    }

    private var guestButton: some View {
        Button {
            viewModel.continueAsGuest()
        } label: {
            Text(localization.string(.continueAsGuest))
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColor.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
        }
        .disabled(viewModel.isLoading)
    }

    private var signUpFooter: some View {
        HStack(spacing: AppSpacing.xxs) {
            Text(localization.string(.dontHaveAccount))
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)

            Button(action: onNavigateToRegister) {
                Text(localization.string(.signUp))
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColor.accent)
            }
        }
    }
}

#Preview {
    LoginView(
        viewModel: LoginViewModel(authRepository: MockAuthRepository()),
        onNavigateToRegister: {},
        onNavigateToForgotPassword: {}
    )
    .environment(LocalizationManager())
}
