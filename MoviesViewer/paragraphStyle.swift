//
//  paragraphStyle.swift
//  MoviesViewer
//
//  Created by YiHuang on 2/5/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import UIKit

class paragraphStyle: NSObject {
    static func getParagraphStyle(text: String)-> NSMutableAttributedString{
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Justified
        paragraphStyle.firstLineHeadIndent = 15
        paragraphStyle.paragraphSpacingBefore = 10.0
        let attributedStr = NSAttributedString(string: text)
        let mutableAttrStr = NSMutableAttributedString(attributedString: attributedStr)
        mutableAttrStr.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, mutableAttrStr.length))
        return mutableAttrStr
    }
}
