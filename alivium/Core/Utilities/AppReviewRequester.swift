//
//  AppReviewRequester.swift
//  alivium
//

import StoreKit
import UIKit

/// Thin wrapper around `SKStoreReviewController` — a View-layer platform call (like opening a
/// URL), not business logic, so it's fine to call directly from Profile's "Rate the App" row
/// rather than routing through a ViewModel/repository.
enum AppReviewRequester {
    @MainActor
    static func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}
