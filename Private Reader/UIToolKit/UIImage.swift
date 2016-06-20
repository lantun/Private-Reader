//
//  UIImage.swift
//  Private Reader
//
//  Created by Tun Lan on 6/14/16.
//  Copyright © 2016 Tun Lan. All rights reserved.
//

import UIKit


extension UIImage{
    func scaleImage(scaleSize:CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSizeMake(self.size.width*scaleSize, self.size.height*scaleSize))
        self.drawInRect(CGRectMake(0, 0, self.size.width*scaleSize, self.size.height*scaleSize))
        let scaledImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
        
    }
}