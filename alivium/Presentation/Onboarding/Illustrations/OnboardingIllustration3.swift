//
//  OnboardingIllustration3.swift
//  alivium
//

import SwiftUI

struct OnboardingIllustration3: View {
    var body: some View {
        GeometryReader { proxy in
            Image("Onboarding3")
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
                .clipped()
        }
    }
}

#Preview {
    OnboardingIllustration3()
        .frame(height: 420)
}
