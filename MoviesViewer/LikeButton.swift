//
//  LikeButton.swift
//  MoviesViewer
//
//  Created by YiHuang on 1/30/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import UIKit

class LikeButton: UIButton {
    override func awakeFromNib() {
        
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 85.0/255.0, green: 172.0/255.0, blue: 238.0/255.0, alpha: 1.0).CGColor
        
    }


}
