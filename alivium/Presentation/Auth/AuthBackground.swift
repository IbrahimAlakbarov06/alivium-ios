//
//  AuthBackground.swift
//  alivium
//

import SwiftUI

/// Subtle warm backdrop shared by the Auth screens — a whisper of the brand's cream tone
/// bleeding in from the bottom over a solid white base, quiet enough to still read as
/// "clean white app" rather than a hero moment like onboarding's vignette.
struct AuthBackground: View {
    var body: some View {
        ZStack {
            AppColor.background

            LinearGradient(
                colors: [AppColor.background.opacity(0), AppColor.cream.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

#Preview {
    AuthBackground()
}
