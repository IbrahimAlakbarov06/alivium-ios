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

    private enum AuthRoute {
        case login
        case register
    }

    init(container: AppContainer) {
        _loginViewModel = State(initialValue: container.makeLoginViewModel())
        _registerViewModel = State(initialValue: container.makeRegisterViewModel())
    }

    var body: some View {
        Group {
            switch route {
            case .login:
                LoginView(viewModel: loginViewModel) {
                    withAnimation { route = .register }
                }
            case .register:
                RegisterView(viewModel: registerViewModel) {
                    withAnimation { route = .login }
                }
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
