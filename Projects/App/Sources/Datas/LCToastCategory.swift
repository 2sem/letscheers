//
//  LCToastCategory.swift
//  letscheers
//
//  Created by 영준 이 on 2017. 1. 7..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import UIKit

class LCToastCategory : NSObject{
    var name : String!;
    var title : String!;
    var image : UIImage?;
    init(name: String, title: String? = nil, image: UIImage?){
        self.name = name;
        self.title = title;
        if title == nil{
            self.title = name;
        }
        self.image = image;
    }
    
    var toasts : [LCToast] = [];
}
