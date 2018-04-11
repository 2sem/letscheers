//
//  UIImage+.swift
//  relatedstocks
//
//  Created by 영준 이 on 2016. 12. 27..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit
import ImageIO
import MobileCoreServices

extension UIImage {
    func image(withSize size : CGSize, color : UIColor? = nil) -> UIImage{
        var value = self;
        UIGraphicsBeginImageContext(size);
        let ctx = UIGraphicsGetCurrentContext();
        let rect = CGRect(origin: CGPoint.zero, size: size);
        //draw background
        if color != nil{
            ctx!.setFillColor(color!.cgColor);
            ctx!.fill(rect);
        }
        
        //draw image
        self.draw(in: rect);
        
        value = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        return value;
    }
}
