//
//  ViewController.swift
//  letscheers
//
//  Created by 영준 이 on 2017. 1. 7..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import GoogleMobileAds
import LSExtensions

class MainViewController: UIViewController, LSUnvisibleGoogleBottomBanner, GADBannerViewDelegate {
    @IBOutlet var constraint_bottomBanner_Bottom: NSLayoutConstraint!
    var constraint_bottomBanner_Top : NSLayoutConstraint!;
    
    @IBOutlet weak var bottomBannerView: GADBannerView!
    @IBOutlet weak var containerView: UIView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.constraint_bottomBanner_Top = self.bottomBannerView.topAnchor.constraint(equalTo: self.view.bottomAnchor);
        self.googlex.loadUnvisibleBottomBanner(self.bottomBannerView, autoLoad: true);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onReviewButton(_ sender: UIButton) {
        UIApplication.shared.openReview();
    }
    
    // MARK: LSUnvisibleGoogleBottomBanner
    var bottomBannerVisibleLayoutConstraint: NSLayoutConstraint!{
        return self.constraint_bottomBanner_Bottom;
    }
    
    var bottomBannerUnvisibleLayoutConstraint: NSLayoutConstraint!{
        return self.constraint_bottomBanner_Top;
    }
    
    // unused keyboard toggle
    var keyboardEnabled = false;
    @objc func keyboardWillShow(noti: Notification){
        print("keyboard will show move view to upper");
        guard !keyboardEnabled else{
            return;
        }
        
        keyboardEnabled = true;
        let frame = noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect;
        
        // - self.bottomBannerView.frame.height
        if true{ //!self.isIPhone
            let remainHeight = (frame?.height ?? 0);//self.view.frame.height -
            //                var remainHeight : CGFloat = 100.0;
            self.constraint_bottomBanner_Top.constant = -remainHeight;
            self.constraint_bottomBanner_Bottom.constant = -remainHeight;
        }
    }
    
    @objc func keyboardWillHide(noti: Notification){
        print("keyboard will hide move view to lower");
        //        if self.nativeTextView.isFirstResponder{
        
        //        }
        //&&
        if keyboardEnabled {
            keyboardEnabled = false;
            //            self.viewContainer.frame.origin.y += 180;
            
            self.constraint_bottomBanner_Top.constant = 0;
            self.constraint_bottomBanner_Bottom.constant = 0;
            //            self.viewContainer.layoutIfNeeded();
        };
    }

}

