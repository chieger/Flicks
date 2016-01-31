//
//  MoviesViewController.swift
//  MoviesViewer
//
//  Created by YiHuang on 1/22/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import UIKit
import AFNetworking
import PKHUD
import MJRefresh

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate {
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var header: MJRefreshNormalHeader? = nil

    @IBOutlet weak var networkProblemView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func onTapNetworkView(sender: AnyObject) {
        networkProblemView.hidden = true
        fetchMoivesData(true)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        // a little trick to distinguish imageView from other views
        if ((touch.description.rangeOfString("contentOffset")) != nil) {
            return true
        } else {
            return false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(sender?.description)
        if segue.identifier == "gotoMovieDetail" {
            let destinationView:detailMoviePageController = segue.destinationViewController as! detailMoviePageController
            destinationView.movieId = (sender as! MovieCollectoinCell).movieId
        }
    }
    
    func headerRefresh(){
        fetchMoivesData(true)
    }
    
    func fetchMoivesData(pullFlag: Bool) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let _ = error {
                    if pullFlag == true {
                        self.collectionView.mj_header.endRefreshing()
                        self.networkProblemView.hidden = false
                    } else {
                        self.networkProblemView.hidden = false
                    }
                    self.collectionView.reloadData()
                    return
                }
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            if pullFlag == true {
                                self.collectionView.mj_header.endRefreshing()
                            } else {
                                PKHUD.sharedHUD.hide()
                            }
                            self.filteredMovies = self.movies
                            self.collectionView.reloadData()
                    }
                }
        })
        
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        networkProblemView.hidden = true
        let onTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        onTapGesture.delegate = self
        self.view.addGestureRecognizer(onTapGesture)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 179/255, green: 0, blue: 0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.yellowColor()
        self.navigationController?.navigationBar.topItem!.title = "Flicks"
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 179/255, green: 0, blue: 0, alpha: 1.0)
        self.tabBarController?.tabBar.tintColor = UIColor.yellowColor()


        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        header = MJRefreshNormalHeader()
        if let hdr = header {
            hdr.setTitle("Pull down to refresh", forState: MJRefreshState.Idle)
            hdr.setTitle("Release to refresh", forState: MJRefreshState.Pulling)
            hdr.setTitle("Loading...", forState: MJRefreshState.Refreshing)
            hdr.setRefreshingTarget(self, refreshingAction: Selector("headerRefresh"))
            hdr.stateLabel?.hidden = true
        }
        self.collectionView.mj_header = header
        // true => fetching triggered by pull gesture, false => fetching at starting
        fetchMoivesData(false)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
   
    // This method updates filteredData based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            filteredMovies = movies
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredMovies = searchText.isEmpty ? movies : movies!.filter({(dataItem: NSDictionary) -> Bool in
                // If dataItem matches the searchText, return true to include it
                if (dataItem["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = filteredMovies {
            return movies.count
        } else {
            return -1
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCollectoinCell", forIndexPath: indexPath) as! MovieCollectoinCell
        let movie = filteredMovies![indexPath.row]
        if let posterPath = movie["poster_path"] as? String {
            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
            let imageRequest = NSURLRequest(URL: posterUrl!)
            cell.movieId = movie["id"] as! Int
            cell.posterViewInCollectionCell.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.posterViewInCollectionCell.alpha = 0.0
                        cell.posterViewInCollectionCell.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell.posterViewInCollectionCell.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.posterViewInCollectionCell.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })

        }
        else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            cell.posterViewInCollectionCell.image = nil
        }
        
        return cell
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
