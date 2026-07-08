//
//  aliviumApp.swift
//  alivium
//
//  Created by İbrahim Alakbarov on 01.07.26.
//

import SwiftUI

@main
struct aliviumApp: App {
    init() {
        // UI-test-only seam: onboarding only shows once (gated by `hasCompletedOnboarding` in
        // UserDefaults), so a test that needs to walk it for real has to force first-launch
        // state back on rather than relying on whatever the simulator happened to persist.
        if ProcessInfo.processInfo.arguments.contains("--uitest-reset-onboarding") {
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
