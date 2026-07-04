//
//  LocalizedKey.swift
//  alivium
//

import Foundation

/// Every user-facing string in the app, resolved per `AppLanguage`. Enum-driven like
/// `BaseButton`'s style enum — one centralized catalog instead of strings scattered across
/// views, so every screen stays in sync and nothing gets translated inconsistently or missed.
enum LocalizedKey: Equatable {
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
        }
    }
}
