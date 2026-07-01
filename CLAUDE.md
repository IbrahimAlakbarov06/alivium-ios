# Alivium — iOS App Master Plan

> This is the reference document for building the Alivium iOS app screen by screen with Claude Code. Read this before generating or editing any screen.

## 1. What Alivium is
Alivium is a women's fashion e-commerce app (like Trendyol, but boutique/curated instead of marketplace-scale). Categories include: dresses, skirts, coats, shoes, bags, tops, pants, jeans, hats, sunglasses, umbrellas, sneakers — essentially every category of women's fashion and accessories.

Backend: Spring Boot REST API (Java), repo `alivium-backend`. ~70% complete.

## 2. Brand Identity

**Logo:** Circular badge, letter "A" mark (tent/mountain-peak shape), dark green background, gold ring and text.

**Colors:**
- `Primary / Dark` — `#334342` (deep pine/olive green) — used for primary buttons, headers, logo, tab bar active state, price emphasis
- `Accent / Gold` — `#BB9264` (warm tan/gold) — used for highlights, badges, secondary CTAs, icons, dividers, sale tags
- `Background` — `#FFFFFF` / off-white `#FAFAF8`
- `Text primary` — near-black `#1C1C1A`
- `Text secondary / muted` — warm gray `#8A8580`
- `Surface / card background` — `#F4F2EE` (warm light beige, not cold gray)
- `Error / destructive` — standard red, used sparingly (e.g. `#C0392B`)

**Typography:** A clean serif or high-contrast sans for headings (evokes the boutique/luxury feel of the logo), and a simple neutral sans (SF Pro / Inter-like) for body text and prices. Avoid anything playful/rounded — Alivium should feel elegant, warm, boutique — not youth-streetwear.

**Tone:** Warm minimal boutique — closer to Zara/COS/Massimo Dutti than to Shein/Trendyol's dense colorful grid. Generous white space, large product photography, gold as an accent not a dominant color.

## 3. Reference UI (structural inspiration only — NOT visual style)
Two reference screens were provided (Home, Discover) from a generic "GemStore" template. We reuse their **layout patterns** (top category pills, hero banner, horizontal product rails, category list with item counts) but **restyle everything** with Alivium's palette, typography and warmer spacing. Do not copy GemStore's black/white/cold styling or its Women/Men/Accessories/Beauty top toggle — Alivium is women-only, so that toggle is replaced by category chips (see Home screen below).

## 4. Navigation — Tab Bar (5 tabs)
1. **Home** — house icon
2. **Search / Discover** — magnifying glass
3. **Wishlist** — heart outline
4. **Cart** — bag icon (with item-count badge)
5. **Profile** — person icon

Active tab: filled icon in `#334342`. Inactive: outline icon in muted gray.

## 5. Screens (build order)

### Phase 1 — Core browsing (build first)
1. **Splash / Launch screen** — logo centered on `#334342` background
2. **Onboarding** (optional, 2–3 slides) — can skip if time-constrained
3. **Auth** — Login, Register, Forgot Password (matches backend: email/password + Google login button)
4. **Home** — top bar (menu icon, "Alivium" wordmark, notification bell), horizontal category chips (Dresses, Shoes, Bags, Accessories, New In, Sale...), hero banner carousel (seasonal collection), "Featured Products" horizontal rail, promotional banner block, "Recommended" rail, "Top Collections" section
5. **Search / Discover** — search bar + filter icon, expandable category list with item counts (Clothing → Jackets, Skirts, Dresses, Sweaters, Jeans, T-Shirts, Pants...), large tappable category banners (Accessories, Shoes, Bags, Collection)
6. **Category / Product Listing** — grid of products (2 columns), filter + sort bar
7. **Product Detail** — image carousel/gallery, variant selector (size + color, from `ProductVariant`), price + discount badge, add to cart, add to wishlist, description, reviews summary + list, related products
8. **Cart** — line items with variant/qty controls, subtotal, voucher code input, shipping method preview (Free / Standard $4.90 / Fast $9.90), checkout button
9. **Wishlist** — grid of saved products, quick add-to-cart
10. **Profile** — user info, order history (UI only for now, see note below), addresses, saved cards (UI only), settings, logout

### Phase 2 — Checkout & extras (build after core is solid)
11. **Checkout** — Address selection/add, shipping method (Free/Standard/Fast — already defined in backend `ShippingMethod` enum), payment step (UI placeholder — backend `PaymentMethod` not implemented yet), order summary, confirm
12. **Order confirmation** — success screen
13. **Order history / detail** — list + status timeline (Pending → Confirmed → Processing → Shipped → Delivered)
14. **Reviews — write a review** (with photo upload)
15. **Chat / Support** — backend has WebSocket chat rooms ready
16. **Notifications** — list screen, backend ready

## 6. Backend status (as of last check)
Ready & should be wired in Phase 2 of networking:
- Auth (register, email verify, login, Google login, refresh token, forgot/reset password)
- Product, ProductVariant, ProductImage (CRUD, filter by category/collection, discount, active status)
- Category, Collection
- Cart, CartItem
- Wishlist
- Review, ReviewImage
- Address
- Voucher / VoucherUsage
- Notification (incl. admin/push)
- Chat (WebSocket — ChatRoom, ChatMessage)
- SearchHistory, Feedback

**Not ready yet (build UI only, mock data, connect later):**
- No `OrderController` / `OrderService` — Order/OrderItem/Payment entities exist but nothing serves them yet
- `PaymentMethod` enum is empty — no payment methods defined yet
- `ShippingMethod` enum IS ready: `FREE` (7 days, $0), `STANDARD` (5 days, $4.90), `FAST` (3 days, $9.90)

## 7. Build strategy with Claude Code
1. **Phase 1: UI only.** For each screen: design in Stitch → export PNG → give Claude Code the PNG + this MD file + a short screen-specific prompt → it builds the SwiftUI view with hardcoded/mock sample data. No networking yet. Verify each screen builds and runs in Simulator before moving to the next.
2. **Phase 2: Networking.** Build `APIService`/`NetworkManager` (URLSession-based), `Codable` Swift models matching backend DTOs (`ProductResponse`, `CategoryResponse`, `CartResponse`, etc.), then wire screens to real endpoints one at a time, starting with Auth → Home/Products → Category → Cart → Wishlist → Profile. Order/Payment gets wired once backend is ready.

## 8. Swift project conventions (to keep Claude Code consistent across sessions)
- SwiftUI, iOS 17+ target
- MVVM: `Views/`, `ViewModels/`, `Models/`, `Networking/`, `Resources/`
- Color palette defined once in `Assets.xcassets` / a `Theme.swift` (AliviumGreen, AliviumGold, AliviumBackground, AliviumSurface, AliviumTextPrimary, AliviumTextSecondary)
- Reusable components: `ProductCard`, `PrimaryButton`, `SecondaryButton`, `CategoryChip`, `SectionHeader` (title + "Show all")
- Each new screen should reuse existing components from `Components/` rather than redefining styles inline

## 9. Senior-Level Architecture Spec

This is the authoritative architecture for the Alivium iOS app. Claude Code must follow this on every screen. The goal is production-grade, senior-level code: clean layering, protocol-oriented design, dependency injection, no duplication, performance-conscious.

### 9.1 Guiding principles
- **Clean Architecture in 3 layers:** `Presentation` (SwiftUI + ViewModels), `Domain` (business models + use cases + repository *protocols*), `Data` (repository *implementations* + networking + DTOs + mapping). Dependencies point inward: Presentation → Domain ← Data. Domain knows nothing about SwiftUI or URLSession.
- **Program to protocols, not concretes.** ViewModels depend on repository protocols, never on a concrete `URLSession` service. This makes every screen testable and mockable (critical for Phase 1 mock data — we just inject a mock repo).
- **Dependency Injection via a container**, not singletons scattered in views. One `AppContainer` composes the object graph at launch and hands dependencies down.
- **Unidirectional data flow.** State lives in the ViewModel (`@Observable`), views are a pure function of state. No business logic in views.
- **DTO ≠ Domain model.** Network DTOs (`Codable`, mirror the backend JSON exactly) are mapped into clean Domain models the rest of the app uses. The UI never touches `BigDecimal`-style raw JSON or nullable server fields directly.
- **Enum-driven design system.** One base component per UI primitive, configured by an enum/style — never copy-pasted variants. (See 9.6.)
- **async/await first.** Networking and use cases are `async throws`. Combine only where genuinely reactive (e.g. debounced search text).
- **No over-engineering.** Use cases exist where there's real logic; for trivial pass-throughs the ViewModel may call the repository directly. Pragmatic senior code, not ceremony.

### 9.2 Target & tooling
- SwiftUI, iOS 17+ (uses `@Observable` macro, not `ObservableObject`, unless a screen needs iOS 16 support)
- Swift Concurrency (async/await, actors for caches)
- No third-party deps required for v1. If image caching needs it later, Kingfisher/Nuke is acceptable, but start with a lightweight in-house `AsyncImage` cache actor.
- Swift Package structure optional; single app target is fine for v1 as long as folders enforce boundaries.

### 9.3 Folder structure

```
Alivium/
├── App/
│   ├── AliviumApp.swift              // @main entry, builds AppContainer
│   ├── AppContainer.swift            // DI composition root
│   ├── AppCoordinator.swift          // root navigation (auth vs main tab)
│   └── AppEnvironment.swift          // baseURL, build config, feature flags
│
├── DesignSystem/                     // the visual foundation — used everywhere
│   ├── Theme/
│   │   ├── AppColor.swift            // #334342, #BB9264, etc. semantic tokens
│   │   ├── AppTypography.swift       // font scales (display/title/body/caption)
│   │   ├── AppSpacing.swift          // 4/8/12/16/24... spacing scale
│   │   └── AppRadius.swift           // corner radius scale
│   ├── Components/
│   │   ├── BaseButton.swift          // one button, enum-driven style/size/state
│   │   ├── BaseTextField.swift       // one text field, enum-driven
│   │   ├── ProductCard.swift         // enum-driven layout (grid vs rail vs wide)
│   │   ├── CategoryChip.swift
│   │   ├── SectionHeader.swift       // title + optional "Show all"
│   │   ├── Badge.swift               // cart count / sale tag, enum-driven
│   │   ├── PriceLabel.swift          // handles price + discount strikethrough
│   │   ├── RatingView.swift
│   │   ├── AsyncImageView.swift      // cached remote image (see 9.7)
│   │   ├── LoadingView.swift / ShimmerView.swift  // skeleton loading
│   │   └── EmptyStateView.swift / ErrorStateView.swift
│   └── Modifiers/
│       ├── CardStyle.swift
│       └── ShimmerModifier.swift
│
├── Domain/                           // pure Swift, zero framework imports
│   ├── Models/
│   │   ├── Product.swift
│   │   ├── ProductVariant.swift
│   │   ├── Category.swift
│   │   ├── Collection.swift
│   │   ├── Cart.swift / CartItem.swift
│   │   ├── User.swift
│   │   ├── Review.swift
│   │   ├── Address.swift
│   │   ├── Voucher.swift
│   │   ├── Money.swift               // value type for price (avoids Double bugs)
│   │   └── ProductFilter.swift       // domain-side search/sort params
│   ├── Repositories/                 // PROTOCOLS only
│   │   ├── ProductRepository.swift
│   │   ├── CategoryRepository.swift
│   │   ├── CartRepository.swift
│   │   ├── WishlistRepository.swift
│   │   ├── AuthRepository.swift
│   │   ├── ReviewRepository.swift
│   │   ├── AddressRepository.swift
│   │   └── OrderRepository.swift      // Phase 2, mock impl for now
│   └── UseCases/                     // only where real logic exists
│       ├── FetchHomeFeedUseCase.swift
│       ├── AddToCartUseCase.swift
│       ├── ToggleWishlistUseCase.swift
│       ├── ApplyVoucherUseCase.swift
│       └── LoginUseCase.swift
│
├── Data/
│   ├── Network/
│   │   ├── APIClient.swift           // protocol: request(Endpoint) async throws -> T
│   │   ├── URLSessionAPIClient.swift // concrete impl
│   │   ├── Endpoint.swift            // path, method, query, body, auth flag
│   │   ├── HTTPMethod.swift
│   │   ├── APIError.swift            // typed errors
│   │   ├── RequestBuilder.swift      // builds URLRequest from Endpoint
│   │   ├── AuthInterceptor.swift     // injects Bearer token, handles 401 refresh
│   │   └── TokenStore.swift          // Keychain-backed access/refresh tokens
│   ├── Endpoints/
│   │   ├── ProductEndpoint.swift     // /api/products, /category/{id}, etc.
│   │   ├── CartEndpoint.swift        // /api/cart, /items, /clear...
│   │   ├── AuthEndpoint.swift        // /api/auth/login, /register...
│   │   └── ...                       // one per backend controller group
│   ├── DTOs/                         // Codable, mirror backend JSON exactly
│   │   ├── ProductDTO.swift
│   │   ├── ProductVariantDTO.swift
│   │   ├── CategoryDTO.swift
│   │   ├── CartDTO.swift
│   │   ├── AuthResponseDTO.swift
│   │   └── ...
│   ├── Mappers/                      // DTO -> Domain (and request DTOs)
│   │   ├── ProductMapper.swift
│   │   ├── CategoryMapper.swift
│   │   └── ...
│   └── Repositories/                 // protocol IMPLEMENTATIONS
│       ├── DefaultProductRepository.swift   // uses APIClient
│       ├── MockProductRepository.swift      // returns sample data (Phase 1!)
│       ├── DefaultCartRepository.swift
│       ├── MockCartRepository.swift
│       └── ...
│
├── Presentation/                     // one folder per feature/screen
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── HomeViewModel.swift        // @Observable, depends on repo protocols
│   │   └── HomeViewState.swift        // idle/loading/loaded/error enum
│   ├── Discover/
│   ├── ProductList/
│   ├── ProductDetail/
│   ├── Cart/
│   ├── Wishlist/
│   ├── Profile/
│   ├── Auth/
│   │   ├── Login/ Register/ ForgotPassword/
│   └── Checkout/                      // Phase 2
│
├── Navigation/
│   ├── AppRoute.swift                 // typed routes (enum)
│   ├── TabCoordinator.swift           // the 5-tab shell
│   └── NavigationRouter.swift         // NavigationStack path wrapper
│
├── Core/
│   ├── Extensions/                    // View+, String+, Optional+, etc.
│   ├── Utilities/                     // Logger, DateFormatter cache
│   └── Persistence/                   // Keychain wrapper, UserDefaults store
│
└── Resources/
    ├── Assets.xcassets                // colors, app icon, placeholders
    ├── SampleData/                    // JSON/Swift fixtures for mock repos
    └── Localizable.xcstrings          // strings (AZ/EN ready)
```

### 9.4 Layer contracts (how the pieces talk)

```
View (SwiftUI)
  → observes → ViewModel (@Observable, holds ViewState)
      → calls → UseCase or Repository protocol (async throws)
          → Domain model in, Domain model out
              ↑ implemented by
          DefaultXRepository (Data)
              → APIClient.request(Endpoint) -> DTO
              → Mapper: DTO -> Domain model
```

- **Views** never call APIClient, never see DTOs, never format prices manually (use `PriceLabel`/`Money`).
- **ViewModels** hold a `ViewState` enum and expose intent methods (`func onAppear()`, `func addToCart(_:)`). No `URLSession`, no navigation logic beyond emitting routes.
- **Repositories (protocol)** live in Domain; implementations live in Data. Swapping `MockProductRepository` for `DefaultProductRepository` is a one-line change in the container — this is exactly how we do Phase 1 (mock) → Phase 2 (real API).

### 9.5 Dependency Injection

`AppContainer` is the composition root, built once in `AliviumApp`. It owns shared infrastructure (APIClient, TokenStore) and vends repositories. A simple constructor-injection approach — no heavyweight DI framework needed.

```swift
@MainActor
final class AppContainer {
    // Infrastructure
    let environment: AppEnvironment
    private let apiClient: APIClient
    private let tokenStore: TokenStore

    // Repositories (swap Mock <-> Default here to flip Phase 1/2)
    let productRepository: ProductRepository
    let cartRepository: CartRepository
    let authRepository: AuthRepository
    // ...

    init(environment: AppEnvironment = .live) {
        self.environment = environment
        self.tokenStore = KeychainTokenStore()
        self.apiClient = URLSessionAPIClient(
            baseURL: environment.baseURL,
            interceptor: AuthInterceptor(tokenStore: tokenStore)
        )
        // PHASE 1: use Mock*; PHASE 2: switch to Default*
        self.productRepository = MockProductRepository()
        self.cartRepository    = MockCartRepository()
        self.authRepository    = MockAuthRepository()
    }

    // ViewModel factories keep views free of wiring
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(productRepository: productRepository,
                      categoryRepository: categoryRepository)
    }
}
```

Views receive their ViewModel from the container (via factory methods or `@Environment`), so no view constructs its own dependencies.

### 9.6 Design System — enum-driven components (the core of "no duplication")

This is exactly the pattern the user described (BaseButton + enum), applied consistently. **Never** create `PrimaryButton`, `SecondaryButton`, `GhostButton` as separate views. Instead:

```swift
// One style enum drives look; one Size enum drives metrics.
enum AppButtonStyleKind { case primary, secondary, ghost, destructive }
enum AppButtonSize      { case large, medium, small }

struct BaseButton: View {
    let title: String
    var icon: Image? = nil
    var kind: AppButtonStyleKind = .primary
    var size: AppButtonSize = .large
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View { /* single implementation reading kind/size tokens */ }
}

// Usage:
BaseButton(title: "Add to Cart", kind: .primary) { vm.addToCart() }
BaseButton(title: "Save", kind: .ghost, size: .small) { vm.save() }
```

Apply the same enum-driven approach to:
- `BaseTextField(style: .standard | .search | .secure)`
- `ProductCard(layout: .grid | .rail | .wide)` — same data, different arrangement
- `Badge(style: .cartCount | .sale | .new)`
- `SectionHeader(title:, action:)` — the "Show all" pattern in one place

All colors/fonts/spacing/radius come from `AppColor` / `AppTypography` / `AppSpacing` / `AppRadius` tokens — never hardcoded hex or magic numbers inside a component. Change the brand in one place, it propagates everywhere.

### 9.7 Networking details

- `APIClient` is a protocol: `func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T`.
- `Endpoint` is a value type describing path, method, query items, body, and whether auth is required.
- `AuthInterceptor` injects the `Bearer` access token and, on a `401`, transparently calls `/api/auth/refresh-token` once, retries, and only then fails — matching the backend's refresh-token flow.
- `TokenStore` is Keychain-backed (never UserDefaults for tokens).
- `APIError` is a typed enum: `.unauthorized`, `.notFound`, `.server(code:)`, `.decoding`, `.network`, `.offline` — mapped to friendly `ErrorStateView` messages.
- **Image loading & caching:** `AsyncImageView` backed by an `actor ImageCache` (in-memory NSCache + optional disk). Prevents redundant downloads while scrolling product grids. Product lists use `LazyVGrid`/`LazyHStack` so cells and images load on demand.

### 9.8 State & performance

- Each screen has a `ViewState` enum: `case idle, loading, loaded(Data), empty, error(AppError)` — views switch on it, so loading/empty/error are handled uniformly (with `ShimmerView` skeletons, not spinners, for a premium feel).
- **Pagination:** product lists load pages (backend supports paged `/api/products`). ViewModel exposes `loadNextPageIfNeeded(currentItem:)` triggered near the end of the list.
- Avoid unnecessary re-renders: keep `@Observable` state granular; use `Equatable` view models/state where helpful; pass value types.
- Use `.task(id:)` for lifecycle-bound async work so navigation cancels in-flight requests automatically.
- Debounce search input (Combine or `AsyncStream`) before hitting the search endpoint.

### 9.9 Domain modeling notes (mapping from backend)
- Backend `price`/`discountPrice` are `BigDecimal` → map to a `Money` value type (integer minor units) to avoid floating-point money bugs; format via a single currency formatter.
- `ProductVariant` (color + size + stock) → drives the size/color selector on Product Detail; "add to cart" requires a selected variant.
- `Category` is self-referential (has `subCategories`, `parentId`) → Discover screen renders the tree; map recursively.
- `ProductResponse.images` (minimal: `imageUrl`) → gallery; first image is the card thumbnail.
- Nullable server fields are resolved during mapping (DTO optionals → sensible Domain defaults), so the UI layer never deals with optionals from the server.

### 9.10 Phase 1 vs Phase 2 in this architecture
- **Phase 1 (now):** container wires `Mock*` repositories that return `SampleData` fixtures. Every screen is built and demoed fully without a running backend. Because ViewModels depend on protocols, zero UI code changes are needed later.
- **Phase 2:** flip the container to `Default*` repositories (real `APIClient`). Wire order: Auth → Home/Products → Category/Discover → ProductDetail → Cart → Wishlist → Profile. Order/Payment last, once the backend `OrderController`/`PaymentMethod` are implemented.

### 9.11 Testing hooks (kept lightweight for v1)
- Because everything is protocol-injected, unit tests target ViewModels with mock repos.
- Mappers get pure unit tests (DTO JSON → expected Domain model).
- No need for full coverage in v1, but the seams are there for a senior-quality codebase.

