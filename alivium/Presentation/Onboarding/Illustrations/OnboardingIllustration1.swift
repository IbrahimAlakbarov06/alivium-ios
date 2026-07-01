//
//  OnboardingIllustration1.swift
//  alivium
//

import SwiftUI

struct OnboardingIllustration1: View {
    @State private var hasAppeared = false

    var body: some View {
        GeometryReader { proxy in
            Image("Onboarding1")
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
                .clipped()
        }
        .opacity(hasAppeared ? 1 : 0)
        .scaleEffect(hasAppeared ? 1 : 0.85)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                hasAppeared = true
            }
        }
    }
}

#Preview {
    OnboardingIllustration1()
        .frame(height: 420)
}
