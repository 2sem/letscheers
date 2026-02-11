# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

letscheers (술마셔 건배사) is a lifestyle utility app that solves a common social problem: the awkward moment when you're asked to give a toast at a drinking occasion but can't think of anything to say. The app provides a curated collection of Korean toast phrases (건배사) organized by category and situation, allowing users to quickly find and deliver appropriate toasts.

**App Store:** https://apps.apple.com/us/app/id1193053041  
**Current Version:** 1.1.17  
**Bundle ID:** com.credif.letscheers  
**Minimum iOS:** 13.0 (supports iPhone, iPad)  
**Age Rating:** 18+ (alcohol references)

Built with UIKit and Tuist, the app uses Excel files as the primary data source for toasts, with Core Data managing user favorites. Users can browse toasts by category, search for specific phrases, save favorites, and share toasts via Kakao.

## Build System & Commands

### Tuist Workflow

This project uses **Tuist 4.140.2** (managed via mise) for project generation. The Xcode project files are generated from Swift manifests and should never be edited directly.

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

**CRITICAL**: Only run `tuist generate` when adding or removing files. Do not regenerate for code-only changes.

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

The project is organized as three Tuist modules:

1. **App** (`.app`) - Main application
   - Bundle ID: `com.credif.letscheers`
   - Depends on ThirdParty + DynamicThirdParty + GADManager

2. **ThirdParty** (`.staticFramework`) - Static dependencies
   - RxSwift/RxCocoa, KakaoSDK, CoreXLSX, etc.
   - Bundle ID: `com.credif.letscheers.thirdparty`

3. **DynamicThirdParty** (`.framework`) - Firebase (must be dynamic)
   - FirebaseCrashlytics, Analytics, Messaging, RemoteConfig
   - Bundle ID: `com.credif.letscheers.thirdparty.dynamic`

### Data Architecture

**Excel → Memory → Core Data (Favorites only)**

```
LCExcelController.shared
  ├── Loads toasts from Excel files (Projects/App/Resources/Excel/)
  ├── Parses categories and toast data using CoreXLSX
  └── Provides in-memory data access

LCModelController.shared
  ├── Manages Core Data context for favorites only
  ├── NSFetchedResultsController for reactive updates
  └── Synchronized initialization with semaphore
```

**Key distinction**: 
- Toast data is read-only from Excel files (bundled resources)
- Only favorites are persisted in Core Data
- Categories are loaded at app launch from Excel

### View Architecture

**RxSwift-based reactive bindings:**

```
BehaviorSubject<[LCToast]> → tableView.rx.items → Cells
```

View controllers use `NSFetchedResultsController` for Core Data and `BehaviorSubject` for Excel data, both bound to table/collection views via RxCocoa.

Navigation flow:
- `MainViewController` (container) → Category selection → Toast list per category
- Parallel: Favorites view (Core Data-backed)

## Code Organization

### Naming Conventions

- **Prefix `LC`** for all app-specific classes: `LCToast`, `LCModelController`, `LCToastTableViewController`
- **Suffix pattern**: `*ViewController`, `*Cell`, `*Controller`
- **IBOutlets**: Prefix `constraint_` for layout constraints

### Source Structure

```
Projects/App/Sources/
├── AppDelegate.swift              # App lifecycle, GADManager setup
├── MainViewController.swift       # Root container
├── Datas/                        # Data models (LCToast, LCCategory)
├── Controllers/                  # Business logic
│   ├── LCModelController         # Core Data (singleton, favorites)
│   ├── LCExcelController         # Excel data loading (singleton)
│   └── LCFavoriteModelController # Favorite-specific queries
├── Views/                        # View controllers and cells
└── Extensions/                   # Framework extensions (RxCocoa, GAD, UIKit)
```

### Extension Organization

- Protocol conformance goes in extensions with MARK comments
- Framework extensions in subdirectories: `Extensions/RxCocoa/`, `Extensions/GoogleMobileAds/`
- Use MARK: `// MARK: - ProtocolName` for section headers

## Tuist Project Configuration

### Adding Dependencies

**To ThirdParty (static):** Edit `Projects/ThirdParty/Project.swift`
```swift
packages: [
    .remote(url: "...", requirement: .upToNextMajor(from: "1.0.0"))
]
```

**To DynamicThirdParty (Firebase only):** Edit `Projects/DynamicThirdParty/Project.swift`

**Runtime packages (like GADManager):** Edit `Projects/App/Project.swift` with `.package(product: "...", type: .runtime)`

### Project Manifests

- `Workspace.swift` - Defines workspace with projects array
- `Tuist.swift` - Global config (Xcode 16.0+ compatibility)
- `Projects/*/Project.swift` - Individual module definitions
- `Tuist/ProjectDescriptionHelpers/` - Shared constants and helpers

**Helper example:**
```swift
// String+.swift defines bundle ID
static var appBundleId: String { "com.credif.letscheers" }

// TargetDependency+.swift provides project dependencies
.Projects.ThirdParty  // instead of .project(target: "ThirdParty", ...)
```

## Data Flow

### Excel Loading (App Launch)

1. `LCExcelController.init()` loads CoreXLSX document from bundle
2. Parses headers and worksheets
3. `loadCategories()` creates `LCCategory` objects
4. Categories drive UI (collection view)
5. Per-category toast loading is lazy via `loadToasts(withCategory:)`

### Favorites System

1. User taps favorite button → `LCModelController.createFavorite(name:contents:)`
2. Core Data entity created with toast name + contents
3. `NSFetchedResultsController` triggers RxSwift update
4. Table view automatically reflects change via reactive binding

### Search Flow

`UISearchBar` → `searchBar(_:textDidChange:)` → Filter `BehaviorSubject` → Table view updates

## Google Mobile Ads Integration

- **GADManager 1.3.5** handles ad lifecycle
- Ad unit IDs in `Info.plist` under `GADUnitIdentifiers` dictionary
- `AppDelegate` conforms to `GADRewardManagerDelegate`
- Extensions: `GADBannerView+.swift`, `GADRewardedAd+.swift`, `GADInterstitialAd+.swift`

## Build Configurations

Two xcconfig files in `Projects/App/Configs/`:

- **debug.xcconfig** - Automatic signing, simulator support, debug optimization
- **release.xcconfig** - Manual signing (for CI/CD), production settings

Both specify:
- `MARKETING_VERSION=1.1.17` (update for new releases)
- `IPHONEOS_DEPLOYMENT_TARGET=13.0`
- `TARGETED_DEVICE_FAMILY=1,2` (iPhone + iPad)

## CI/CD

GitHub Actions workflow (`.github/workflows/deploy-ios.yml`):
1. Runs on macOS 15 with Xcode 16.2
2. Decrypts secrets via git-secret + GPG
3. Installs Tuist via mise
4. Builds workspace
5. Fastlane handles certificate/profile setup and App Store upload

## Important Constraints

- **iOS 13.0+** minimum deployment target
- **Dark mode only** (`UIUserInterfaceStyle: Dark` in Info.plist)
- **Swift 5.0** with bridging header for Objective-C compatibility
- **No Catalyst or XR support** (explicitly disabled)
- **Xcode 16.0+** required (Tuist compatibility constraint)

## Development Notes

- Think and implement code following Paul Hudson or Antoine van der Lee patterns
- Never regenerate Tuist project without file insertion/deletion
- Use `mise x --` prefix for all Tuist commands to ensure correct version
- Favorites are the only mutable data; toasts are read-only from Excel
- All LC-prefixed controllers are singletons accessed via `.shared`
