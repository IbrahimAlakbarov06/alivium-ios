//
//  SwipeBackGestureEnabler.swift
//  alivium
//

import SwiftUI
import UIKit

/// Hiding the navigation bar via `.toolbar(.hidden, for: .navigationBar)` (used for screens with
/// a custom overlay back button, like Product Detail's gallery) also disables
/// `UINavigationController`'s own interactive edge-swipe-to-pop gesture as a side effect — a
/// known SwiftUI/UIKit quirk. This re-enables it directly on the underlying controller so the
/// swipe gesture keeps working alongside the visible back button.
private struct SwipeBackGestureEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            guard let navigationController = uiViewController.navigationController else { return }
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
            navigationController.interactivePopGestureRecognizer?.delegate = context.coordinator
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }
    }
}

extension View {
    /// Restores the native edge-swipe-to-pop gesture on screens that hide the navigation bar.
    func restoresSwipeBackGesture() -> some View {
        background(SwipeBackGestureEnabler())
    }
}
