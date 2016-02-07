//
//  MoviesViewController.swift
//  Flickster
//
//  Created by Priscilla Lok on 2/4/16.
//  Copyright © 2016 Priscilla Lok. All rights reserved.
//

import UIKit
import AFNetworking
import M13ProgressSuite


class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var searchResults: [NSDictionary]?
    var useSearchResults: Bool?

    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        useSearchResults = false
        
        tableView.dataSource = self
        tableView.delegate = self
        self.offlineView.hidden = true
        makeRequestToAPI()
        
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        self.searchBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeRequestToAPI() {
        self.navigationController?.showProgress()
        self.navigationController?.setProgress(0, animated: true)
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
   //     let request = NSURLRequest(URL: url!)
        let request = NSURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 60.0)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue())
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: {(dataOrNil, response, error) in
                if let data = dataOrNil
                {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary
                    {
                        self.movies = responseDictionary["results"] as? [NSDictionary]
                        self.searchResults = self.movies
                        self.tableView.reloadData()
                    }
                    self.offlineView.hidden = true
                }
                if error != nil
                {
                    self.offlineView.hidden = false
                    return
                }
                
                self.navigationController?.setProgress(1, animated: true)
                self.navigationController?.setProgress(0, animated: false)
                self.navigationController?.finishProgress()
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            })
        task.resume()
    }
    
    func getCurrentMovies() -> [NSDictionary] {
        if self.useSearchResults == true {
            return self.searchResults!
        }
        else {
            return self.movies!
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        if self.useSearchResults == false {
            let movie = movies![indexPath.row]
            let title = movie["title"] as! String
            if let posterPath = movie["poster_path"] as? String {
                let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
                let posterUrl = NSURL(string: posterBaseUrl + posterPath)
                cell.posterView.setImageWithURL(posterUrl!)
            }
            else {
                // No poster image. Can either set to nil (no image) or a default movie poster image
                // that you include as an asset
                cell.posterView.image = nil
            }
            cell.starRatingView.settings.fillMode = .Half
            cell.starRatingView.rating = (movie["vote_average"] as? Double)!/2.0
            
            cell.titleLabel.text = title
        } else {
            let movie = self.searchResults![indexPath.row]
            print (indexPath.row)
            print (searchResults?.count)
            let title = movie["title"] as! String
            if let posterPath = movie["poster_path"] as? String {
                let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
                let posterUrl = NSURL(string: posterBaseUrl + posterPath)
                cell.posterView.setImageWithURL(posterUrl!)
            }
            else {
                // No poster image. Can either set to nil (no image) or a default movie poster image
                // that you include as an asset
                cell.posterView.image = nil
            }
            cell.starRatingView.settings.fillMode = .Half
            cell.starRatingView.rating = (movie["vote_average"] as? Double)!/2.0
            
            cell.titleLabel.text = title
        }
        
        return cell
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! MovieDetailsViewController
        let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
        if  self.movies != nil {
            let movie = self.movies![indexPath!.row]
            
            if let posterPath = movie["poster_path"] as? String {
                let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
                let posterUrl = posterBaseUrl + posterPath
                vc.posterUrl = posterUrl

            }
            let title = movie["title"] as? String
            vc.movieTitle = title
            
            let language = movie["original_language"] as? String
            vc.language = language
                
            let rating = movie["vote_average"] as? String
            vc.rating = rating
            
            let releaseDate = movie["release_date"] as? String
            vc.releaseDate = releaseDate
            
            let overview = movie["overview"] as? String
            vc.overview = overview

        }
    }


    // Makes a network request to get updated data
    func refreshControlAction(refreshControl: UIRefreshControl) {
        makeRequestToAPI()
    }
    
    //# MARK: Search Methods
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.getSearchResultsForSearchText(searchText)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.useSearchResults = true
        self.searchBar.showsCancelButton = true
        self.getSearchResultsForSearchText(searchBar.text!)
    }
    
    func getSearchResultsForSearchText(searchText: String)
    {
        //clear search results
        self.searchResults?.removeAll()
        if searchText.characters.count == 0 {
            //no search text, default to all movies
            for movie in self.movies! {
                self.searchResults?.append(movie)
            }
        } else {
            for movie in self.getMoviesForSearchText(searchText) {
                self.searchResults?.append(movie)
            }
        }
        
        
        self.tableView.reloadData()
    }
    
    func getMoviesForSearchText(text: String) -> [NSDictionary] {
        let predicate: NSPredicate = NSPredicate(format: "title contains[c] %@", text)
        let results: [NSDictionary] = (self.movies! as NSArray).filteredArrayUsingPredicate(predicate) as! [NSDictionary]
        return results
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.useSearchResults = false
        self.tableView.reloadData()
    }
 
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.useSearchResults = false
        self.searchBar.endEditing(true)
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
