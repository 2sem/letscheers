# Project Overview: letscheers (술마셔 건배사)

## Purpose
letscheers is an iOS app that provides Korean drinking toast phrases and cheers (건배사). The app helps users find and share appropriate toasts for various occasions.

## Key Information
- **App Name**: 술마셔 건배사 (Let's Cheers)
- **Bundle ID**: com.credif.letscheers
- **iTunes App ID**: 1193053041
- **Current Version**: 1.1.17
- **Minimum iOS**: 13.0
- **Target Devices**: iPhone and iPad

## Tech Stack

### Core Technologies
- **Language**: Swift 5.0
- **UI Framework**: UIKit (Interface Builder + Programmatic)
- **Architecture**: MVC
- **Project Management**: Tuist 4.38.2
- **Xcode**: 16.0+ compatible (currently using 16.2)
- **Deployment**: iOS 13.0+

### Key Dependencies

#### Static Framework (ThirdParty)
- **RxSwift 5.1+**: Reactive programming
- **RxCocoa 5.1+**: Reactive extensions for Cocoa
- **CoreXLSX 0.14.1**: Excel file handling
- **DropDown**: Dropdown UI component
- **KakaoSDK 2.22.2+**: Kakao platform integration for sharing
- **Toast-Swift 5.1+**: Toast notifications
- **SwiftyGif 5.4.5+**: GIF support
- **LSExtensions 0.1.22**: Custom utility extensions
- **LSCountDownLabel 0.0.5+**: Countdown timer label
- **StringLogger 0.7.0+**: Logging utility

#### Dynamic Framework (DynamicThirdParty)
- **Firebase 11.14.0+**:
  - FirebaseCrashlytics
  - FirebaseAnalytics
  - FirebaseMessaging
  - FirebaseRemoteConfig

#### Runtime Packages
- **GADManager 1.3.5+**: Google Mobile Ads integration

### Project Structure
```
letscheers/
├── Tuist/                      # Tuist configuration
│   ├── Package.swift          # Tuist dependencies
│   └── ProjectDescriptionHelpers/  # Helper extensions
├── Projects/
│   ├── App/                   # Main application
│   │   ├── Sources/
│   │   │   ├── AppDelegate.swift
│   │   │   ├── MainViewController.swift
│   │   │   ├── Datas/         # Data models
│   │   │   ├── Extensions/    # Swift extensions
│   │   │   ├── Controllers/   # Model controllers
│   │   │   └── Views/         # View controllers
│   │   ├── Resources/         # Assets, storyboards
│   │   └── Configs/          # Build configurations
│   ├── ThirdParty/           # Static framework wrapper
│   └── DynamicThirdParty/    # Dynamic framework wrapper
├── fastlane/                  # CI/CD automation
├── .github/workflows/         # GitHub Actions
└── Workspace.swift           # Tuist workspace definition
```

## Key Features
- Browse toasts by category
- Search functionality
- Favorite toasts
- Share toasts via Kakao
- Google Mobile Ads integration
- Dark mode support
