//
//  MovieDetailsViewController.swift
//  Flickster
//
//  Created by Priscilla Lok on 2/4/16.
//  Copyright © 2016 Priscilla Lok. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var detailsScrollView: UIScrollView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var movieDetailsView: UIView!
    
    var movieTitle: String?
    var posterUrl: String?
    var language: String?
    var overview: String?
    var releaseDate: String?
    var rating: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.posterUrl != nil) {
            posterImageView.setImageWithURL(NSURL(string: self.posterUrl!)!)
            posterImageView.contentMode = .ScaleAspectFit
        } else {
            //set default image
        }
        
        titleLabel.text = movieTitle
        releaseDateLabel.text = releaseDate
        languageLabel.text = language
        ratingLabel.text = rating
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        
        let contentRect = CGRectUnion(movieDetailsView.frame, overviewLabel.frame)

        detailsScrollView.contentSize = contentRect.size


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
