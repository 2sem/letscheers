import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "ThirdParty",
    packages: [
        .package(id: "coreoffice.CoreXLSX", from: "0.14.1"),
        .remote(url: "https://github.com/AssistoLab/DropDown",
                requirement: .branch("master")),
        .package(id: "kakao.kakao-ios-sdk", from: "2.22.2"),
        .remote(url: "https://github.com/2sem/LProgressWebViewController",
                requirement: .upToNextMajor(from: "3.1.0")),
        .remote(url: "https://github.com/2sem/LSCountDownLabel",
                requirement: .upToNextMajor(from: "0.0.5")),
//        .local(path: "../../../../../pods/LSCountDownLabel/src/LSCountDownLabel"),
        .package(id: "scalessec.Toast-Swift", from: "5.1.0"),
        .package(id: "alexiscreuzot.SwiftyGif", from: "5.4.5"),
        .remote(url: "https://github.com/2sem/LSExtensions",
                requirement: .exact("0.1.22")),
        .remote(url: "https://github.com/2sem/StringLogger",
                requirement: .upToNextMajor(from: "0.7.0"))
    ],
    targets: [
        .target(
            name: "ThirdParty",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: .appBundleId.appending(".thirdparty"),
            dependencies: [.package(product: "CoreXLSX", type: .runtime),
                           .package(product: "DropDown", type: .runtime),
                           .package(product: "KakaoSDK", type: .runtime),
                           .package(product: "LSExtensions", type: .runtime),
                           .package(product: "StringLogger", type: .runtime),
            ]
        ),
    ]
)
