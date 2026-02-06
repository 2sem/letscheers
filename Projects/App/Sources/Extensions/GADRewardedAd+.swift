//
//  GADRewardedAd+.swift
//  letscheers
//
//  Created by 영준 이 on 2021/11/21.
//  Copyright © 2021 leesam. All rights reserved.
//

import Foundation
import GoogleMobileAds

extension GoogleMobileAds.RewardedAd{
    func isReady(for viewController: UIViewController? = nil) -> Bool{
        do{
            let rootViewController: UIViewController?
            if let providedViewController = viewController {
                rootViewController = providedViewController
            } else {
                // Use UIWindowScene.windows instead of deprecated UIApplication.shared.windows
                rootViewController = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first { $0.isKeyWindow }?
                    .rootViewController
            }

            if let viewController = rootViewController {
                try self.canPresent(from: viewController);
                return true;
            }
            return false
        }catch{}

        return false;
    }
}
