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
    let gradientLayer = CAGradientLayer()
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var header: MJRefreshNormalHeader? = nil
    var endpoint: String!
    var kbHide: Int = 0
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
        if (searchBar.isFirstResponder()) {
            return true
        } else {
            return false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        print(sender?.description)
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
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(self.endpoint)?api_key=\(apiKey)")
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
    
    

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        //LightContent
        return UIStatusBarStyle.Default
        
        //Default
        //return UIStatusBarStyle.Default
        
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
        if searchText.isEmpty {
            filteredMovies = movies
        } else {
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
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cell:MovieCollectoinCell = collectionView.cellForItemAtIndexPath(indexPath) as! MovieCollectoinCell
        cell.layer.cornerRadius = 10.0
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        cell.layer.borderWidth = 3.0
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.collectionView {
            let cell:MovieCollectoinCell = collectionView.cellForItemAtIndexPath(indexPath) as! MovieCollectoinCell
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                }, completion: { (sucess) -> Void in
                cell.layer.borderWidth = 0
            })

        }
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
            let posterBaseUrl = "http://image.tmdb.org/t/p/w45"
            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
            let imageRequest = NSURLRequest(URL: posterUrl!)
            let largeImageBaseUrl = "http://image.tmdb.org/t/p/original"
            let largePosterUrl = NSURL(string: largeImageBaseUrl + posterPath)
            let fullImageRequest = NSURLRequest(URL: largePosterUrl!)
            cell.movieId = movie["id"] as! Int
            cell.posterViewInCollectionCell.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                        cell.posterViewInCollectionCell.alpha = 0.0
                        cell.posterViewInCollectionCell.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            
                            cell.posterViewInCollectionCell.alpha = 1.0
                            
                            }, completion: { (sucess) -> Void in
                                
                                // The AFNetworking ImageView Category only allows one request to be sent at a time
                                cell.posterViewInCollectionCell.setImageWithURLRequest(
                                    fullImageRequest,
                                    placeholderImage: image,
                                    success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                        
                                        cell.posterViewInCollectionCell.image = largeImage;
                                        
                                    },
                                    failure: { (request, response, error) -> Void in

                                })
                        })


                        cell.posterViewInCollectionCell.setImageWithURLRequest(fullImageRequest, placeholderImage: nil, success: { (fullImageRequest, newimageResponse, newimage) -> Void in
                            cell.posterViewInCollectionCell.image = newimage
                            
                            }, failure: { (fullImageRequest, newimageResponse, error) -> Void in
                                // do something for the failure condition
                        })

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
