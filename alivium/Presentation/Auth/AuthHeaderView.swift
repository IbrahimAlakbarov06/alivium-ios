//
//  AuthHeaderView.swift
//  alivium
//

import SwiftUI

/// Shared top bar for the Auth screens: brand mark + wordmark on the leading edge, an AZ/EN
/// language toggle on the trailing edge. Identical on Login and Register.
struct AuthHeaderView: View {
    @Environment(LocalizationManager.self) private var localization
    @State private var dragTranslation: CGFloat = 0

    private let segmentWidth: CGFloat = 40

    var body: some View {
        HStack {
            HStack(spacing: AppSpacing.xs) {
                Image("LogoMark")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())

                Text("ALIVIUM")
                    .font(.system(size: 24, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(AppColor.primary)
            }

            Spacer()

            languageSwitch
        }
    }

    private var languageSwitch: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(AppColor.primary)
                .frame(width: segmentWidth)
                .offset(x: thumbOffset)

            HStack(spacing: 0) {
                languageLabel(title: "AZ", isSelected: isAzerbaijani)
                languageLabel(title: "EN", isSelected: !isAzerbaijani)
            }
        }
        // One gesture recognizer is the sole source of truth for both tap and drag — a second,
        // competing recognizer per label (onTapGesture) previously raced this one and could
        // resolve to the wrong side on fast touches. onEnded reads the finger's absolute
        // location rather than translation-from-rest, so taps and drags share the same logic.
        .contentShape(Rectangle())
        .gesture(toggleGesture)
        .padding(3)
        .background(AppColor.surface)
        .clipShape(Capsule())
    }

    private func languageLabel(title: String, isSelected: Bool) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(isSelected ? AppColor.background : AppColor.textSecondary)
            .frame(width: segmentWidth)
            .padding(.vertical, AppSpacing.xxs)
    }

    private var isAzerbaijani: Bool {
        localization.currentLanguage == .az
    }

    private var restingOffset: CGFloat {
        isAzerbaijani ? 0 : segmentWidth
    }

    private var thumbOffset: CGFloat {
        min(max(restingOffset + dragTranslation, 0), segmentWidth)
    }

    private var toggleGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                dragTranslation = min(max(restingOffset + value.translation.width, 0), segmentWidth) - restingOffset
            }
            .onEnded { value in
                select(azerbaijani: value.location.x < segmentWidth)
            }
    }

    private func select(azerbaijani: Bool) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            localization.setLanguage(azerbaijani ? .az : .en)
            dragTranslation = 0
        }
    }
}

#Preview {
    AuthHeaderView()
        .padding()
        .environment(LocalizationManager())
}
