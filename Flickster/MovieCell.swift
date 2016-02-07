//
//  MovieCell.swift
//  Flickster
//
//  Created by Priscilla Lok on 2/4/16.
//  Copyright © 2016 Priscilla Lok. All rights reserved.
//

import UIKit
import Cosmos

class MovieCell: UITableViewCell {


    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var starRatingView: CosmosView!
    @IBOutlet weak var movieDetailsCellView: UIView!
    @IBOutlet weak var posterView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [UIColor.greenColor(), UIColor.blueColor()]
        movieDetailsCellView.layer.insertSublayer(gradientLayer, atIndex: 0)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
