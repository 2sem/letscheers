# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

letscheers (술마셔 건배사) is a lifestyle utility app that solves a common social problem: the awkward moment when you're asked to give a toast at a drinking occasion but can't think of anything to say. The app provides a curated collection of Korean toast phrases (건배사) organized by category and situation, allowing users to quickly find and deliver appropriate toasts.

**App Store:** https://apps.apple.com/us/app/id1193053041  
**Current Version:** see `marketingVersion` in `Projects/App/Project.swift`  
**Bundle ID:** com.credif.letscheers  
**Minimum iOS:** 18.0 (supports iPhone, iPad)  
**Age Rating:** 18+ (alcohol references)

Built with SwiftUI, SwiftData and Tuist. The bundled Excel workbook (`cheers.xlsx`) is the source of truth for toasts; on first launch / data-version change it is imported into SwiftData, which also stores favorites. Users can browse toasts by category, search, save favorites, roll a random toast, and share.

## Build System & Commands

### Tuist Workflow

This project uses **Tuist 4.218.2** (managed via mise) for project generation. The Xcode project files are generated from Swift manifests and should never be edited directly.

```bash
# Install dependencies (SPM packages)
mise x -- tuist install

# Generate Xcode workspace from manifests
mise x -- tuist generate

# Build the project
mise x -- tuist build

# Clean generated files
mise x -- tuist clean
```

`Sources/` and `Resources/` are Xcode buildable folders (synchronized groups): adding, removing or moving files inside them needs **no** regeneration. Run `tuist generate` only when manifests (`Project.swift`, `Tuist/Package.swift`, helpers) change.

### Development Workflow

```bash
# Open workspace after generation
open letscheers.xcworkspace

# Build with xcodebuild
xcodebuild -workspace letscheers.xcworkspace -scheme App -configuration Debug build
```

### Deployment

```bash
# Deploy to TestFlight
fastlane ios release description:"Changes" isReleasing:false

# Deploy to App Store with review submission
fastlane ios release description:"Changes" isReleasing:true
```

## Architecture

### Module Structure

The project is a single Tuist module:

- **App** (`.app`) - Main application
  - Bundle ID: `com.credif.letscheers`
  - Depends directly on external SPM packages (CoreXLSX, KakaoSDK, LSExtensions,
    StringLogger, GADManager, Firebase) declared in `Tuist/Package.swift`
    and linked via `.externals.*` helpers in `TargetDependency+.swift`.

The old `ThirdParty` static framework and `DynamicThirdParty` modules have been removed.

### Data Architecture

**Excel → SwiftData (toasts, categories, favorites)**

```
DataMigrationManager
  ├── Imports cheers.xlsx (via LCExcelController + CoreXLSX) into SwiftData
  │   when the store is empty or the workbook's info!version changes
  └── One-time migration of legacy Core Data favorites, then cleans them up

ToastsManager / FavoritesManager (ObservableObject, environment objects)
  └── Query/mutate SwiftData (Toast, ToastCategory, Favorite models)
```

**Key distinction**:
- Toast data is read-only, owned by the bundled workbook; bump its `info!version`
  or existing installs never re-sync
- Favorites are the only user-mutable data

**CRITICAL — `cheers.xlsx` must keep its sharedStrings table.**

`LCExcelController.swift` calls `try! document.parseSharedStrings()`, which
traps when `xl/sharedStrings.xml` is missing, and CoreXLSX's `stringValue(_:)`
resolves only `t="s"` cells. A workbook without that part is a **launch crash**,
not a degraded list.

openpyxl 3.1.x writes every string as `t="inlineStr"` and emits no
`xl/sharedStrings.xml`, so a plain `load_workbook` → `save` round-trip destroys
it. Any code path that writes this workbook **must** call
`restore_shared_strings()` from `.github/scripts/xlsx_shared_strings.py`
immediately after saving. `update_toasts.py` and `append_toasts.py` already do.

Verify after any change to the workbook:

```bash
unzip -l Projects/App/Resources/Excel/cheers.xlsx | grep sharedStrings
```

To repair a workbook that already lost the part (idempotent):

```bash
python3 .github/scripts/xlsx_shared_strings.py Projects/App/Resources/Excel/cheers.xlsx
```

Never fix this by editing the Swift side to tolerate inline strings — the
workbook format is the contract, and the original Google Sheets export
satisfies it.

### View Architecture

SwiftUI + `@Query` / `ObservableObject` view models. Navigation is a single
`NavigationStack` driven by `NavigationRouter` (`NavigationDestination` enum) in
`MainScreen`. The random-toast flow (`Random/`) is a sheet state machine owned by
`RandomToastCoordinator` (environment object), including the opt-in ad gate.

## Code Organization

### Naming Conventions

- Legacy UIKit-era types keep the `LC` prefix (`LCExcelController`, `LCToast`); new SwiftUI code uses plain names
- **Suffix pattern**: `*Screen` (navigation destinations), `*View`, `*ViewModel`, `*Manager`

### Source Structure

```
Projects/App/Sources/
├── LetsCheersApp.swift   # @main, SwiftData container, ads setup
├── Screens/              # Navigation destinations (*Screen)
├── Navigation/           # NavigationRouter + NavigationDestination
├── Random/               # Random toast sheet, coordinator, ad gate
├── Views/                # Reusable views, native ad rows
├── ViewModels/
├── Models/               # SwiftData models (Toast, ToastCategory, Favorite)
├── Managers/             # Data migration, toasts, favorites, ads
├── Controllers/          # LCExcelController (workbook parsing)
├── Datas/                # Legacy Excel DTOs (LCToast, LCCategory)
└── Extensions/           # Ads, theme colors, UIKit helpers
```

### Extension Organization

- Protocol conformance goes in extensions with MARK comments
- Framework extensions in subdirectories: `Extensions/RxCocoa/`, `Extensions/GoogleMobileAds/`
- Use MARK: `// MARK: - ProtocolName` for section headers

## Tuist Project Configuration

### Adding Dependencies

All SPM packages live in `Tuist/Package.swift` (resolved by Tuist's swifterpm). Add the
`.package(url:...)`, run `mise x -- tuist install`, then reference the product from a target
with `.external(name: "Product")` (or a `.externals.*` helper in `TargetDependency+.swift`).
Do not declare `packages:` in `Project.swift`.

### Project Manifests

- `Workspace.swift` - Defines workspace with projects array
- `Tuist.swift` - Global config (compatibleXcodeVersions: 26.x and 27.x)
- `Projects/*/Project.swift` - Individual module definitions
- `Tuist/ProjectDescriptionHelpers/` - Shared constants and helpers

**Helper example:**
```swift
// String+.swift defines bundle ID
static var appBundleId: String { "com.credif.letscheers" }

// TargetDependency+.swift provides external package dependencies
.externals.gadManager  // instead of .external(name: "GADManager")
```

## Data Flow

### App Launch

1. `DataMigrationManager.migrateToSwiftData` imports the workbook into SwiftData if needed
2. Screens read SwiftData via `@Query` / managers

### Favorites

`FavoritesManager` creates/removes `Favorite` models; `@Query` views update automatically.

## Google Mobile Ads Integration

- **GADManager 1.5.0** handles ad lifecycle
- Ad unit IDs in `Info.plist` under `GADUnitIdentifiers` dictionary
- `SwiftUIAdManager` wraps GADManager for SwiftUI (native, interstitial, rewarded)
- Extensions: `GADBannerView+.swift`, `GADRewardedAd+.swift`, `GADInterstitialAd+.swift`

## Build Configurations

Build settings live in `Projects/App/Project.swift` (no xcconfig files). Xcode's
Build Settings pane is read-only in practice: edits there are lost on the next `tuist generate`.

- `base` - shared settings, including `-ObjC` (required: static LSExtensions adds Swift
  extensions on UIKit classes that the linker would otherwise drop)
- `Debug` - Automatic signing, `-Onone`
- `Release` - Manual signing (provisioning profile `letscheers`, for CI/CD)
- `marketingVersion` / `buildNumber` constants at the top of `Project.swift` - bump both
  for a release (build number must be strictly higher than the last submitted one)

## CI/CD

GitHub Actions workflow (`.github/workflows/deploy-ios.yml`):
1. Runs on the `xcode-27` runner image (macOS 27, Xcode 27.0 as the default Xcode; no `xcode-select` step)
2. Decrypts secrets via git-secret + GPG
3. Installs Tuist via mise
4. Builds workspace
5. Fastlane handles certificate/profile setup and App Store upload

## Important Constraints

- **iOS 18.0+** minimum deployment target
- **Dark mode only** (`UIUserInterfaceStyle: Dark` in Info.plist)
- **No Catalyst or XR support** (explicitly disabled)
- **Xcode 26.0+** required (Tuist `compatibleXcodeVersions`: 26.x, 27.x)
- **`cheers.xlsx` must keep `xl/sharedStrings.xml`** — writing it with openpyxl
  strips the part and crashes the app at launch. Always call
  `restore_shared_strings()` after saving (see Data Architecture)

## Development Notes

- Think and implement code following Paul Hudson or Antoine van der Lee patterns
- Never regenerate Tuist project unless a manifest changed (files in buildable folders sync automatically)
- Use `mise x --` prefix for all Tuist commands to ensure correct version
- Favorites are the only mutable data; toasts are read-only from Excel
