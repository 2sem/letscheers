//
//  UIView+.swift
//  letscheers
//
//  Created by 영준 이 on 2020/07/04.
//  Copyright © 2020 leesam. All rights reserved.
//

import UIKit

@objc extension UIView{
    @IBInspectable var shadowColor : UIColor?{
        get{
            guard let value = self.layer.shadowColor else {
                return nil;
            }
            
            return UIColor.init(cgColor: value);
        }
        
        set(value){
            self.layer.shadowColor = value?.cgColor
        }
    }
    
    @IBInspectable var shadowOffset : CGSize{
        get{
            return self.layer.shadowOffset
        }
        
        set(value){
            self.layer.shadowOffset = value;
        }
    }
    
    @IBInspectable var shadowRadius : CGFloat{
        get{
            return self.layer.shadowRadius
        }
        
        set(value){
            self.layer.shadowRadius = value;
        }
    }
    
    @IBInspectable var shadowOpacity : Float{
        get{
            return self.layer.shadowOpacity;
        }
        
        set(value){
            self.layer.shadowOpacity = value;
        }
    }
}
