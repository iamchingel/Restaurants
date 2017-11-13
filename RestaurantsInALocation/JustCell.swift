//
//  JustCell.swift
//  RestaurantsInALocation
//
//  Created by Sanket  Ray on 07/11/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit

class JustCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var backgroundCardView: UIView!
    @IBOutlet weak var restaurantLocality: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
