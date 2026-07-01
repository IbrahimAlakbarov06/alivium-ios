//
//  OnboardingPage.swift
//  alivium
//

import SwiftUI

struct OnboardingPageContent: Identifiable {
    let id: Int
    let kicker: String
    let title: String
    let subtitle: String
    /// A warm neutral sampled from the photo itself, used for the page's background gradient.
    let backgroundTint: Color
    /// A deeper shade of the same tone, used for the card's ambient shadow.
    let shadowTint: Color
}

enum OnboardingContent {
    static let pages: [OnboardingPageContent] = [
        OnboardingPageContent(
            id: 0,
            kicker: "CURATED SELECTION",
            title: "Curated Fashion,\nDelivered",
            subtitle: "A boutique edit of women's fashion, hand-picked each season.",
            backgroundTint: Color(hex: 0xDDC9A8), // warm sandstone, from the archway photo
            shadowTint: Color(hex: 0x8A7452)
        ),
        OnboardingPageContent(
            id: 1,
            kicker: "SIGNATURE STYLE",
            title: "Discover Your\nSignature Style",
            subtitle: "Every piece tells a story — find the ones that tell yours.",
            backgroundTint: Color(hex: 0xD6C4A9), // warm taupe, from the stucco wall photo
            shadowTint: Color(hex: 0x7D6B52)
        ),
        OnboardingPageContent(
            id: 2,
            kicker: "SEAMLESS DELIVERY",
            title: "Track Every Order,\nBeautifully",
            subtitle: "From checkout to your doorstep, always know where your pieces are.",
            backgroundTint: Color(hex: 0xCFC2A0), // warm khaki, from the woven-fabric photo
            shadowTint: Color(hex: 0x6E6248)
        )
    ]
}
