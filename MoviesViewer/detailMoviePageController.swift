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
import Cosmos
import FMDB

// API key
let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"

// DB parameters
let filemgr = NSFileManager.defaultManager()
let dirPaths = filemgr.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
let databasePath = dirPaths[0].URLByAppendingPathComponent("favs.db").path!

// Animation parameters
let offset_HeaderStop:CGFloat = 20 // At this offset the Header stops its transformations
let offset_B_LabelHeader:CGFloat = 95.0 // At this offset the Black label reaches the Header
let distance_W_LabelHeader:CGFloat = 35.0 // The distance between the bottom of the Header and the top

class detailMoviePageController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    var movieId:Int = -1
    var favState:Int = 0
    var apiResult:NSDictionary?
    
    @IBOutlet weak var castProfilesCollection: UICollectionView!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var movieOverviewLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var rateView: CosmosView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var networkTip: UIView!
    
    @IBOutlet weak var favButton: UIButton!
    
    var backDrop: UIImageView?
    var movies = [NSDictionary]()
    var movieObjs: Movie?
    var castsProfiles = [NSDictionary]()
    
    @IBAction func onTap(sender: AnyObject) {
        networkTip.hidden = true
        fetchSimilarMovieDetail()
        fetchMovieDetail()
    }
    
    func checkDB() {
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = filemgr.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        let databasePath = dirPaths[0].URLByAppendingPathComponent("favs.db").path!
        if !filemgr.fileExistsAtPath(databasePath as String) {
            
            let contactDB = FMDatabase(path: databasePath as String)
            
            if contactDB == nil {
                print("Error: \(contactDB.lastErrorMessage())")
            }
            
            if contactDB.open() {
                let sql_stmt = "CREATE TABLE IF NOT EXISTS FAVS (ID INTEGER PRIMARY KEY AUTOINCREMENT, MOVIEID TEXT)"
                if !contactDB.executeStatements(sql_stmt) {
                    print("Error: \(contactDB.lastErrorMessage())")
                }
                contactDB.close()
            } else {
                print("Error: \(contactDB.lastErrorMessage())")
            }
        }
    }
    
    @IBAction func addFavTap(sender: AnyObject) {
        let contactDB = FMDatabase(path: databasePath as String)
        if self.favState == 0 {
            if let id = self.movieObjs?.id {
                if contactDB.open() {
                    
                    let insertSQL = "INSERT INTO FAVS (MOVIEID) VALUES ('\(id)')"
                    
                    let result = contactDB.executeUpdate(insertSQL,
                        withArgumentsInArray: nil)
                    
                    if !result {
                        print("Failed to add Fav")
                        print("Error: \(contactDB.lastErrorMessage())")
                    } else {
                        print("Fav Added")
                        self.favState = 1
                        favButton.setImage(UIImage(named: "fav"), forState: UIControlState.Normal)

                        
                    }
                } else {
                    print("Error: \(contactDB.lastErrorMessage())")
                }
                
            }
        
        } else {
            //        DELETE FROM student_info WHERE RollNo=
            if let id = self.movieObjs?.id {
                if contactDB.open() {
                    
                    let insertSQL = "DELETE FROM FAVS WHERE MOVIEID='\(id)'"
                    
                    let result = contactDB.executeUpdate(insertSQL,
                        withArgumentsInArray: nil)
                    
                    if !result {
                        print("Failed to add Fav")
                        print("Error: \(contactDB.lastErrorMessage())")
                    } else {
                        print("Fav Deleted")
                        favButton.setImage(UIImage(named: "unfav"), forState: UIControlState.Normal)
                        self.favState = 0
                    }
                } else {
                    print("Error: \(contactDB.lastErrorMessage())")
                }
                
            }
            
            
        }
        


    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.collectionView {
            let cell:RelatedInfoCell = collectionView.cellForItemAtIndexPath(indexPath) as! RelatedInfoCell
            performSegueWithIdentifier("detailSelfSegue", sender: cell)

        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return self.movies.count
        } else {
            return self.castsProfiles.count
        }

    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("RelatedInfoCell", forIndexPath: indexPath) as! RelatedInfoCell
            
            let movie = movies[indexPath.row]
            cell.id = movie["id"] as! Int
            cell.mainTextLabel.text = movie["title"] as? String
            if let moviePosterPath = movie["poster_path"] as? String {
                let posterURL = "http://image.tmdb.org/t/p/w500/" + moviePosterPath
                cell.mainImageView.setImageWithURL(NSURL(string: posterURL)!, placeholderImage: nil)
            } else {
                cell.mainImageView.image = UIImage(named: "notfound")
            }

            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("RelatedInfoCell", forIndexPath: indexPath) as! RelatedInfoCell
            let cast = castsProfiles[indexPath.row]
            cell.mainTextLabel.text = cast["name"] as? String
            if let profilePath = cast["profile_path"] as? String {
                let profileURL = "http://image.tmdb.org/t/p/w500/" + profilePath
                cell.mainImageView.setImageWithURL(NSURL(string: profileURL)!, placeholderImage: nil)
            } else {
                cell.mainImageView.image = UIImage(named: "notfound")
            }
            
            return cell
        }
    }
  
    
    
    func fetchCastProfiles() {
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(movieId)/credits?api_key=\(apiKey)")
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
                            self.castsProfiles = (responseDictionary["cast"] as? [NSDictionary])!
                            print("reloadData for cast profiles")
                            self.castProfilesCollection.reloadData()
                    }
                }
        })
        task.resume()
    }
    
    func fetchSimilarMovieDetail() {
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
                            self.movies = (responseDictionary["results"] as? [NSDictionary])!
                            print("reloadData")
                            if self.movies.count > 0 {
                                self.collectionView.reloadData()
                            } else {
                                self.collectionView.bounds.size.height = 0
                            }
                    }
                }
        })
        task.resume()
    }
    
    
    func fetchMovieDetail() {
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
                                self.movieObjs = Movie(id: apiResult["id"] as! Int, title: apiResult["title"] as! String, overview: apiResult["overview"] as! String, rating: apiResult["vote_average"] as? Double, runtime: apiResult["runtime"] as? Int, posterUrl: apiResult["poster_path"] as? String, backdropUrl: apiResult["backdrop_path"] as? String, releaseDate: apiResult["release_date"] as? String)
                                self.movieTitleLabel.text = self.movieObjs?.title
                                PKHUD.sharedHUD.hide(afterDelay: 0.5)
                                if let posterUrl = self.movieObjs?.posterUrl {
                                    self.posterView.setImageWithURL(NSURL(string: "http://image.tmdb.org/t/p/w500/" + posterUrl)!, placeholderImage: nil)
                                }
                                if let backdropUrl = self.movieObjs?.backdropUrl {
                                    self.backDrop?.setImageWithURL(NSURL(string: "http://image.tmdb.org/t/p/w500/" + backdropUrl)!, placeholderImage: nil)
                                }
                                
                                // Todo: fix empty backdrop picture
                                if let overview = self.movieObjs?.overview {
                                    let alignedText = paragraphStyle.getParagraphStyle(overview)
                                    self.movieOverviewLabel.attributedText = alignedText
                                    self.movieOverviewLabel.sizeToFit()
                                }

                                if let rating = self.movieObjs?.rating {
                                    self.rateView.rating = rating/2
                                    self.rateView.text = "\(rating)/10"
                                }
                                if let runtime = self.movieObjs?.runtime {
                                    self.runtimeLabel.text = "Runtime: \(runtime) min"
                                }
                                if let releaseDate = self.movieObjs?.releaseDate {
                                    self.releaseLabel.text = "Release: \(releaseDate)"
                                }

                            }
                    }
                }
        })
        task.resume()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let backButton = UIBarButtonItem(
            title: "Back",
            style: UIBarButtonItemStyle.Plain, // Note: .Bordered is deprecated
            target: nil,
            action: nil
        )
        self.navigationController!.navigationBar.topItem!.backBarButtonItem = backButton
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //        print(sender?.description)
        if segue.identifier == "detailSelfSegue" {
            let destinationView:detailMoviePageController = segue.destinationViewController as! detailMoviePageController
            destinationView.movieId = (sender as! RelatedInfoCell).id
        } else if segue.identifier == "posterFullScreen" {
            let destinationView:FullScreenPhotoViewController = segue.destinationViewController as! FullScreenPhotoViewController
            destinationView.image = self.posterView.image
        }
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
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
                    if posterView.layer.zPosition < header.layer.zPosition {
                        header.layer.zPosition = 0
                    }
                    
                }else {
                    if posterView.layer.zPosition >= header.layer.zPosition {
                        header.layer.zPosition = 2
                    }
                }
            }
            
            header.layer.transform = headerTransform
            posterView.layer.transform = avatarTransform
        }
        
        
    }
    
    func checkFavState() {
        let contactDB = FMDatabase(path: databasePath as String)
        if self.movieId == -1 {
            return
        }
        
        if contactDB.open() {
            let querySQL = "SELECT MOVIEID FROM FAVS WHERE MOVIEID = '\(self.movieId)'"
            
            let results:FMResultSet? = contactDB.executeQuery(querySQL,
                withArgumentsInArray: nil)
            
            if results?.next() == true {
                print("Found and ID = \(results?.stringForColumn("MOVIEID"))")
                favButton.setImage(UIImage(named: "fav"), forState: UIControlState.Normal)
                self.favState = 1
                
            } else {
                print("Record not found")
            }
            contactDB.close()
        } else {
            print("Error: \(contactDB.lastErrorMessage())")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkDB()
        PKHUD.sharedHUD.show()
        scrollView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        castProfilesCollection.dataSource = self
        castProfilesCollection.registerNib(UINib(nibName: "RelatedInfoCell", bundle: nil), forCellWithReuseIdentifier: "RelatedInfoCell")
        collectionView.registerNib(UINib(nibName: "RelatedInfoCell", bundle: nil), forCellWithReuseIdentifier: "RelatedInfoCell")
        header.clipsToBounds = true
        let bgImageView = UIImageView(frame: header.bounds)
        bgImageView.contentMode = UIViewContentMode.ScaleAspectFill
        backDrop = bgImageView
        header.addSubview(bgImageView)
        header.clipsToBounds = true
        networkTip.hidden = true
        fetchMovieDetail()
        fetchSimilarMovieDetail()
        fetchCastProfiles()
        checkFavState()
        
        

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
