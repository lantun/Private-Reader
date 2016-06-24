//
//  UIView.swift
//  Private Reader
//
//  Created by Tun Lan on 6/24/16.
//  Copyright © 2016 Tun Lan. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    
    func imageByRenderingView(scale scale: Float = 1.0) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, CGFloat(scale))
        self .drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage
        
    }
}