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
                backgroundGradient
                    .ignoresSafeArea()
            )
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                // Confined vignette glow around the photo card: dark → light → dark.
                .init(color: page.backgroundTint.opacity(0.55), location: 0),
                .init(color: page.backgroundTint.opacity(0.25), location: 0.14),
                .init(color: AppColor.background, location: 0.36),
                .init(color: page.backgroundTint.opacity(0.28), location: 0.56),
                // Smooth blend down into a clean, flat, mostly-neutral zone for text/dots/button.
                .init(color: page.backgroundTint.opacity(0.06), location: 0.68),
                .init(color: page.backgroundTint.opacity(0.06), location: 1)
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
