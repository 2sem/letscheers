//
//  LCCategoryCollectionViewAdsCell.swift
//  letscheers
//
//  Created by 영준 이 on 2020/07/04.
//  Copyright © 2020 leesam. All rights reserved.
//

import UIKit
import GoogleMobileAds

class GADNativeCollectionViewCell: UICollectionViewCell {
    #if DEBUG
    let gadUnit : String = "ca-app-pub-3940256099942544/3986624511";
    #else
    let gadUnit : String = "ca-app-pub-9684378399371172/1903064527";
    #endif
    
    var rootViewController : UIViewController?;
    var gadLoader : GADAdLoader?;
    var tapGesture : UITapGestureRecognizer!;
    
    @IBOutlet weak var nativeAdView: GADNativeAdView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.openAds(_:)));
        self.nativeAdView.addGestureRecognizer(self.tapGesture);
        self.loadDeveloper();
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    func loadAds(){
        self.gadLoader = GADAdLoader(adUnitID: self.gadUnit,
                                     rootViewController: self.rootViewController,
                                     adTypes: [ .native ],
                                     options: []);
        self.gadLoader?.delegate = self;
        
        let req = GADRequest();
        let extras = GADExtras();
        extras.additionalParameters = ["suppress_test_label" : "1"]
        req.register(extras)
//        #if targetEnvironment(simulator)
//        return;
//        #endif
        self.gadLoader?.load(req);
    }
    
    func loadDeveloper(){
        if let header = self.nativeAdView?.headlineView as? UILabel{
            header.text = "ads header".localized();
            header.isHidden = false;
        }
        if let advertiser = self.nativeAdView?.advertiserView as? UILabel{
            advertiser.text = "advertiser".localized();
            advertiser.isHidden = false;
        }
        //self.nativeAdView?.starRatingView?.isHidden = true;// nativeAd.starRating == nil;
        if let button = self.nativeAdView?.callToActionView as? UIButton{
            button.setTitle("ads action".localized(), for: .normal);
            button.isHidden = false;
        }
        if let imageView = self.nativeAdView?.iconView as? UIImageView{
            imageView.image = #imageLiteral(resourceName: "othreapp");
            imageView.stopAnimating();
        }
        self.nativeAdView?.iconView?.isHidden = false;
        if let body = self.nativeAdView?.bodyView as? UILabel{
            body.text = "ads description".localized();
            body.isHidden = false;
        }
        
        self.nativeAdView?.isUserInteractionEnabled = true;
        self.tapGesture?.isEnabled = true;
        //self.nativeAdView.isHidden = true;
    }
    
    @objc func openAds(_ gesture : UITapGestureRecognizer){
        guard let url = URL.init(string: "https://itunes.apple.com/kr/app/myapp/id1189758512") else{
            return;
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
       //UIApplication.shared.open(url, options: [ : false], completionHandler: nil);
    }
}

extension GADNativeCollectionViewCell : GADNativeAdLoaderDelegate{
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        print("\(#function)");
        self.nativeAdView?.nativeAd = nativeAd;
        
        if let header = nativeAdView.headlineView as? UILabel{
            header.text = nativeAd.headline;
        }
//        if let advertiser = nativeAdView.advertiserView as? UILabel{
//            advertiser.text = nativeAd.advertiser;
//        }
//        self.nativeAdView?.advertiserView?.isHidden = nativeAd.advertiser == nil;
        //self.nativeAdView?.starRatingView?.isHidden = true;// nativeAd.starRating == nil;
        if let button = nativeAdView.callToActionView as? UIButton{
            button.setTitle(nativeAd.callToAction, for: .normal);
        }
        self.nativeAdView?.callToActionView?.isHidden = nativeAd.callToAction == nil;
        
        self.nativeAdView?.iconView?.isHidden = true;
        self.nativeAdView?.imageView?.isHidden = true;

        if let imageView = nativeAdView.iconView as? UIImageView, let icon = nativeAd.icon?.image{
            imageView.image = icon;
            print("[\(#function)] icon[\(icon)]")
            imageView.isHidden = false;
        }else if let imageView = nativeAdView.iconView as? UIImageView, let images = nativeAd.images{
            imageView.animationImages = images.compactMap{ $0.image };
            imageView.animationDuration = 3;
            imageView.animationRepeatCount = 0;
            imageView.startAnimating();
            print("[\(#function)] images[\(images)]")
            imageView.isHidden = false;
        }
        
        if let images = nativeAd.images{
            //imageView.image = nativeAd.icon?.image;
            print("[\(#function)] images[\(images)]")
        }
        
        self.nativeAdView?.advertiserView?.isHidden = true;
        if let starLabel = nativeAdView.starRatingView as? UILabel, let star = nativeAd.starRating{
            starLabel.text = star.description;
            starLabel.isHidden = false;
        }else if let priceLabel = nativeAdView.priceView as? UILabel, let price = nativeAd.price{
            priceLabel.text = price;
            priceLabel.isHidden = false;
        }else if let advertiserLabel = nativeAdView.advertiserView as? UILabel, let advertiser = nativeAd.advertiser{
            advertiserLabel.text = advertiser;
            advertiserLabel.isHidden = false;
        }
        
        print("[\(#function)] star[\(nativeAd.starRating)] price[\(nativeAd.price)]");
        
        if let body = nativeAdView.bodyView as? UILabel{
            body.text = nativeAd.body;
        }
        self.nativeAdView.bodyView?.isHidden = nativeAd.body == nil;
        self.nativeAdView?.isUserInteractionEnabled = true;
        self.tapGesture.isEnabled = false;
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("[\(#function)] native ads error - \(error)");
        self.loadDeveloper();
    }
}
