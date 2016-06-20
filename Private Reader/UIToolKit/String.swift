//
//  String.swift
//  Private Reader
//
//  Created by Tun Lan on 6/14/16.
//  Copyright © 2016 Tun Lan. All rights reserved.
//

import Foundation
import UIKit


extension String{
    subscript(start: Int, end: Int)->String{
        return self.substringWithRange(self.startIndex.advancedBy(start)..<self.startIndex.advancedBy(start+end))
    }
    
    func getAutoheight(font:UIFont,width:CGFloat) -> CGFloat {
        let str:NSString = NSString.init(string: self)
        let rect = str.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil)
        return rect.height
    }
}

extension NSString{
    
    func getAutoheight(font:UIFont,width:CGFloat) -> CGFloat {
        let rect = self.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil)
        return rect.height
    }
}