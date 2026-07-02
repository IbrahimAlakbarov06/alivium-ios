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

    private enum AuthRoute {
        case login
        case register
        case forgotPassword
    }

    init(container: AppContainer) {
        _loginViewModel = State(initialValue: container.makeLoginViewModel())
        _registerViewModel = State(initialValue: container.makeRegisterViewModel())
        _forgotPasswordViewModel = State(initialValue: container.makeForgotPasswordViewModel())
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
                RegisterView(viewModel: registerViewModel) {
                    withAnimation { route = .login }
                }
            case .forgotPassword:
                ForgotPasswordView(
                    viewModel: forgotPasswordViewModel,
                    onNavigateBack: {
                        withAnimation { route = .login }
                    },
                    onSuccess: {
                        // TODO: navigate to the Verification Code screen once it's built.
                        print("Reset link sent — TODO: navigate to Verification Code screen")
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
