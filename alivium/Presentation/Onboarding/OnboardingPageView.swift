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

    /// Tan vignette confined to the photo card and the kicker label directly beneath it:
    /// dark at the top of the photo, lightest in the gap right before the kicker, dark again
    /// at the bottom of the kicker, then a sharp cut to flat `AppColor.background` for the
    /// headline onward. Exactly four stops — no intermediate plateau stops — so there is no
    /// re-lightening after the final dark point.
    private func backgroundGradient(height: CGFloat, cardHeight: CGFloat) -> some View {
        let cardTop = AppSpacing.lg
        let cardBottom = cardTop + cardHeight
        let textBlockTop = cardBottom + AppSpacing.xl

        let kickerLineHeight: CGFloat = 16 // caption-weight kicker line
        let kickerBottom = textBlockTop + kickerLineHeight

        func location(_ point: CGFloat) -> CGFloat {
            guard height > 0 else { return 0 }
            return min(max(point / height, 0), 1)
        }

        return LinearGradient(
            gradient: Gradient(stops: [
                .init(color: page.backgroundTint.opacity(0.62), location: 0.0),
                .init(color: page.backgroundTint.opacity(0.06), location: location(textBlockTop)),
                .init(color: page.backgroundTint.opacity(0.62), location: location(kickerBottom)),
                .init(color: AppColor.background, location: location(kickerBottom) + 0.02)
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
