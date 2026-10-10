import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "ThirdParty",
    targets: [
        .target(
            name: "ThirdParty",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: .appBundleId.appending(".thirdparty"),
            dependencies: [.external(name: "CoreXLSX"),
                           .external(name: "DropDown"),
                           .external(name: "KakaoSDK"),
                           .external(name: "LSExtensions"),
                           .external(name: "StringLogger"),
            ]
        ),
    ]
)
