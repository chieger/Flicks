//
//  detailMoviePageController.swift
//  MoviesViewer
//
//  Created by YiHuang on 1/25/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import UIKit
import PKHUD
import AFNetworking

let offset_HeaderStop:CGFloat = 20 // At this offset the Header stops its transformations
let offset_B_LabelHeader:CGFloat = 95.0 // At this offset the Black label reaches the Header
let distance_W_LabelHeader:CGFloat = 35.0 // The distance between the bottom of the Header and the top

class detailMoviePageController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    var movieId:Int = -1
    var apiResult:NSDictionary?
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var movieOverviewLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var header: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var networkTip: UIView!
    
    var backDrop: UIImageView?
    var movies:[NSDictionary]?
    
    @IBAction func onTap(sender: AnyObject) {
        networkTip.hidden = true
        fetchSimilarMovieDetail()
        fetchMovieDetail()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = self.movies {
            print(movies.count)
            return movies.count
        } else {
            return -1
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SimilarMovieCell", forIndexPath: indexPath) as! SimilarMovieCell
        let movie = movies![indexPath.row]
        let posterURL = "http://image.tmdb.org/t/p/w500/" + (movie["poster_path"] as! String)
        cell.similarPoster.setImageWithURL(NSURL(string: posterURL)!, placeholderImage: nil)
        return cell
    }
    
    func fetchSimilarMovieDetail() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(movieId)/similar?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let _ = error {
                    PKHUD.sharedHUD.hide(afterDelay: 2.0)
                    self.networkTip.hidden = false

                    return
                }
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            print("reloadData")
                            self.collectionView.reloadData()
                            
                    }
                }
        })
        task.resume()
    }
    
    
    func fetchMovieDetail() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(movieId)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let _ = error {
                    PKHUD.sharedHUD.hide(afterDelay: 2.0)
                    self.networkTip.hidden = false
                    return
                }
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.apiResult = responseDictionary as NSDictionary
                            if let apiResult = self.apiResult {
                                self.movieTitleLabel.text = apiResult["title"] as! String
//                                self.movieOverviewLabel.text = apiResult["overview"] as! String
                                PKHUD.sharedHUD.hide(afterDelay: 0.5)
                                self.posterView.setImageWithURL(NSURL(string: "http://image.tmdb.org/t/p/w500/" + (apiResult["poster_path"] as! String))!, placeholderImage: nil)
                                self.backDrop?.setImageWithURL(NSURL(string: "http://image.tmdb.org/t/p/w500/" + (apiResult["backdrop_path"] as! String))!, placeholderImage: nil)
                                self.movieOverviewLabel.text = apiResult["overview"] as! String
                            }
                    }
                }
        })
        task.resume()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        print("offset \(offset)")
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        if offset < 0 {
            
            let headerScaleFactor:CGFloat = -(offset) / header.bounds.height
            let headerSizevariation = ((header.bounds.height * (1.0 + headerScaleFactor)) - header.bounds.height)/2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
        }
        else {
            
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / posterView.bounds.height / 1.4 // Slow down the animation
            let avatarSizeVariation = ((posterView.bounds.height * (1.0 + avatarScaleFactor)) - posterView.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
            if offset <= offset_HeaderStop {
                
                if posterView.layer.zPosition < header.layer.zPosition{
                    header.layer.zPosition = 0
                }
                
            }else {
                if posterView.layer.zPosition >= header.layer.zPosition{
                    header.layer.zPosition = 2
                }
            }
        }
        
        header.layer.transform = headerTransform
        posterView.layer.transform = avatarTransform

        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PKHUD.sharedHUD.show()
        scrollView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        header.clipsToBounds = true
        let bgImageView = UIImageView(frame: header.bounds)
        bgImageView.contentMode = UIViewContentMode.ScaleAspectFill
        backDrop = bgImageView
        header.addSubview(bgImageView)
        header.clipsToBounds = true
        networkTip.hidden = true
        fetchMovieDetail()
        fetchSimilarMovieDetail()
        
        

        // Do any additional setup after loading the view.
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
