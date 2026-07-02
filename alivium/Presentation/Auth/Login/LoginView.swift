//
//  LoginView.swift
//  alivium
//

import SwiftUI

struct LoginView: View {
    @State var viewModel: LoginViewModel
    let onNavigateToRegister: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                AuthHeaderView()
                    .padding(.bottom, AppSpacing.xl)

                Text("Welcome Back")
                    .font(AppTypography.display)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                formSection
                    .padding(.top, AppSpacing.xl)

                BaseButton(
                    title: "Log In",
                    kind: .primary,
                    size: .large,
                    isLoading: viewModel.isLoading
                ) {
                    viewModel.login()
                }
                .padding(.top, AppSpacing.lg)

                LabeledDivider(label: "or continue with")
                    .padding(.top, AppSpacing.xxl)

                socialButtons
                    .padding(.top, AppSpacing.md)

                signUpFooter
                    .padding(.top, AppSpacing.xl)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AuthBackground())
        .scrollDismissesKeyboard(.interactively)
    }

    private var formSection: some View {
        VStack(spacing: 0) {
            BaseTextField(
                placeholder: "Email Address",
                text: $viewModel.email,
                keyboardType: .emailAddress,
                autocapitalization: .never,
                disablesAutocorrection: true
            )

            BaseTextField(
                placeholder: "Password",
                text: $viewModel.password,
                style: .secure
            )
            .padding(.top, AppSpacing.md)

            HStack {
                Spacer()
                Button {
                    // TODO: navigate to Forgot Password screen
                } label: {
                    Text("Forgot Password?")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.accent)
                }
            }
            .padding(.top, AppSpacing.xs)
        }
    }

    private var socialButtons: some View {
        VStack(spacing: AppSpacing.md) {
            SocialSignInButton(provider: .google, isLoading: viewModel.isLoading) {
                viewModel.continueWithGoogle()
            }
            SocialSignInButton(provider: .apple, isLoading: viewModel.isLoading) {
                viewModel.continueWithApple()
            }
            guestButton
        }
    }

    private var guestButton: some View {
        Button {
            viewModel.continueAsGuest()
        } label: {
            Text("Continue as Guest")
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColor.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
        }
        .disabled(viewModel.isLoading)
    }

    private var signUpFooter: some View {
        HStack(spacing: AppSpacing.xxs) {
            Text("Don't have an account?")
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)

            Button(action: onNavigateToRegister) {
                Text("Sign Up")
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColor.accent)
            }
        }
    }
}

#Preview {
    LoginView(
        viewModel: LoginViewModel(authRepository: MockAuthRepository()),
        onNavigateToRegister: {}
    )
}
