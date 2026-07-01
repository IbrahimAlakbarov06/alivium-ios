//
//  OnboardingPageView.swift
//  alivium
//

import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPageContent

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let progress = width == 0 ? 0 : proxy.frame(in: .global).minX / width
            let cardHeight = height * 0.54

            VStack(spacing: 0) {
                photoCard(width: width, height: cardHeight, progress: progress)
                    .padding(.top, AppSpacing.lg)

                textBlock(progress: progress)
                    .padding(.top, AppSpacing.xl)

                Spacer(minLength: 0)
            }
            .frame(width: width, height: height)
            .background(
                backgroundGradient(height: height, cardHeight: cardHeight)
                    .ignoresSafeArea()
            )
        }
    }

    /// Tan vignette confined to the photo card and the kicker label directly beneath it,
    /// with its own dark → light → dark rhythm: darkest at the top of the photo, lightening
    /// through the photo to its lightest point in the gap before the kicker, then darkening
    /// again through the kicker label. The headline, subtitle, and everything below fall on
    /// flat `AppColor.background`. All transition points are derived from the actual card
    /// height and kicker line height (in points, converted to a fraction of `height`).
    private func backgroundGradient(height: CGFloat, cardHeight: CGFloat) -> some View {
        let cardTop = AppSpacing.lg
        let cardBottom = cardTop + cardHeight
        let textBlockTop = cardBottom + AppSpacing.xl

        let kickerLineHeight: CGFloat = 16 // caption-weight kicker line
        let kickerBottom = textBlockTop + kickerLineHeight

        // Fade completes well before the headline (which starts AppSpacing.sm after the
        // kicker), so the title block always sits on flat background.
        let fade = AppSpacing.xs

        let darkOpacity: Double = 0.62
        let lightOpacity: Double = 0.06

        func location(_ point: CGFloat) -> CGFloat {
            guard height > 0 else { return 0 }
            return min(max(point / height, 0), 1)
        }

        return LinearGradient(
            gradient: Gradient(stops: [
                // Darkest at the top of the photo card. This edge has an implicit plateau
                // (the color extends upward behind the status bar), so it reads as a solid
                // tone rather than a fleeting peak.
                .init(color: page.backgroundTint.opacity(darkOpacity), location: location(0)),
                // Lightens through the photo, reaching its lightest point in the gap
                // right before the kicker label.
                .init(color: page.backgroundTint.opacity(lightOpacity), location: location(textBlockTop)),
                // Darkens again through the kicker label, holding at full dark opacity for
                // a short plateau (mirroring the top edge) before the white fade begins,
                // so it reads with the same visual weight instead of an instant peak.
                .init(color: page.backgroundTint.opacity(darkOpacity), location: location(kickerBottom - fade)),
                .init(color: page.backgroundTint.opacity(darkOpacity), location: location(kickerBottom)),
                // Then the existing fade into flat white for the headline onward.
                .init(color: AppColor.background, location: location(kickerBottom + fade))
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func photoCard(width: CGFloat, height: CGFloat, progress: CGFloat) -> some View {
        illustration
            .frame(width: width - AppSpacing.lg * 2, height: height)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl))
            .shadow(color: page.shadowTint.opacity(0.35), radius: 20, x: 0, y: 12)
            .offset(x: progress * -28)
            .scaleEffect(1 - min(abs(progress) * 0.1, 0.1), anchor: .top)
            .opacity(1 - min(abs(progress) * 0.6, 0.6))
    }

    private func textBlock(progress: CGFloat) -> some View {
        VStack(spacing: AppSpacing.sm) {
            Text(page.kicker)
                .font(AppTypography.caption)
                .fontWeight(.semibold)
                .tracking(2)
                .foregroundStyle(AppColor.accent)

            Text(page.title)
                .font(AppTypography.display)
                .tracking(-0.4)
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.center)

            Text(page.subtitle)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.lg)
        }
        .frame(maxWidth: .infinity)
        .offset(x: progress * 50)
        .opacity(1 - min(abs(progress) * 0.9, 0.9))
    }

    @ViewBuilder
    private var illustration: some View {
        switch page.id {
        case 0:
            OnboardingIllustration1()
        case 1:
            OnboardingIllustration2()
        default:
            OnboardingIllustration3()
        }
    }
}

#Preview {
    OnboardingPageView(page: OnboardingContent.pages[0])
}
