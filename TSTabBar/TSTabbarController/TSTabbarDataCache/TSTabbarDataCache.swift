//
//  TSTabbarDataCache.swift
//  TSTabbarController
//
//  Created by 洪利 on 2018/7/10.
//  Copyright © 2018年 洪利. All rights reserved.
//

import UIKit
import TSDataPersistence



class TSTabbarDataCache: NSObject {

    //更新缓存
    class func updateTabbarInfoCache(tabbarInfo:TSTabBarInfoModel, complete: @escaping ()->()) {
        ts_cache.set(tabbarInfo, forKey: "TS_TabBarInfo_Cache") { (cache, a, b) in
            complete()
        }
    }
    class func getTabbarInfoCache(complete: @escaping (_ tabbarInfo:TSTabBarInfoModel?)->()) {
        
        if let md: TSTabBarInfoModel = ts_cache.object(forKey: "TS_TabBarInfo_Cache") {
            complete(md)
        }else{
            complete(nil)
        }
    }
   
}


class TSTabBarInfoModel: Codable {
    var norTitleColor = "#808080"
    var selTitleColor = "#d81e06"
    var isClearTabBarTopLine:Bool = true
    var tabBarTopLineColor = "#dddddd"
    var tabBarBackGround = "#ffffff"
    var typeLayout : TSConfigTypeLayout = .TSConfigTypeLayoutNormal
    var badgeTextColor = "#ffffff"
    var badgeBackGroundColor = "#ff4040"
    var titleArr = Array<String>()
    var norImageArr = Array<Data>()
    var selImageArr = Array<Data>()
    
    var imageSize = CGSize(width: 28, height: 28)

    
}




