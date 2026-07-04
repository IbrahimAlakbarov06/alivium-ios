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
            sleep(1) // let the sheet's dismiss animation finish before the next tap
        }

        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        tabBar.buttons["Profil"].tap()

        let logOutRow = app.buttons["Çıxış et"].firstMatch
        if !logOutRow.waitForExistence(timeout: 3) {
            // The tab tap can occasionally race the sheet's dismiss animation; retry once.
            tabBar.buttons["Profil"].tap()
        }
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
    func testProfileCurrencyRemovedAndSupportChatFlow() throws {
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

        let guestButton = app.buttons["Qonaq kimi davam edin"].firstMatch
        XCTAssertTrue(guestButton.waitForExistence(timeout: 5), "Expected Login screen with Guest option")
        guestButton.tap()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        tabBar.buttons["Profil"].tap()

        let liveChatRow = app.buttons["Canlı Dəstək"].firstMatch
        XCTAssertTrue(liveChatRow.waitForExistence(timeout: 5), "Expected Live Chat row in Support section")
        XCTAssertFalse(app.staticTexts["Valyuta"].exists, "Currency row should be removed from Preferences")
        XCTAssertFalse(app.staticTexts["Currency"].exists, "Currency row should be removed from Preferences")
        save("chat_1_profile_no_currency")

        liveChatRow.tap()
        let welcomeMessage = app.staticTexts["Hi, this is Alivium Support — how can we help you today?"].firstMatch
        XCTAssertTrue(welcomeMessage.waitForExistence(timeout: 5), "Expected the seeded support welcome message")
        save("chat_2_opened_with_seed_message")

        let messageField = app.textFields["Mesajınızı yazın..."].firstMatch
        XCTAssertTrue(messageField.waitForExistence(timeout: 5))
        messageField.tap()
        messageField.typeText("I have a question about my order")

        app.buttons["chatSendButton"].firstMatch.tap()
        let sentBubble = app.staticTexts["I have a question about my order"].firstMatch
        XCTAssertTrue(sentBubble.waitForExistence(timeout: 5), "Expected the typed message to appear as a new bubble")
        save("chat_3_message_sent")
    }

    @MainActor
    func testSearchBrowsingAndQueryFlow() throws {
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

        let guestButton = app.buttons["Qonaq kimi davam edin"].firstMatch
        XCTAssertTrue(guestButton.waitForExistence(timeout: 5), "Expected Login screen with Guest option")
        guestButton.tap()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        tabBar.buttons["Axtar"].tap()

        // Browsing state: banners + expandable subcategory list, driven by the mock category tree.
        // CategoryBanner uppercases its label ("CLOTHING"); the expandable row below uses the
        // category's real name ("Clothing") — distinct elements.
        let clothingBanner = app.buttons["CLOTHING"].firstMatch
        XCTAssertTrue(clothingBanner.waitForExistence(timeout: 5), "Expected the Clothing category banner")
        save("search_1_browsing")

        let clothingExpandRow = app.buttons["Clothing"].firstMatch
        XCTAssertTrue(clothingExpandRow.waitForExistence(timeout: 5), "Expected the expandable Clothing row")
        clothingExpandRow.tap()
        let dressesSubcategory = app.staticTexts["Dresses"].firstMatch
        XCTAssertTrue(dressesSubcategory.waitForExistence(timeout: 5), "Expected Clothing to expand into its subcategories")
        save("search_2_expanded_subcategories")

        // Search-as-you-type: a query matching a real mock product name.
        let searchField = app.textFields["Don, ayaqqabı, çanta axtarın..."].firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("Silk")

        let matchedProduct = app.staticTexts["Silk Wrap Midi Dress"].firstMatch
        XCTAssertTrue(matchedProduct.waitForExistence(timeout: 5), "Expected search results filtered by 'Silk'")
        save("search_3_query_results")

        // Clear (BaseTextField has no built-in clear button, so backspace the existing value)
        // and type a nonsense query — expect the empty-results state.
        if let existingValue = searchField.value as? String {
            searchField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: existingValue.count))
        }
        searchField.typeText("zzzznonexistentproduct")

        let noResults = app.staticTexts["Nəticə tapılmadı"].firstMatch
        XCTAssertTrue(noResults.waitForExistence(timeout: 5), "Expected the No Results Found empty state")
        save("search_4_no_results")
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
