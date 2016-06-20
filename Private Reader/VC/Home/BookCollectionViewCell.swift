//
//  BookCollectionView.swift
//  Private Reader
//
//  Created by Tun Lan on 6/14/16.
//  Copyright © 2016 Tun Lan. All rights reserved.
//

// 首页 collectionViewCell 单元视图
import UIKit

class BookCollectionViewCell: UICollectionViewCell {

    let bookName:UILabel
    override init(frame: CGRect) {
        bookName = UILabel.init(frame: CGRectMake(0, 12, frame.width, frame.height-24))
        bookName.textColor = UIColor.init(red: 225/255, green: 225/255, blue: 225/255, alpha: 1.00)
        bookName.font = UIFont.systemFontOfSize(10)
        bookName.textAlignment = .Center
        bookName.numberOfLines = 0
        
        super.init(frame: frame)
        self.addSubview(bookName)
        self.backgroundColor = UIColor.init(red: 113/255, green: 113/255, blue: 113/255, alpha: 1.00)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
