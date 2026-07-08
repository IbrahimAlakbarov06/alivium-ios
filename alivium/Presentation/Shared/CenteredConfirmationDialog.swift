//
//  CenteredConfirmationDialog.swift
//  alivium
//

import SwiftUI

/// Replaces the native `.confirmationDialog(...)` for consequential actions (Cancel Order, Log
/// Out) — on this app's target OS that API renders as a small popover anchored to the trigger
/// button (arrow tail included), landing wherever that button happens to sit on screen rather
/// than as a stable, centered sheet, and can visually collide with the content underneath it.
/// This instead always renders centered (vertically and horizontally) with a dimmed backdrop,
/// matching the app's own considered, boutique design language rather than deferring to
/// whatever a given OS version does with the system dialog.
extension View {
    func centeredConfirmationDialog(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        confirmTitle: String,
        confirmRole: ButtonRole? = .destructive,
        cancelTitle: String,
        onConfirm: @escaping () -> Void
    ) -> some View {
        modifier(
            CenteredConfirmationDialogModifier(
                isPresented: isPresented,
                title: title,
                message: message,
                confirmTitle: confirmTitle,
                confirmRole: confirmRole,
                cancelTitle: cancelTitle,
                onConfirm: onConfirm
            )
        )
    }
}

private struct CenteredConfirmationDialogModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let confirmTitle: String
    let confirmRole: ButtonRole?
    let cancelTitle: String
    let onConfirm: () -> Void

    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    CenteredConfirmationDialogCard(
                        title: title,
                        message: message,
                        confirmTitle: confirmTitle,
                        confirmRole: confirmRole,
                        cancelTitle: cancelTitle,
                        onConfirm: {
                            isPresented = false
                            onConfirm()
                        },
                        onCancel: { isPresented = false }
                    )
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isPresented)
    }
}

/// The dimmed backdrop + centered card — kept separate from the modifier so the appear/disappear
/// transition below applies only to this overlay, never to `content` underneath it.
private struct CenteredConfirmationDialogCard: View {
    let title: String
    let message: String
    let confirmTitle: String
    let confirmRole: ButtonRole?
    let cancelTitle: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture(perform: onCancel)

            card
                .padding(.horizontal, AppSpacing.xl)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.92)))
        .zIndex(1)
    }

    private var card: some View {
        VStack(spacing: AppSpacing.lg) {
            VStack(spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                Text(message)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: AppSpacing.sm) {
                BaseButton(
                    title: confirmTitle,
                    kind: confirmRole == .destructive ? .destructive : .primary,
                    size: .large,
                    action: onConfirm
                )
                .accessibilityIdentifier("centeredDialogConfirmButton")

                Button(action: onCancel) {
                    Text(cancelTitle)
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.xs)
                }
                .accessibilityIdentifier("centeredDialogCancelButton")
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.2), radius: 30, x: 0, y: 12)
    }
}

#Preview {
    Color.gray.opacity(0.15)
        .ignoresSafeArea()
        .centeredConfirmationDialog(
            isPresented: .constant(true),
            title: "Sifariş ləğv edilsin?",
            message: "Bu sifarişi ləğv etmək istədiyinizə əminsiniz?",
            confirmTitle: "Sifarişi ləğv et",
            cancelTitle: "Ləğv et",
            onConfirm: {}
        )
}
