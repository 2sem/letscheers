import ProjectDescription
import ProjectDescriptionHelpers

let skAdNetworks: [Plist.Value] = ["cstr6suwn9",
                                   "4fzdc2evr5",
                                   "2fnua5tdw4",
                                   "ydx93a7ass",
                                   "5a6flpkh64",
                                   "p78axxw29g",
                                   "v72qych5uu",
                                   "c6k4g5qg8m",
                                   "s39g8k73mm",
                                   "3qy4746246",
                                   "3sh42y64q3",
                                   "f38h382jlk",
                                   "hs6bdukanm",
                                   "prcb7njmu6",
                                   "wzmmz9fp6w",
                                   "yclnxrl5pm",
                                   "4468km3ulz",
                                   "t38b2kh725",
                                   "7ug5zh24hu",
                                   "9rd848q2bz",
                                   "n6fk4nfna4",
                                   "kbd757ywx3",
                                   "9t245vhmpl",
                                   "2u9pt9hc89",
                                   "8s468mfl3y",
                                   "av6w8kgt66",
                                   "klf5c3l5u5",
                                   "ppxm28t8ap",
                                   "424m5254lk",
                                   "uw77j35x4d",
                                   "e5fvkxwrpn",
                                   "zq492l623r",
                                   "3qcr597p9d"
    ]
    .map{ .dictionary(["SKAdNetworkIdentifier" : "\($0).skadnetwork"]) }

let project = Project(
    name: "App",
    packages: [
        .remote(url: "https://github.com/2sem/GADManager",
                requirement: .upToNextMajor(from: "1.3.5")),
//        .local(path: .relativeToRoot("../../../pods/GADManager/src/GADManager"))
    ],
    settings: .settings(configurations: [
        .debug(
            name: "Debug",
            xcconfig: "Configs/debug.xcconfig"),
        .release(
            name: "Release",
            xcconfig: "Configs/release.xcconfig")
    ]),
    targets: [
        .target(
            name: "App",
            destinations: .iOS,
            product: .app,
            bundleId: .appBundleId,
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen",
                    "UIMainStoryboardFile": "Main",
                    "UIUserInterfaceStyle": "Dark",
                    "GADApplicationIdentifier": "ca-app-pub-9684378399371172~8024571245",
                    "GADUnitIdentifiers": ["Launch" : "ca-app-pub-9684378399371172/4877474273",
                                           "FullAd" : "ca-app-pub-9684378399371172/4931504044"],
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
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .Projects.ThirdParty,
                .Projects.DynamicThirdParty,
                .package(product: "GADManager", type: .runtime)
            ]
        )
    ]
)
