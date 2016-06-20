//
//  BookPageViewController.swift
//  Private Reader
//
//  Created by Tun Lan on 6/14/16.
//  Copyright © 2016 Tun Lan. All rights reserved.
//

// 阅读控制器
import UIKit


class BookPageViewController: UIViewController,UIPageViewControllerDataSource,UIPageViewControllerDelegate {
    // 书本数据字典
    var bookItem:[String:AnyObject]?

    let enc:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
    
    // 分页存储内容
    var textStorage:[[String:AnyObject]]?
    // 页面控制器
    var pageController:UIPageViewController?
    
    let slider = UISlider()
    
    var fontSize:CGFloat = 12.0
    
    var forwardTransition:Bool = false
    
    var currentIndex:Int = 0
    // 首次加载时
    var firstLoad = true

    var fd:UnsafeMutablePointer<FILE> = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        fd = fopen(bookItem!["Path"] as! String, "r")
        

        self.title = bookItem!["Name"] as? String
        let detailKey = (bookItem!["Name"] as! String) + "detailKey"
        
        let ud = NSUserDefaults.standardUserDefaults()
        let detailBookData:[String:AnyObject]? = ud.objectForKey(detailKey) as? [String:AnyObject]
        if (detailBookData != nil) {
            self.textStorage = detailBookData?["textStorage"] as? [[String:AnyObject]]
            self.currentIndex = detailBookData?["currentIndex"] as! Int
            firstLoad = false
        }else{
            firstLoad = true
        }
        
        // Do any additional setup after loading the view.
 
        initBar()
        initPageViewController()

    }
    
    // 初始化页面控制器
    func initPageViewController() {
        pageController = UIPageViewController(transitionStyle: .PageCurl, navigationOrientation: .Horizontal, options: nil)
        let childVC:PageChildViewController = viewControllerAtIndex(forward: true) as! PageChildViewController
        childVC.readProgress = Float(currentIndex) * 100 / Float((textStorage?.count)!)
        // 设内容
        childVC.contentView.text = (textStorage?[currentIndex]["text"] as! String)
        childVC.title = bookItem!["Name"] as? String
        pageController?.setViewControllers([childVC], direction: .Forward, animated: true, completion: nil)
        pageController?.delegate = self
        pageController?.dataSource = self
        self.addChildViewController(pageController!)
        self.view.addSubview(pageController!.view)
        pageController?.didMoveToParentViewController(self)

        
    }
    

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let ud = NSUserDefaults.standardUserDefaults()
        let detailKey = (bookItem!["Name"] as! String) + "detailKey"
        let detailBookData = [
            "textStorage":self.textStorage!,
            "currentIndex":self.currentIndex
            ]
        ud.setObject(detailBookData, forKey: detailKey)
        ud.synchronize()
        fclose(fd)
        
        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.hidesBarsOnTap = true
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    // 初始化工具栏，目前未添加功能
    func initBar() {
        self.navigationController?.toolbarHidden = false
        let rectToolBar = (self.navigationController?.toolbar.frame)!
        slider.frame = CGRectMake(0, 0, rectToolBar.width - 30, rectToolBar.height)
        slider.maximumValue = 100
        slider.minimumValue = 0
        
        slider.value = Float(currentIndex * 100 / (textStorage?.count)! )

        slider.continuous = true
        slider.addTarget(self, action: #selector(BookPageViewController.readSliderChange(_:)), forControlEvents: .TouchUpInside)
        let toolBarItem: UIBarButtonItem = UIBarButtonItem.init(customView: slider)
        self.toolbarItems = [toolBarItem]

        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.hidesBarsOnTap = true

        
    }
    
    func readSliderChange(sender:UISlider) {
        log("\(sender.value)")
        weak var weakSelf = self
        
        // 初始化前后200页的数据 直接写到moveToProgress里
        dispatch_async(dispatch_get_main_queue()) {
            weakSelf!.moveToProgress(Int(sender.value))
        }
//        NSTimer.
    }
    
    // 测试
    func test(sender:UIBarButtonItem) {
        log("test")
    }

    override func didReceiveMemoryWarning() {
        log("didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // 按下标生成子页面
    /*!
     
     - author: Tun Lan
     - date: 16-06-16 01:06:03
     按下标生成子页面
     
     - parameter before: 翻页方向是否向后，false即向前
     
     - returns: 生成的子页面
     */
    func viewControllerAtIndex(forward forward:Bool) -> UIViewController? {
        let childVC = PageChildViewController()
        forwardTransition = forward
        return childVC
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    internal func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?{
        if currentIndex == 0 {
            return nil
        }
        return viewControllerAtIndex(forward: false)
    }
    
    internal func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?{
        if currentIndex == (textStorage?.count)! - 1 {
            return nil
        }
        return viewControllerAtIndex(forward: true)
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    internal func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
        log("didFinishAnimating")
    }
    
    internal func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]){
        // 发生翻译时，隐藏bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
        weak var weakSelf = self
        
        log("\(pendingViewControllers.count)")
        
        let childVC:PageChildViewController = pendingViewControllers.last as! PageChildViewController
        if currentIndex  == 0  {
            if firstLoad && forwardTransition {
                childVC.readProgress = Float(weakSelf!.currentIndex * 100 / (weakSelf!.textStorage?.count)!)
                // 设内容
                childVC.contentView.text = (weakSelf!.textStorage?[weakSelf!.currentIndex]["text"] as! String)
                // 设标题
                childVC.title = weakSelf!.bookItem!["Name"] as? String
                firstLoad = false
            }
        }
        dispatch_async(dispatch_get_main_queue()) {
            if weakSelf!.forwardTransition {
                if weakSelf!.currentIndex != (weakSelf!.textStorage?.count)! - 1 {
                    weakSelf!.currentIndex = weakSelf!.currentIndex + 1
                }
                
            }else{
                if weakSelf!.currentIndex != 0 {
                    weakSelf!.currentIndex = weakSelf!.currentIndex - 1
                }
            }
            if weakSelf!.currentIndex >= weakSelf!.textStorage?.count {
                weakSelf!.currentIndex = (weakSelf!.textStorage?.count)! - 1
            }
            if weakSelf!.currentIndex < 0 {
                weakSelf!.currentIndex = 0
            }
            weakSelf!.moveToIndex(weakSelf!.currentIndex)
        }

    }
    
    /*!
     
     - author: Tun Lan
     - date: 16-06-20 17:06:01
     移动到索引
     
     - parameter index: 索引下标
     */
    func moveToIndex(index:Int){
        guard case self.currentIndex = index where self.currentIndex >= 0 && self.currentIndex < self.textStorage?.count else{
            return
        }
        
        let childVC:PageChildViewController = self.pageController?.viewControllers!.last as! PageChildViewController
        
        childVC.readProgress = Float(self.currentIndex) * 100 / Float((self.textStorage?.count)!)
        // 设内容
        let attrString = self.bookItem!["content"] as! NSAttributedString
        let textPos:Int = self.textStorage![self.currentIndex]["begin"] as! Int
        let length:Int = self.textStorage![self.currentIndex]["size"] as! Int
        childVC.contentView.text = attrString.attributedSubstringFromRange(NSRange.init(location: textPos, length: length)).string
        // 设标题
        childVC.title = self.bookItem!["Name"] as? String
        
        // save read progress
        let ud = NSUserDefaults.standardUserDefaults()
        let detailKey = (self.bookItem!["Name"] as! String) + "detailKey"
        let detailBookData = [
            "textStorage":self.textStorage!,
            "currentIndex":self.currentIndex
        ]
        ud.setObject(detailBookData, forKey: detailKey)
        ud.synchronize()
        self.slider.value = childVC.readProgress
    }
    
    /*!
     
     - author: Tun Lan
     - date: 16-06-20 17:06:32
     移动到百分比
     
     - parameter progress: 百分比
     */
    func moveToProgress(progress:Int) {
        weak var weakSelf = self
        
        // 先初始化前后200页 （好像作用不大）
        /*
        weakSelf!.currentIndex = progress * (weakSelf!.textStorage?.count)! / 100
        var tempIndex = weakSelf!.currentIndex - 200
        if tempIndex <= 0 {
            tempIndex = 0
        }
        let attrString = weakSelf!.bookItem!["content"] as! NSAttributedString
        for i in 0..<400 {
            
            let textPos:Int = weakSelf!.textStorage![tempIndex + i]["begin"] as! Int
            let length:Int = weakSelf!.textStorage![tempIndex + i]["size"] as! Int
            weakSelf!.textStorage![tempIndex + i]["text"] = attrString.attributedSubstringFromRange(NSRange.init(location: textPos, length: length)).string
        }

        */
        if weakSelf!.currentIndex >= weakSelf!.textStorage?.count {
            weakSelf!.currentIndex = (weakSelf!.textStorage?.count)! - 1
        }
        if weakSelf!.currentIndex < 0 {
            weakSelf!.currentIndex = 0
        }
        
        let childVC:PageChildViewController = weakSelf!.pageController?.viewControllers!.last as! PageChildViewController
        childVC.readProgress = Float(weakSelf!.currentIndex) * 100 / Float((weakSelf!.textStorage?.count)!)
        // 设内容
        let attrString = weakSelf!.bookItem!["content"] as! NSAttributedString
        let textPos:Int = weakSelf!.textStorage![weakSelf!.currentIndex]["begin"] as! Int
        let length:Int = weakSelf!.textStorage![weakSelf!.currentIndex]["size"] as! Int
        childVC.contentView.text = attrString.attributedSubstringFromRange(NSRange.init(location: textPos, length: length)).string
//        childVC.contentView.text = (weakSelf!.textStorage?[weakSelf!.currentIndex]["text"] as! String)
        // 设标题
        childVC.title = weakSelf!.bookItem!["Name"] as? String
        
        // save read progress
        let ud = NSUserDefaults.standardUserDefaults()
        let detailKey = (weakSelf!.bookItem!["Name"] as! String) + "detailKey"
        let detailBookData = [
            "textStorage":weakSelf!.textStorage!,
            "currentIndex":weakSelf!.currentIndex
        ]
        ud.setObject(detailBookData, forKey: detailKey)
        ud.synchronize()
        
    }
}
