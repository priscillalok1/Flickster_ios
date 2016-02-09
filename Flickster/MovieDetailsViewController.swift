//
//  MovieDetailsViewController.swift
//  Flickster
//
//  Created by Priscilla Lok on 2/4/16.
//  Copyright © 2016 Priscilla Lok. All rights reserved.
//

import UIKit
import Cosmos

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var detailsScrollView: UIScrollView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var movieDetailsView: UIView!
    @IBOutlet weak var starRatingsView: CosmosView!
    @IBOutlet weak var detailsViewStateImage: UIImageView!
    
    var movieTitle: String?
    var posterUrl: String?
    
    var overview: String?
    var releaseDate: String?
    var rating: Double?
    
    var detailsIsExpanded: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.posterUrl != nil) {
            posterImageView.setImageWithURL(NSURL(string: self.posterUrl!)!)
            posterImageView.contentMode = .ScaleAspectFit
        } else {
            //set default image
        }
        
        //set title
        titleLabel.text = movieTitle
        if releaseDate != nil {
            releaseDateLabel.text = "Released: \(releaseDate!)"
        }
        
        //set star ratings
        starRatingsView.settings.fillMode = .Half
        starRatingsView.rating = rating!/2.0
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        
        //set dimensions of movie details box
        var contentRect = CGRectUnion(movieDetailsView.frame, overviewLabel.frame)
        let paddingView: CGRect = CGRectMake(7.0, contentRect.height, overviewLabel.frame.width, 30.0) //padding at bottom of movie details box
        
        contentRect = CGRectUnion(contentRect, paddingView)
        detailsScrollView.contentSize = contentRect.size

        let width = self.view.frame.width
        let height = movieDetailsView.frame.height
        let yPosition = self.view.frame.height - height
        let xPosition:CGFloat = 0.0
        
        self.detailsScrollView.frame = CGRectMake(xPosition, yPosition, width, height)
        detailsIsExpanded = false
        detailsViewStateImage.image = UIImage(named: "white_plus_sign_icon")
        
    }

    @IBAction func onTapMovieDetails(sender: AnyObject) {
        
        
        if detailsIsExpanded == false {
            let height = min(detailsScrollView.contentSize.height, self.view.frame.height)
            let width = self.view.frame.width
            let xPosition = detailsScrollView.frame.origin.x
            let yPosition = self.view.frame.height - height
            
            UIView.animateWithDuration(0.5, animations: {
                
                self.detailsScrollView.frame = CGRectMake(xPosition, yPosition, width, height)
                
            })
            detailsIsExpanded = true
            detailsViewStateImage.image = UIImage(named: "white_minus_sign")
        }
        
        else if detailsIsExpanded == true {
            let width = self.view.frame.width
            let height = movieDetailsView.frame.height
            let yPosition = self.view.frame.height - height
            let xPosition:CGFloat = 0.0
            
            UIView.animateWithDuration(0.5, animations: {
                self.detailsScrollView.frame = CGRectMake(xPosition, yPosition, width, height)
            })
            detailsIsExpanded = false
            detailsViewStateImage.image = UIImage(named: "white_plus_sign_icon")
        }
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
