//
//  GADBannerView+Unvisible.swift
//  letscheers
//
//  Created by 영준 이 on 2018. 4. 6..
//  Copyright © 2018년 leesam. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

struct LSGoogleBannerContainer<Container>{
    static var bannerName : String { return "BottomBanner" };

    let container : Container;
    init(_ container : Container) {
        self.container = container;
    }
}

/**
    I tried to inherit from GADBannerViewDelegate, but I coudn't be compiled : segmentation fault.
 
    usage: self.google.loadUnvisibleBottomBanner(self.bottomBannerView);
 */
protocol LSUnvisibleGoogleBottomBanner{
    associatedtype View
    var googlex : LSGoogleBannerContainer<View>{ get }
    var bottomBannerVisibleLayoutConstraint : NSLayoutConstraint!{ get }
    var bottomBannerUnvisibleLayoutConstraint : NSLayoutConstraint!{ get }
}

extension LSUnvisibleGoogleBottomBanner{
    var googlex : LSGoogleBannerContainer<Self>{
        get{
            return LSGoogleBannerContainer(self); //
        }
    }
    
    func toggleBottomBannerContraint(value : Bool, constraintOn : NSLayoutConstraint, constarintOff : NSLayoutConstraint){
        if constraintOn.isActive{
            constraintOn.isActive = value;
            constarintOff.isActive = !value;
        }else{
            constarintOff.isActive = !value;
            constraintOn.isActive = value;
        }
    }
    
    func showBanner(_ banner: GADBannerView, visible: Bool){
        guard self.bottomBannerVisibleLayoutConstraint != nil
            && self.bottomBannerUnvisibleLayoutConstraint != nil else {
            return;
        }
        
        self.toggleBottomBannerContraint(value: visible,
            constraintOn: self.bottomBannerVisibleLayoutConstraint,
            constarintOff: self.bottomBannerUnvisibleLayoutConstraint);
        
        if visible{
            print("show banner");
        }else{
            print("hide banner");
        }
        
        banner.isHidden = !visible;
    }
    
    /// MARK: GADBannerViewDelegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.showBanner(bannerView, visible: true);
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        self.showBanner(bannerView, visible: false);
    }
}

extension LSGoogleBannerContainer where Container : UIViewController{
    /**
        load unit id for admob(and start showing bottom banner).
        you don't need to implment GADBannerViewDelegate to toggle layout constraints
        * require inherit from GADBannerViewDelegate
 
     - Parameter banner: banner for google admob
     - Parameter unitName: default unit id name - you should write unit name of bottom banner info.Plist GoogleADUnitID/{unitName} -- default "ButtomBanner"
     - Parameter autoLoad need to load banner auto matically
    */
    func loadUnvisibleBottomBanner(_ banner: GADBannerView, unitName : String = LSGoogleBannerContainer.bannerName, autoLoad : Bool = false){
        banner.isHidden = false;
        banner.isAutoloadEnabled = autoLoad;
        banner.loadUnitId(name: unitName);
    }
}

