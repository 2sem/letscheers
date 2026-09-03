// swift-tools-version: 5.9

import PackageDescription

#if TUIST
    import ProjectDescription

    // let packageSettings = PackageSettings(
    //     // Customize the product types for specific package product
    //     // Default is .staticFramework
    //     // productTypes: ["Alamofire": .framework,]
    //     productTypes: [
    //         // "FirebaseCore": .framework,
    //         // "FirebaseCrashlytics": .framework,
    //         // "FirebaseAnalytics": .framework,
    //         // "FirebaseMessaging": .framework,
    //         // "FirebaseRemoteConfig": .framework,
    //     ],
    //     // Firebase's Obj-C internal targets (e.g. FirebaseCoreInternal,
    //     // FirebaseRemoteConfigInternal) only get pulled into a consuming
    //     // dynamic framework's link when -ObjC forces the whole archive in.
    //     baseSettings: .settings(base: ["OTHER_LDFLAGS": "$(inherited) -ObjC"])
    // )
#endif

let package = Package(
    name: "letscheers",
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMinor(from: "12.18.0")),
    ]
)
