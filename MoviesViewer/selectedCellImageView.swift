//
//  selectedCellImageView.swift
//  MoviesViewer
//
//  Created by YiHuang on 2/6/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import UIKit

class selectedCellImageView: UIImageView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override func awakeFromNib() {
        self.layer.cornerRadius = 10.0
        self.layer.borderColor = UIColor.blueColor().CGColor
        self.layer.borderWidth = 2.0
    }
}
