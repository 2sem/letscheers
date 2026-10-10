//
//  TargetDependency+.swift
//  AppManifests
//
//  Created by 영준 이 on 12/13/24.
//

import Foundation
import ProjectDescription

// MARK: External SPM packages
public extension TargetDependency {
    class externals {
        public static let gadManager: TargetDependency = .external(name: "GADManager")
        public static let coreXLSX: TargetDependency = .external(name: "CoreXLSX")
        public static let kakaoSDK: TargetDependency = .external(name: "KakaoSDK")
        public static let lsExtensions: TargetDependency = .external(name: "LSExtensions")
        public static let stringLogger: TargetDependency = .external(name: "StringLogger")

        public class firebase {
            public static let core: TargetDependency = .external(name: "FirebaseCore")
            public static let crashlytics: TargetDependency = .external(name: "FirebaseCrashlytics")
            public static let analytics: TargetDependency = .external(name: "FirebaseAnalytics")
            public static let messaging: TargetDependency = .external(name: "FirebaseMessaging")
            public static let remoteConfig: TargetDependency = .external(name: "FirebaseRemoteConfig")
        }
    }
}
