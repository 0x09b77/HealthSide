# Healthside iOS

Client app for storing and understanding lab results / medical documents.
Talks to the backend in the sibling repo `HealthSideBackEnd`.

> This README describes **what's actually in the code today**, not the
> target vision. Full design/architecture docs live in `HealthSideDocs`
> (`Mobile/Architecture.md`, `Mobile/Navigation.md`,
> `Mobile/Networking-and-Firebase.md`, `Mobile/Persistence-and-Testing.md`,
> `Mobile/Design-Spec.md`). Anything not built yet is marked `[later]` there
> or called out as a TODO in the code.

## Stack

- **SwiftUI** for all UI.
- **TCA** ([swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture) 1.26) for state, navigation, and DI (`@Dependency`).
- **Custom network layer** (`Core/Network`) on top of `URLSession`: `CompositeInterceptor([AuthInterceptor(), RetryInterceptor()])` (auth/refresh, then retry on offline/timeout), JSON parser, status validator.
- **Keychain** for tokens (`Core/TokenStore`).
- **UserDefaults** for onboarding flags (welcome/consent/biometric lock).
- **SwiftGen** (`swiftgen.yml`) generates type-safe accessors for colors,
  images, and localized strings from `Assets.xcassets` and
  `Resources/en.lproj/Localizable.strings`/`.stringsdict` into
  `Healthside/Generated/` (`Asset.*`, `L10n.*`). See "Localization &
  SwiftGen" below.
- No tests, SwiftData, or Firebase in the project yet (see below).

Requirements: **Xcode 26.5**, iOS deployment target **26.5**, Swift 5 tools (Swift 6 language mode is not enforced), **SwiftGen** (`brew install swiftgen`).

## Structure

One target, `Healthside`, no local SPM packages. `Architecture.md` describes
splitting into `Features/Core/Clients` packages, but in practice these are
just folders inside a single target:

```
Healthside/
  App/            AppFeature (launching/welcome/auth/setup/main), RootFeature (+ biometric lock), app entry point
  Core/
    Network/      transport: interceptors, validators, parser, logger
    Services/     Auth/Documents/LabResults/User: wrappers over Network
    TokenStore/   Keychain
    Session/      sessionExpired event (401 → logout)
    Permissions/  biometrics, system push permission prompt (no FCM)
    Preferences/  UserDefaults onboarding flags
    DesignSystem/ HSColor/HSButton/HSTextField/HSStatusBadge
    SharedUI/     shared views (DocumentRow, document scanner)
    Models/       DTOs and domain models
  Features/       Welcome, Auth, Setup, Main (tab bar), Home, Records (+Document),
                  Add (upload), Insights (+Biomarker), Profile, Lock
```

## Build & run

1. Open `Healthside.xcodeproj` in Xcode (or build headless:
   `xcodebuild -project Healthside.xcodeproj -scheme Healthside -destination 'platform=iOS Simulator,name=<simulator>' build`).
2. The app talks to the hosted backend by default
   (`https://healthsideback-production.up.railway.app`, set in
   `Core/Network/NetworkDependency.swift` via `StaticBaseUrlProvider`).
   Both Debug and Release point there, so no local backend, Docker, or LAN
   setup is needed to run the app. `qa`/`preprod` in `StaticBaseUrlProvider`
   are still placeholders for when those environments exist.
3. Run the `Healthside` scheme on a simulator or a device.

To point the app at a local backend instead (e.g. for backend development),
run `HealthSideBackEnd/Healthside` with `docker compose up -d` + `swift run`
and temporarily change the `NetworkConfig` environment in
`NetworkDependency.swift` to `.custom("http://127.0.0.1:8080")` (simulator)
or your Mac's LAN address (physical device). `Info-Debug.plist` already
allows cleartext HTTP to the local network for this case
(`NSAllowsLocalNetworking`).

## Localization & SwiftGen

Colors, images, and localized strings live as data (`Assets.xcassets`,
`Resources/en.lproj/Localizable.strings`/`.stringsdict`), not hardcoded in
Swift. A **Run Script build phase** ("SwiftGen", runs on every build) invokes
`swiftgen config run --config swiftgen.yml`, which regenerates
`Healthside/Generated/Assets.swift` (`Asset.<name>.swiftUIColor` /
`.image`) and `Healthside/Generated/Strings.swift` (`L10n.<Screen>.<key>`)
from those inputs.

- `HSColor` is now a thin alias layer over `Asset.*` so existing
  `HSColor.coral` etc. call sites didn't need to change.
- All screens' literal strings are migrated to `Localizable.strings`/`L10n`
  (including `APIError`'s error descriptions and `AlertState` text). New
  screens/strings follow the same pattern: add the key to
  `Localizable.strings`, use `L10n.<Screen>.<key>` in the view/reducer,
  then run `swiftgen config run --config swiftgen.yml` (or just build).
- `Generated/` is **committed to git**, not gitignored: Xcode's
  file-system-synchronized group computes its file list before the
  SwiftGen build phase runs, so a missing/empty `Generated/` folder makes
  the *first* build after a fresh clone fail with "cannot find 'Asset'/'L10n'
  in scope" (a second build then picks the freshly generated files up).
  Committing them avoids that trap; the build phase still overwrites them
  from source on every build, so they never really go stale.
- The script needs `swiftgen` on `PATH`; it's a Homebrew binary
  (`/opt/homebrew/bin`), which Xcode's Run Script phases don't include by
  default, so the script phase prepends it explicitly. `ENABLE_USER_SCRIPT_SANDBOXING`
  is off for this target (Xcode's script sandbox otherwise blocks the
  script from reading `swiftgen.yml`/`Resources`).
- `stringsdict` is wired into `swiftgen.yml` (merged into the same `strings`
  command, `Resources/en.lproj/Localizable.stringsdict`) but currently empty:
  no plural strings exist in the app yet.

## Design tokens & dark mode

All 21 `HSColor` tokens (plus a new `brandTeal`) are named colorsets in
`Assets.xcassets` with both light and dark appearances (each colorset's
`Contents.json` carries a `luminosity: dark` variant alongside the default).

- `background`/`surface` dark values are the exact hex from `Design-Spec.md`
  (`#1E1B18`/`#29241F`); `status/green|yellow|red` and `brand/teal` now match
  the spec's light-mode hex exactly (they'd drifted before).
- Every other dark value is *derived*, not hand-picked, since the spec only
  gives exact bg/surface hex and says "same accents, a bit lighter" for the
  rest: accents/status colors are the light hex with HSL lightness raised
  ~10-12%; text/neutral steps are a warm-hue ladder off the dark background;
  soft/fill/border variants are alpha-blends of the (lightened) accent over
  the dark surface. It's internally consistent and reproducible from the
  light palette, but hasn't had a visual design pass yet: expect to tweak
  specific values by eye once someone looks at it on a dark-mode device.

## Tests

**There are no tests in the project**: no test files and no test target in the
scheme. `Persistence-and-Testing.md` describes the intended strategy
(`TestStore`, dependency overrides), but it isn't implemented yet.
There's nothing for `xcodebuild test` to run against this scheme.

## What actually works

- Register/login, refresh token with single-flight coordination and
  session-expiry handling (401 → logout).
- Onboarding: welcome → auth → consent/notifications/Face ID (setup) → main.
- Biometric lock (Face ID/Touch ID) with a privacy blur over content when the
  scene goes inactive (even if the lock itself is off).
- Tab bar: Home (document feed + parse-status polling), Records (timeline,
  search, filter, document detail, delete), Add (camera/photo/files →
  multipart upload), Insights (biomarker trends computed client-side from the
  document feed), Profile (account, biometric lock, logout).
- Fallback polling for parse status with exponential backoff
  (`Core/Polling.swift`), currently the only status-update channel.

## Known gaps and issues (as of the last review)

A full breakdown is in the chat/project history. Fixed since the initial
review: the consent flag now resets on every path that ends a session
(`ProfileFeature.logoutTapped`, `RootFeature`'s lock-screen logout,
`AppFeature.sessionExpired`) so a second account on the same device gets the
Consent screen again; `status/green|yellow|red` and `brand/teal` now match
`Design-Spec.md` exactly and dark mode exists (see "Design tokens & dark
mode" above); `RetryInterceptor` is wired in via `CompositeInterceptor`;
the three copies of the polling backoff loop are now one `Polling.run`
helper; Alamofire and Kingfisher are removed. Still open:

- **No SwiftData / offline cache.** Without a network connection, screens
  just show an error; there's no write-through cache as described in
  `Persistence-and-Testing.md`.
- **No Firebase (FCM/Crashlytics/Analytics).** Push notifications, deep
  links from pushes (`AppFeature` has a `// TODO: deep links from pushes`),
  and the batch-debounce push from `System-Flow` aren't implemented. Everything
  relies on fallback polling instead.
- **No confirm-password field on sign up**, despite `Design-Spec.md` §4.1
  calling for one. Login and register share a single password field.
- **No CheckupFeature**, intentionally: the backend doesn't have a checkup
  endpoint yet (see the comment in `HomeFeature.swift`).

Some rows in Profile (Export data / Delete everything / Change password /
Auto-lock) are shown disabled. That's an intentional placeholder for
endpoints that don't exist yet, not a bug.
