//
//  TSBadgeValue.swift
//  TSTabbarController
//
//  Created by 洪利 on 2018/7/7.
//  Copyright © 2018年 洪利. All rights reserved.
//

import UIKit

enum TSBadgeValueType {
    case TSBadgeValueTypePoint  //点
    case TSBadgeValueTypeNew    //new
    case TSBadgeValueTypeNumber //number
}


class TSBadgeValue: UIView {

    var badgeL = UILabel()
    var type: TSBadgeValueType = .TSBadgeValueTypePoint {
        didSet{
            if (type == .TSBadgeValueTypePoint) {
                self.badgeL.ts_size = CGSize(width: 10, height: 10)
                self.badgeL.layer.cornerRadius = 5.0
                self.badgeL.ts_x = 0
                self.badgeL.ts_y = self.ts_height * 0.5 - self.badgeL.ts_size.height * 0.5
            } else if (type == .TSBadgeValueTypeNew) {
                self.badgeL.ts_size = CGSize(width: self.ts_width, height: self.ts_height)
            } else if (type == .TSBadgeValueTypeNumber) {
                var size = CGSize.zero;
                var radius = 8.0
                if ((self.badgeL.text?.count)! <= 1) {
                    size = CGSize(width: self.ts_height, height: self.ts_height)
                    radius = Double(self.ts_height * 0.5)
                } else if ((self.badgeL.text?.count)! > 1) {
                    size = self.bounds.size;
                    radius = 8.0
                }
                self.badgeL.ts_size = size
                self.badgeL.layer.cornerRadius = CGFloat(radius)
            }
            
            let animType = ts_tabbar_config.animType
            if (animType == .TSConfigBadgeAnimTypeShake) {   //抖动
                self.badgeL.layer.add(CAAnimation.TS_HL_ShakeAnimation_RepeatTimes(repeatTimes: 5), forKey: "shakeAnimation")
            } else if (animType == .TSConfigBadgeAnimTypeOpacity) { //透明过渡动画'
                self.badgeL.layer.add(CAAnimation.TS_HL_OpacityAnimatioinDurTimes(time: 0.3), forKey: "opacityAniamtion")
            } else if (animType == .TSConfigBadgeAnimTypeScale) { //缩放动画
                self.badgeL.layer.add(CAAnimation.TS_HL_ScaleAnimation(), forKey: "scaleAnimation")
            }
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.badgeL = UILabel.init(frame: self.bounds)
        self.badgeL.textColor = ts_tabbar_config.badgeTextColor
        self.badgeL.font = UIFont.systemFont(ofSize: 11.0)
        self.badgeL.textAlignment = .center;
        self.badgeL.layer.cornerRadius = 8;
        self.badgeL.layer.masksToBounds = true;
        self.badgeL.backgroundColor = ts_tabbar_config.badgeBackgroundColor
        self.addSubview(self.badgeL)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func sizeWithAttribute(text:NSString) -> CGSize {
        return text.size(withAttributes: [NSAttributedStringKey.font: self.badgeL.font])
    }
}
