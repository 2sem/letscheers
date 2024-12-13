//
//  LCCategoryCollectionViewFavoriteCell.swift
//  letscheers
//
//  Created by 영준 이 on 2020/07/04.
//  Copyright © 2020 leesam. All rights reserved.
//

import UIKit

class LCCategoryCollectionViewFavoriteCell: UICollectionViewCell {
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.updateInfo();
    }
    
    func updateInfo(){
        self.countLabel?.text = LCModelController.shared.countForFavorites().description;
    }
    //
}
