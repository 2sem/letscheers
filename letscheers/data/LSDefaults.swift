//
//  LCDefaults.swift
//  letscheers
//
//  Created by 영준 이 on 2017. 4. 11..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit

class LSDefaults{
    static var Defaults : UserDefaults{
        get{
            return UserDefaults.standard;
        }
    }
    
    class Keys{
        static let LastFullAdShown = "LastFullAdShown";
        static let LastShareShown = "LastShareShown";
        static let LastRewardAdShown = "LastRewardAdShown";
        static let LastOpeningAdPrepared = "LastOpeningAdPrepared";
        
        static let LaunchCount = "LaunchCount";
    }
    
    static var LastFullAdShown : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastFullAdShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastFullAdShown);
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
}
