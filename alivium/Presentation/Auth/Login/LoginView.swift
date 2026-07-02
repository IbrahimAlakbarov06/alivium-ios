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
            VStack(spacing: AppSpacing.lg) {
                logo

                Text("Welcome Back")
                    .font(AppTypography.display)
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.top, AppSpacing.sm)

                VStack(spacing: AppSpacing.md) {
                    BaseTextField(
                        placeholder: "Email Address",
                        text: $viewModel.email,
                        keyboardType: .emailAddress,
                        autocapitalization: .never,
                        disablesAutocorrection: true
                    )

                    VStack(spacing: AppSpacing.xs) {
                        BaseTextField(
                            placeholder: "Password",
                            text: $viewModel.password,
                            style: .secure
                        )

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
                    }
                }
                .padding(.top, AppSpacing.md)

                BaseButton(
                    title: "Log In",
                    kind: .primary,
                    size: .large,
                    isLoading: viewModel.isLoading
                ) {
                    viewModel.login()
                }

                LabeledDivider(label: "or continue with")

                VStack(spacing: AppSpacing.sm) {
                    SocialSignInButton(provider: .google, isLoading: viewModel.isLoading) {
                        viewModel.continueWithGoogle()
                    }
                    SocialSignInButton(provider: .apple, isLoading: viewModel.isLoading) {
                        viewModel.continueWithApple()
                    }
                }

                signUpFooter
                    .padding(.top, AppSpacing.sm)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.xxl)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AppColor.background.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
    }

    private var logo: some View {
        Image("LogoMark")
            .resizable()
            .scaledToFill()
            .frame(width: 64, height: 64)
            .clipShape(Circle())
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
