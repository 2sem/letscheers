//
//  LCCategoryCollectionViewCell.swift
//  letscheers
//
//  Created by 영준 이 on 2020/07/03.
//  Copyright © 2020 leesam. All rights reserved.
//

import UIKit

class LCCategoryCollectionViewCell: UICollectionViewCell {
    var info : LCCategory!{
        didSet{
            self.updateInfo();
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        self.updateShadow();
    }
    
    override class func awakeFromNib() {
        
    }
    
    func updateInfo(){
        self.layer
        self.imageView?.image = self.info?.image;
        self.nameLabel?.text = self.info?.name;
        self.countLabel?.text = self.info?.count.description;
    }
    
    func updateShadow(){
        //self.clipsToBounds = false;
        //self.layer.shadowColor = UIColor.black.cgColor;
        //self.layer.shadowOffset = CGSize(width: 5, height: 5);
        //self.layer.shadowRadius = 5;
        //self.layer.shadowOpacity = 0.5;
    }
}
