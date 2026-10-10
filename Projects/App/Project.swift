import ProjectDescription
import ProjectDescriptionHelpers

let skAdNetworkIDs: [String] = [
    "cstr6suwn9", "4fzdc2evr5", "2fnua5tdw4", "ydx93a7ass", "p78axxw29g",
    "v72qych5uu", "ludvb6z3bs", "cp8zw746q7", "3sh42y64q3", "c6k4g5qg8m",
    "s39g8k73mm", "wg4vff78zm", "3qy4746246", "f38h382jlk", "hs6bdukanm",
    "mlmmfzh3r3", "v4nxqhlyqp", "wzmmz9fp6w", "su67r6k2v3", "yclnxrl5pm",
    "t38b2kh725", "7ug5zh24hu", "gta9lk7p23", "vutu7akeur", "y5ghdn5j9k",
    "v9wttpbfk9", "n38lu8286q", "47vhws6wlr", "kbd757ywx3", "9t245vhmpl",
    "a2p9lx4jpn", "22mmun2rn5", "44jx6755aq", "k674qkevps", "4468km3ulz",
    "2u9pt9hc89", "8s468mfl3y", "klf5c3l5u5", "ppxm28t8ap", "kbmxgpxpgc",
    "uw77j35x4d", "578prtvx9j", "4dzt52r2t5", "tl55sbb4fm", "c3frkrj4fj",
    "e5fvkxwrpn", "8c4e2ghe7u", "3rd42ekr43", "97r2b46745", "3qcr597p9d"
]

let skAdNetworks: [Plist.Value] = skAdNetworkIDs
    .map { .dictionary(["SKAdNetworkIdentifier": .string("\($0).skadnetwork")]) }

// Bump both together for a release; the build number must be strictly higher than the last submitted one.
let marketingVersion = "2.2.0"
let buildNumber = "3"

let project = Project(
    name: "App",
    settings: .settings(
        base: [
            "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
            "CLANG_ENABLE_MODULES": "YES",
            "CURRENT_PROJECT_VERSION": .string(buildNumber),
            "DEVELOPMENT_TEAM": "M29A6H95KD",
            "INFOPLIST_KEY_LSApplicationCategoryType": "public.app-category.lifestyle",
            "MARKETING_VERSION": .string(marketingVersion),
            "PRODUCT_BUNDLE_IDENTIFIER": "com.credif.letscheers",
            "PRODUCT_NAME": "$(TARGET_NAME)",
            "SUPPORTS_MACCATALYST": "NO",
            "SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD": "NO",
            "SUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD": "NO",
            "SWIFT_OBJC_BRIDGING_HEADER": "Sources/letscheers-Bridging-Header.h",
            "TARGETED_DEVICE_FAMILY": "1,2",
            // LSExtensions (static) adds Swift extensions on UIKit classes; without -ObjC the
            // linker drops them and calls crash with "unrecognized selector".
            "OTHER_LDFLAGS": "$(inherited) -ObjC",
        ],
        configurations: [
            .debug(name: "Debug", settings: [
                "CODE_SIGN_IDENTITY": "Apple Development",
                "CODE_SIGN_STYLE": "Automatic",
                "PROVISIONING_PROFILE_SPECIFIER": "",
                "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
            ]),
            .release(name: "Release", settings: [
                "CODE_SIGN_IDENTITY": "iPhone Distribution",
                "CODE_SIGN_STYLE": "Manual",
                "PROVISIONING_PROFILE_SPECIFIER": "letscheers",
            ]),
        ]
    ),
    targets: [
        .target(
            name: "App",
            destinations: .iOS,
            product: .app,
            bundleId: .appBundleId,
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen",
                    "UIUserInterfaceStyle": "Dark",
                    "GADApplicationIdentifier": "ca-app-pub-9684378399371172~8024571245",
                    "GADUnitIdentifiers": ["Launch" : "ca-app-pub-9684378399371172/4877474273",
                                           "FullAd" : "ca-app-pub-9684378399371172/4931504044",
                                           "NativeAd" : "ca-app-pub-9684378399371172/1903064527",
                                           "ToastListNativeAd" : "ca-app-pub-9684378399371172/7022853663"],
                    "Itunes App Id": "1193053041",
                    "NSUserTrackingUsageDescription": "맞춤형 광고 허용을 통해 개발자에게 더 많이 후원할 수 있습니다",
                    "SKAdNetworkItems": .array(skAdNetworks),
                    "ITSAppUsesNonExemptEncryption": "NO",
                    "CFBundleShortVersionString": "${MARKETING_VERSION}",
                    "CFBundleDisplayName": "술마셔 건배사",
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitaryLoadsForMedia" : true,
                        "NSAllowsArbitraryLoads" : true,
                        "NSAllowsArbitraryLoadsInWebContent" : true
                    ],
                    "CFBundleURLTypes": .array([[
                        "CFBundleTypeRole": "Editor",
                        "CFBundleURLSchemes": .array(["kakao3abbe5c2685a23c91e101aedb00c6d12"])
                    ]]),
                    "KAKAO_APP_KEY": "3abbe5c2685a23c91e101aedb00c6d12",
                    "LSApplicationQueriesSchemes": .array(["kakaotalk-5.9.7",
                                                          "kakao3abbe5c2685a23c91e101aedb00c6d12",
                                                          "kakaolink",
                                                          "fb",
                                                          "fbapi",
                                                          "fb-message-api",
                                                          "fbauth2"]),
                    "UIViewControllerBasedStatusBarAppearance": true
                ]
            ),
            buildableFolders: [
                "Sources",
                // Encrypted copy of cheers.xlsx (git-secret); must not ship in the app bundle.
                .folder("Resources", exceptions: [.exception(excluded: ["Excel/cheers.xlsx.secret"])]),
            ],
            dependencies: [
                .externals.coreXLSX,
                .externals.kakaoSDK,
                .externals.lsExtensions,
                .externals.stringLogger,
                .externals.gadManager,
                .externals.firebase.core,
                .externals.firebase.crashlytics,
                .externals.firebase.analytics,
            ]
        )
    ]
)
