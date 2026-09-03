//
//  TargetDependency+.swift
//  AppManifests
//
//  Created by 영준 이 on 12/13/24.
//

import Foundation
import ProjectDescription

// MARK: Store Projects
public extension TargetDependency {
    private static func targetProject(_ name: String) -> TargetDependency {
        return .project(target: name, path: .projects(name))
    }

    class externals {
        public class firebase {
            public static let core: TargetDependency = .external(name: "FirebaseCore")
            public static let crashlytics: TargetDependency = .external(name: "FirebaseCrashlytics")
            public static let analytics: TargetDependency = .external(name: "FirebaseAnalytics")
            public static let messaging: TargetDependency = .external(name: "FirebaseMessaging")
            public static let remoteConfig: TargetDependency = .external(name: "FirebaseRemoteConfig")
        }
    }
    
    class Projects {
        public static let ThirdParty: TargetDependency = .targetProject("ThirdParty")
    }
}
