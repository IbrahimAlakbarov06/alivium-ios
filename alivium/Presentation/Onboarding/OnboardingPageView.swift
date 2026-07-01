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

    /// Four-zone vignette: dark behind the photo card, light in the card-to-title gap,
    /// dark again behind the title block, light for the remainder of the page. Stop
    /// locations are derived from the actual card/text layout (in points, converted to
    /// fractions of `height`) rather than guessed, so the dark zones track the content
    /// they sit behind instead of a fixed percentage of the screen.
    private func backgroundGradient(height: CGFloat, cardHeight: CGFloat) -> some View {
        let cardTop = AppSpacing.lg
        let cardBottom = cardTop + cardHeight
        let textBlockTop = cardBottom + AppSpacing.xl

        // Estimated text block height from AppTypography metrics: kicker (caption line)
        // + title (display, up to 2 lines) + subtitle (body, up to 2 lines), separated
        // by AppSpacing.sm.
        let kickerLineHeight: CGFloat = 16
        let titleLineHeight: CGFloat = 41 // 34pt bold display font
        let titleHeight = titleLineHeight * 2
        let subtitleLineHeight: CGFloat = 20 // 16pt body font
        let subtitleHeight = subtitleLineHeight * 2
        let textBlockHeight = kickerLineHeight + AppSpacing.sm + titleHeight + AppSpacing.sm + subtitleHeight
        let textBlockBottom = textBlockTop + textBlockHeight

        let gapFade = AppSpacing.xs   // tight fade within the small card-to-title gap
        let outFade = AppSpacing.lg   // roomier fade below the title block

        // Shared opacity for every "dark" stop so Zone A and Zone C read as the same
        // intensity — using different values per zone made C visibly lighter than A.
        let darkOpacity: Double = 0.52

        func location(_ point: CGFloat) -> CGFloat {
            guard height > 0 else { return 0 }
            return min(max(point / height, 0), 1)
        }

        return LinearGradient(
            gradient: Gradient(stops: [
                // Zone A — dark, behind the photo card.
                .init(color: page.backgroundTint.opacity(darkOpacity), location: location(0)),
                .init(color: page.backgroundTint.opacity(darkOpacity), location: location(cardBottom)),
                // Zone B — light gap between the card and the title block.
                .init(color: AppColor.background, location: location(cardBottom + gapFade)),
                .init(color: AppColor.background, location: location(textBlockTop - gapFade)),
                // Zone C — dark again, spanning the title block.
                .init(color: page.backgroundTint.opacity(darkOpacity), location: location(textBlockTop)),
                .init(color: page.backgroundTint.opacity(darkOpacity), location: location(textBlockBottom)),
                // Zone D — light again for the remainder of the page.
                .init(color: AppColor.background, location: location(textBlockBottom + outFade))
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
