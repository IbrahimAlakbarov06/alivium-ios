//
//  aliviumUITests.swift
//  aliviumUITests
//
//  Created by İbrahim Alakbarov on 01.07.26.
//

import XCTest

final class aliviumUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testHomeAndTabShellSmoke() throws {
        let app = XCUIApplication()
        app.launch()

        func save(_ name: String) {
            let attachment = XCTAttachment(screenshot: app.screenshot())
            attachment.name = name
            attachment.lifetime = .keepAlways
            add(attachment)
        }

        // Skip onboarding (Splash auto-dismisses after ~1.4s).
        let skipButton = app.buttons["Keç"].firstMatch
        _ = skipButton.waitForExistence(timeout: 5)
        if skipButton.exists { skipButton.tap() }

        // Land on Login; go Guest to reach the tab shell.
        let guestButton = app.buttons["Qonaq kimi davam edin"].firstMatch
        XCTAssertTrue(guestButton.waitForExistence(timeout: 5), "Expected Login screen with Guest option")
        save("2_login")
        guestButton.tap()

        // Home should now be showing (first tab).
        let homeWordmark = app.staticTexts["ALIVIUM"].firstMatch
        XCTAssertTrue(homeWordmark.waitForExistence(timeout: 5), "Expected Home screen after guest login")
        sleep(1) // allow mock feed's simulated load to finish rendering images/layout
        save("3_home")

        // Scroll down to exercise the rest of the feed, capturing each section.
        for step in 1...4 {
            app.swipeUp()
            sleep(1)
            save("4_home_scrolled_\(step)")
        }

        // Walk the remaining 4 tabs.
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        let tabNames = ["Axtar", "Seçilmişlər", "Səbət", "Profil"]
        for (index, name) in tabNames.enumerated() {
            let tabButton = tabBar.buttons[name]
            XCTAssertTrue(tabButton.waitForExistence(timeout: 5), "Missing tab: \(name)")
            tabButton.tap()
            sleep(1)
            save("5_tab_\(index)_\(name)")
        }

        // Back to Home tab to confirm state persists.
        tabBar.buttons["Əsas"].tap()
        sleep(1)
        save("6_back_home")
    }

    @MainActor
    func testProfileGuestAndAuthenticatedFlow() throws {
        let app = XCUIApplication()
        app.launch()

        func save(_ name: String) {
            let attachment = XCTAttachment(screenshot: app.screenshot())
            attachment.name = name
            attachment.lifetime = .keepAlways
            add(attachment)
        }

        // Skip onboarding (Splash auto-dismisses after ~1.4s).
        let skipButton = app.buttons["Keç"].firstMatch
        _ = skipButton.waitForExistence(timeout: 5)
        if skipButton.exists { skipButton.tap() }

        // --- Guest path ---
        let guestButton = app.buttons["Qonaq kimi davam edin"].firstMatch
        XCTAssertTrue(guestButton.waitForExistence(timeout: 5), "Expected Login screen with Guest option")
        guestButton.tap()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        tabBar.buttons["Profil"].tap()

        let logInOrSignUp = app.buttons["Daxil ol / Qeydiyyat"].firstMatch
        XCTAssertTrue(logInOrSignUp.waitForExistence(timeout: 5), "Expected Guest CTA on Profile header")
        save("profile_1_guest")

        // Tapping the Guest CTA should drop straight back to the Auth flow.
        logInOrSignUp.tap()
        let emailFieldAfterGuestCTA = app.textFields["E-poçt ünvanı"].firstMatch
        XCTAssertTrue(emailFieldAfterGuestCTA.waitForExistence(timeout: 5), "Expected Guest CTA to return to Login")
        save("profile_2_guest_cta_returned_to_login")

        // --- Authenticated path ---
        let emailField = app.textFields["E-poçt ünvanı"].firstMatch
        emailField.tap()
        emailField.typeText("aysel@alivium.com")

        let passwordField = app.secureTextFields["Şifrə"].firstMatch
        passwordField.tap()
        passwordField.typeText("password123")

        app.buttons["Daxil ol"].firstMatch.tap()

        // The simulator's "Save Password?" sheet can appear after a real (non-guest) login and
        // will swallow the next tap if left up.
        let notNowButton = app.sheets.buttons["Not Now"].firstMatch
        if notNowButton.waitForExistence(timeout: 3) {
            notNowButton.tap()
        }

        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        tabBar.buttons["Profil"].tap()

        let logOutRow = app.buttons["Çıxış et"].firstMatch
        XCTAssertTrue(logOutRow.waitForExistence(timeout: 5), "Expected authenticated Profile header with Log Out row")
        save("profile_3_authenticated")

        // Toggle language and confirm Profile's own strings update, matching Auth's toggle.
        // LanguageToggle's "AZ"/"EN" labels are plain Text under a gesture, not Buttons.
        app.staticTexts["EN"].firstMatch.tap()
        sleep(1)
        XCTAssertTrue(app.buttons["Log Out"].firstMatch.waitForExistence(timeout: 5), "Expected Profile strings to switch to English")
        save("profile_4_english")
        app.staticTexts["AZ"].firstMatch.tap()
        sleep(1)

        // Log Out should require confirmation, then return to the Auth flow. The dialog's own
        // destructive button shares its label with the row that triggered it, but only the
        // dialog's copy lives under `app.sheets`.
        logOutRow.tap()
        let confirmLogOut = app.sheets.buttons["Çıxış et"].firstMatch
        XCTAssertTrue(confirmLogOut.waitForExistence(timeout: 5), "Expected Log Out confirmation dialog")
        save("profile_5_logout_confirm")
        confirmLogOut.tap()

        XCTAssertTrue(emailField.waitForExistence(timeout: 5), "Expected Log Out to return to the Auth flow")
        save("profile_6_after_logout")
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
