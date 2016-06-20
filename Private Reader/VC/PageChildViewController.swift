//
//  PageChildViewController.swift
//  Private Reader
//
//  Created by Tun Lan on 6/15/16.
//  Copyright © 2016 Tun Lan. All rights reserved.
//

// 阅读子控制器，显示文本内容
import UIKit

class PageChildViewController: UIViewController {

    // 标题
    let titleLable:UILabel = UILabel()
    // 进度
    let progressLB:UILabel = UILabel()
    // 文本内容显示
    let contentView:UITextView = UITextView()
    
    var pageNumber = 0;
    
    var readProgress:Float = 0.0{
        didSet{
            progressLB.text = String.init(format: "%.2f%%", readProgress)
        }
    }
    
    

    var fontSize:CGFloat = 12.0{
        didSet{
            contentView.font = UIFont.systemFontOfSize(fontSize)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }
    
    // 初始化ui
    func initUI() {
        
        self.view.backgroundColor = UIColor.init(red: 239/255, green: 239/255, blue: 224/255, alpha: 1.00)
        
        titleLable.font = UIFont.systemFontOfSize(10)
        titleLable.text = self.title
        titleLable.textColor = UIColor.blackColor()
        titleLable.frame = CGRectMake(40, 20, self.view.frame.size.width-80, 20)
        titleLable.textAlignment = .Center
        self.view.addSubview(titleLable)
        
        
        progressLB.font = UIFont.systemFontOfSize(10)
//        progressLB.text = String.init(format: "%.2f%%", f)
        progressLB.textColor = UIColor.blackColor()
        progressLB.frame = CGRectMake(self.view.frame.size.width-40, 20, 40, 20)
        progressLB.textAlignment = .Left
        self.view.addSubview(progressLB)
        
        contentView.font = UIFont.systemFontOfSize(fontSize)
        contentView.textColor = UIColor.blackColor()
        contentView.frame = CGRectMake(10, 40, self.view.frame.size.width-20, self.view.frame.size.height - 40)
        contentView.editable = false
        contentView.textContainerInset = UIEdgeInsetsZero
        contentView.contentInset = UIEdgeInsetsZero
        
        contentView.backgroundColor = UIColor.init(red: 239/255, green: 239/255, blue: 224/255, alpha: 1.00)
        contentView.textAlignment = .Left
        contentView.scrollEnabled = false
        self.view.addSubview(contentView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        log(touches)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        log(touches)
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
