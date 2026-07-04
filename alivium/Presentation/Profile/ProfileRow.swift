//
//  ProfileRow.swift
//  alivium
//

import SwiftUI

/// Grouped-list-style row (icon + label + trailing chevron/value) used across Profile's
/// Account/Preferences/Support sections. Kept local to Profile rather than promoted to
/// DesignSystem/Components since nothing else needs this exact shape yet.
struct ProfileRow: View {
    enum Trailing {
        case chevron
        case value(String)
    }

    let icon: String
    let title: String
    var trailing: Trailing = .chevron
    var titleColor: Color = AppColor.textPrimary
    var iconColor: Color = AppColor.primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(iconColor)
                    .frame(width: 24)

                Text(title)
                    .font(AppTypography.body)
                    .foregroundStyle(titleColor)

                Spacer()

                if case .value(let value) = trailing {
                    Text(value)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColor.textSecondary.opacity(0.6))
            }
            .padding(.vertical, AppSpacing.sm)
            .padding(.horizontal, AppSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Rounded card container with a thin, icon-aligned separator between rows — the grouped
/// "Settings-style" section shape, restyled with our own tokens instead of a system List.
struct ProfileSectionCard<Content: View>: View {
    var title: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            if let title {
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .padding(.horizontal, AppSpacing.xs)
            }

            VStack(spacing: 0) {
                content()
            }
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }
    }
}

/// Thin divider indented past the row icon, so it reads as part of the grouped card rather
/// than a full-bleed line.
struct ProfileRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppColor.textSecondary.opacity(0.15))
            .frame(height: 1)
            .padding(.leading, AppSpacing.md + 24 + AppSpacing.sm)
    }
}

#Preview {
    ProfileSectionCard(title: "ACCOUNT") {
        ProfileRow(icon: "bag", title: "Order History") {}
        ProfileRowDivider()
        ProfileRow(icon: "mappin.and.ellipse", title: "Addresses") {}
        ProfileRowDivider()
        ProfileRow(icon: "creditcard", title: "Payment Methods") {}
    }
    .padding()
}
