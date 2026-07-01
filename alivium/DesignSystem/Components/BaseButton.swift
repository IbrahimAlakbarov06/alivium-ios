//
//  BaseButton.swift
//  alivium
//

import SwiftUI

enum AppButtonStyleKind {
    case primary
    case secondary
    case ghost
    case destructive
}

enum AppButtonSize {
    case large
    case medium
    case small
}

struct BaseButton: View {
    let title: String
    var icon: Image? = nil
    var kind: AppButtonStyleKind = .primary
    var size: AppButtonSize = .large
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(foregroundColor)
                } else {
                    icon
                    Text(title)
                        .font(font)
                }
            }
            .frame(maxWidth: size == .small ? nil : .infinity)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(borderColor, lineWidth: kind == .ghost ? 1 : 0)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1 : 0.5)
    }

    private var font: Font {
        switch size {
        case .large: return AppTypography.bodyEmphasis
        case .medium: return AppTypography.body
        case .small: return AppTypography.caption
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .large: return AppSpacing.md
        case .medium: return AppSpacing.xs
        case .small: return AppSpacing.xxs
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .large: return AppSpacing.lg
        case .medium: return AppSpacing.md
        case .small: return AppSpacing.sm
        }
    }

    private var backgroundColor: Color {
        switch kind {
        case .primary: return AppColor.primary
        case .secondary: return AppColor.accent
        case .ghost: return .clear
        case .destructive: return AppColor.error
        }
    }

    private var foregroundColor: Color {
        switch kind {
        case .primary, .secondary, .destructive: return AppColor.background
        case .ghost: return AppColor.primary
        }
    }

    private var borderColor: Color {
        switch kind {
        case .ghost: return AppColor.primary
        default: return .clear
        }
    }
}

#Preview {
    VStack(spacing: AppSpacing.sm) {
        BaseButton(title: "Add to Cart", kind: .primary) {}
        BaseButton(title: "Save", kind: .secondary, size: .medium) {}
        BaseButton(title: "Cancel", kind: .ghost, size: .small) {}
        BaseButton(title: "Remove", kind: .destructive) {}
        BaseButton(title: "Loading", kind: .primary, isLoading: true) {}
        BaseButton(title: "Disabled", kind: .primary, isEnabled: false) {}
    }
    .padding()
}
