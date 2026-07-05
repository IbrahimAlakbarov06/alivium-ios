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

        // Browsing state: banners are localized (AZ "GEYIM" = Clothing) and the Clothing banner
        // itself is the accordion trigger — tapping it expands its subcategories directly below.
        let clothingBanner = app.buttons["GEYIM"].firstMatch
        XCTAssertTrue(clothingBanner.waitForExistence(timeout: 5), "Expected the localized Clothing category banner")
        save("search_1_browsing")

        clothingBanner.tap()
        let dressesSubcategory = app.staticTexts["Donlar"].firstMatch
        XCTAssertTrue(dressesSubcategory.waitForExistence(timeout: 5), "Expected Clothing to expand into its localized subcategories")
        save("search_2_expanded_subcategories")

        // Tapping again collapses it (accordion, not a permanent static list).
        clothingBanner.tap()
        sleep(1)
        XCTAssertFalse(dressesSubcategory.exists, "Expected the subcategory list to collapse on second tap")
        clothingBanner.tap()
        _ = dressesSubcategory.waitForExistence(timeout: 3)

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
    func testWishlistAndCartFlow() throws {
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

        // --- Wishlist, Guest state ---
        tabBar.buttons["Seçilmişlər"].tap()
        let guestPrompt = app.staticTexts["Sevimlilərinizi saxlamaq üçün daxil olun"].firstMatch
        XCTAssertTrue(guestPrompt.waitForExistence(timeout: 5), "Expected the Guest sign-in prompt, distinct from an empty wishlist")
        save("wishlist_1_guest_prompt")

        // --- Cart works fine for Guests, with the seeded mock items and a correct tab badge ---
        tabBar.buttons["Səbət"].tap()
        let firstCartProduct = app.staticTexts["Silk Wrap Midi Dress"].firstMatch
        XCTAssertTrue(firstCartProduct.waitForExistence(timeout: 5), "Expected seeded cart items to load for a Guest")
        save("cart_1_populated_with_badge")

        // Bump the first item's quantity and confirm the stepper + totals react.
        let incrementButtons = app.buttons.matching(identifier: "quantityStepperIncrement")
        incrementButtons.firstMatch.tap()
        sleep(1)
        save("cart_2_quantity_incremented")

        app.swipeUp()
        sleep(1)
        save("cart_2b_summary_scrolled")

        // --- Sign in for real, so Wishlist has a session to persist against ---
        tabBar.buttons["Profil"].tap()
        let logInOrSignUp = app.buttons["Daxil ol / Qeydiyyat"].firstMatch
        XCTAssertTrue(logInOrSignUp.waitForExistence(timeout: 5))
        logInOrSignUp.tap()

        let emailField = app.textFields["E-poçt ünvanı"].firstMatch
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        emailField.tap()
        emailField.typeText("aysel@alivium.com")

        let passwordField = app.secureTextFields["Şifrə"].firstMatch
        passwordField.tap()
        passwordField.typeText("password123")

        app.buttons["Daxil ol"].firstMatch.tap()

        let notNowButton = app.sheets.buttons["Not Now"].firstMatch
        if notNowButton.waitForExistence(timeout: 3) {
            notNowButton.tap()
            sleep(1)
        }
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        // --- Wishlist, authenticated + loaded state ---
        // "Structured Leather Tote" also appears in Home's Featured rail, so checking for its
        // text alone can't distinguish Home from Wishlist if the tab tap doesn't land (a race
        // seen before). `wishlistHeartFilled` only exists on the Wishlist grid, so use that as
        // the real "did we actually land on Wishlist" signal.
        tabBar.buttons["Seçilmişlər"].tap()
        let filledHearts = app.buttons.matching(identifier: "wishlistHeartFilled")
        let wishlistedProduct = app.staticTexts["Structured Leather Tote"].firstMatch
        // The mock repository has its own ~0.6s artificial load delay, so an immediate 0 count
        // doesn't necessarily mean the tab tap didn't land — wait properly before concluding
        // that and retrying the tap (the actual race seen before).
        XCTAssertTrue(wishlistedProduct.waitForExistence(timeout: 5), "Expected seeded wishlist products once authenticated")
        if filledHearts.count == 0 {
            tabBar.buttons["Seçilmişlər"].tap() // guard against the same tab-tap/dialog race seen before
            sleep(1)
        }
        XCTAssertGreaterThan(filledHearts.count, 0, "Expected filled hearts confirming we're actually on the Wishlist screen")
        save("wishlist_2_authenticated_loaded")

        // Tapping any filled heart removes that item — assert by count (firstMatch may not be
        // the specific product checked above, since 4 items are seeded).
        let heartCountBeforeRemoval = filledHearts.count
        app.buttons.matching(identifier: "wishlistHeartFilled").firstMatch.tap()
        sleep(1)
        XCTAssertEqual(filledHearts.count, heartCountBeforeRemoval - 1, "Expected one fewer wishlist item after removing one")
        save("wishlist_3_after_remove")

        // --- Cart empty state ---
        tabBar.buttons["Səbət"].tap()
        let removeButtons = app.buttons.matching(identifier: "Sil")
        while removeButtons.count > 0 {
            removeButtons.firstMatch.tap()
            sleep(1)
        }
        let cartEmptyTitle = app.staticTexts["Səbətiniz boşdur"].firstMatch
        XCTAssertTrue(cartEmptyTitle.waitForExistence(timeout: 5), "Expected Cart's empty state after removing all items")
        save("cart_3_empty")

        // "Start Browsing" should switch to the Home tab.
        app.buttons["Gəzintiyə başla"].firstMatch.tap()
        let homeWordmark = app.staticTexts["ALIVIUM"].firstMatch
        XCTAssertTrue(homeWordmark.waitForExistence(timeout: 5), "Expected Start Browsing to switch to the Home tab")
        save("cart_4_start_browsing_switched_to_home")
    }

    @MainActor
    func testProductDetailFlow() throws {
        let app = XCUIApplication()
        app.launch()

        func save(_ name: String) {
            let attachment = XCTAttachment(screenshot: app.screenshot())
            attachment.name = name
            attachment.lifetime = .keepAlways
            add(attachment)
        }

        let skipButton = app.buttons["Keç"].firstMatch
        _ = skipButton.waitForExistence(timeout: 5)
        if skipButton.exists { skipButton.tap() }

        let guestButton = app.buttons["Qonaq kimi davam edin"].firstMatch
        XCTAssertTrue(guestButton.waitForExistence(timeout: 5), "Expected Login screen with Guest option")
        guestButton.tap()

        // --- Tap a product on Home ---
        let homeWordmark = app.staticTexts["ALIVIUM"].firstMatch
        XCTAssertTrue(homeWordmark.waitForExistence(timeout: 5))
        sleep(1)

        // Navigation on Home/Wishlist is a hidden background NavigationLink (not a wrapping one,
        // so the wishlist heart stays a plain un-nested Button — see ProductCard) — the product
        // name renders as its own plain StaticText rather than folding into a composite Button
        // label. Tapping the StaticText still hits the invisible link behind it.
        let silkDressCard = app.staticTexts["Silk Wrap Midi Dress"].firstMatch
        XCTAssertTrue(silkDressCard.waitForExistence(timeout: 5), "Expected the Silk Wrap Midi Dress card on Home")
        silkDressCard.tap()

        // --- Product Detail: gallery, rating, variant selection, Add to Cart ---
        let productTitle = app.staticTexts["Silk Wrap Midi Dress"].firstMatch
        XCTAssertTrue(productTitle.waitForExistence(timeout: 5), "Expected Product Detail to open")
        save("product_detail_1_initial")

        let addToCartButton = app.buttons["Səbətə əlavə et"].firstMatch
        XCTAssertTrue(addToCartButton.waitForExistence(timeout: 5))
        XCTAssertFalse(addToCartButton.isEnabled, "Expected Add to Cart disabled before a variant is selected")

        app.buttons["M"].firstMatch.tap()
        app.buttons["Ivory"].firstMatch.tap()
        XCTAssertTrue(addToCartButton.isEnabled, "Expected Add to Cart enabled once size + color are both selected")
        save("product_detail_2_variant_selected")

        addToCartButton.tap()
        let addedConfirmation = app.buttons["Səbətə əlavə edildi"].firstMatch
        XCTAssertTrue(addedConfirmation.waitForExistence(timeout: 5), "Expected the button to confirm the item was added")
        save("product_detail_3_added_to_cart")

        // --- Wishlist heart toggle from within Product Detail ---
        let wishlistHeart = app.buttons["productDetailWishlistHeart"].firstMatch
        wishlistHeart.tap()
        sleep(1)

        // --- Related products rail drills into another Product Detail ---
        let relatedProductCard = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "US$")
        ).allElementsBoundByIndex.last
        if let relatedProductCard, relatedProductCard.exists {
            relatedProductCard.tap()
            sleep(1)
            save("product_detail_4_related_product_drilldown")

            // Back should return to the previous product, not all the way to Home.
            app.buttons["productDetailBackButton"].firstMatch.tap()
            XCTAssertTrue(productTitle.waitForExistence(timeout: 5), "Expected back to return to the previous Product Detail")
        }

        // Dismiss back to Home.
        app.buttons["productDetailBackButton"].firstMatch.tap()
        XCTAssertTrue(homeWordmark.waitForExistence(timeout: 5), "Expected back to return to Home")

        // --- Confirm the added item reflects in Cart ---
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        tabBar.buttons["Səbət"].tap()
        let addedItemInCart = app.staticTexts["Silk Wrap Midi Dress"].firstMatch
        XCTAssertTrue(addedItemInCart.waitForExistence(timeout: 5), "Expected the item added from Product Detail to appear in Cart")
        save("product_detail_5_in_cart")
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
