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
    var bookItem: [String: AnyObject]?

    let enc: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
    
    // 分页存储内容
    var textPosStorage: [[String: AnyObject]]? = [[String: AnyObject]]()
    
    
    // 索引偏移
    var offset: Int = 0
    // 页面控制器
    var pageController: UIPageViewController?
    
    let slider = UISlider()
    
    var fontSize: CGFloat = 12.0
    
    var forwardTransition: Bool = false
    
    var currentIndex: Int = 0
    // 首次加载时
    var firstLoad = true

    var fd: UnsafeMutablePointer<FILE> = nil
    
    var childVCs: [PageChildViewController] = [PageChildViewController]()
    
    var nsprogress: NSProgress?
    let progressView: UIProgressView = UIProgressView.init(frame: CGRectMake(0, 64, 320, 44))
    
    let queue = dispatch_queue_create("com.lt.private-reader", DISPATCH_QUEUE_SERIAL)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view .backgroundColor = UIColor.init(red: 239/255, green: 239/255, blue: 224/255, alpha: 1.00)
        
        
        fd = fopen(bookItem!["Path"] as! String, "r")
        

        self.title = bookItem!["Name"] as? String
        
        let detailKey = (bookItem!["Name"] as! String) + "detailKey"
        
        let ud = NSUserDefaults.standardUserDefaults()
        let detailBookData: [String: AnyObject]? = ud.objectForKey(detailKey) as? [String: AnyObject]
        if (detailBookData != nil) {
            self.textPosStorage = detailBookData?["textPosStorage"] as? [[String: AnyObject]]
            self.currentIndex = detailBookData?["currentIndex"] as! Int
            firstLoad = false
        }else{
            firstLoad = true
        }
        
        // Do any additional setup after loading the view.

        self.view .addSubview(progressView)
        

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //        saveReadProgress()
        
        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.hidesBarsOnTap = true
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        readProgress()
    }
    
    override func didReceiveMemoryWarning() {
        log("didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
//        log(change)
        weak var weakSelf: BookPageViewController! = self
        if keyPath == "completedUnitCount" {
            log("completedUnitCount:\(change)")
            if nsprogress?.fractionCompleted == 1.0 {
                dispatch_async(dispatch_get_main_queue(), {
                    weakSelf.pageController!.setViewControllers([weakSelf.childVCs[0]], direction: .Forward, animated: true, completion: nil)
                    weakSelf.pageController?.delegate = self
                    weakSelf.pageController?.dataSource = self
                    weakSelf.addChildViewController(weakSelf.pageController!)
                    weakSelf.view.addSubview(weakSelf.pageController!.view)
                    weakSelf.pageController?.didMoveToParentViewController(weakSelf)
                })
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    weakSelf.progressView.setProgress((change!["new"] as! Float / Float((weakSelf.nsprogress?.totalUnitCount)!)), animated: true)
                })
            }
            
        }
    }
    
    // 初始化页面控制器
    func initPageViewController() {
        weak var weakSelf: BookPageViewController! = self
        pageController = UIPageViewController(transitionStyle: .PageCurl, navigationOrientation: .Horizontal, options: nil)
        for i in 0..<textPosStorage!.count {
            let childVC = PageChildViewController()
            childVC.percent = Float(currentIndex + i) * 100 / Float((textPosStorage?.count)!)
            // 设内容
            let item: [String: AnyObject] = (textPosStorage?[i])!
            childVC.text = (item["text"] as? String)!
            childVC.title = bookItem!["Name"] as? String
            childVC.pageNumber = i
            childVCs.append(childVC)
            nsprogress?.completedUnitCount = i + 1

            
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            if weakSelf.progressView.progress == 1.0 {
                
            }
            
        })
        
        
    }
    
    // 初始化工具栏，目前未添加功能
    func initBar() {
        weak var weakSelf:BookPageViewController! = self
        dispatch_async(dispatch_get_main_queue()) { 
            let rectToolBar = (weakSelf.navigationController?.toolbar.frame)!
            weakSelf.slider.frame = CGRectMake(0, 0, 290, rectToolBar.height)
            weakSelf.slider.maximumValue = 100
            weakSelf.slider.minimumValue = 0
            
            weakSelf.slider.value = Float(weakSelf.currentIndex * 100 / (weakSelf.textPosStorage?.count)! )
            
            
            weakSelf.slider.continuous = true
            weakSelf.slider.addTarget(self, action: #selector(BookPageViewController.readSliderChange(_: )), forControlEvents: .TouchUpInside)
            weakSelf.slider.addTarget(self, action: #selector(BookPageViewController.sliderFalse(_: )), forControlEvents: .TouchUpOutside)
            let toolBarItem: UIBarButtonItem = UIBarButtonItem.init(customView: weakSelf.slider)
            toolBarItem.imageInsets = UIEdgeInsetsZero
            weakSelf.toolbarItems = [toolBarItem]
            weakSelf.navigationController?.hidesBarsOnSwipe = true
            weakSelf.navigationController?.hidesBarsOnTap = true
            
            weakSelf.navigationController?.toolbarHidden = false
        }
        
    }
    
    
    
    func readProgress() {
        readFile(&bookItem!, textPosStorage: &textPosStorage!)
        nsprogress = NSProgress.init(totalUnitCount: Int64((textPosStorage?.count)!))
        nsprogress?.addObserver(self, forKeyPath: "completedUnitCount", options: NSKeyValueObservingOptions.New, context: nil)
        dispatch_async(queue, {
            self.initPageViewController()
        })
        dispatch_async(queue, {
            self.initBar()
        })
        
        
    }
    
    // 读取书本内容
    func readFile(inout bookItem: [String: AnyObject], inout textPosStorage: [[String: AnyObject]])-> Bool {
        
        let fileSize: Int = bookItem["Size"] as! Int
        var readBuffer = [UInt8].init(count: fileSize, repeatedValue: 0)
        let fd: UnsafeMutablePointer<FILE> = fopen(bookItem["Path"] as! String, "r")
        fseek(fd, 0, SEEK_SET)
        fread(&readBuffer, fileSize, 1, fd)
        fclose(fd)
        let enc: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
        let bookContent = String.init(bytes: readBuffer, encoding: enc)
        readBuffer.removeAll()
        var textPos = 0
        let totalSize = (bookContent?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))!
        if totalSize == 0 {
            return false
        }
        let frameXOffset: CGFloat = 20.0;
        let frameYOffset: CGFloat = 60.0;
        
        let path: CGMutablePathRef = CGPathCreateMutable();
        let textFrame: CGRect = CGRectInset(self.view.bounds, frameXOffset, frameYOffset);
        CGPathAddRect(path, nil, textFrame );
        
        let attrString = NSAttributedString.init(string: bookContent!, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(12)])
        let framesetter: CTFramesetterRef = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)
        while textPos < totalSize  {
            let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos,0), path, nil)
            let range: CFRange = CTFrameGetVisibleStringRange(frame);
            if range.length == 0 {
                break
            }
            
            let content = attrString.attributedSubstringFromRange(NSRange.init(location: textPos, length: range.length))
            let item = ["begin": textPos,"size": range.length,"text": content.string]
            textPosStorage.append(item as! [String : AnyObject])
            //            let item = ["begin": textPos,"size": range.length]
            //            textPosStorage.append(item)
            
            textPos = textPos + range.length
            //            dispatch_sync(queue, {
            
            
            //            })
            self.progressView.setNeedsDisplay()
        }
        bookItem["content"] = attrString
        
        return true
    }
    
    func sliderFalse(sender: UISlider) {
        log("sliderFalse")
        slider.value = Float(currentIndex * 100 / (textPosStorage?.count)! )
    }
    
    func readSliderChange(sender: UISlider) {
        log("\(sender.value)")
        weak var weakSelf = self
        
        // 初始化前后200页的数据 直接写到moveToProgress里
        dispatch_async(dispatch_get_main_queue()) {
            weakSelf!.moveToProgress(Int(sender.value))
        }
//        NSTimer.
    }
    
    // 测试
    func test(sender: UIBarButtonItem) {
        log("test")
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
     - date: 16-06-16 01: 06: 03
     按下标生成子页面
     
     - parameter before: 翻页方向是否向后，false即向前
     
     - returns: 生成的子页面
     */
    func viewControllerAtIndex(forward forward: Bool) -> UIViewController? {
        let childVC = PageChildViewController()
        forwardTransition = forward
        return childVC
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    internal func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int{
        return currentIndex
    }
    
    internal func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int{
        return (childVCs.count)
    }
    
    internal func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?{
        let vc: PageChildViewController = viewController as! PageChildViewController
        if vc.pageNumber == 0 {
            return nil
        }
        log(vc.pageNumber)
        let childVC = childVCs[vc.pageNumber - 1]
//        self.view .addSubview(childVC.view)
        return childVC
    }
    
    internal func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?{
        let vc: PageChildViewController = viewController as! PageChildViewController
        if vc.pageNumber == (textPosStorage?.count)! - 1 {
            return nil
        }
        log(vc.pageNumber)
        let childVC = childVCs[vc.pageNumber + 1]
        return childVC
    }
    
    // MARK: - UIPageViewControllerDelegate
    
//    internal func pageViewController(pageViewController: UIPageViewController, spineLocationForInterfaceOrientation orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation{
//        UIPageViewControllerSpineLocationMid
//    }
    
    internal func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
        log("didFinishAnimating")
    }
    
    internal func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]){
        // 发生翻译时，隐藏bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
        /*
        weak var weakSelf = self
        
        log("\(pendingViewControllers.count)")
        
        let childVC: PageChildViewController = pendingViewControllers.last as! PageChildViewController
        if currentIndex  == 0  {
            if firstLoad && forwardTransition {
                childVC.readProgress = Float(weakSelf!.currentIndex * 100 / (weakSelf!.textStorage?.count)!)
                // 设内容
                childVC.contentView.text = weakSelf!.textStorage?[weakSelf!.currentIndex]
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
        }*/

    }
    
    /*!
     
     - author: Tun Lan
     - date: 16-06-20 17: 06: 01
     移动到索引
     
     - parameter index: 索引下标
     */
    /*
    func moveToIndex(index: Int){
        guard case self.currentIndex = index where self.currentIndex >= 0 && self.currentIndex < self.textStorage?.count else{
            return
        }
        
        let childVC: PageChildViewController = self.pageController?.viewControllers!.last as! PageChildViewController
        
        childVC.readProgress = Float(self.currentIndex) * 100 / Float((self.textStorage?.count)!)
        // 设内容
        childVC.contentView.text = self.textStorage?[self.currentIndex - offset]
        // 设标题
        childVC.title = self.bookItem!["Name"] as? String
        
        // save read progress
        saveReadProgress()
        self.slider.value = childVC.readProgress
    }
    */
    /*!
     
     - author: Tun Lan
     - date: 16-06-20 17: 06: 32
     移动到百分比
     
     - parameter progress: 百分比
     */
    func moveToProgress(progress: Int) {
//        weak var weakSelf = self
        
        // 先初始化前后200页
        
//        weakSelf!.currentIndex = progress * (weakSelf!.textPosStorage?.count)! / 100
//        offset = weakSelf!.currentIndex - 200
//        if offset <= 0 {
//            offset = 0
//        }
//        let attrString = weakSelf!.bookItem!["content"] as! NSAttributedString
//        for i in 0..<400 {
//            if offset + i >= (weakSelf!.textPosStorage?.count)! {
//                break
//            }
//            let textPos: Int = weakSelf!.textPosStorage![offset + i]["begin"] as! Int
//            let length: Int = weakSelf!.textPosStorage![offset + i]["size"] as! Int
//            let text = attrString.attributedSubstringFromRange(NSRange.init(location: textPos, length: length)).string
//            weakSelf!.textStorage![i] = text
//        }
//
//        
//        if weakSelf!.currentIndex >= weakSelf!.textStorage?.count {
//            weakSelf!.currentIndex = (weakSelf!.textStorage?.count)! - 1
//        }
//        if weakSelf!.currentIndex < 0 {
//            weakSelf!.currentIndex = 0
//        }
//        
//        let childVC: PageChildViewController = weakSelf!.pageController?.viewControllers!.last as! PageChildViewController
//        childVC.readProgress = Float(weakSelf!.currentIndex) * 100 / Float((weakSelf!.textStorage?.count)!)
//        // 设内容
//        childVC.contentView.text = weakSelf!.textStorage?[weakSelf!.currentIndex - offset]
//        // 设标题
//        childVC.title = weakSelf!.bookItem!["Name"] as? String
        
        // save read progress
//        saveReadProgress()
        var tempIndex = progress * (textPosStorage?.count)! / 100
        if tempIndex >= childVCs.count {
            tempIndex = childVCs.count - 1
        }
        var direction: UIPageViewControllerNavigationDirection = UIPageViewControllerNavigationDirection.Forward
        if tempIndex < currentIndex  {
            direction = .Reverse
        }
        weak var weakSelf = self
        self.pageController?.setViewControllers([childVCs[tempIndex]], direction: direction, animated: true, completion: { (success) in
            if success {
                weakSelf!.currentIndex = tempIndex
            }
        })
    }
    /*
    func saveReadProgress() {
        let ud = NSUserDefaults.standardUserDefaults()
        let detailKey = (self.bookItem!["Name"] as! String) + "detailKey"
        let detailBookData = [
            "textPosStorage": self.textPosStorage!,
            "currentIndex": self.currentIndex,
            "offset": self.offset
        ]
        ud.setObject(detailBookData, forKey: detailKey)
        ud.synchronize()
    }
 */
}
