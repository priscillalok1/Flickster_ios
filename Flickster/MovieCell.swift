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
        self.backgroundColor = UIColor(red: 0, green: 0.1647, blue: 0.3176, alpha: 1.0)
        let backgroundView = UIView()
        self.selectionStyle = UITableViewCellSelectionStyle.Gray
        self.selectedBackgroundView = backgroundView
        //set gradient at the bottom of each cell in tableview
        let mGradient = CAGradientLayer()
        mGradient.frame = posterView.bounds
        var colors = [CGColor]()
        colors.append(UIColor(red: 0, green: 0, blue: 0, alpha: 0.9).CGColor) //black
        colors.append(UIColor(red: 0, green: 0, blue: 0, alpha: 0).CGColor) //clear
        mGradient.colors = colors
        mGradient.startPoint = CGPointMake(0.5, 0.5)
        mGradient.endPoint = CGPointMake(0.5, 0.2)
        
        posterView.layer.addSublayer(mGradient)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
