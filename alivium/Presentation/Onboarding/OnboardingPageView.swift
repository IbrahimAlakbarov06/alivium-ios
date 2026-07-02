//
//  OnboardingPageView.swift
//  alivium
//

import SwiftUI

struct OnboardingPageView: View {
    @Environment(LocalizationManager.self) private var localization
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

    /// Tan vignette confined to the photo card and the kicker label directly beneath it.
    /// Fully symmetric: it fades IN from the very top edge of the screen (opacity 0 at y=0)
    /// up to its darkest point at the top of the photo, over `edgeFadeDistance`. It's lightest
    /// exactly in the middle, dark again at the bottom of the kicker (mirroring the top curve),
    /// then fades back OUT to flat `AppColor.background` over that same `edgeFadeDistance` —
    /// so the top and bottom curves are true mirror images of each other, and no tint bleeds
    /// behind the bold title text.
    private func backgroundGradient(height: CGFloat, cardHeight: CGFloat) -> some View {
        let cardTop = AppSpacing.lg
        let cardBottom = cardTop + cardHeight
        let textBlockTop = cardBottom + AppSpacing.xl

        let kickerLineHeight: CGFloat = 16 // caption-weight kicker line
        let kickerBottom = textBlockTop + kickerLineHeight

        // Symmetric region: top of photo card -> bottom of kicker.
        let regionTop = cardTop
        let regionBottom = kickerBottom
        let regionMid = (regionTop + regionBottom) / 2

        // Same distance used on both edges, so the fade-in at the top and the fade-out at
        // the bottom are mirror images of each other.
        let edgeFadeDistance: CGFloat = AppSpacing.lg
        let fadeInStart = max(regionTop - edgeFadeDistance, 0)
        let fadeOutEnd = regionBottom + edgeFadeDistance

        func location(_ point: CGFloat) -> CGFloat {
            guard height > 0 else { return 0 }
            return min(max(point / height, 0), 1)
        }

        let darkOpacity = 0.62
        let lightOpacity = 0.06

        return LinearGradient(
            gradient: Gradient(stops: [
                .init(color: page.backgroundTint.opacity(0), location: location(fadeInStart)),
                .init(color: page.backgroundTint.opacity(darkOpacity), location: location(regionTop)),
                .init(color: page.backgroundTint.opacity(lightOpacity), location: location(regionMid)),
                .init(color: page.backgroundTint.opacity(darkOpacity), location: location(regionBottom)),
                .init(color: AppColor.background, location: location(fadeOutEnd))
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
            Text(localization.string(page.kickerKey))
                .font(AppTypography.caption)
                .fontWeight(.semibold)
                .tracking(2)
                .foregroundStyle(AppColor.accent)

            Text(localization.string(page.titleKey))
                .font(AppTypography.display)
                .tracking(-0.4)
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.center)

            Text(localization.string(page.subtitleKey))
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
        .environment(LocalizationManager())
}
