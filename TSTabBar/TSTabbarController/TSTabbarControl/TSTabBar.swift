//
//  TSTabBar.swift
//  TSTabbarController
//
//  Created by 洪利 on 2018/7/7.
//  Copyright © 2018年 洪利. All rights reserved.
//

import UIKit
//import TSTabBarConfig
protocol TSTabBarDelegate {
    func tabbarDidSelectIndex(tabbar:TSTabBar, selectIndex:NSInteger)
}

class TSTabBar: UITabBar {

    var myDelegate : TSTabBarDelegate?
    
    var saveTabBarArrM = Array<TSTabbarButton>()
    var titleImageArrM = Array<String>()
    var selImageArrM = Array<UIImage>()
    var norImageArrM = Array<UIImage>()
    var selectedIndex:NSInteger = 0 {
        didSet{
            self.setUpSelectedIndex(selectedIndex: self.selectedIndex)
        }
    }
    func initWithFrame(frame:CGRect) -> TSTabBar {
        self.frame = frame
        var i = 0
        for _ in ts_tabbar_config.titleArr {
            var tbBtn = TSTabbarButton()
            tbBtn = tbBtn.initWithFrame(frame: CGRect.zero)
            tbBtn.imageView?.image = ts_tabbar_config.norImageArr[i]
            tbBtn.title?.text = ts_tabbar_config.titleArr[i];
            tbBtn.title?.textColor = ts_tabbar_config.norTitleColor;
            tbBtn.typeLayout = ts_tabbar_config.typeLayout;
            tbBtn.tag = i;
            self.addSubview(tbBtn)

            
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapClick))
            tbBtn.addGestureRecognizer(tap)
            self.saveTabBarArrM.append(tbBtn)
            self.titleImageArrM = ts_tabbar_config.titleArr
            self.norImageArrM = ts_tabbar_config.norImageArr
            self.selImageArrM = ts_tabbar_config.selImageArr
            i += 1
        }
        

        
        //背景颜色处理
        self.backgroundColor = ts_tabbar_config.tabBarBackground
        
        //顶部线条处理
        if (ts_tabbar_config.isClearTabBarTopLine) {
            self.topLineIsClearColor(state:true)
        } else {
            self.topLineIsClearColor(state:false)
        }
        return self
    }
    
    @objc func tapClick(tap:UITapGestureRecognizer) {
        self.setUpSelectedIndex(selectedIndex:(tap.view?.tag)!)
        self.myDelegate?.tabbarDidSelectIndex(tabbar: self, selectIndex: (tap.view?.tag)!)
    }
    func setUpSelectedIndex(selectedIndex:NSInteger) {
        var i = 0
        for tabBtn in self.saveTabBarArrM {
            let tbBtn = self.saveTabBarArrM[i]
            if (i == selectedIndex) {
                tbBtn.title?.textColor = ts_tabbar_config.selTitleColor
                tbBtn.imageView?.image = self.selImageArrM[i]
                
                let type = ts_tabbar_config.tabBarAnimtype
                if (type == .TSConfigTabBarAnimTypeRotationY) {
                    tbBtn.imageView?.layer.add(CAAnimation.TS_HL_TabBarRotationY(), forKey: "rotateAnimation")
                } else if (type == .TSConfigTabBarAnimTypeScale) {
                    
                    let anim = CABasicAnimation(keyPath: "transform.translation.y")
                    var point = tbBtn.imageView?.frame.origin;
                    point?.y -= 15;
                    anim.toValue = NSNumber(floatLiteral: CDouble((point?.y)!))
                    
                    let anim1 = CABasicAnimation(keyPath: "transform.scale")
                    anim1.toValue = NSNumber(floatLiteral: CDouble(1.3))
                    
                    let groupAnimation = CAAnimationGroup()
                    groupAnimation.fillMode = kCAFillModeForwards;
                    groupAnimation.isRemovedOnCompletion = false;
                    groupAnimation.animations = [anim1]
                    
                    tbBtn.imageView?.layer.add(groupAnimation, forKey: "groupAnimation")
                } else if (type == .TSConfigTabBarAnimTypeBoundsMin) {
                    tbBtn.imageView?.layer.add(CAAnimation.TS_HL_TabBarBoundsMin(), forKey: "min")
                } else if (type == .TSConfigTabBarAnimTypeBoundsMax) {
                    tbBtn.imageView?.layer.add(CAAnimation.TS_HL_TabBarBoundsMax(), forKey: "max")
                }
            } else {
                tbBtn.title?.textColor = ts_tabbar_config.norTitleColor
                tbBtn.imageView?.image = self.norImageArrM[i]
                tbBtn.imageView?.layer.removeAllAnimations()
            }
            i += 1
        }
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var tempArr = Array<Any>()
        for tabBarButton in self.subviews {
            if tabBarButton.isKind(of: NSClassFromString("UITabBarButton")!) {
                tabBarButton.removeFromSuperview()
            }
            if tabBarButton.isKind(of: TSTabbarButton.self) || tabBarButton.isKind(of: UIButton.self)  {
                tempArr.append(tabBarButton)
            }
        }
        
        //    JMLog(@"%@",tempArr);
        
        //进行排序
        for view  in tempArr {
            if (view as AnyObject).isKind(of:UIButton.self) {
                tempArr.insert(view, at: (view as AnyObject).tag)
                tempArr.removeLast()
                break;
            }
        }
        
        let viewW = self.ts_width / CGFloat(tempArr.count);
        let viewH = self.ts_height;
        let viewY = 0;
        var i = 0
        for viewS in tempArr {
            let viewX = CGFloat(i) * viewW
            (viewS as AnyObject).setValue(CGRect(x:viewX, y:CGFloat(viewY), width:viewW, height:viewH), forKey: "frame")
            i += 1
        }
    }
    
    func topLineIsClearColor(state:Bool) {
        var color = UIColor.clear
        if !state {
            color = ts_tabbar_config.tabBarTopLineColor
        }
        let rect = CGRect(x: 0, y: 0, width: self.ts_width, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext();
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.backgroundImage = UIImage()
        self.shadowImage = img
    
    }
    
}
