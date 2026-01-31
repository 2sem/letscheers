//
//  Tuist.swift
//  letscheersManifests
//
//  Created by 영준 이 on 3/9/25.
//

import ProjectDescription

let tuist = Tuist(
    project: .tuist(
        compatibleXcodeVersions: .upToNextMajor("16.0"),
//                    swiftVersion: "",
//                    plugins: <#T##[PluginLocation]#>,
        generationOptions: .options(
            enableCaching: true,
            registryEnabled: true
        )
//                    installOptions: <#T##Tuist.InstallOptions#>)
    )
)
