//
//  SplashView.swift
//  alivium
//

import SwiftUI

struct SplashView: View {
    @State private var badgeOpacity: Double = 0
    @State private var badgeScale: CGFloat = 0.8
    @State private var leftOffset: CGFloat = -300
    @State private var rightOffset: CGFloat = 300

    var body: some View {
        ZStack {
            AppColor.primary
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.md) {
                logoBadge
                    .opacity(badgeOpacity)
                    .scaleEffect(badgeScale)

                wordmark
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                badgeOpacity = 1
                badgeScale = 1
                leftOffset = 0
                rightOffset = 0
            }
        }
    }

    private var logoBadge: some View {
        Image("LogoMark")
            .resizable()
            .scaledToFit()
            .frame(width: 150, height: 150)
            .clipShape(Circle())
    }

    private var wordmark: some View {
        HStack(spacing: 0) {
            Text("ALI")
                .font(AppTypography.headline)
                .kerning(4)
                .foregroundStyle(AppColor.background)
                .offset(x: leftOffset)
            Text("VIUM")
                .font(AppTypography.headline)
                .kerning(4)
                .foregroundStyle(AppColor.background)
                .offset(x: rightOffset)
        }
    }
}

#Preview {
    SplashView()
}
