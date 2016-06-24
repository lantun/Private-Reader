//
//  AppDelegate.swift
//  Private Reader
//
//  Created by Tun Lan on 6/12/16.
//  Copyright © 2016 Tun Lan. All rights reserved.
//

import UIKit

let umKey = "576cead567e58eba500021c0"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func umengTrack() {
        UMAnalyticsConfig.sharedInstance().appKey = umKey
        UMAnalyticsConfig.sharedInstance().channelId = "App Store"
        UMAnalyticsConfig.sharedInstance().eSType = .E_UM_NORMAL // 仅适用于游戏场景，应用统计不用设置
        MobClick.startWithConfigure(UMAnalyticsConfig.sharedInstance())
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let winRect = UIScreen.mainScreen().bounds
        window = UIWindow(frame: winRect)
        window?.backgroundColor = UIColor.whiteColor()
        let flowLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(50, 80) //设置cell的尺寸
        flowLayout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0) //设定全局的区内边距
        flowLayout.minimumLineSpacing = 10;//设定全局的行间距
        flowLayout.minimumInteritemSpacing = 10;//设定全局的Cell间距
        flowLayout.scrollDirection = .Vertical;//设定滚动方向

        let BookListVC = UINavigationController(rootViewController: BookListCollectionViewController(collectionViewLayout: flowLayout))
        BookListVC.navigationBar.tintColor = UIColor.blackColor()
        BookListVC.toolbar.tintColor = UIColor.blackColor()
        BookListVC.navigationBar.backgroundColor = RGB(r: 239, g: 239, b: 224)
        window?.rootViewController = BookListVC
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

