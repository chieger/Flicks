//
//  FullScreenPhotoViewController.swift
//  MoviesViewer
//
//  Created by YiHuang on 2/6/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import UIKit

class FullScreenPhotoViewController: UIViewController, UIScrollViewDelegate {

    var photoUrl:String?
    var image:UIImage?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var fullscreenImage: UIImageView!
    
    @IBAction func closeTap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        fullscreenImage.image = self.image
        /* fetch image from Internet */
        /*
        let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
        if let url = self.photoUrl{
            let posterUrl = NSURL(string: posterBaseUrl + url)
            let imageRequest = NSURLRequest(URL: posterUrl!)
            fullscreenImage.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })

        }
        */
        
                // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return fullscreenImage
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
