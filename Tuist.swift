//
//  Tuist.swift
//  letscheersManifests
//
//  Created by 영준 이 on 3/9/25.
//

import ProjectDescription

let tuist = Tuist(
    fullHandle: "gamehelper/letscheers",
    project: .tuist(
        compatibleXcodeVersions: .list([.upToNextMajor("26.0"), .upToNextMajor("27.0")]),
//                    swiftVersion: "",
//                    plugins: <#T##[PluginLocation]#>,
        generationOptions: .options(
            enableCaching: true,
            registryEnabled: true
        )
//                    installOptions: <#T##Tuist.InstallOptions#>)
    )
)
