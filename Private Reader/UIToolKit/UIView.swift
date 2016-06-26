//
//  UIView.swift
//  Private Reader
//
//  Created by Tun Lan on 6/24/16.
//  Copyright © 2016 Tun Lan. All rights reserved.
//

import Foundation
import UIKit

var viewBackgroundColor = RGB(r: 239, g: 239, b: 224)
var textColor = RGB(r: 0, g: 0, b: 0)
var bookItemTextColor = RGB(r: 225, g: 225, b: 225)
var bookItembackgroundColor = RGB(r: 113, g: 113, b: 113)


extension UIView{
    
    func imageByRenderingView(scale scale: Float = 1.0) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, CGFloat(scale))
        self .drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage
        
    }
    
    // 添加夜间模式，tag为666的uiview都支持夜间切换
    
    func switchModel(night night:Bool) -> Void {
        if night {
            viewBackgroundColor = RGB(r: 113, g: 113, b: 113)
            textColor = RGB(r: 254, g: 254, b: 233)
            bookItemTextColor = RGB(r: 113, g: 113, b: 113)
            bookItembackgroundColor = RGB(r: 239, g: 239, b: 224)
        }else{
            viewBackgroundColor = RGB(r: 239, g: 239, b: 224)
            textColor = RGB(r: 113, g: 113, b: 113)
            bookItemTextColor = RGB(r: 255, g: 255, b: 255)
            bookItembackgroundColor = RGB(r: 113, g: 113, b: 113)
        }
        if tag == 666 {
            self.backgroundColor = viewBackgroundColor
            if self.classForCoder == UILabel.classForCoder() {
                let lb = self as! UILabel
                lb.textColor = textColor
            }
            if self.classForCoder == UITextView.classForCoder() {
                let tv = self as! UITextView
                tv.textColor = textColor
            }
        }
        if self.classForCoder == UICollectionView.classForCoder(){
            let cv = self as! UICollectionView
            cv.backgroundColor = viewBackgroundColor
            for cell:BookCollectionViewCell in cv.visibleCells() as! [BookCollectionViewCell]  {
                if cell.tag == 666 {
                    cell.contentView.backgroundColor = bookItembackgroundColor
                    cell.bookName.textColor = bookItemTextColor
                    cell.setNeedsDisplay()
                }
            }
            
        }
        for v in self.subviews {
            if v.tag == 666 {
                v.backgroundColor = viewBackgroundColor
                if v.classForCoder == UILabel.classForCoder() {
                    let lb = v as! UILabel
                    lb.textColor = textColor
                }
                if v.classForCoder == UITextView.classForCoder() {
                    let tv = v as! UITextView
                    tv.textColor = textColor
                }
                if v.classForCoder == UICollectionView.classForCoder(){
                    let cv = v as! UICollectionView
                    for cell in cv.visibleCells() {
                        if cell.tag == 666 {
                            cell.backgroundColor = bookItembackgroundColor
                            cell.tintColor = bookItemTextColor
                        }
                    }
                    
                }
            }
        }
    }
}