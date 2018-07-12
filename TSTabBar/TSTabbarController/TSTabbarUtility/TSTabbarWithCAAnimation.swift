//
//  TSTabbarWithCAAnimation.swift
//  TSTabbarController
//
//  Created by 洪利 on 2018/7/7.
//  Copyright © 2018年 洪利. All rights reserved.
//

import Foundation
import UIKit



extension CAAnimation {
    
    
    class func ts_angle2Rad(angle:Int) -> Double {
        return Double(angle)/180.0 * .pi
    }
    
    class func TS_HL_ShakeAnimation_RepeatTimes(repeatTimes:Float) -> CAKeyframeAnimation {
        let anima = CAKeyframeAnimation(keyPath: "transform.rotation")
        anima.values = [(ts_angle2Rad(angle: -15)),
                        (ts_angle2Rad(angle: -10)),
                        (ts_angle2Rad(angle: -7)),
                        (ts_angle2Rad(angle: -5)),
                        (ts_angle2Rad(angle: 0)),
                        (ts_angle2Rad(angle: 5)),
                        (ts_angle2Rad(angle: -7)),
                        (ts_angle2Rad(angle: 10)),
                        (ts_angle2Rad(angle: 15))]
        anima.repeatCount = repeatTimes
        return anima
    }
    class func TS_HL_OpacityAnimatioinDurTimes(time:Double) -> CABasicAnimation {
        let anima = CABasicAnimation(keyPath: "opacity")
        anima.fromValue = NSNumber(floatLiteral: 1.0)
        anima.toValue = NSNumber(floatLiteral: 0.2)
        anima.repeatCount = 3
        anima.duration = time
        anima.autoreverses = true
        return anima
    }
    class func TS_HL_ScaleAnimation() -> CABasicAnimation {
        let anima = CABasicAnimation(keyPath: "transform.scale")
        anima.toValue = NSNumber(floatLiteral: 1.2)
        anima.duration = 0.3
        anima.repeatCount = 3
        anima.autoreverses = true
        return anima
    }
    
    
    class func TS_HL_TabBarRotationY() -> CABasicAnimation {
        let anima = CABasicAnimation(keyPath: "transform.rotation.y")
        anima.toValue = NSNumber(floatLiteral: .pi*2)
        return anima
    }
    
    class func TS_HL_TabBarBoundsMin() -> CABasicAnimation {
        let anima = CABasicAnimation(keyPath: "bounds.size")
        anima.toValue = NSValue.init(cgPoint: CGPoint(x: 12, y: 12))
        return anima
    }
    
    class func TS_HL_TabBarBoundsMax() -> CABasicAnimation {
        let anima = CABasicAnimation(keyPath: "bounds.size")
        anima.toValue = NSValue.init(cgPoint: CGPoint(x: 46, y: 46))
        return anima
    }
    
    
}






