//
//  LCToastTableViewCell.swift
//  letscheers
//
//  Created by 영준 이 on 2017. 1. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit

class LCToastTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
