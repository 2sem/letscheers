//
//  AppDelegate.swift
//  letscheers
//
//  Created by 영준 이 on 2017. 1. 7..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GADInterstialManagerDelegate, ReviewManagerDelegate, GADRewardManagerDelegate {

    var window: UIWindow?
    var fullAd : GADInterstitialManager?;
    var rewardAd : GADRewardManager?;
    var reviewManager : ReviewManager?;
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GADMobileAds.configure(withApplicationID: "ca-app-pub-9684378399371172~8024571245");
        
        // MARK: Sets review Ads interval - 2 days
        self.reviewManager = ReviewManager(self.window!, interval: 60.0 * 60 * 24 * 2);
        self.reviewManager?.delegate = self;
        //self.reviewManager?.show();
        
        // MARK: Sets reward Ads interval - 6 hours
        self.rewardAd = GADRewardManager(self.window!, unitId: GADInterstitial.loadUnitId(name: "RewardAd") ?? "", interval: 60.0 * 60.0 * 6); //
        self.rewardAd?.delegate = self;
        
        // MARK: Sets interstitial Ads interval - 3 hours
        self.fullAd = GADInterstitialManager(self.window!, unitId: GADInterstitial.loadUnitId(name: "FullAd") ?? "", interval: 60.0 * 60 * 3);
        self.fullAd?.delegate = self;
        self.fullAd?.canShowFirstTime = false;
        
        //Shows interstitial Ads If this time is over reward ads interval
        if self.rewardAd?.canShow ?? false{
            self.fullAd?.show();
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        guard self.reviewManager?.canShow ?? false else{
            return;
        }
        self.reviewManager?.show();
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
        LCModelController.shared.saveChanges();
    }

    // MARK: GADInterstialManagerDelegate
    func GADInterstialGetLastShowTime() -> Date {
        return LCDefaults.LastFullAdShown;
    }
    
    func GADInterstialUpdate(showTime: Date) {
        LCDefaults.LastFullAdShown = showTime;
    }
    
    func GADInterstialWillLoad() {
        
    }
    
    // MARK: ReviewManagerDelegate
    func reviewGetLastShowTime() -> Date {
        return LCDefaults.LastShareShown;
    }
    
    func reviewUpdate(showTime: Date) {
        LCDefaults.LastShareShown = showTime;
    }
    
    // MARK: GADRewardManagerDelegate
    func GADRewardGetLastShowTime() -> Date {
        return LCDefaults.LastRewardAdShown;
    }
    
    func GADRewardUserCompleted() {
        LCDefaults.LastRewardAdShown = Date();
    }
    
    func GADRewardUpdate(showTime: Date) {
        
    }
}

