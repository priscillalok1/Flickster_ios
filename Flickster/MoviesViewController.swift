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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITabBarDelegate {
    
    @IBOutlet weak var backgroundLayerView: UIView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var searchResults: [NSDictionary]?
    var useSearchResults: Bool?

    var movies: [NSDictionary]?
    var topRatedMovies: [NSDictionary]?
    var nowPlayingMovies: [NSDictionary]?
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set color schemes
        let primaryColor: UIColor = UIColor(red: 0.05, green: 0.14, blue: 0.22, alpha: 1.0)
        let secondaryColor: UIColor = UIColor(red: 0.42, green: 0.52, blue: 0.62, alpha: 1.0)
        
        self.backgroundLayerView.backgroundColor = primaryColor

        self.tableView.backgroundColor = primaryColor
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        let textSearchField: UITextField = self.searchBar.valueForKey("_searchField") as! UITextField
        textSearchField.backgroundColor = primaryColor
        textSearchField.textColor = secondaryColor
        self.searchBar.barTintColor = secondaryColor
        
        UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).tintColor = primaryColor

        self.tabBar.barTintColor = primaryColor
        UITabBar.appearance().tintColor = UIColor(red: 0.32, green: 0.42, blue: 0.52, alpha: 1.0)
        
        //initialize and set up tableview
        tableView.dataSource = self
        tableView.delegate = self
        self.offlineView.hidden = true
        makeRequestToAPI()
        
        //initialize and set up refresh control
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        //initialize and set up search bar
        self.searchBar.delegate = self
        useSearchResults = false
        
        //initialize and set up tab bar
        self.tabBar.delegate = self
        self.tabBar.selectedItem = self.tabBar.items![0]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //# MARK: Obtain movie data methods
    func makeRequestToAPI() {
        
        var nowPlayingRequestDone = false
        var topRatedRequestDone = false
        
        self.navigationController?.showProgress()
        self.navigationController?.setProgress(0, animated: true)
        
        //now_playing API call
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 60.0)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue())
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: {(dataOrNil, response, error) in
                if error != nil {
                    self.offlineView.hidden = false
                    return
                }
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                        self.nowPlayingMovies = responseDictionary["results"] as? [NSDictionary]
                        //assign movies based on which tab is selected
                        if (self.tabBar.items?.indexOf(self.tabBar.selectedItem!))! == 0{
                            self.movies = self.nowPlayingMovies
                        } else {
                            self.movies = self.topRatedMovies
                        }
                        self.searchResults = self.movies
                        self.tableView.reloadData()
                    }
                    self.offlineView.hidden = true
                }
                
                nowPlayingRequestDone = true
                self.refreshControl.endRefreshing()
                
                if nowPlayingRequestDone == true && topRatedRequestDone == true {
                    self.navigationController?.setProgress(1, animated: true)
                    self.navigationController?.setProgress(0, animated: false)
                    self.navigationController?.finishProgress()
                    self.tableView.reloadData()

                }
            })
        task.resume()
        
        //top_rated API call
        let topRatedUrl = NSURL(string: "https://api.themoviedb.org/3/movie/top_rated?api_key=\(apiKey)")
        let topRatedRequest = NSURLRequest(URL: topRatedUrl!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 60.0)
        let topRatedSession = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue())
        
        let topRatedTask : NSURLSessionDataTask = topRatedSession.dataTaskWithRequest(topRatedRequest,
            completionHandler: {(dataOrNil, response, error) in
                if error != nil {
                    self.offlineView.hidden = false
                    return
                }
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                        self.topRatedMovies = responseDictionary["results"] as? [NSDictionary]
                        if (self.tabBar.items?.indexOf(self.tabBar.selectedItem!))! == 0{
                            self.movies = self.nowPlayingMovies
                        } else {
                            self.movies = self.topRatedMovies
                        }
                        self.searchResults = self.movies
                        
                        self.tableView.reloadData()
                    }
                    self.offlineView.hidden = true
                }
                
                topRatedRequestDone = true
                self.refreshControl.endRefreshing()
                
                if nowPlayingRequestDone == true && topRatedRequestDone == true {
                    self.navigationController?.setProgress(1, animated: true)
                    self.navigationController?.setProgress(0, animated: false)
                    self.navigationController?.finishProgress()
                    self.tableView.reloadData()
                    
                }
        })
        topRatedTask.resume()
    }
    
    
    //# MARK: Navigation methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! MovieDetailsViewController
        let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
        let currentMovies: [NSDictionary]? = self.getCurrentMovies()
        
        //
        if currentMovies != nil {
            let movie = currentMovies![(indexPath?.row)!]
            if let posterPath = movie["poster_path"] as? String {
                let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
                let posterUrl = posterBaseUrl + posterPath
                vc.posterUrl = posterUrl
                
            }
            let title = movie["title"] as? String
            vc.movieTitle = title
            
            let rating = movie["vote_average"] as? Double
            vc.rating = rating
            
            let releaseDate = movie["release_date"] as? String
            vc.releaseDate = releaseDate
            
            let overview = movie["overview"] as? String
            vc.overview = overview
        }
    }
    
    
    //# MARK: TableView Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getCurrentMovies().count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        cell.selectionStyle = .Gray
        var movie :NSDictionary = [:]
        
        //determine which array to parse movie from
        if self.useSearchResults == false {
            movie = movies![indexPath.row]
        } else {
            movie = self.searchResults![indexPath.row]
        }
        
        let title = movie["title"] as! String
        if let posterPath = movie["poster_path"] as? String {
            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
            let imageRequest = NSURLRequest(URL: posterUrl!)
            
            //set image in cell
            cell.posterView.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.posterView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
            })
            cell.posterView.contentMode = .ScaleAspectFill
        }
        else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            cell.posterView.image = nil
        }
        
        //set title
        cell.titleLabel.text = title
        
        //set star ratings
        cell.starRatingView.settings.fillMode = .Half
        cell.starRatingView.rating = (movie["vote_average"] as? Double)!/2.0

        return cell
    }
    
    //# MARK: Tab Bar Methods
    //tab bar for selection between now_playing and top_rated movies
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        let selectedIndex = tabBar.items?.indexOf(item)
        if selectedIndex == 0 {
            self.movies = self.nowPlayingMovies
        } else {
            self.movies = self.topRatedMovies
        }
        self.tableView.reloadData()
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
    
    //function to either get search results or entire list of movies
    func getCurrentMovies() -> [NSDictionary] {
        if self.useSearchResults == true {
            if self.searchResults != nil {
                return self.searchResults!
            }
            else {
                return []
            }
        }
        else {
            if self.movies != nil{
                return self.movies!
            }
            else {
                return []
            }
        }
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
 
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.useSearchResults = false
        self.searchBar.text = ""
        self.searchBar.endEditing(true)
        self.searchBar.showsCancelButton = false
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.useSearchResults = true
        self.view.endEditing(true)
        self.searchBar.showsCancelButton = false
        self.tableView.reloadData()
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
