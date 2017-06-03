//
//  ResaurantTableViewCell.swift
//  FoodPin
//
//  Created by Eric Chen on 2017/4/3.
//  Copyright © 2017年 Eric Chen. All rights reserved.
//

import UIKit

class ResaurantTableViewCell: UITableViewCell {
    
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var typrLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
