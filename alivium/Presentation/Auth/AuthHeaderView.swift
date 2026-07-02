//
//  AuthHeaderView.swift
//  alivium
//

import SwiftUI

/// Shared top bar for the Auth screens: brand mark + wordmark on the leading edge, an AZ/EN
/// language toggle on the trailing edge. Identical on Login and Register.
struct AuthHeaderView: View {
    @State private var isAzerbaijani: Bool = true
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
        HStack(spacing: 0) {
            languageOption(title: "AZ", isSelected: isAzerbaijani) {
                select(azerbaijani: true)
            }
            languageOption(title: "EN", isSelected: !isAzerbaijani) {
                select(azerbaijani: false)
            }
        }
        .background(alignment: .leading) {
            // The draggable selected-segment indicator. minimumDistance keeps plain taps on
            // the AZ/EN labels falling through to their own Buttons instead of being eaten
            // by this gesture.
            Capsule()
                .fill(AppColor.primary)
                .frame(width: segmentWidth)
                .offset(x: thumbOffset)
                .gesture(thumbDragGesture)
        }
        .padding(3)
        .background(AppColor.surface)
        .clipShape(Capsule())
    }

    private func languageOption(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? AppColor.background : AppColor.textSecondary)
                .frame(width: segmentWidth)
                .padding(.vertical, AppSpacing.xxs)
        }
    }

    private var restingOffset: CGFloat {
        isAzerbaijani ? 0 : segmentWidth
    }

    private var thumbOffset: CGFloat {
        min(max(restingOffset + dragTranslation, 0), segmentWidth)
    }

    private var thumbDragGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                dragTranslation = value.translation.width
            }
            .onEnded { value in
                let finalOffset = min(max(restingOffset + value.translation.width, 0), segmentWidth)
                select(azerbaijani: finalOffset < segmentWidth / 2)
            }
    }

    private func select(azerbaijani: Bool) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isAzerbaijani = azerbaijani
            dragTranslation = 0
        }
    }
}

#Preview {
    AuthHeaderView()
        .padding()
}
