//
//  LocalizedKey.swift
//  alivium
//

import Foundation

/// Every user-facing string in the app, resolved per `AppLanguage`. Enum-driven like
/// `BaseButton`'s style enum — one centralized catalog instead of strings scattered across
/// views, so every screen stays in sync and nothing gets translated inconsistently or missed.
enum LocalizedKey: Hashable {
    // MARK: - Onboarding
    case skip
    case next
    case getStarted
    case onboardingPage1Kicker
    case onboardingPage1Title
    case onboardingPage1Subtitle
    case onboardingPage2Kicker
    case onboardingPage2Title
    case onboardingPage2Subtitle
    case onboardingPage3Kicker
    case onboardingPage3Title
    case onboardingPage3Subtitle

    // MARK: - Auth shared (Login + Register)
    case emailAddress
    case password
    case orContinueWith
    case continueWithGoogle
    case continueWithApple
    case continueAsGuest
    case logIn

    // MARK: - Login
    case welcomeBack
    case forgotPassword
    case dontHaveAccount
    case signUp

    // MARK: - Register
    case createYourAccount
    case fullName
    case confirmPassword
    case termsAgreement
    case terms
    case termsAnd
    case privacyPolicy
    case termsAgreementOutro
    case createAccount
    case alreadyHaveAccount

    // MARK: - Forgot Password
    case back
    case resetYourPassword
    case resetPasswordSubtitle
    case sendResetLink
    case backToLogIn

    // MARK: - Verification Code
    case verifyYourEmail
    case enterResetCode
    case verifyEmailSubtitle
    case resetCodeSubtitle
    case verify
    case didntReceiveCode
    case resend

    // MARK: - Create New Password
    case setNewPassword
    case setNewPasswordSubtitle
    case newPassword
    case savePassword
    case passwordsDontMatch

    // MARK: - Home
    case featuredProducts
    case recommended
    case topCollections
    case showAll
    case somethingWentWrong
    case tryAgain
    case comingSoon

    // MARK: - Tab bar
    case homeTab
    case searchTab
    case wishlistTab
    case cartTab
    case profileTab

    // MARK: - Search / Discover
    case discoverTitle
    case searchPlaceholder
    case noResultsFound
    case items

    // MARK: - Search filters
    case filtersTitle
    case priceRangeLabel
    case minPriceLabel
    case maxPriceLabel
    case categoryFilterLabel
    case allCategories
    case resetFilters

    // MARK: - Category names (mock data's stable ids -> display names)
    case categoryNewIn
    case categoryClothing
    case categoryDresses
    case categorySkirts
    case categoryJackets
    case categorySweaters
    case categoryJeans
    case categoryTShirts
    case categoryPants
    case categoryShoes
    case categoryBags
    case categoryAccessories
    case categorySale

    // MARK: - Category / Product Listing
    case sortLabel
    case sortFeatured
    case sortPriceLowToHigh
    case sortPriceHighToLow
    case sortTopRated
    case onSaleFilter
    case categoryEmptyTitle
    case categoryEmptySubtitle
    case noProductsMatchFilters

    // MARK: - Wishlist
    case wishlistEmptyTitle
    case wishlistEmptySubtitle
    case wishlistGuestTitle
    case wishlistGuestSubtitle
    case startBrowsing
    case wishlistSavedCountSuffix
    /// Compact placeholder for the inline size dropdown on a Wishlist row — distinct from
    /// `.selectSize`'s full "Select Size" phrase, which reads as too long next to "Add to Cart".
    case sizePlaceholder

    // MARK: - Cart
    case cartEmptyTitle
    case cartEmptySubtitle
    case subtotal
    case havePromoCode
    case voucherCodePlaceholder
    case apply
    case voucherApplied
    case shippingSectionTitle
    case shippingFree
    case shippingStandard
    case shippingFast
    case shippingDaysSuffix
    case total
    case proceedToCheckout
    case removeItem

    // MARK: - Product Detail
    case selectSize
    case selectColor
    case addToCart
    case addedToCart
    case descriptionSectionTitle
    case reviewsSectionTitle
    case reviewsCountSuffix
    case youMightAlsoLike

    // MARK: - Profile
    case guestLabel
    case logInOrSignUp
    case editProfile
    case accountSection
    case orderHistory
    case addresses
    case paymentMethods
    case preferencesSection
    case language
    case notifications
    case supportSection
    case liveChat
    case supportChatTitle
    case chatInputPlaceholder
    case helpCenter
    case contactUs
    case rateTheApp
    case termsAndPrivacyPolicy
    case logOut
    case logOutConfirmTitle
    case logOutConfirmMessage
    case deleteAccount
    case deleteAccountConfirmTitle
    case deleteAccountConfirmMessage
    case cancel

    // MARK: - Notifications
    case notificationsEmptyTitle
    case notificationsEmptySubtitle
    case markAllAsRead
    case justNow
    case minutesAgoSuffix
    case hoursAgoSuffix
    case daysAgoSuffix
    case yesterday

    func value(for language: AppLanguage) -> String {
        switch self {
        // MARK: Onboarding
        case .skip:
            return language == .az ? "Keç" : "Skip"
        case .next:
            return language == .az ? "Növbəti" : "Next"
        case .getStarted:
            return language == .az ? "Başlayaq" : "Get Started"
        case .onboardingPage1Kicker:
            return language == .az ? "SEÇİLMİŞ KOLLEKSİYA" : "CURATED SELECTION"
        case .onboardingPage1Title:
            return language == .az ? "Seçilmiş Moda,\nÇatdırılır" : "Curated Fashion,\nDelivered"
        case .onboardingPage1Subtitle:
            return language == .az
                ? "Hər mövsüm əl ilə seçilmiş qadın geyimlərinin butik kolleksiyası."
                : "A boutique edit of women's fashion, hand-picked each season."
        case .onboardingPage2Kicker:
            return language == .az ? "FƏRDİ TƏRZ" : "SIGNATURE STYLE"
        case .onboardingPage2Title:
            return language == .az ? "Öz Unikal\nTərzini Kəşf Et" : "Discover Your\nSignature Style"
        case .onboardingPage2Subtitle:
            return language == .az
                ? "Hər parça bir hekayə danışır — sənin hekayəni danışanı tap."
                : "Every piece tells a story — find the ones that tell yours."
        case .onboardingPage3Kicker:
            return language == .az ? "QÜSURSUZ ÇATDIRILMA" : "SEAMLESS DELIVERY"
        case .onboardingPage3Title:
            return language == .az ? "Hər Sifarişi\nZərif Şəkildə İzlə" : "Track Every Order,\nBeautifully"
        case .onboardingPage3Subtitle:
            return language == .az
                ? "Ödənişdən qapınıza qədər, məhsullarınızın harada olduğunu həmişə bilin."
                : "From checkout to your doorstep, always know where your pieces are."

        // MARK: Auth shared
        case .emailAddress:
            return language == .az ? "E-poçt ünvanı" : "Email Address"
        case .password:
            return language == .az ? "Şifrə" : "Password"
        case .orContinueWith:
            return language == .az ? "və ya davam edin" : "or continue with"
        case .continueWithGoogle:
            return language == .az ? "Google ilə davam edin" : "Continue with Google"
        case .continueWithApple:
            return language == .az ? "Apple ilə davam edin" : "Continue with Apple"
        case .continueAsGuest:
            return language == .az ? "Qonaq kimi davam edin" : "Continue as Guest"
        case .logIn:
            return language == .az ? "Daxil ol" : "Log In"

        // MARK: Login
        case .welcomeBack:
            return language == .az ? "Xoş gəlmisiniz" : "Welcome Back"
        case .forgotPassword:
            return language == .az ? "Şifrəni unutmusunuz?" : "Forgot Password?"
        case .dontHaveAccount:
            return language == .az ? "Hesabınız yoxdur?" : "Don't have an account?"
        case .signUp:
            return language == .az ? "Qeydiyyat" : "Sign Up"

        // MARK: Register
        case .createYourAccount:
            return language == .az ? "Hesabınızı yaradın" : "Create Your Account"
        case .fullName:
            return language == .az ? "Ad Soyad" : "Full Name"
        case .confirmPassword:
            return language == .az ? "Şifrəni təsdiqləyin" : "Confirm Password"
        case .termsAgreement:
            return language == .az ? "Davam etməklə" : "By continuing, you agree to our"
        case .terms:
            return language == .az ? "Şərtlərimizi" : "Terms"
        case .termsAnd:
            return language == .az ? "və" : "and"
        case .privacyPolicy:
            return language == .az ? "Məxfilik Siyasətimizi" : "Privacy Policy"
        case .termsAgreementOutro:
            return language == .az ? "qəbul edirsiniz." : ""
        case .createAccount:
            return language == .az ? "Hesab yarat" : "Create Account"
        case .alreadyHaveAccount:
            return language == .az ? "Artıq hesabınız var?" : "Already have an account?"

        // MARK: Forgot Password
        case .back:
            return language == .az ? "Geri" : "Back"
        case .resetYourPassword:
            return language == .az ? "Şifrənizi yeniləyin" : "Reset Your Password"
        case .resetPasswordSubtitle:
            return language == .az
                ? "E-poçtunuzu daxil edin, şifrənizi yeniləmək üçün sizə link göndərək."
                : "Enter your email and we'll send you a link to reset your password."
        case .sendResetLink:
            return language == .az ? "Linki göndər" : "Send Reset Link"
        case .backToLogIn:
            return language == .az ? "Girişə qayıt" : "Back to Log In"

        // MARK: Verification Code
        case .verifyYourEmail:
            return language == .az ? "E-poçtunuzu təsdiqləyin" : "Verify Your Email"
        case .enterResetCode:
            return language == .az ? "Sıfırlama kodunu daxil edin" : "Enter Reset Code"
        case .verifyEmailSubtitle:
            return language == .az
                ? "6 rəqəmli kodu {email} ünvanına göndərdik."
                : "We've sent a 6-digit code to {email}."
        case .resetCodeSubtitle:
            return language == .az
                ? "Davam etmək üçün {email} ünvanına göndərilən 6 rəqəmli kodu daxil edin."
                : "Enter the 6-digit code sent to {email} to continue."
        case .verify:
            return language == .az ? "Təsdiqlə" : "Verify"
        case .didntReceiveCode:
            return language == .az ? "Kodu almadınız?" : "Didn't receive the code?"
        case .resend:
            return language == .az ? "Yenidən göndər" : "Resend"

        // MARK: Create New Password
        case .setNewPassword:
            return language == .az ? "Yeni şifrə təyin edin" : "Set a New Password"
        case .setNewPasswordSubtitle:
            return language == .az
                ? "Hesabınızı qorumaq üçün güclü bir şifrə seçin."
                : "Choose a strong password to secure your account."
        case .newPassword:
            return language == .az ? "Yeni şifrə" : "New Password"
        case .savePassword:
            return language == .az ? "Şifrəni yadda saxla" : "Save Password"
        case .passwordsDontMatch:
            return language == .az ? "Şifrələr uyğun gəlmir" : "Passwords don't match"

        // MARK: Home
        case .featuredProducts:
            return language == .az ? "Seçilmiş Məhsullar" : "Featured Products"
        case .recommended:
            return language == .az ? "Tövsiyə olunan" : "Recommended"
        case .topCollections:
            return language == .az ? "Ən Yaxşı Kolleksiyalar" : "Top Collections"
        case .showAll:
            return language == .az ? "Hamısına bax" : "Show all"
        case .somethingWentWrong:
            return language == .az ? "Nəsə səhv getdi. Yeniləmək üçün çəkin." : "Something went wrong. Pull to refresh."
        case .tryAgain:
            return language == .az ? "Yenidən cəhd edin" : "Try Again"
        case .comingSoon:
            return language == .az ? "Tezliklə" : "Coming Soon"

        // MARK: Tab bar
        case .homeTab:
            return language == .az ? "Əsas" : "Home"
        case .searchTab:
            return language == .az ? "Axtar" : "Search"
        case .wishlistTab:
            return language == .az ? "Seçilmişlər" : "Wishlist"
        case .cartTab:
            return language == .az ? "Səbət" : "Cart"
        case .profileTab:
            return language == .az ? "Profil" : "Profile"

        // MARK: Search / Discover
        case .discoverTitle:
            return language == .az ? "Kəşf et" : "Discover"
        case .searchPlaceholder:
            return language == .az ? "Don, ayaqqabı, çanta axtarın..." : "Search dresses, shoes, bags..."
        case .noResultsFound:
            return language == .az ? "Nəticə tapılmadı" : "No results found"
        case .items:
            return language == .az ? "məhsul" : "Items"

        // MARK: Search filters
        case .filtersTitle:
            return language == .az ? "Filtrlər" : "Filters"
        case .priceRangeLabel:
            return language == .az ? "Qiymət aralığı" : "Price Range"
        case .minPriceLabel:
            return language == .az ? "Min" : "Min"
        case .maxPriceLabel:
            return language == .az ? "Maks" : "Max"
        case .categoryFilterLabel:
            return language == .az ? "Kateqoriya" : "Category"
        case .allCategories:
            return language == .az ? "Hamısı" : "All"
        case .resetFilters:
            return language == .az ? "Sıfırla" : "Reset"

        // MARK: Category names
        case .categoryNewIn:
            return language == .az ? "Yenilər" : "New In"
        case .categoryClothing:
            return language == .az ? "Geyim" : "Clothing"
        case .categoryDresses:
            return language == .az ? "Donlar" : "Dresses"
        case .categorySkirts:
            return language == .az ? "Ətəklər" : "Skirts"
        case .categoryJackets:
            return language == .az ? "Gödəkçələr" : "Jackets"
        case .categorySweaters:
            return language == .az ? "Sviterlər" : "Sweaters"
        case .categoryJeans:
            return language == .az ? "Cinslər" : "Jeans"
        case .categoryTShirts:
            return language == .az ? "Tişörtlər" : "T-Shirts"
        case .categoryPants:
            return language == .az ? "Şalvarlar" : "Pants"
        case .categoryShoes:
            return language == .az ? "Ayaqqabılar" : "Shoes"
        case .categoryBags:
            return language == .az ? "Çantalar" : "Bags"
        case .categoryAccessories:
            return language == .az ? "Aksesuarlar" : "Accessories"
        case .categorySale:
            return language == .az ? "Endirim" : "Sale"

        // MARK: Category / Product Listing
        case .sortLabel:
            return language == .az ? "Sırala" : "Sort"
        case .sortFeatured:
            return language == .az ? "Seçilmiş" : "Featured"
        case .sortPriceLowToHigh:
            return language == .az ? "Qiymət: Aşağıdan Yuxarı" : "Price: Low to High"
        case .sortPriceHighToLow:
            return language == .az ? "Qiymət: Yuxarıdan Aşağı" : "Price: High to Low"
        case .sortTopRated:
            return language == .az ? "Ən Yüksək Reytinq" : "Top Rated"
        case .onSaleFilter:
            return language == .az ? "Endirimli" : "On Sale"
        case .categoryEmptyTitle:
            return language == .az ? "Hələ məhsul yoxdur" : "No Products Yet"
        case .categoryEmptySubtitle:
            return language == .az
                ? "Bu kateqoriyada yeni məhsullar üçün tezliklə yenidən yoxlayın."
                : "Check back soon for new arrivals in this category."
        case .noProductsMatchFilters:
            return language == .az ? "Filtrlərinizə uyğun məhsul tapılmadı" : "No products match your filters"

        // MARK: Wishlist
        case .wishlistEmptyTitle:
            return language == .az ? "Seçilmişlər siyahınız boşdur" : "Your Wishlist is Empty"
        case .wishlistEmptySubtitle:
            return language == .az
                ? "Bəyəndiyiniz məhsulları saxlayın və istənilən vaxt burada tapın."
                : "Save the pieces you love and find them here anytime."
        case .wishlistGuestTitle:
            return language == .az ? "Sevimlilərinizi saxlamaq üçün daxil olun" : "Sign in to save your favorites"
        case .wishlistGuestSubtitle:
            return language == .az
                ? "Bəyəndiyiniz məhsulları izləmək üçün hesab yaradın."
                : "Create an account to keep track of the pieces you love."
        case .startBrowsing:
            return language == .az ? "Gəzintiyə başla" : "Start Browsing"
        case .wishlistSavedCountSuffix:
            return language == .az ? "məhsul seçilib" : "items saved"
        case .sizePlaceholder:
            return language == .az ? "Ölçü" : "Size"

        // MARK: Cart
        case .cartEmptyTitle:
            return language == .az ? "Səbətiniz boşdur" : "Your Cart is Empty"
        case .cartEmptySubtitle:
            return language == .az ? "Hələ heç nə əlavə etməmisiniz." : "Looks like you haven't added anything yet."
        case .subtotal:
            return language == .az ? "Ara cəm" : "Subtotal"
        case .havePromoCode:
            return language == .az ? "Endirim kodunuz var?" : "Have a promo code?"
        case .voucherCodePlaceholder:
            return language == .az ? "Endirim kodu daxil edin" : "Enter voucher code"
        case .apply:
            return language == .az ? "Tətbiq et" : "Apply"
        case .voucherApplied:
            return language == .az ? "Kod tətbiq edildi!" : "Voucher applied!"
        case .shippingSectionTitle:
            return language == .az ? "Çatdırılma" : "Shipping"
        case .shippingFree:
            return language == .az ? "Pulsuz" : "Free"
        case .shippingStandard:
            return language == .az ? "Standart" : "Standard"
        case .shippingFast:
            return language == .az ? "Sürətli" : "Fast"
        case .shippingDaysSuffix:
            return language == .az ? "gün ərzində çatdırılma" : "day delivery"
        case .total:
            return language == .az ? "Cəmi" : "Total"
        case .proceedToCheckout:
            return language == .az ? "Sifarişi tamamla" : "Proceed to Checkout"
        case .removeItem:
            return language == .az ? "Sil" : "Remove"

        // MARK: Product Detail
        case .selectSize:
            return language == .az ? "Ölçü seçin" : "Select Size"
        case .selectColor:
            return language == .az ? "Rəng seçin" : "Select Color"
        case .addToCart:
            return language == .az ? "Səbətə əlavə et" : "Add to Cart"
        case .addedToCart:
            return language == .az ? "Səbətə əlavə edildi" : "Added to Cart"
        case .descriptionSectionTitle:
            return language == .az ? "Təsvir" : "Description"
        case .reviewsSectionTitle:
            return language == .az ? "Rəylər" : "Reviews"
        case .reviewsCountSuffix:
            return language == .az ? "rəy" : "reviews"
        case .youMightAlsoLike:
            return language == .az ? "Bunlar da xoşunuza gələ bilər" : "You Might Also Like"

        // MARK: Profile
        case .guestLabel:
            return language == .az ? "Qonaq" : "Guest"
        case .logInOrSignUp:
            return language == .az ? "Daxil ol / Qeydiyyat" : "Log In / Sign Up"
        case .editProfile:
            return language == .az ? "Profili redaktə et" : "Edit Profile"
        case .accountSection:
            return language == .az ? "HESAB" : "ACCOUNT"
        case .orderHistory:
            return language == .az ? "Sifariş tarixçəsi" : "Order History"
        case .addresses:
            return language == .az ? "Ünvanlar" : "Addresses"
        case .paymentMethods:
            return language == .az ? "Ödəniş üsulları" : "Payment Methods"
        case .preferencesSection:
            return language == .az ? "TƏRCİHLƏR" : "PREFERENCES"
        case .language:
            return language == .az ? "Dil" : "Language"
        case .notifications:
            return language == .az ? "Bildirişlər" : "Notifications"
        case .supportSection:
            return language == .az ? "DƏSTƏK" : "SUPPORT"
        case .liveChat:
            return language == .az ? "Canlı Dəstək" : "Live Chat"
        case .supportChatTitle:
            return language == .az ? "Dəstək Söhbəti" : "Support Chat"
        case .chatInputPlaceholder:
            return language == .az ? "Mesajınızı yazın..." : "Type a message..."
        case .helpCenter:
            return language == .az ? "Kömək Mərkəzi" : "Help Center"
        case .contactUs:
            return language == .az ? "Bizimlə əlaqə" : "Contact Us"
        case .rateTheApp:
            return language == .az ? "Tətbiqi qiymətləndirin" : "Rate the App"
        case .termsAndPrivacyPolicy:
            return language == .az ? "Şərtlər və Məxfilik Siyasəti" : "Terms & Privacy Policy"
        case .logOut:
            return language == .az ? "Çıxış et" : "Log Out"
        case .logOutConfirmTitle:
            return language == .az ? "Çıxış edilsin?" : "Log Out?"
        case .logOutConfirmMessage:
            return language == .az ? "Hesabınızdan çıxmaq istədiyinizə əminsiniz?" : "Are you sure you want to log out?"
        case .deleteAccount:
            return language == .az ? "Hesabı sil" : "Delete Account"
        case .deleteAccountConfirmTitle:
            return language == .az ? "Hesab silinsin?" : "Delete Account?"
        case .deleteAccountConfirmMessage:
            return language == .az
                ? "Bu, hesabınızı həmişəlik siləcək. Bu əməliyyat geri qaytarıla bilməz."
                : "This will permanently delete your account. This action cannot be undone."
        case .cancel:
            return language == .az ? "Ləğv et" : "Cancel"

        // MARK: Notifications
        case .notificationsEmptyTitle:
            return language == .az ? "Hələ bildiriş yoxdur" : "No Notifications Yet"
        case .notificationsEmptySubtitle:
            return language == .az
                ? "Sifarişləriniz, endirimlər və hesab fəaliyyəti haqqında bildirişlər burada görünəcək."
                : "Updates on your orders, sales, and account activity will show up here."
        case .markAllAsRead:
            return language == .az ? "Hamısını oxunmuş et" : "Mark All as Read"
        case .justNow:
            return language == .az ? "İndicə" : "Just now"
        case .minutesAgoSuffix:
            return language == .az ? "dəqiqə əvvəl" : "minutes ago"
        case .hoursAgoSuffix:
            return language == .az ? "saat əvvəl" : "hours ago"
        case .daysAgoSuffix:
            return language == .az ? "gün əvvəl" : "days ago"
        case .yesterday:
            return language == .az ? "Dünən" : "Yesterday"
        }
    }

    /// Maps a mock category's stable id to its catalog key — `Category.name` itself stays a
    /// plain fallback string (matching what a real backend might send pre-resolved in one
    /// field), while views that need real AZ/EN switching resolve through this instead.
    static func categoryName(forId id: String) -> LocalizedKey? {
        switch id {
        case "new-in": return .categoryNewIn
        case "clothing": return .categoryClothing
        case "dresses": return .categoryDresses
        case "skirts": return .categorySkirts
        case "jackets": return .categoryJackets
        case "sweaters": return .categorySweaters
        case "jeans": return .categoryJeans
        case "t-shirts": return .categoryTShirts
        case "pants": return .categoryPants
        case "shoes": return .categoryShoes
        case "bags": return .categoryBags
        case "accessories": return .categoryAccessories
        case "sale": return .categorySale
        default: return nil
        }
    }

    /// Maps a `ProductSortOption`'s raw value to its catalog key — same indirection as
    /// `categoryName(forId:)`, keeping this file free of a direct `Domain` import.
    static func sortOptionName(forId id: String) -> LocalizedKey? {
        switch id {
        case "featured": return .sortFeatured
        case "priceLowToHigh": return .sortPriceLowToHigh
        case "priceHighToLow": return .sortPriceHighToLow
        case "topRated": return .sortTopRated
        default: return nil
        }
    }
}
