//
//  LCDefaults.swift
//  letscheers
//
//  Created by 영준 이 on 2017. 4. 11..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import StringLogger
import AppTrackingTransparency

class LSDefaults{
    static var Defaults : UserDefaults{
        get{
            return UserDefaults.standard;
        }
    }
    
    class Keys{
        static let LastFullADShown = "LastFullADShown";
        static let LastShareShown = "LastShareShown";
        static let LastRewardAdShown = "LastRewardAdShown";
        static let LastOpeningAdPrepared = "LastOpeningAdPrepared";

        static let LaunchCount = "LaunchCount";

        static let AdsShownCount = "AdsShownCount";
        static let AdsTrackingRequested = "AdsTrackingRequested";

        static let LastDataVersion = "LastDataVersion";
    }
    
    static var LastFullADShown : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastFullADShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastFullADShown);
        }
    }
    
    static var LastShareShown : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastShareShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastShareShown);
        }
    }
    
    static var LastOpeningAdPrepared : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastOpeningAdPrepared);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastOpeningAdPrepared);
        }
    }
    
    static var LastRewardAdShown : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastRewardAdShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastRewardAdShown);
        }
    }
    
    static func increaseLaunchCount(){
        self.LaunchCount = self.LaunchCount.advanced(by: 1);
    }
    
    static var LaunchCount : Int{
        get{
            //UIApplication.shared.version
            return Defaults.integer(forKey: Keys.LaunchCount);
        }

        set(value){
            Defaults.set(value, forKey: Keys.LaunchCount);
        }
    }

    static var LastDataVersion : String?{
        get{
            return Defaults.string(forKey: Keys.LastDataVersion);
        }

        set(value){
            Defaults.set(value, forKey: Keys.LastDataVersion);
        }
    }
}

extension LSDefaults{
    static var AdsShownCount : Int{
        get{
            return Defaults.integer(forKey: Keys.AdsShownCount);
        }
        
        set{
            Defaults.set(newValue, forKey: Keys.AdsShownCount);
        }
    }
    
    static func increateAdsShownCount(){
        guard AdsShownCount < 3 else {
            return
        }
        
        AdsShownCount += 1;
        "Ads Shown Count[\(AdsShownCount)]".debug();
    }
    
    static var AdsTrackingRequested : Bool{
        get{
            return Defaults.bool(forKey: Keys.AdsTrackingRequested);
        }
        
        set{
            Defaults.set(newValue, forKey: Keys.AdsTrackingRequested);
        }
    }
    
    static func requestAppTrackingIfNeed() -> Bool{
        guard !AdsTrackingRequested else{
            return false;
        }
        
        guard LaunchCount > 2 else{
//            AdsShownCount += 1;
            return false;
        }
        
        guard #available(iOS 14.0, *) else{
            return false;
        }

        ATTrackingManager.requestTrackingAuthorization { status in
            AdsTrackingRequested = true;
        }

        return true;
    }
}
