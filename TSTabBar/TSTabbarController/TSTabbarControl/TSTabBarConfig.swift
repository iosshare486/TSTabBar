//
//  TSTabBarConfig.swift
//  TSTabbarController
//
//  Created by 洪利 on 2018/7/7.
//  Copyright © 2018年 洪利. All rights reserved.
//

import UIKit

protocol TSTabbarDefaultConfig {
    func tabBarDefaultConfig() -> ()
}
enum TSConfigTypeLayout:Int,Codable {
    case TSConfigTypeLayoutNormal = 0 //默认布局 图片在上 文字在下
    case TSConfigTypeLayoutImage = 1 //只有图片 (图片居中)
}
enum TSConfigTabBarAnimType:Int,Codable {
    case TSConfigTabBarAnimTypeNormal = 0 //无动画
    case TSConfigTabBarAnimTypeRotationY = 1 //Y轴旋转
    case TSConfigTabBarAnimTypeBoundsMin = 2 //缩小
    case TSConfigTabBarAnimTypeBoundsMax = 3 //放大
    case TSConfigTabBarAnimTypeScale = 4 //缩放动画
}

enum TSConfigBadgeAnimType:Int,Codable {
    case TSConfigBadgeAnimTypeNormal = 0 //无动画
    case TSConfigBadgeAnimTypeShake = 1 //抖动动画
    case TSConfigBadgeAnimTypeOpacity = 2 //透明过渡动画
    case TSConfigBadgeAnimTypeScale = 3 //缩放动画
}

public typealias TSConfigCustomBtnBlock = (()->(btn:UIButton, index:NSInteger))

public let ts_tabbar_config = TSTabBarConfig.createConfig()







open class TSTabBarConfig: NSObject {
    
    /******************************** tabBar 基本配置 ********************************/
    /** 布局类型 (默认是 图片在上, 文字在下) */
    var typeLayout : TSConfigTypeLayout = .TSConfigTypeLayoutNormal
    /** 标题的默认颜色 (默认为 #808080) */
    var norTitleColor : UIColor = UIColor.ts_colorWithHexString(color: "#808080")
    /** 标题的选中颜色 (默认为 #d81e06)*/
    var selTitleColor : UIColor = UIColor.ts_colorWithHexString(color: "#d81e06")
    /** 图片的size (默认 28*28) */
    var imageSize : CGSize = CGSize(width: 28, height: 28)
    var tabBarAnimtype : TSConfigTabBarAnimType?
    /** 是否显示tabBar顶部线条颜色 (默认 YES) */
    var isClearTabBarTopLine : Bool = true
    /** tabBar顶部线条颜色 (默认亮灰色) */
    public var tabBarTopLineColor : UIColor = .lightGray
    /** tabBar的背景颜色 (默认白色) */
    var tabBarBackground : UIColor = .white
    /** tabBarController */
    var tabBarController : TSTabbarViewController?
    var tabbarDefaultConfigDelegate : TSTabbarDefaultConfig?
    /******************************** badgeValue 基本配置 ********************************/
    /** badgeColor(默认 #FFFFFF) */
    var badgeTextColor : UIColor = .white{
        didSet{
            let arrM = getTabBarButtons()
            for btn in arrM {
                btn.badgeValue?.badgeL.textColor = self.badgeTextColor
            }
        }
    }
    /** badgeBackgroundColor (默认 #FF4040)*/
    var badgeBackgroundColor : UIColor = UIColor.ts_colorWithHexString(color: "#FF4040"){
            didSet{
                    let arrM = getTabBarButtons()
                    for btn in arrM {
                        btn.badgeValue?.badgeL.backgroundColor = self.badgeBackgroundColor;
                    }
            }
    }
    /** badgeSize (如没有特殊需求, 请勿修改此属性, 此属性只有在控制器加载完成后有效)*/
    var badgeSize: CGSize = CGSize(width: 20.0, height: 20.0) {
        didSet{
            let arrM = getTabBarButtons()
            for btn in arrM {
                btn.badgeValue?.badgeL.ts_size = self.badgeSize
            }
        }
    }
    /** badgeOffset (如没有特殊需求, 请勿修改此属性, 此属性只有在控制器加载完成后有效) */
    var badgeOffset : CGPoint = CGPoint(x: 0, y: 0 ){
        didSet{
            let arrM = getTabBarButtons()
            for btn in arrM {
                btn.badgeValue?.badgeL.ts_x += self.badgeOffset.x
                btn.badgeValue?.badgeL.ts_y += self.badgeOffset.y
            }
        }
    }
    /** badge圆角大小 (如没有特殊需求, 请勿修改此属性, 此属性只有在控制器加载完成后有效, 一般配合badgeSize或badgeOffset使用) */
    var badgeRadius : CGFloat = 4.0{
        didSet{
            let arrM = getTabBarButtons()
            for btn in arrM {
                btn.badgeValue?.badgeL.layer.cornerRadius = self.badgeRadius
            }
        }
    }
    /** badge动画 (默认无动画) */
    var animType : TSConfigBadgeAnimType?
    
    
    
    /******************************** 自定义按钮 基本配置 ********************************/
    /** btnClickBlock */
    var btnClickBlock : TSConfigCustomBtnBlock?
    
    static var configSinglation : TSTabBarConfig?
    class func createConfig() ->TSTabBarConfig {
        if configSinglation == nil {
            let config = TSTabBarConfig()
            config.configNormal()
            return config
        }else{
            return configSinglation!
        }
    }
    
    func configNormal() {
            self.norTitleColor = UIColor.ts_colorWithHexString(color: "#808080")
            self.selTitleColor = UIColor.ts_colorWithHexString(color: "#d81e06")
            self.isClearTabBarTopLine = true;
            self.tabBarTopLineColor = .lightGray
            self.tabBarBackground = .white
            self.typeLayout = .TSConfigTypeLayoutNormal
            self.imageSize = CGSize(width:28, height:28)
            self.badgeTextColor = UIColor.ts_colorWithHexString(color:"#FFFFFF")
            self.badgeBackgroundColor = UIColor.ts_colorWithHexString(color:"#FF4040")
    }
    
    /**
     对单个进行圆角设置
     @param radius 圆角值
     @param index 下标
     */
    func badgeRadius(radius:CGFloat, index:NSInteger) {
        let tabBarButton = self.getTabBarButtonAtIndex(index:index)
        tabBarButton.badgeValue?.badgeL.layer.cornerRadius = radius;
    }
    
    /**
     显示圆点badgevalue  (以下关于badgeValue的操作可以在app全局操作)  使用方法 [[JMConfig config] showPointBadgeValue: AtIndex: ]
     @param index 显示的下标
     */
    func showPointBadgeAtIndex(index:NSInteger) {
        let tabBarButton = self.getTabBarButtonAtIndex(index:index)
        tabBarButton.badgeValue?.isHidden = false;
        tabBarButton.badgeValue?.type = .TSBadgeValueTypePoint;
    }
    
    
    /**
     显示newBadgeValue (以下关于badgeValue的操作可以在app全局操作)
     @param index 下标
     */
    func showNewBadgeAtIndex(index:NSInteger) {
        let tabBarButton = self.getTabBarButtonAtIndex(index:index)
        tabBarButton.badgeValue?.isHidden = false;
        tabBarButton.badgeValue?.badgeL.text = "new";
        tabBarButton.badgeValue?.type = .TSBadgeValueTypeNew;
        
    }
    
    /**
     显示带数值的下标  (注意: 此方法可以全局重复调用)
     @param badgeValue 数值
     @param index 下标
     */
    func showNumberBadgeValue(badgeValue:String, index:NSInteger) {
        let tabBarButton = self.getTabBarButtonAtIndex(index:index)
        tabBarButton.badgeValue?.isHidden = false;
        tabBarButton.badgeValue?.badgeL.text = badgeValue;
        tabBarButton.badgeValue?.type = .TSBadgeValueTypeNumber;
    }
    
    
    /**
     隐藏下标的badgeValue
     
     @param index 下标
     */
    func hideBadgeAtIndex(index:NSInteger) {
        self.getTabBarButtonAtIndex(index:index).badgeValue?.isHidden = true
    }
    
    
    /******************************** 自定义按钮 基本配置 ********************************/
    
    
    /**
     添加自定义按钮 (目前只支持自定义按钮, 如果需要自定义view或者对加号按钮有更多需求的请联系我)
     @param btn 自定义btn
     @param index 添加的下标位置
     @param btnClickBlock 按钮点击事件的回调
     */

    func addCustomBtn(btn:UIButton, index:NSInteger , btnClickBlock:@escaping TSConfigCustomBtnBlock) {
        btn.tag = index;
        btn.addTarget(self, action: #selector(customBtnClick), for:.touchUpInside)
        self.btnClickBlock = btnClickBlock;
        self.tabBarController?.ts_tabBar.addSubview(btn);
        
    }
    
    @objc func customBtnClick(sender:UIButton) {
        
    }
    
    
    
    func getTabBarButtonAtIndex(index:NSInteger) -> TSTabbarButton {
        let subViews = self.tabBarController?.ts_tabBar.subviews;
        for btn in subViews! {
            if btn.isKind(of: TSTabbarButton.self) && subViews?.index(of: btn) == index{
                return btn as! TSTabbarButton
            }
        }
        let sBtn : TSTabbarButton? = nil
        return sBtn!
    }
    
    func getTabBarButtons() ->Array<TSTabbarButton> {
        let subViews = self.tabBarController?.ts_tabBar.subviews
        var tempArr = Array<TSTabbarButton>()
        if subViews != nil {
            for btn in subViews! {
                if btn.isKind(of:TSTabbarButton.self) {
                    tempArr.append(btn as! TSTabbarButton)
                }
            }
        }
        return tempArr;
    }
    
}





extension TSTabBarConfig{
    func startConfigTabbar(window:UIWindow) {
        TSTabbarDataCache.getTabbarInfoCache { (tabbarInfo) in
//            self.configTabBar(tabBarInfo: TSTabBarInfoModel(), window:window)
            var newTabbarInfo : TSTabBarInfoModel?

            if tabbarInfo != nil {
                //数据有效
                newTabbarInfo = tabbarInfo
                self.configTabBar(tabBarInfo: newTabbarInfo!, window: window)
            }else{
                //数据无效，执行默认配置
                self.tabbarDefaultConfigDelegate?.tabBarDefaultConfig()

            }
            
        }
    }
    func configTabBar(tabBarInfo:TSTabBarInfoModel, window:UIWindow) {

        let titleArr = tabBarInfo.titleArr
        var imageNormalArr = Array<UIImage>()
        var imageSelectedArr = Array<UIImage>()

        for data in tabBarInfo.norImageArr {
            let image : UIImage = UIImage.init(data: data)!
            imageNormalArr.append(image)
        }
        for data2 in tabBarInfo.selImageArr {
            let image :UIImage = UIImage.init(data: data2)!
            imageSelectedArr.append(image)
        }
        

        var controllersArr = Array<UIViewController>();

        for title in titleArr {
            if titleArr.index(of: title) == 0 {
                let vc = ViewController()
                let nav = UINavigationController(rootViewController: vc)
                controllersArr.append(nav)
            }else{
                let vc = UIViewController()
                let nav = UINavigationController(rootViewController: vc)
                controllersArr.append(nav)
            }

        }
        
        let tabBarVc = TSTabbarViewController().initWithTabBarControllers(controllers: controllersArr, norImageArr: imageNormalArr , selImageArr: imageSelectedArr , titleArr: titleArr, config: ts_tabbar_config)

        
        window.rootViewController = tabBarVc;
    }
}




