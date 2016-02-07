//
//  NavController.swift
//  MoviesViewer
//
//  Created by YiHuang on 2/4/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import UIKit
import JXGradientNavigationBar

extension UIImage {
    
    class func convertGradientToImage(colors: [UIColor], frame: CGRect) -> UIImage {
        
        // start with a CAGradientLayer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame

        // add colors as CGCologRef to a new array and calculate the distances
        var colorsRef : [CGColorRef] = []
        var locations : [NSNumber] = []
        
        for i in 0 ... colors.count-1 {
            colorsRef.append(colors[i].CGColor as CGColorRef)
            locations.append(Float(i)/Float(colors.count))
        }
        
        gradientLayer.colors = colorsRef
        gradientLayer.locations = locations
        
        // now build a UIImage from the gradient
//        gradientLayer.bounds.size.height += 20
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.renderInContext(UIGraphicsGetCurrentContext()!)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // return the gradient image
        return gradientImage
    }
}




class NavController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let colors = [
            UIColor.blackColor(),
            UIColor.blackColor(),
            UIColor.blackColor(),
            UIColor.blackColor(),
            UIColor.blackColor(),
            UIColor.blackColor(),

            UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1.0)
            // and many more if you wish
        ]
        let gradientImage = UIImage.convertGradientToImage(colors, frame: navigationBar.bounds)
        navigationBar.setBackgroundImage(gradientImage, forBarMetrics: .Default)
        self.navigationBar.topItem!.title = "Flicks"
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationBar.titleTextAttributes = titleDict as! [String : AnyObject]
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
