//
//  NavigationRouter.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

enum NavigationDestination: Hashable {
    case toastList(category: String, title: String)
    case favorites
    /// A swipeable deck of toasts (by their unique `no`) opened at `index`.
    case toastDetail(toastNos: [Int16], index: Int)
}

@MainActor
class NavigationRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    func navigate(to destination: NavigationDestination) {
        path.append(destination)
    }
    
    func openDetail(of toasts: [Toast], at index: Int) {
        navigate(to: .toastDetail(toastNos: toasts.map(\.no), index: index))
    }

    func navigateBack() {
        path.removeLast()
    }
    
    func navigateToRoot() {
        path.removeLast(path.count)
    }
}
