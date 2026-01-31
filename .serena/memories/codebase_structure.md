# Codebase Structure

## Project Overview

letscheers is organized as a Tuist multi-module project with clear separation of concerns.

## Directory Structure

```
letscheers/
│
├── Tuist/                          # Tuist configuration and helpers
│   ├── Package.swift              # Tuist framework dependencies
│   ├── ProjectDescriptionHelpers/ # Helper extensions for project definition
│   │   ├── Path+.swift
│   │   ├── String+.swift          # Bundle ID constant
│   │   └── TargetDependency+.swift
│   └── (generated files)
│
├── Projects/                       # All project modules
│   │
│   ├── App/                       # Main application target
│   │   ├── Project.swift         # Tuist project manifest
│   │   ├── Configs/              # Build configuration files
│   │   │   ├── debug.xcconfig
│   │   │   └── release.xcconfig
│   │   │
│   │   ├── Sources/              # Swift source code
│   │   │   ├── AppDelegate.swift
│   │   │   ├── MainViewController.swift
│   │   │   ├── letscheers-Bridging-Header.h
│   │   │   │
│   │   │   ├── Datas/           # Data models and Core Data entities
│   │   │   │   ├── LCCategory.swift
│   │   │   │   ├── LCToast.swift
│   │   │   │   ├── LCToastCategory.swift
│   │   │   │   └── LSDefaults.swift
│   │   │   │
│   │   │   ├── Controllers/      # Business logic controllers
│   │   │   │   ├── LCModelController.swift
│   │   │   │   ├── LCExcelController.swift
│   │   │   │   └── LCFavoriteModelController.swift
│   │   │   │
│   │   │   ├── Views/            # View controllers and custom views
│   │   │   │   ├── LCToastTableViewController.swift
│   │   │   │   ├── LCCategotyTableViewController.swift
│   │   │   │   ├── LCFavoriteTableViewController.swift
│   │   │   │   ├── LCCategoryCollectionViewController.swift
│   │   │   │   ├── LCToastTableViewCell.swift
│   │   │   │   ├── LCCategoryTableViewCell.swift
│   │   │   │   ├── LCCategoryCollectionViewCell.swift
│   │   │   │   ├── LCCategoryCollectionViewFavoriteCell.swift
│   │   │   │   └── GADNativeCollectionViewCell.swift
│   │   │   │
│   │   │   └── Extensions/       # Swift extensions organized by type
│   │   │       ├── RxCocoa/
│   │   │       │   └── ObservableType+UITableView.swift
│   │   │       ├── Lx/
│   │   │       │   └── NSFetchedResultsController+UITableView.swift
│   │   │       ├── GoogleMobileAds/
│   │   │       │   └── GADBannerView+Unvisible.swift
│   │   │       ├── GADBannerView+.swift
│   │   │       ├── GADRewardedAd+.swift
│   │   │       ├── GADInterstitialAd+.swift
│   │   │       ├── GADRewardManager.swift
│   │   │       ├── ReviewManager.swift
│   │   │       ├── UIApplication+KakaoLink.swift
│   │   │       └── UIView+.swift
│   │   │
│   │   ├── Resources/            # Assets, storyboards, data files
│   │   │   ├── Assets.xcassets/
│   │   │   ├── LaunchScreen.storyboard
│   │   │   ├── Main.storyboard
│   │   │   └── (other resources)
│   │   │
│   │   └── App.xcodeproj/        # Generated Xcode project (by Tuist)
│   │
│   ├── ThirdParty/               # Static framework for dependencies
│   │   └── Project.swift         # Dependencies: RxSwift, Kakao SDK, etc.
│   │
│   └── DynamicThirdParty/        # Dynamic framework for Firebase
│       └── Project.swift         # Firebase dependencies
│
├── fastlane/                      # Deployment automation
│   └── Fastfile                  # Fastlane lanes for iOS deployment
│
├── .github/                       # GitHub configuration
│   └── workflows/
│       └── deploy-ios.yml        # CI/CD workflow
│
├── .gitsecret/                    # Encrypted secrets management
├── .serena/                       # Serena agent configuration
├── .claude/                       # Claude Code configuration
│
├── letscheers.xcworkspace/       # Generated workspace (by Tuist)
├── realtornote.xcworkspace/      # Legacy workspace (likely unused)
│
├── Tuist.swift                    # Tuist configuration (Xcode 16.0+)
├── Workspace.swift                # Tuist workspace definition
├── .mise.toml                     # Tool version management (Tuist 4.38.2)
├── .package.resolved              # SPM resolved versions
├── .gitignore
└── .DS_Store

```

## Module Descriptions

### App Module
**Type**: iOS Application
**Product**: `.app`
**Bundle ID**: `com.credif.letscheers`

The main application module containing all app-specific code.

#### Sources Organization

1. **Root Level**
   - `AppDelegate.swift`: App lifecycle and global configuration
   - `MainViewController.swift`: Main container view controller

2. **Datas/** - Data Layer
   - Core Data models and entities
   - User defaults wrapper
   - Data transfer objects

3. **Controllers/** - Business Logic
   - `LCModelController`: Core Data management
   - `LCExcelController`: Excel file handling
   - `LCFavoriteModelController`: Favorites management

4. **Views/** - Presentation Layer
   - Table view controllers for toast lists
   - Collection view controllers for categories
   - Custom table/collection view cells
   - Ad integration cells

5. **Extensions/** - Utility Extensions
   - Framework extensions (RxCocoa, GoogleMobileAds)
   - UIKit extensions
   - Custom protocols and helpers

### ThirdParty Module
**Type**: Static Framework
**Product**: `.staticFramework`
**Bundle ID**: `com.credif.letscheers.thirdparty`

Wraps static third-party dependencies:
- RxSwift/RxCocoa (Reactive programming)
- CoreXLSX (Excel file support)
- DropDown (UI component)
- KakaoSDK (Social sharing)
- LSExtensions (Utilities)
- Toast-Swift (Notifications)
- SwiftyGif (GIF support)
- StringLogger (Logging)

### DynamicThirdParty Module
**Type**: Dynamic Framework
**Product**: `.framework`
**Bundle ID**: `com.credif.letscheers.thirdparty.dynamic`

Wraps Firebase dynamic frameworks:
- FirebaseCrashlytics
- FirebaseAnalytics
- FirebaseMessaging
- FirebaseRemoteConfig

**Note**: Firebase must be in a dynamic framework to work correctly.

## Build Configurations

### Debug Configuration (`debug.xcconfig`)
- Automatic code signing
- Simulator support
- Development team: M29A6H95KD
- Debug optimization level
- Device family: iPhone and iPad (1,2)

### Release Configuration (`release.xcconfig`)
- Manual code signing (for CI/CD)
- Production optimizations
- Same deployment target and device support

## Key Files

### Tuist Manifests
- `Workspace.swift`: Defines workspace structure
- `Tuist.swift`: Global Tuist configuration
- `Projects/*/Project.swift`: Individual project definitions

### Configuration
- `.mise.toml`: Development tool versions
- `Configs/*.xcconfig`: Build settings
- `.gitignore`: Git exclusions

### CI/CD
- `.github/workflows/deploy-ios.yml`: Automated deployment
- `fastlane/Fastfile`: Build and upload scripts

## Dependencies Flow

```
App
├── ThirdParty (static)
│   ├── RxSwift
│   ├── KakaoSDK
│   ├── CoreXLSX
│   └── ...
├── DynamicThirdParty (dynamic)
│   └── Firebase*
└── GADManager (runtime, SPM)
```

## Data Flow

1. **User Input** → View Controllers
2. **View Controllers** → Controllers (business logic)
3. **Controllers** → Data Models (Core Data)
4. **Data Models** → NSFetchedResultsController
5. **NSFetchedResultsController** → RxSwift BehaviorSubject
6. **BehaviorSubject** → Table/Collection View binding

## Navigation Structure

```
MainViewController (container)
└── Tab/Navigation (via storyboard)
    ├── LCCategoryCollectionViewController
    │   └── LCToastTableViewController (per category)
    └── LCFavoriteTableViewController
```

## Asset Organization

- **Assets.xcassets**: App icon, images, colors
- **Storyboards**: Main.storyboard, LaunchScreen.storyboard
- **Data files**: Excel files with toast data (if present)

## Code Organization Principles

1. **MVC Architecture**: Clear separation of Model-View-Controller
2. **Protocol Extensions**: Protocol conformance in extensions
3. **Reactive Bindings**: RxSwift for data flow
4. **Modular Dependencies**: Separate framework modules
5. **Tuist Management**: No manual Xcode project editing

## Important Notes

- **Do not manually edit** `.xcodeproj` files - use Tuist manifests
- **Tuist generates** Xcode projects from Swift manifests
- **Only regenerate** when adding/removing files, not for edits
- **Extensions** organize code by protocol/functionality
- **LC prefix** identifies app-specific classes
