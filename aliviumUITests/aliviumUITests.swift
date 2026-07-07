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

        // --- Cart starts empty for a fresh Guest session (no hardcoded seed data) ---
        tabBar.buttons["Səbət"].tap()
        let cartEmptyTitleGuest = app.staticTexts["Səbətiniz boşdur"].firstMatch
        XCTAssertTrue(cartEmptyTitleGuest.waitForExistence(timeout: 5), "Expected a fresh Guest session to start with an empty cart")
        save("cart_0_guest_starts_empty")

        // Add an item from Home -> Product Detail so Cart has something to exercise below.
        tabBar.buttons["Əsas"].tap()
        let silkDressCard = app.staticTexts["Silk Wrap Midi Dress"].firstMatch
        XCTAssertTrue(silkDressCard.waitForExistence(timeout: 5))
        silkDressCard.tap()
        app.buttons["M"].firstMatch.tap()
        let productDetailAddToCartButton = app.buttons["Səbətə əlavə et"].firstMatch
        XCTAssertTrue(productDetailAddToCartButton.waitForExistence(timeout: 5))
        productDetailAddToCartButton.tap()
        sleep(1)
        app.buttons["productDetailBackButton"].firstMatch.tap()

        // --- Cart now reflects the added item, with a correct tab badge ---
        tabBar.buttons["Səbət"].tap()
        let firstCartProduct = app.staticTexts["Silk Wrap Midi Dress"].firstMatch
        XCTAssertTrue(firstCartProduct.waitForExistence(timeout: 5), "Expected the item added from Product Detail to appear in Cart")
        save("cart_1_populated_with_badge")

        // Tapping the line item (not its stepper/remove controls) should still open Product
        // Detail — verifies the Cart row's own navigation independently of ProductCard's.
        firstCartProduct.tap()
        XCTAssertTrue(app.buttons["productDetailBackButton"].firstMatch.waitForExistence(timeout: 5), "Expected tapping a Cart line item to open Product Detail")
        app.buttons["productDetailBackButton"].firstMatch.tap()

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
        // seen before) — the Wishlist screen's own ScrollView identifier disambiguates that.
        tabBar.buttons["Seçilmişlər"].tap()
        let wishlistScrollView = app.scrollViews.matching(identifier: "wishlistScrollView").firstMatch
        let wishlistedProduct = app.staticTexts["Structured Leather Tote"].firstMatch
        // The mock repository has its own ~0.6s artificial load delay, so an immediate miss
        // doesn't necessarily mean the tab tap didn't land — wait properly before concluding
        // that and retrying the tap (the actual race seen before).
        XCTAssertTrue(wishlistedProduct.waitForExistence(timeout: 5), "Expected seeded wishlist products once authenticated")
        if !wishlistScrollView.exists {
            tabBar.buttons["Seçilmişlər"].tap() // guard against the same tab-tap/dialog race seen before
            sleep(1)
        }
        XCTAssertTrue(wishlistScrollView.exists, "Expected the Wishlist screen's own list to be showing")
        save("wishlist_2_authenticated_loaded")

        // Tapping the row (not its heart/Add to Cart controls) should open Product Detail.
        wishlistedProduct.tap()
        XCTAssertTrue(app.buttons["productDetailBackButton"].firstMatch.waitForExistence(timeout: 5), "Expected tapping a Wishlist row to open Product Detail")
        app.buttons["productDetailBackButton"].firstMatch.tap()
        save("wishlist_3_row_opens_product_detail")

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
    func testWishlistInlineSizeDropdown() throws {
        let app = XCUIApplication()
        app.launch()

        func save(_ name: String) {
            let attachment = XCTAttachment(screenshot: app.screenshot())
            attachment.name = name
            attachment.lifetime = .keepAlways
            add(attachment)
        }

        // Skip onboarding, then sign in directly (Login's own fields, no need to go via Guest).
        let skipButton = app.buttons["Keç"].firstMatch
        _ = skipButton.waitForExistence(timeout: 5)
        if skipButton.exists { skipButton.tap() }

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

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        let wishlistTabButton = tabBar.buttons["Seçilmişlər"]
        wishlistTabButton.tap()
        sleep(1)
        // The very first tap right after the post-login transition is occasionally swallowed
        // (the tab bar button still reports as existing but never becomes selected) — one retry
        // tap reliably lands once the transition has settled.
        if !wishlistTabButton.isSelected {
            wishlistTabButton.tap()
            sleep(1)
        }

        // Scoped to Wishlist's own scroll view (not just `app`) — TabView keeps every tab's view
        // mounted, and "Silk Wrap Midi Dress" (p-1) also appears in Home's off-screen Featured
        // Products rail, so an unscoped query can match that copy instead while Wishlist's own
        // (slower, repository-backed) row is still loading.
        let wishlistScroll = app.scrollViews["wishlistScrollView"]

        // "Silk Wrap Midi Dress" (p-1) is seeded with 2 colors x S/M/L, so it's a genuine
        // multi-size row — the dropdown should appear and gate Add to Cart. (Bags/accessories are
        // single-variant in real boutiques and no longer exercise this dropdown at all — see
        // MockProductRepository's `singleVariant`.)
        let dressName = wishlistScroll.staticTexts["Silk Wrap Midi Dress"].firstMatch
        XCTAssertTrue(dressName.waitForExistence(timeout: 5), "Expected seeded wishlist products once authenticated")

        // The whole row is one NavigationLink-wrapped Button (see `WishlistRow`'s own comment on
        // why), so SwiftUI exposes it as a single accessibility container whose label carries the
        // product name — scope through it rather than correlating rows by frame position, since
        // the size dropdown and Add to Cart button have different heights and are never exactly
        // vertically centered to the same point once SwiftUI lays them out.
        let dressRow = wishlistScroll.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Silk Wrap Midi Dress")).firstMatch
        XCTAssertTrue(dressRow.waitForExistence(timeout: 5), "Expected the Silk Wrap Midi Dress row as a single row container")

        let sizeMenu = dressRow.buttons["wishlistRowSizeMenu-p-1"].firstMatch
        XCTAssertTrue(sizeMenu.waitForExistence(timeout: 5), "Expected an inline size dropdown next to Add to Cart for a multi-size product")
        XCTAssertTrue(sizeMenu.label.contains("Ölçü"), "Expected the dropdown's placeholder label before a size is picked")

        let dressAddToCartButton = dressRow.buttons["Səbətə əlavə et"].firstMatch
        XCTAssertTrue(dressAddToCartButton.waitForExistence(timeout: 5), "Expected an Add to Cart button in the same row as the size dropdown")
        XCTAssertFalse(dressAddToCartButton.isEnabled, "Expected Add to Cart disabled before a size is picked")
        save("wishlist_size_dropdown_1_before_selection")

        // Tapping the dropdown reveals the size options inline (a Menu, not a full-screen sheet).
        sizeMenu.tap()
        let mSizeOption = app.buttons["M"].firstMatch
        XCTAssertTrue(mSizeOption.waitForExistence(timeout: 5), "Expected the Menu to reveal size options")
        mSizeOption.tap()

        XCTAssertTrue(sizeMenu.label.contains("M"), "Expected the dropdown's label to update to the picked size")
        XCTAssertTrue(dressAddToCartButton.isEnabled, "Expected Add to Cart enabled once a size is picked")
        save("wishlist_size_dropdown_2_size_selected")

        dressAddToCartButton.tap()
        sleep(1)
        save("wishlist_size_dropdown_3_added_to_cart")
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

        // This product has two colors, but color is descriptive metadata, not a required
        // choice — only picking a size should already enable the button.
        app.buttons["M"].firstMatch.tap()
        XCTAssertTrue(addToCartButton.isEnabled, "Expected Add to Cart enabled once only size is selected — color stays optional")
        save("product_detail_2a_size_only_selected")

        app.buttons["Ivory"].firstMatch.tap()
        XCTAssertTrue(addToCartButton.isEnabled, "Expected Add to Cart to remain enabled after also picking a color")
        save("product_detail_2_variant_selected")

        addToCartButton.tap()
        let addedConfirmation = app.buttons["Səbətə əlavə edildi"].firstMatch
        XCTAssertTrue(addedConfirmation.waitForExistence(timeout: 5), "Expected the button to confirm the item was added")
        save("product_detail_3_added_to_cart")

        // --- Wishlist heart toggle from within Product Detail: Guest sees a sign-in prompt,
        // not a silent toggle ---
        let wishlistHeart = app.buttons["productDetailWishlistHeart"].firstMatch
        wishlistHeart.tap()
        let guestWishlistAlertTitle = app.staticTexts["Sevimlilərinizi saxlamaq üçün daxil olun"].firstMatch
        XCTAssertTrue(guestWishlistAlertTitle.waitForExistence(timeout: 5), "Expected a Guest tapping the heart to see a sign-in prompt instead of toggling the wishlist")
        save("product_detail_3b_guest_wishlist_alert")
        app.alerts.buttons["Ləğv et"].firstMatch.tap()

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
            // Every Product Detail's back button shares the same accessibility identifier, so a
            // second tap fired the instant the first pop's transition finishes (rather than once
            // the view hierarchy has actually settled) can land on this same identifier mid-
            // animation and pop twice. Give the transition a beat before tapping again.
            sleep(1)
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
    func testTapImageAreaNavigatesToDetail() throws {
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
        XCTAssertTrue(guestButton.waitForExistence(timeout: 5))
        guestButton.tap()

        let homeWordmark = app.staticTexts["ALIVIUM"].firstMatch
        XCTAssertTrue(homeWordmark.waitForExistence(timeout: 5))
        sleep(1)
        app.swipeUp()
        sleep(1)

        // `CatalogImage` used to swallow touches (SwiftUI's default hit-testing lets a plain
        // `Image` intercept taps that would otherwise reach a background NavigationLink, unlike
        // `Text`), so only the product name — never the photo above it — actually navigated.
        // Tap squarely inside the image region, well clear of the wishlist heart's own corner.
        let silkDressText = app.staticTexts["Silk Wrap Midi Dress"].firstMatch
        XCTAssertTrue(silkDressText.waitForExistence(timeout: 5))
        save("tap_image_1_home")

        let coordinate = silkDressText.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.0))
            .withOffset(CGVector(dx: 0, dy: -70))
        coordinate.tap()

        let addToCartButton = app.buttons["Səbətə əlavə et"].firstMatch
        XCTAssertTrue(addToCartButton.waitForExistence(timeout: 5), "Expected tapping the product image (not just its name) to open Product Detail")
        save("tap_image_2_product_detail_opened")
    }

    @MainActor
    func testCategoryListingAndSearchProductNavigation() throws {
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
        XCTAssertTrue(guestButton.waitForExistence(timeout: 5))
        guestButton.tap()

        let homeWordmark = app.staticTexts["ALIVIUM"].firstMatch
        XCTAssertTrue(homeWordmark.waitForExistence(timeout: 5))
        sleep(1)

        // --- Home "Show all" -> Category/Product Listing -> Product Detail ---
        let showAllButton = app.buttons["Hamısına bax"].firstMatch
        XCTAssertTrue(showAllButton.waitForExistence(timeout: 5), "Expected a Show all action on Home's Featured Products rail")
        showAllButton.tap()
        sleep(1)
        save("listing_1_opened")

        let listingProduct = app.staticTexts["Silk Wrap Midi Dress"].firstMatch
        XCTAssertTrue(listingProduct.waitForExistence(timeout: 5), "Expected Featured Products in the listing grid")
        listingProduct.tap()

        let productDetailBack = app.buttons["productDetailBackButton"].firstMatch
        XCTAssertTrue(productDetailBack.waitForExistence(timeout: 5), "Expected tapping a product in Category/Product Listing to open Product Detail on the first tap")
        save("listing_2_product_detail_opened")
        productDetailBack.tap()

        // --- Search results -> Product Detail, repeated across several distinct products to
        // rule out flakiness rather than a one-off race ---
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        tabBar.buttons["Axtar"].tap()

        let searchField = app.textFields["Don, ayaqqabı, çanta axtarın..."].firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))

        let queries: [(String, String)] = [
            ("Tailored", "Tailored Wool Coat"),
            ("Cashmere", "Cashmere Blend Sweater"),
            ("Structured", "Structured Leather Tote"),
            ("Suede", "Suede Ankle Boots")
        ]

        for (index, entry) in queries.enumerated() {
            let (query, productName) = entry
            searchField.tap()
            searchField.typeText(query)

            let result = app.staticTexts[productName].firstMatch
            XCTAssertTrue(result.waitForExistence(timeout: 5), "Expected a search result for '\(query)'")
            result.tap()

            XCTAssertTrue(
                productDetailBack.waitForExistence(timeout: 5),
                "Expected tapping the '\(productName)' search result to open Product Detail on the first tap (attempt \(index + 1))"
            )
            save("search_nav_\(index)_\(productName)")
            productDetailBack.tap()

            // Back on Search results — clear the field before the next query.
            XCTAssertTrue(searchField.waitForExistence(timeout: 5))
            if let existingValue = searchField.value as? String {
                searchField.tap()
                searchField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: existingValue.count))
            }
        }
    }

    @MainActor
    func testShoeAndAccessoryVariantsAreRealistic() throws {
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
        XCTAssertTrue(guestButton.waitForExistence(timeout: 5))
        guestButton.tap()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        tabBar.buttons["Axtar"].tap()

        let searchField = app.textFields["Don, ayaqqabı, çanta axtarın..."].firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))

        // --- Shoes: numeric EU sizes, not S/M/L ---
        searchField.tap()
        searchField.typeText("Suede")
        let bootsResult = app.staticTexts["Suede Ankle Boots"].firstMatch
        XCTAssertTrue(bootsResult.waitForExistence(timeout: 5))
        bootsResult.tap()

        XCTAssertTrue(app.buttons["productDetailBackButton"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Ölçü seçin"].firstMatch.waitForExistence(timeout: 5), "Expected a size section for a multi-size shoe")
        XCTAssertTrue(app.buttons["38"].firstMatch.exists, "Expected a numeric EU shoe size chip")
        XCTAssertFalse(app.buttons["M"].exists, "Expected shoes to use numeric sizes, not clothing S/M/L")
        save("variants_1_shoe_numeric_sizes")
        app.buttons["productDetailBackButton"].firstMatch.tap()

        // --- Bags: single variant, no size picker at all ---
        if let existingValue = searchField.value as? String {
            searchField.tap()
            searchField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: existingValue.count))
        }
        searchField.tap()
        searchField.typeText("Structured")
        let toteResult = app.staticTexts["Structured Leather Tote"].firstMatch
        XCTAssertTrue(toteResult.waitForExistence(timeout: 5))
        toteResult.tap()

        XCTAssertTrue(app.buttons["productDetailBackButton"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Ölçü seçin"].exists, "Expected no size picker for a single-variant bag")
        save("variants_2_bag_no_size_picker")
        app.buttons["productDetailBackButton"].firstMatch.tap()

        // --- Accessories: single variant, no size picker at all ---
        if let existingValue = searchField.value as? String {
            searchField.tap()
            searchField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: existingValue.count))
        }
        searchField.tap()
        searchField.typeText("Felt Hat")
        let hatResult = app.staticTexts["Wide Brim Felt Hat"].firstMatch
        XCTAssertTrue(hatResult.waitForExistence(timeout: 5))
        hatResult.tap()

        XCTAssertTrue(app.buttons["productDetailBackButton"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Ölçü seçin"].exists, "Expected no size picker for a single-variant accessory")
        save("variants_3_accessory_no_size_picker")
    }

    @MainActor
    func testFavoritingOnHomeAppearsInWishlist() throws {
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

        // Sign in for real — Wishlist needs a session to persist against.
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

        let homeWordmark = app.staticTexts["ALIVIUM"].firstMatch
        XCTAssertTrue(homeWordmark.waitForExistence(timeout: 5))
        sleep(1)

        // --- Visit Wishlist FIRST so its ViewModel caches a loaded state — this is the exact
        // scenario that exposed the bug: favoriting something afterwards, on another tab, never
        // showed up until a cold relaunch because the cached state never refreshed on revisit. ---
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        tabBar.buttons["Seçilmişlər"].tap()
        let wishlistScroll = app.scrollViews["wishlistScrollView"]
        XCTAssertTrue(wishlistScroll.waitForExistence(timeout: 5))
        // "Cashmere Blend Sweater" (p-3) is NOT part of the seeded wishlist — confirms it's
        // genuinely absent before the favorite, not just slow to load.
        XCTAssertFalse(wishlistScroll.staticTexts["Cashmere Blend Sweater"].firstMatch.exists, "Expected p-3 to not be wishlisted yet")
        save("wishlist_sync_1_before_favoriting")

        tabBar.buttons["Əsas"].tap()
        XCTAssertTrue(homeWordmark.waitForExistence(timeout: 5))
        sleep(1)

        // Favorite "Cashmere Blend Sweater" from Home's Featured rail via its card's heart button.
        // `ProductCard`'s heart has no per-product identifier on a rail (unlike WishlistRow's
        // "wishlistRowHeart-<id>"), so every card's heart shares the same "wishlistHeartOutline"
        // identifier/label — index into the match list instead (empirically confirmed to land on
        // the Featured rail's 3rd card, Cashmere Blend Sweater, rather than assuming DOM order
        // maps 1:1 onto `MockProductRepository.featuredProducts`).
        let sweaterHeart = app.buttons.matching(identifier: "wishlistHeartOutline").element(boundBy: 1)
        XCTAssertTrue(sweaterHeart.waitForExistence(timeout: 5), "Expected a product card heart button on Home")
        sweaterHeart.tap()
        sleep(1)
        save("wishlist_sync_2_favorited_on_home")

        // --- Back to Wishlist: the newly favorited product must now show up ---
        tabBar.buttons["Seçilmişlər"].tap()
        let sweaterInWishlist = wishlistScroll.staticTexts["Cashmere Blend Sweater"].firstMatch
        XCTAssertTrue(sweaterInWishlist.waitForExistence(timeout: 5), "Expected favoriting on Home to be reflected in Wishlist without a relaunch")
        save("wishlist_sync_3_appears_in_wishlist")
    }

    @MainActor
    func testSearchFilterNarrowsResultsByPrice() throws {
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
        XCTAssertTrue(guestButton.waitForExistence(timeout: 5))
        guestButton.tap()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        tabBar.buttons["Axtar"].tap()

        // "o" matches products spanning several categories/prices (Tailored Wool Coat $349,
        // Structured Leather Tote $259, Suede Ankle Boots $219, Gold-Tone Hoop Earrings $59, ...).
        let searchField = app.textFields["Don, ayaqqabı, çanta axtarın..."].firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("o")

        let expensiveCoat = app.staticTexts["Tailored Wool Coat"].firstMatch
        XCTAssertTrue(expensiveCoat.waitForExistence(timeout: 5), "Expected the unfiltered result set to include the $349 coat")
        save("search_filter_1_unfiltered_results")

        let filterButton = app.buttons["searchFilterButton"].firstMatch
        XCTAssertTrue(filterButton.waitForExistence(timeout: 5))
        filterButton.tap()

        let filterSheetTitle = app.staticTexts["Filtrlər"].firstMatch
        XCTAssertTrue(filterSheetTitle.waitForExistence(timeout: 5), "Expected the filter sheet to open")
        save("search_filter_2_sheet_opened")

        // Drag the max-price slider down near the lower bound — low enough that the $349 coat
        // can no longer pass the filter regardless of exactly where the slider lands.
        let sliders = app.sliders
        XCTAssertEqual(sliders.count, 2, "Expected a min and a max price slider")
        let maxPriceSlider = sliders.element(boundBy: 1)
        maxPriceSlider.adjust(toNormalizedSliderPosition: 0.1)

        app.buttons["Tətbiq et"].firstMatch.tap()
        save("search_filter_3_applied_low_max_price")

        XCTAssertFalse(expensiveCoat.exists, "Expected the $349 coat to be filtered out by a low max price")

        // Reset should restore the full unfiltered result set. Reset alone doesn't dismiss the
        // sheet (only Apply does) — it just clears the criteria for another look before closing.
        filterButton.tap()
        XCTAssertTrue(app.staticTexts["Filtrlər"].firstMatch.waitForExistence(timeout: 5))
        app.buttons["Sıfırla"].firstMatch.tap()
        app.buttons["Tətbiq et"].firstMatch.tap()
        XCTAssertTrue(expensiveCoat.waitForExistence(timeout: 5), "Expected Reset to restore the full result set")
        save("search_filter_4_reset")
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
