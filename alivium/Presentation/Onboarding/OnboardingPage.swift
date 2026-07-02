//
//  OnboardingPage.swift
//  alivium
//

import SwiftUI

struct OnboardingPageContent: Identifiable {
    let id: Int
    let kickerKey: LocalizedKey
    let titleKey: LocalizedKey
    let subtitleKey: LocalizedKey
    /// A warm neutral sampled from the photo itself, used for the page's background gradient.
    let backgroundTint: Color
    /// A deeper shade of the same tone, used for the card's ambient shadow.
    let shadowTint: Color
}

enum OnboardingContent {
    static let pages: [OnboardingPageContent] = [
        OnboardingPageContent(
            id: 0,
            kickerKey: .onboardingPage1Kicker,
            titleKey: .onboardingPage1Title,
            subtitleKey: .onboardingPage1Subtitle,
            backgroundTint: Color(hex: 0xDDC9A8), // warm sandstone, from the archway photo
            shadowTint: Color(hex: 0x8A7452)
        ),
        OnboardingPageContent(
            id: 1,
            kickerKey: .onboardingPage2Kicker,
            titleKey: .onboardingPage2Title,
            subtitleKey: .onboardingPage2Subtitle,
            backgroundTint: Color(hex: 0xD6C4A9), // warm taupe, from the stucco wall photo
            shadowTint: Color(hex: 0x7D6B52)
        ),
        OnboardingPageContent(
            id: 2,
            kickerKey: .onboardingPage3Kicker,
            titleKey: .onboardingPage3Title,
            subtitleKey: .onboardingPage3Subtitle,
            backgroundTint: Color(hex: 0xCFC2A0), // warm khaki, from the woven-fabric photo
            shadowTint: Color(hex: 0x6E6248)
        )
    ]
}
