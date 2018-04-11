//
//  LCDefaults.swift
//  letscheers
//
//  Created by 영준 이 on 2017. 4. 11..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit

class LCDefaults{
    static var Defaults : UserDefaults{
        get{
            return UserDefaults.standard;
        }
    }
    
    class Keys{
        static let LastFullAdShown = "LastFullAdShown";
        static let LastShareShown = "LastShareShown";
        static let LastRewardAdShown = "LastRewardAdShown";
    }
    
    static var LastFullAdShown : Date{
        get{
            var seconds = Defaults.double(forKey: Keys.LastFullAdShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastFullAdShown);
        }
    }
    
    static var LastShareShown : Date{
        get{
            var seconds = Defaults.double(forKey: Keys.LastShareShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastShareShown);
        }
    }
    
    static var LastRewardAdShown : Date{
        get{
            var seconds = Defaults.double(forKey: Keys.LastRewardAdShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastRewardAdShown);
        }
    }
}
