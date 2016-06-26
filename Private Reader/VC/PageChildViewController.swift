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
    lazy var titleLable:UILabel = {
        let titleLableTmp = UILabel(frame: CGRectMake(40, 20, self.view.frame.size.width-80, 20))
        titleLableTmp.font = UIFont.systemFontOfSize(10)
        titleLableTmp.text = self.title
        titleLableTmp.textColor = textColor
        titleLableTmp.textAlignment = .Center
        return titleLableTmp
    }()
    // 进度
    var percent:Float = 0.0
    
    lazy var progressLB:UILabel = {
        let progressLBTmp = UILabel(frame: CGRectMake(self.view.frame.size.width-40, 20, 40, 20))
        progressLBTmp.font = UIFont.systemFontOfSize(10)
        progressLBTmp.textColor = textColor
        progressLBTmp.textAlignment = .Left
        return progressLBTmp
    }()
    // 文本内容显示
    
    var text:String = ""
    
    lazy var contentView:UITextView = {
        let contentViewTmp = UITextView(frame: CGRectMake(10, 40, self.view.frame.size.width-20, self.view.frame.size.height - 40))
        contentViewTmp.font = UIFont.systemFontOfSize(12)
        contentViewTmp.textColor = textColor
        contentViewTmp.editable = false
        contentViewTmp.textContainerInset = UIEdgeInsetsZero
        contentViewTmp.contentInset = UIEdgeInsetsZero
        
        contentViewTmp.backgroundColor = viewBackgroundColor
        contentViewTmp.textAlignment = .Left
        contentViewTmp.scrollEnabled = false
        return contentViewTmp
    }()
    
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
        
        self.view.backgroundColor = viewBackgroundColor
        
        self.titleLable.text = self.title
        self.view.addSubview(titleLable)
        
        readProgress = percent
        
        self.view.addSubview(progressLB)
        
        contentView.text = text
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
