//
//  AppDelegate.swift
//  TSTabBar
//
//  Created by 洪利 on 2018/7/12.
//  Copyright © 2018年 洪利. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//
//        let titleArr = ["首页","热点","doki","个人中心"]
//        let imageNormalArr : Array<UIImage> = [UIImage(named: "tab1_nor")!,UIImage(named:"tab2_nor")!,UIImage(named: "tab3_nor")!,UIImage(named: "tab4_nor")!];
//        let imageSelectedArr : Array<UIImage> = [UIImage(named: "tab1_sel")!,UIImage(named: "tab2_sel")!,UIImage(named: "tab3_sel")!,UIImage(named: "tab4_sel")!]
//
//
        let model1 = TSTabBarInfoModel()
        model1.title = "首页"
        model1.norImage = UIImage(named: "tab1_nor")!
        model1.selImage = UIImage(named: "tab1_sel")!
        model1.controller = UINavigationController(rootViewController: ViewController())
        
        let model2 = TSTabBarInfoModel()
        model2.title = "热点"
        model2.norImage = UIImage(named: "tab2_nor")!
        model2.selImage = UIImage(named: "tab2_sel")!
        model2.controller = UINavigationController(rootViewController: UIViewController())
        
        let model3 = TSTabBarInfoModel()
        model3.title = "doki"
        model3.norImage = UIImage(named: "tab3_nor")!
        model3.selImage = UIImage(named: "tab3_sel")!
        model3.controller = UINavigationController(rootViewController: UIViewController())
        
        let model4 = TSTabBarInfoModel()
        model4.title = "个人中心"
        model4.norImage = UIImage(named: "tab4_nor")!
        model4.selImage = UIImage(named: "tab4_sel")!
        model4.controller = UINavigationController(rootViewController: UIViewController())
        
        
        
        /*
         1、提供model
         2、图片转@3X
         3、单独配置item
         */
        ts_tabbar_config.setTabBarInfo(info: [model1,model2,model3,model4])
        //选中时横向翻转动画
        ts_tabbar_config.setTabBarAnimtype(type: .TSConfigTabBarAnimTypeRotationY)
        let vc = ts_tabbar_config.getTabBarVC()
        self.window?.rootViewController = vc
        //初始化配置信息
        //    //无文字 只有图片
        //            ts_tabbar_config.typeLayout = .TSConfigTypeLayoutNormal;
        
        
        //    //选中时图片以底部为起点，向上伸展
        //            ts_tabbar_config.tabBarAnimType = TSConfigTabBarAnimTypeScale;
        
        //    //选中时向外扩张一次的弹簧动画
        //            ts_tabbar_config.tabBarAnimType = TSConfigTabBarAnimTypeBoundsMax;
        //    //选中时向内扩张一次的弹簧动画
        //            ts_tabbar_config.tabBarAnimType = TSConfigTabBarAnimTypeBoundsMin;
        //    //未选中、选中状态下的文字颜色
        //            ts_tabbar_config.norTitleColor = [UIColor blueColor];
        //            ts_tabbar_config.selTitleColor = [UIColor redColor];
        //    //tabbar背景色
        //            ts_tabbar_config.tabBarBackground = [UIColor greenColor];
        self.perform(#selector(setBadge), with: nil, afterDelay: 2)
        return true
    }
    
    
    @objc func setBadge() {
        
        
        
//        /** 标题的默认颜色 (默认为 #808080) */
//        private(set) var norTitleColor : UIColor = UIColor.ts_colorWithHexString(color: "#808080")
//        /** 标题的选中颜色 (默认为 #d81e06)*/
//        private(set) var selTitleColor : UIColor = UIColor.ts_colorWithHexString(color: "#d81e06")
//        /** 图片的size (默认 28*28) */
//        private(set) var imageSize : CGSize = CGSize(width: 28, height: 28)
//        private(set) var tabBarAnimtype : TSConfigTabBarAnimType?
//        /** 是否显示tabBar顶部线条颜色 (默认 YES) */
//        var isClearTabBarTopLine : Bool = true
//        /** tabBar顶部线条颜色 (默认亮灰色) */
//        private(set) var tabBarTopLineColor : UIColor = .lightGray
//        /** tabBar的背景颜色 (默认白色) */
//        private(set) var tabBarBackground : UIColor = .white
        
//        /** 标题的默认颜色 (默认为 #808080) */
//        ts_tabbar_config.setNorTitleColor(color: UIColor.blue)
//        /** 标题的选中颜色 (默认为 #d81e06)*/
//        ts_tabbar_config.setSelTitleColor(color: UIColor.blue)
//        /** 图片的size (默认 28*28) */
//        ts_tabbar_config.setImageSize(imageSize: CGSize(width: 20, height: 20))
//        /** tabBarItem选中动画 */
//        ts_tabbar_config.setTabBarAnimtype(type: .TSConfigTabBarAnimTypeRotationY)
//        /** 是否展示tabBar顶部线条 */
//        ts_tabbar_config.setIsClearTabBarTopLine(state: false)
//        /** 设置顶部线条颜色 */
//        ts_tabbar_config.setTabBarTopLineColor(color: UIColor.blue)
//        /** 设置tabbar背景色 */
//        ts_tabbar_config.setBadgeBackgroundColor(color: UIColor.blue)
        
        ts_tabbar_config.setbadgeAnimType(type: .TSConfigBadgeAnimTypeScale)
        ts_tabbar_config.setBadgeBackgroundColor(color:UIColor.red)
        ts_tabbar_config.setBadgeTextColor(color: UIColor.blue)
        ts_tabbar_config.setBadgeRadius(radius: 4)
        ts_tabbar_config.setBadgeOffset(offset: CGPoint(x: 30, y: 30))
        ts_tabbar_config.setBadgeSize(size: CGSize(width: 20, height: 20))
        
        
        
        ts_tabbar_config.showPointBadgeAtIndex(index: 1)
        ts_tabbar_config.showNewBadgeAtIndex(index: 2)
        ts_tabbar_config.showNumberBadgeValue(badgeValue: "67", index: 4)
        //        ts_tabbar_config.showNewBadgeAtIndex(index: 1)
        //        ts_tabbar_config.showPointBadgeAtIndex(index: 2)
        
        //        ts_tabbar_config.showNumberBadgeValue(badgeValue: "6", index: 3)
        //        ts_tabbar_config.showNumberBadgeValue(badgeValue: "67", index: 4)
        
//        ts_tabbar_config.animType = .TSConfigBadgeAnimTypeShake
        
        //        ts_tabbar_config.animType = .TSConfigBadgeAnimTypeOpacity
        //        ts_tabbar_config.showNumberBadgeValue(badgeValue: "67", index: 4)
        
        //        ts_tabbar_config.animType = .TSConfigBadgeAnimTypeScale
        //        ts_tabbar_config.showNumberBadgeValue(badgeValue: "67", index: 4)
        self.perform(#selector(removeBadge), with: nil, afterDelay: 2)
        
    }
    
    
    @objc func removeBadge() {
        ts_tabbar_config.hideBadgeAtIndex(index: 3)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

