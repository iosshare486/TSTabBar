//
//  TSTUIColorWithHexString.swift
//  TSTabbarController
//
//  Created by 洪利 on 2018/7/7.
//  Copyright © 2018年 洪利. All rights reserved.
//

import Foundation
import UIKit


extension UIColor {
    
    class func ts_colorWithHexString(color: String) -> UIColor {
        return ts_colorWithHexString(color: color, alpha: 1.0)
    }
    
    class func ts_colorWithHexString(color: String, alpha:CGFloat) -> UIColor {
        var cString = color.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        if cString.count < 6 {
            return UIColor.clear
        }
        
        //判断前缀
        if cString.hasPrefix("0X") || cString.hasPrefix("0x") {
            cString = NSString(string: cString).substring(from: 2)
        }
        if cString.hasPrefix("#") {
            cString = NSString(string: cString).substring(from: 1)
        }
        if cString.count != 6 {
            return UIColor.clear
        }
        
        //从六位数值中找到RGB对应的位数并转换
        var range = NSRange.init(location: 2, length: 2)
        let rString = NSString(string: cString).substring(with: range)
        range.location = 2
        let gString = NSString(string: cString).substring(with: range)
        range.location = 4
        let bString = NSString(string: cString).substring(with: range)
        
        var r: UInt32 = 0x0
        var g: UInt32 = 0x0
        var b: UInt32 = 0x0
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        if #available(iOS 10.0, *) {
            return UIColor(displayP3Red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(1))
        } else {
            return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(1))
        }
    }
    
    
}

