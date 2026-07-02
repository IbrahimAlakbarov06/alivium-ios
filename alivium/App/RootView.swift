//
//  RootView.swift
//  alivium
//

import SwiftUI

/// Cold-launch flow: brand Splash, then either Onboarding (first launch) or the
/// Auth stub (returning user) — per CLAUDE.md Phase 1 build order.
struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var isShowingSplash = true
    @State private var container = AppContainer()

    var body: some View {
        Group {
            if isShowingSplash {
                SplashView()
            } else if hasCompletedOnboarding {
                AuthFlowView(container: container)
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
        .environment(container.localizationManager)
        .task {
            try? await Task.sleep(for: .seconds(1.4))
            withAnimation {
                isShowingSplash = false
            }
        }
    }
}

#Preview {
    RootView()
}
