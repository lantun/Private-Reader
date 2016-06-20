//
//  BookListCollectionViewController.swift
//  Private Reader
//
//  Created by Tun Lan on 6/12/16.
//  Copyright © 2016 Tun Lan. All rights reserved.
//

// 首页
import UIKit
import LocalAuthentication

private let reuseIdentifier = "Cell"

// 列表按钮图片数组
let iconOnArray = ["WiFiOn","bright"]
let iconOffArray = ["WiFi","brightness"]

class BookListCollectionViewController: UICollectionViewController,GCDWebUploaderDelegate,UITableViewDelegate,UITableViewDataSource {

    // wifi 服务器
    let _webServer:GCDWebUploader = GCDWebUploader.init(uploadDirectory: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!)
    // 书本数组
    var bookListArray:[[String:AnyObject]] = [[String:AnyObject]]()
    
    // 过通验证 = 是
    var evaluatePolicyOK = true
    
    // 导航右按钮显示的列表按钮
    var rightTableMenu:UITableView?
    // 列表按钮显示 = 是
    var rightTableMenuIsShow:Bool = true
    // 列表按钮行数
    var cellcount = 0;
    
    
    
    // 显示列表按钮
    func showRightTableMenu(sender:UIBarButtonItem) {
        if !rightTableMenuIsShow {
            cellcount = 0
            rightTableMenuIsShow = true
        }else{
            cellcount = iconOnArray.count
            rightTableMenuIsShow = false
        }
        rightTableMenu?.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: .Fade)
    }
    
    // MARK: UITableViewDataSource
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return cellcount
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell:UITableViewCell = UITableViewCell()
        cell.backgroundColor = UIColor.clearColor()
        cell.tintColor = UIColor.grayColor()
        cell.backgroundView = UIImageView(image: UIImage(named: iconOffArray[indexPath.row]))
        cell.selectedBackgroundView = UIImageView(image: UIImage(named: iconOnArray[indexPath.row]))
        cell.selectedBackgroundView?.tintColor = UIColor.blackColor()
        return cell
    }
    
    internal func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    // MARK: UITableViewDelegate
    internal func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 40
    }
    
    internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        switch indexPath.row {
        case 0:
            // wifi on
            openWiFi()
            break
        case 1:
            // bright on
            break
        default:
            log("switch err")
            break
        }
    }
    internal func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath){
        switch indexPath.row {
        case 0:
            // wifi off
            closeWiFi()
            break
        case 1:
            // bright off
            break
        default:
            log("switch err")
            break
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        
        self.title = "Home"
        self.collectionView!.backgroundColor = UIColor.init(red: 239/255, green: 239/255, blue: 224/255, alpha: 1.00)
            //[UIColor colorWithRed:0.451 green:0.451 blue:0.451 alpha:1.00]
    
        
        self.collectionView!.registerClass(BookCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)


        evaluatePolicy()
        // Do any additional setup after loading the view.
        let rightBtn:UIBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "more"), style: .Plain, target: self, action: #selector(BookListCollectionViewController.showRightTableMenu(_:)))
        rightBtn.imageInsets = UIEdgeInsetsMake(13, 8, 8, 5)
        let leftBtn:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(BookListCollectionViewController.reloadDir))
        self.navigationItem.rightBarButtonItems = [rightBtn]
        self.navigationItem.leftBarButtonItems = [leftBtn]
        
        
        initRightTableViewMenu()
    }
    
    // 页面初始化右边列表按钮
    func initRightTableViewMenu() {
        let rect:CGRect = CGRectMake(self.view.frame.width - 50, 74, 40, 80)
        rightTableMenu = UITableView(frame: rect, style: .Plain)
        rightTableMenu?.delegate = self
        rightTableMenu?.dataSource = self
        rightTableMenu?.bounces = false
        rightTableMenu?.backgroundColor = UIColor.clearColor()
        rightTableMenu?.separatorStyle = .None
        rightTableMenu?.separatorInset = UIEdgeInsetsZero
        rightTableMenu?.allowsMultipleSelection = true
        self.view.addSubview(rightTableMenu!)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.setToolbarHidden(true, animated: true)
        super.viewWillAppear(animated)
    }
    
    // 读取书本内容
    func readFile(inout bookItem:[String:AnyObject], inout textStorage:[[String:AnyObject]])-> Bool {
        
        let fileSize:Int = bookItem["Size"] as! Int
        var readBuffer = [UInt8].init(count: fileSize, repeatedValue: 0)
        let fd:UnsafeMutablePointer<FILE> = fopen(bookItem["Path"] as! String, "r")
        fseek(fd, 0, SEEK_SET)
        fread(&readBuffer, fileSize, 1, fd)
        fclose(fd)
        let enc:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
        let bookContent = String.init(bytes: readBuffer, encoding: enc)
        readBuffer.removeAll()
        var textPos = 0
        let totalSize = (bookContent?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))!
        if totalSize == 0 {
            return false
        }
        
        let frameXOffset:CGFloat = 20.0;
        let frameYOffset:CGFloat = 60.0;
        
        let path:CGMutablePathRef = CGPathCreateMutable();
        let textFrame:CGRect = CGRectInset(self.view.bounds, frameXOffset, frameYOffset);
        CGPathAddRect(path, nil, textFrame );
        
        let attrString = NSAttributedString.init(string: bookContent!, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12)])
        let framesetter:CTFramesetterRef = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)
        while textPos < totalSize  {
            let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos,0), path, nil)
            let range:CFRange = CTFrameGetVisibleStringRange(frame);
            if range.length == 0 {
                break
            }
            
            
//            let item = ["begin":textPos,"size":range.length,"text":content.string]
//            textStorage.append(item as! [String : AnyObject])
            let item = ["begin":textPos,"size":range.length]
            textStorage.append(item)

            textPos = textPos + range.length
        }
        bookItem["content"] = attrString
        
//        let content = attrString.attributedSubstringFromRange(NSRange.init(location: textPos, length: range.length))
//        totalSize = (bookContent?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))!
//        if totalSize == 0 {
//            return false
//        }
//        let tvWidth = self.view.frame.size.width-20
//        let tvHeight = self.view.frame.size.height - 40
//        var allHeight:CGFloat = 0.0
//        let maxReadSize = 100000
//        if totalSize > maxReadSize {
//            let w = Int(totalSize/maxReadSize) + 1
//            let progressView:UIProgressView = UIProgressView()
//            progressView.frame = CGRectMake(10, self.view .frame.height/2 - 10, self.view .frame.width - 20, 20)
//            self.view .addSubview(progressView)
//            for i in 0..<w {
//                if i == w - 1 {
//                    allHeight = allHeight + (bookContent?[i*maxReadSize,totalSize - i*maxReadSize].getAutoheight(UIFont.systemFontOfSize(12), width: tvWidth))!
//                }else{
//                    allHeight = allHeight + (bookContent?[i*maxReadSize,maxReadSize].getAutoheight(UIFont.systemFontOfSize(12), width: tvWidth))!
//                }
//                // show progress
//                progressView .progress = Float(i/w)
//                log("progress :\(progressView .progress) \(i)\\\(w)")
//            }
//        }else{
//            allHeight = (bookContent?.getAutoheight(UIFont.systemFontOfSize(12), width: tvWidth))!
//        }
        
        
//        if fileSize > 300 {
//            totalIndex = Int(fileSize / 300) + 1
//        }else{
//            totalIndex = 1
//        }
        
        return true
    }
    // 读取文件列表
    func reloadDir() {
        bookListArray.removeAll()
//        if !evaluatePolicyOK {
//            collectionView?.reloadData()
//            return
//        }
        let manager = NSFileManager.defaultManager()
        let root:String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        let enumerator:NSDirectoryEnumerator? =  manager.enumeratorAtPath(root)
        var filename:String? = (enumerator?.nextObject()) as? String
        while filename != nil {
            
            let filePath = root+"/"+filename!
            
            let fileSize:Int = (enumerator?.fileAttributes?[NSFileSize])! as! Int
            
            log(filePath+",filesize:\(fileSize)")
            let bookItem:[String : AnyObject] = [
                "Path":filePath,
                "Name":filename!,
                "Size":fileSize
            ]
            bookListArray.append(bookItem)
            filename = (enumerator?.nextObject()) as? String
        }
        collectionView?.reloadData()
    }

    var msgView:UIView?
    var msgLabel:UILabel?
    // 打开wifi
    func openWiFi() {
        
        _webServer.delegate = self
        _webServer.allowHiddenItems = true
        if _webServer.start() {
            // show msg
            msgView = UIView()
            msgView?.frame = CGRectMake(0, self.view.frame.height - 50, self.view.frame.width, 50)
            msgView?.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(msgView!)
            
            msgLabel = UILabel()
            msgLabel?.frame = CGRectMake(10, 4, self.view.frame.width-20, 42)
            msgLabel?.textColor = UIColor.blackColor()
            msgLabel?.textAlignment = .Center
            msgLabel?.numberOfLines = 0
            msgLabel?.lineBreakMode = .ByWordWrapping
            msgLabel?.text = "File upload webservice running \n\(_webServer.serverURL.absoluteString)"
            msgView?.addSubview(msgLabel!)
        }
        
    }
    
    func closeWiFi() {
        _webServer.stop()
        msgLabel?.removeFromSuperview()
        msgView?.removeFromSuperview()
    }
    
    // 打开指纹验证
    func evaluatePolicy() {
        let contect:LAContext = LAContext()
        contect.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock access to locked featured") { (success, err) in
            if success {
                print("evaluatePolicy success!")
                // this thread is not main thread,so add job to main...
                dispatch_sync(dispatch_get_main_queue(), {
                    self.evaluatePolicyOK = true
                    self.reloadDir()
                })
            }else{
                print("evaluatePolicy false!\(err.debugDescription)")
                dispatch_sync(dispatch_get_main_queue(), {
                    self.bookListArray.removeAll()
                    self.collectionView?.reloadData()
                    self.evaluatePolicyOK = false
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookListArray.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:BookCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! BookCollectionViewCell
    
        // Configure the cell

        let item = bookListArray[indexPath.row]
        cell.bookName.text = item["Name"] as? String

        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        log(indexPath.row)
        guard var item:[String:AnyObject] = bookListArray[indexPath.row] else{return}
        let bookPageVC:BookPageViewController = BookPageViewController()
        
        var textStorage:[[String:AnyObject]] = [[String:AnyObject]]()
        if readFile(&item, textStorage: &textStorage) {
            bookPageVC.bookItem = item
            bookPageVC.textStorage = textStorage
            self.navigationController?.pushViewController(bookPageVC, animated: true)
            bookListArray[indexPath.row] = item
        }else{
            log("readFile err \(item)")
        }
        
        
    }
    
    // MARK: GCDWebUploaderDelegate
    func webUploader(uploader: GCDWebUploader!, didCreateDirectoryAtPath path: String!) {
        debugPrint("Create:\(path)")
    }
    
    func webUploader(uploader: GCDWebUploader!, didUploadFileAtPath path: String!) {
        debugPrint("UploadFile:\(path)")
        self.reloadDir()
    }
    
    func webUploader(uploader: GCDWebUploader!, didDeleteItemAtPath path: String!) {
        debugPrint("Delete:\(path)")
        self.reloadDir()
    }
    
    func webUploader(uploader: GCDWebUploader!, didDownloadFileAtPath path: String!) {
         debugPrint("Download:\(path)")
    }
    
    func webUploader(uploader: GCDWebUploader!, didMoveItemFromPath fromPath: String!, toPath: String!) {
         debugPrint("MoveItem:\(toPath)")
        self.reloadDir()
    }
}
