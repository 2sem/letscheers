//
//  LCCategory.swift
//  letscheers
//
//  Created by 영준 이 on 2020/07/04.
//  Copyright © 2020 leesam. All rights reserved.
//

import UIKit

class LCCategory : NSObject{
    enum CategoryType{
        case normal
        case ads
        case favorite
    }
    
    var name : String?;
    var title : String;
    var type : CategoryType;
    var image : UIImage;
    var background : UIImage!;
    var data : Any?;
    var count : Int{
        get{
            var value = 0;
            
            switch self.type{
                case .ads:
                    break;
                case .favorite:
                    break;
                default:
                    if let category = self.data as? LCToastCategory{
                        value = category.toasts.count;
                    }
                    break;
            }
            
            return value;
        }
    }
    
    lazy var toasts : [LCToast] = {
        return LCExcelController.shared.categories.first { (category) -> Bool in
            return category.name == self.title;
        }?.toasts ?? [];
    }()
    
    init(name: String?, title: String, type: CategoryType, image: UIImage, background: UIImage! = nil, autoLoad: Bool = true) {
        self.name = name;
        self.title = title;
        self.type = type;
        self.image = image;
        self.background = background;
        
        super.init();
        guard autoLoad else {
            return;
        }
        
        self.loadDataIfNeed();
    }
    
    private func loadDataIfNeed(){
        switch self.type{
            case .ads:
                break;
            case .favorite:
                break;
            default:
                guard self.data == nil else{
                    return;
                }
                self.data = LCToastCategory(name: self.name ?? "", title: self.title, image: self.background);
                break;
        }
    }
}
