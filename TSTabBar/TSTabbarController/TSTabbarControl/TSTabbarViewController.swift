//
//  TSTabbarViewController.swift
//  TSTabbarController
//
//  Created by 洪利 on 2018/7/7.
//  Copyright © 2018年 洪利. All rights reserved.
//

import UIKit

class TSTabbarViewController: UITabBarController {

    public var ts_tabBar = TSTabBar()
    
    func initWithTabBarControllers() -> TSTabbarViewController {
        self.viewControllers = ts_tabbar_config.controllersArr;
        
        self.ts_tabBar = self.ts_tabBar.initWithFrame(frame: self.tabBar.frame)
        self.ts_tabBar.myDelegate = self
        self.setValue(self.ts_tabBar, forKeyPath: "tabBar")
        
        ts_tabbar_config.tabBarController = self
        self.ts_tabBar.selectedIndex = 0
        //KVO
        self.addObserver(self, forKeyPath: "selectedIndex", options: [.old,.new], context: nil)
        
        return self
    }
//    func initWithTabBarControllers(controllers: Array<UIViewController>, norImageArr:Array<UIImage>,selImageArr:Array<UIImage>, titleArr:Array<String>,config:TSTabBarConfig) -> TSTabbarViewController {
//        self.viewControllers = controllers;
//
//        self.ts_tabBar = self.ts_tabBar.initWithFrame(frame: self.tabBar.frame, norImageArr: norImageArr, selImageArr: selImageArr, titleArr: titleArr, config: config)
//        self.ts_tabBar.myDelegate = self;
//        self.setValue(self.ts_tabBar, forKeyPath: "tabBar")
//
//        ts_tabbar_config.tabBarController = self
//        self.ts_tabBar.selectedIndex = 0
//        //KVO
//        self.addObserver(self, forKeyPath: "selectedIndex", options: [.old,.new], context: nil)
//
//        return self
//    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let selectedIndex = ((change! as NSDictionary).object(forKey: "new") as! NSNumber).intValue
        self.ts_tabBar.selectedIndex = selectedIndex;
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

//    override func dealloc (){
//        [self removeObserver:self forKeyPath:@"selectedIndex"];
//    }

}


extension TSTabbarViewController : TSTabBarDelegate{
    func tabbarDidSelectIndex(tabbar: TSTabBar, selectIndex: NSInteger) {
        self.selectedIndex = selectIndex;
    }
}

