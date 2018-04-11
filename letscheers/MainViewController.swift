//
//  ViewController.swift
//  letscheers
//
//  Created by 영준 이 on 2017. 1. 7..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MainViewController: UIViewController, LSUnvisibleBottomBanner, GADBannerViewDelegate {
    @IBOutlet var constraint_bottomBanner_Bottom: NSLayoutConstraint!
    var constraint_bottomBanner_Top : NSLayoutConstraint!;
    
    @IBOutlet weak var bottomBannerView: GADBannerView!
    @IBOutlet weak var containerView: UIView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.constraint_bottomBanner_Top = self.bottomBannerView.topAnchor.constraint(equalTo: self.view.bottomAnchor);
        self.google.loadUnvisibleBottomBanner(self.bottomBannerView);
        self.bottomBannerView.isAutoloadEnabled = true;
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onReviewButton(_ sender: UIButton) {
        UIApplication.shared.openReview();
    }
    
    // MARK: UnvisibleBottomBanner
    var bottomBannerVisibleLayoutConstraint: NSLayoutConstraint!{
        return self.constraint_bottomBanner_Bottom;
    }
    
    var bottomBannerUnvisibleLayoutConstraint: NSLayoutConstraint!{
        return self.constraint_bottomBanner_Top;
    }
    
    var keyboardEnabled = false;
    func keyboardWillShow(noti: Notification){
        print("keyboard will show move view to upper -- \(noti.object)");
        //        if self.nativeTextView.isFirstResponder {
        if !keyboardEnabled {
            keyboardEnabled = true;
            //            self.viewContainer.frame.origin.y -= 180;
            var frame = noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect;
            
            // - self.bottomBannerView.frame.height
            if true{ //!self.isIPhone
                var remainHeight = (frame?.height ?? 0);//self.view.frame.height -
                //                var remainHeight : CGFloat = 100.0;
                self.constraint_bottomBanner_Top.constant = -remainHeight;
                self.constraint_bottomBanner_Bottom.constant = -remainHeight;
            }
            
            //            self.viewContainer.layoutIfNeeded();
        };
        //native y -= (keyboard height - bottom banner height)
        // keyboard top == native bottom
        //        }
    }
    
    func keyboardWillHide(noti: Notification){
        print("keyboard will hide move view to lower  -- \(noti.object)");
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

