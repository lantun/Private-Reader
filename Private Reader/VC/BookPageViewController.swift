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
    var textPosStorage: [[String: AnyObject]]? = nil
    
    // 页面控制器
    var pageController: UIPageViewController?
    
    let slider = UISlider()
    
    var fontSize: CGFloat = 12.0
    
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
        
        let currentIndexKey = (bookItem!["Name"] as! String) + "currentIndexKey"
        let textPosStorageKey = (bookItem!["Name"] as! String) + "textPosStorageKey"
        let ud = NSUserDefaults.standardUserDefaults()
        self.textPosStorage = ud.objectForKey(textPosStorageKey) as? [[String: AnyObject]]
        if (self.textPosStorage != nil) {
            let index = ud.objectForKey(currentIndexKey) as? Int
            if (index != nil) {
                self.currentIndex = index!
            }
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
        
        for vc in childVCs {
            vc.removeFromParentViewController()
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        aiv.backgroundColor = UIColor.clearColor()
        aiv.frame.size = CGSize(width: 100, height: 100)
        aiv.center = self.view.center
        aiv.hidesWhenStopped = false
        aiv.color = UIColor.blackColor()
        self.view .addSubview(aiv)
        dispatch_async(dispatch_get_main_queue()) {
            self.aiv.startAnimating()
        }
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
    
    
    // 加个菊花
    let aiv: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    /*!
     
     - author: Tun Lan
     - date: 16-06-22 23:06:50
     读文件进程
     */
    func readProgress() {
 
        if firstLoad {
            if !readFile(&bookItem!, textPosStorage: &textPosStorage) {
                let alert = UIAlertView.init(title: "", message: "open Err", delegate: nil, cancelButtonTitle: "ok")
                alert.show()
                self.navigationController?.popViewControllerAnimated(true)
                return
            }
            
            let textPosStorageKey = (bookItem!["Name"] as! String) + "textPosStorageKey"
            let ud = NSUserDefaults.standardUserDefaults()
            ud.setObject(self.textPosStorage, forKey: textPosStorageKey)
            ud.synchronize()
            firstLoad = false

        }
        nsprogress = NSProgress.init(totalUnitCount: Int64((textPosStorage?.count)!))
        nsprogress?.addObserver(self, forKeyPath: "completedUnitCount", options: NSKeyValueObservingOptions.New, context: nil)
        dispatch_async(queue, {
            
            self.initPageViewController()
        })
        dispatch_async(queue, {
            self.initBar()
            self.aiv.stopAnimating()
        })
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        weak var weakSelf: BookPageViewController! = self
        if keyPath == "completedUnitCount" {
            log("completedUnitCount:\(change)")
            if nsprogress?.fractionCompleted == 1.0 {
                // 假如已满，则初始化界面
                dispatch_async(dispatch_get_main_queue(), {
                    weakSelf.pageController!.setViewControllers([weakSelf.childVCs[weakSelf.currentIndex]], direction: .Forward, animated: true, completion: nil)
                    weakSelf.pageController?.delegate = self
                    weakSelf.pageController?.dataSource = self
                    weakSelf.addChildViewController(weakSelf.pageController!)
                    weakSelf.view.addSubview(weakSelf.pageController!.view)
                    weakSelf.pageController?.didMoveToParentViewController(weakSelf)
                })
            }else{
                // 假如未满，则更新进度条
                dispatch_async(dispatch_get_main_queue(), {
                    weakSelf.progressView.setProgress((change!["new"] as! Float / Float((weakSelf.nsprogress?.totalUnitCount)!)), animated: true)
                })
            }
            
        }
    }
    
    /*!
     
     - author: Tun Lan
     - date: 16-06-22 23:06:32
     初始化页面控制器
     
     - returns: nil
     */
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
    
    /*!
     
     - author: Tun Lan
     - date: 16-06-22 23:06:43
     初始化工具栏
     
     - returns: nil
     */
    func initBar() {
        weak var weakSelf:BookPageViewController! = self
        dispatch_async(dispatch_get_main_queue()) { 
            let rectToolBar = (weakSelf.navigationController?.toolbar.frame)!
            weakSelf.slider.frame = CGRectMake(0, 0, 290, rectToolBar.height)
            weakSelf.slider.maximumValue = 100
            weakSelf.slider.minimumValue = 0
            
            weakSelf.slider.value = Float(weakSelf.currentIndex * 100 / (weakSelf.textPosStorage?.count)! )
            
            
            weakSelf.slider.continuous = true
            weakSelf.slider.addTarget(self, action: #selector(BookPageViewController.sliderTouchUpInside(_: )), forControlEvents: .TouchUpInside)
            weakSelf.slider.addTarget(self, action: #selector(BookPageViewController.sliderFalse(_: )), forControlEvents: .TouchUpOutside)
            let toolBarItem: UIBarButtonItem = UIBarButtonItem.init(customView: weakSelf.slider)
            toolBarItem.imageInsets = UIEdgeInsetsZero
            weakSelf.toolbarItems = [toolBarItem]
            weakSelf.navigationController?.hidesBarsOnSwipe = true
            weakSelf.navigationController?.hidesBarsOnTap = true
            
            weakSelf.navigationController?.toolbarHidden = false
        }
        
    }
    
    func getTxtEncoding(buffer:[UInt8]) -> NSStringEncoding? {
        let arrEncoding = [
            NSASCIIStringEncoding,
            NSNEXTSTEPStringEncoding,
            NSJapaneseEUCStringEncoding,
            NSUTF8StringEncoding,
            NSISOLatin1StringEncoding,
            NSSymbolStringEncoding,
            NSNonLossyASCIIStringEncoding,
            NSShiftJISStringEncoding,
            NSISOLatin2StringEncoding,
            NSUnicodeStringEncoding,
            NSWindowsCP1251StringEncoding,
            NSWindowsCP1252StringEncoding,
            NSWindowsCP1253StringEncoding,
            NSWindowsCP1254StringEncoding,
            NSWindowsCP1250StringEncoding,
            NSISO2022JPStringEncoding,
            NSMacOSRomanStringEncoding,
            NSUTF16StringEncoding,
            NSUTF16BigEndianStringEncoding,
            NSUTF16LittleEndianStringEncoding,
            NSUTF32StringEncoding,
            NSUTF32BigEndianStringEncoding,
            NSUTF32LittleEndianStringEncoding
        ]
        for enc in arrEncoding {
            let tmp = String.init(bytes: buffer, encoding: enc)
            if tmp != nil {
                return enc
            }
        }
        return nil
    }
    
    /*!
     
     - author: Tun Lan
     - date: 16-06-22 23:06:53
     读取书本内容
     
     - parameter bookItem:       书本信息字典
     - parameter textPosStorage: 书本分页信息字典
     
     - returns: 读取是否成功
     */
    func readFile(inout bookItem: [String: AnyObject], inout textPosStorage: [[String: AnyObject]]?)-> Bool {
        
        let fileSize: Int = bookItem["Size"] as! Int
        var readBuffer = [UInt8].init(count: fileSize, repeatedValue: 0)
        let fd: UnsafeMutablePointer<FILE> = fopen(bookItem["Path"] as! String, "r")
        fseek(fd, 0, SEEK_SET)
        fread(&readBuffer, fileSize, 1, fd)
        fclose(fd)
        let enc = getTxtEncoding(readBuffer)
        let converenc: NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632) // kCFStringEncodingGB_18030_2000
        var bookContent:String? = String.init(bytes: readBuffer, encoding: converenc)
        if (bookContent == nil) {
            bookContent = String.init(bytes: readBuffer, encoding: enc!)
        }
        
        readBuffer.removeAll()
        var textPos = 0
        if bookContent == nil {
            return false
        }
        let totalSize = (bookContent?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))!
        if totalSize == 0 {
            return false
        }
        
        textPosStorage = [[String: AnyObject]]()
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
            textPosStorage?.append(item as! [String : AnyObject])

            textPos = textPos + range.length
        }
        bookItem["content"] = attrString
        
        return true
    }
    
    /*!
     
     - author: Tun Lan
     - date: 16-06-22 23:06:56
     进度条touchoutside响应，还原至当前当前阅读
     
     - parameter sender: 进度条
     */
    func sliderFalse(sender: UISlider) {
        log("sliderFalse")
        slider.value = Float(currentIndex * 100 / (textPosStorage?.count)! )
    }
    
    /*!
     
     - author: Tun Lan
     - date: 16-06-22 23:06:35
     进度条touchoutside响应，当前阅读进度跳转到进度条百分比进度
     
     - parameter sender: 进度条
     */
    func sliderTouchUpInside(sender: UISlider) {
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
        currentIndex = vc.pageNumber - 1
        let childVC = childVCs[currentIndex]
        return childVC
    }
    
    internal func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?{
        let vc: PageChildViewController = viewController as! PageChildViewController
        if vc.pageNumber == (textPosStorage?.count)! - 1 {
            return nil
        }
        log(vc.pageNumber)
        currentIndex = vc.pageNumber + 1
        let childVC = childVCs[currentIndex]
        return childVC
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    internal func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
        if finished {
            saveReadProgress()
        }
    }
    
    internal func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]){
        // 发生翻译时，隐藏bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)

    }
    
    /*!
     
     - author: Tun Lan
     - date: 16-06-20 17: 06: 01
     移动到索引
     
     - parameter index: 索引下标
     */
    
    func moveToIndex(index: Int){
        guard let _:Int = index where index >= 0 && index < self.textPosStorage?.count else{
            return
        }
        var direction = UIPageViewControllerNavigationDirection.Forward
        if index <= self.currentIndex {
            direction = UIPageViewControllerNavigationDirection.Reverse
        }
        self.currentIndex = index
        self.pageController?.setViewControllers([childVCs[self.currentIndex]], direction: direction, animated: true, completion: nil)
        // save read progress
        saveReadProgress()
    }
 
    /*!
     
     - author: Tun Lan
     - date: 16-06-20 17: 06: 32
     移动到百分比
     
     - parameter progress: 百分比
     */
    func moveToProgress(progress: Int) {
        // save read progress
        
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
                weakSelf!.saveReadProgress()
            }
        })
    }
    
    func saveReadProgress() {
        let ud = NSUserDefaults.standardUserDefaults()
        let currentIndexKey = (self.bookItem!["Name"] as! String) + "currentIndexKey"
        ud.setObject(self.currentIndex, forKey: currentIndexKey)
        ud.synchronize()
        log("saveReadProgress")
    }
 
}
