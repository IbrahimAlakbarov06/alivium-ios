//
//  AuthFlowView.swift
//  alivium
//

import SwiftUI

/// Self-contained Login <-> Register flow (CLAUDE.md Phase 1, item 3). Wired directly with
/// closures since there's no app-wide NavigationRouter yet — each screen exposes the
/// navigation it needs and this view owns the tiny bit of routing state between them.
struct AuthFlowView: View {
    @State private var route: AuthRoute = .login
    @State private var loginViewModel: LoginViewModel
    @State private var registerViewModel: RegisterViewModel
    @State private var forgotPasswordViewModel: ForgotPasswordViewModel
    @State private var verificationCodeViewModel: VerificationCodeViewModel

    private enum AuthRoute {
        case login
        case register
        case forgotPassword
        case verification(purpose: VerificationPurpose, email: String)
    }

    init(container: AppContainer) {
        _loginViewModel = State(initialValue: container.makeLoginViewModel())
        _registerViewModel = State(initialValue: container.makeRegisterViewModel())
        _forgotPasswordViewModel = State(initialValue: container.makeForgotPasswordViewModel())
        _verificationCodeViewModel = State(initialValue: container.makeVerificationCodeViewModel())
    }

    var body: some View {
        Group {
            switch route {
            case .login:
                LoginView(
                    viewModel: loginViewModel,
                    onNavigateToRegister: {
                        withAnimation { route = .register }
                    },
                    onNavigateToForgotPassword: {
                        withAnimation { route = .forgotPassword }
                    }
                )
            case .register:
                RegisterView(
                    viewModel: registerViewModel,
                    onNavigateToLogin: {
                        withAnimation { route = .login }
                    },
                    onRegisterSuccess: {
                        withAnimation {
                            route = .verification(purpose: .emailVerification, email: registerViewModel.email)
                        }
                    }
                )
            case .forgotPassword:
                ForgotPasswordView(
                    viewModel: forgotPasswordViewModel,
                    onNavigateBack: {
                        withAnimation { route = .login }
                    },
                    onSuccess: {
                        withAnimation {
                            route = .verification(purpose: .passwordReset, email: forgotPasswordViewModel.email)
                        }
                    }
                )
            case .verification(let purpose, let email):
                VerificationCodeView(
                    viewModel: verificationCodeViewModel,
                    purpose: purpose,
                    email: email,
                    onNavigateBack: {
                        withAnimation {
                            route = purpose == .emailVerification ? .register : .forgotPassword
                        }
                    },
                    onSuccess: {
                        switch purpose {
                        case .emailVerification:
                            // TODO: navigate to Home/main app once it exists.
                            print("Email verified — TODO: navigate to Home")
                        case .passwordReset:
                            // TODO: navigate to Create New Password screen once it's built.
                            print("Code verified — TODO: navigate to Create New Password screen")
                        }
                    }
                )
            }
        }
        .transition(.opacity)
    }
}

#Preview {
    let container = AppContainer()
    AuthFlowView(container: container)
        .environment(container.localizationManager)
}
