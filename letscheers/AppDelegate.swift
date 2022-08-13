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
import StoreKit
import GADManager
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ReviewManagerDelegate, GADRewardManagerDelegate {

    var window: UIWindow?
    static var sharedWindow: UIWindow? {
        return (UIApplication.shared.delegate as? AppDelegate)?.window
    }
    enum GADUnitName : String{
        case full = "FullAd"
        case launch = "Launch"
    }
    static var sharedGADManager : GADManager<GADUnitName>?;
    var rewardAd : GADRewardManager?;
    var reviewManager : ReviewManager?;
    let reviewInterval = 10;
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIApplication.shared.isIPad ? .all : [.portrait, .portraitUpsideDown];
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil);
        
        // MARK: Sets review Ads interval - 2 days
        self.reviewManager = ReviewManager(self.window!, interval: 60.0 * 60 * 24 * 2);
        self.reviewManager?.delegate = self;
        //self.reviewManager?.show();
        
        // MARK: Sets reward Ads interval - 6 hours
        self.rewardAd = GADRewardManager(self.window!, unitId: GADInterstitialAd.loadUnitId(name: "RewardAd") ?? "", interval: 60.0 * 60.0 * 6); //
        self.rewardAd?.delegate = self;
        
        let adManager = GADManager<GADUnitName>.init(self.window!);
        AppDelegate.sharedGADManager = adManager;
        adManager.delegate = self;
    #if DEBUG
        adManager.prepare(interstitialUnit: .full, interval: 60.0);
        adManager.prepare(openingUnit: .launch, isTest: true, interval: 60.0); //
    #else
        adManager.prepare(interstitialUnit: .full, interval: 60.0); // * 60.0 * 6
        adManager.prepare(openingUnit: .launch, interval: 60.0 * 5); //
    #endif
        adManager.canShowFirstTime = true;
        
        LSDefaults.increaseLaunchCount();
        
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
        guard LSDefaults.LaunchCount % reviewInterval != 0 else{
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
            LSDefaults.increaseLaunchCount();
            return;
        }
        
        /*guard self.reviewManager?.canShow ?? false else{
            return;
        }
        self.reviewManager?.show();*/
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("app become active");
        #if DEBUG
        let test = true;
        #else
        let test = false;
        #endif
        
        guard !LSDefaults.requestAppTrackingIfNeed() else{
            return;
        }
        
        AppDelegate.sharedGADManager?.show(unit: .launch, isTest: test, completion: { (unit, ad, result) in
            
        })
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
        LCModelController.shared.saveChanges();
    }
    
    // MARK: ReviewManagerDelegate
    func reviewGetLastShowTime() -> Date {
        return LSDefaults.LastShareShown;
    }
    
    func reviewUpdate(showTime: Date) {
        LSDefaults.LastShareShown = showTime;
    }
    
    // MARK: GADRewardManagerDelegate
    func GADRewardGetLastShowTime() -> Date {
        return LSDefaults.LastRewardAdShown;
    }
    
    func GADRewardUserCompleted() {
        LSDefaults.LastRewardAdShown = Date();
    }
    
    func GADRewardUpdate(showTime: Date) {
        
    }
}

extension AppDelegate : GADManagerDelegate{
    typealias E = GADUnitName
    
    func GAD<E>(manager: GADManager<E>, lastPreparedTimeForUnit unit: E) -> Date{
        let now = Date();
  //        if RSDefaults.LastOpeningAdPrepared > now{
  //            RSDefaults.LastOpeningAdPrepared = now;
  //        }

          return LSDefaults.LastOpeningAdPrepared;
          //Calendar.current.component(<#T##component: Calendar.Component##Calendar.Component#>, from: <#T##Date#>)
    }
    
    func GAD<E>(manager: GADManager<E>, updateLastPreparedTimeForUnit unit: E, preparedTime time: Date){
        LSDefaults.LastOpeningAdPrepared = time;
        
        //RNInfoTableViewController.shared?.needAds = false;
        //RNFavoriteTableViewController.shared?.needAds = false;
    }
    
    func GAD<E>(manager: GADManager<E>, didDismissADForUnit unit: E) where E : Hashable, E : RawRepresentable, E.RawValue == String {
        LSDefaults.increateAdsShownCount();
    }
    
    func GAD<E>(manager: GADManager<E>, lastShownTimeForUnit unit: E) -> Date{
        let now = Date();
        if LSDefaults.LastFullAdShown > now{
            LSDefaults.LastFullAdShown = now;
        }
        
        return LSDefaults.LastFullAdShown;
        //Calendar.current.component(<#T##component: Calendar.Component##Calendar.Component#>, from: <#T##Date#>)
    }
    
    func GAD<E>(manager: GADManager<E>, updatShownTimeForUnit unit: E, showTime time: Date){
        LSDefaults.LastFullAdShown = time;
        
        //RNInfoTableViewController.shared?.needAds = false;
        //RNFavoriteTableViewController.shared?.needAds = false;
    }
}

