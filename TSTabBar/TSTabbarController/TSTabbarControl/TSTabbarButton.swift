//
//  TSTabbarButton.swift
//  TSTabbarController
//
//  Created by 洪利 on 2018/7/7.
//  Copyright © 2018年 洪利. All rights reserved.
//

import UIKit

class TSTabbarButton: UIView {

    var typeLayout: TSConfigTypeLayout = .TSConfigTypeLayoutNormal {
        didSet {
            if (typeLayout == .TSConfigTypeLayoutImage) {
                self.title?.isHidden = true;
                let imageSize = ts_tabbar_config.imageSize
                let imageX = self.ts_width * 0.5 - (imageSize.width) * 0.5
                let imageY = self.ts_height * 0.5 - (imageSize.height) * 0.5
                self.imageView?.frame = CGRect(x:imageX, y:imageY, width:(imageSize.width), height:(imageSize.height))
            }
        }
    }
    
    var imageView : UIImageView?
    var title : UILabel?
    var badgeValue : TSBadgeValue?
    func initWithFrame(frame:CGRect) ->TSTabbarButton{
        self.frame = frame
        self.imageView = UIImageView()
        self.addSubview(self.imageView!);
        
        self.title = UILabel();
        self.title?.textAlignment = .center
//        self.title.font = [UIFont systemFontOfSize:10.f];
        self.title?.font = UIFont.systemFont(ofSize: 10.0)
        self.addSubview(self.title!)
        
        self.badgeValue = TSBadgeValue()
        self.badgeValue?.isHidden = true
        self.addSubview(self.badgeValue!)
        return self
    }

    override func layoutSubviews() {
        let imageSize = ts_tabbar_config.imageSize
        var imageY = 5
        if (ts_tabbar_config.typeLayout == .TSConfigTypeLayoutImage) {
            imageY = Int(self.ts_height * 0.5 - (imageSize.height) * 0.5)
        }
        let iamgeX = self.ts_width * 0.5 - (imageSize.width) * 0.5
        self.imageView?.frame = CGRect(x:iamgeX, y:CGFloat(imageY), width:imageSize.width, height:imageSize.height)
        
        let titleX = 4.0
        let titleH = 14.0
        let titleW = self.ts_width - 8
        let titleY = self.ts_height - 14
        self.title?.frame = CGRect(x:CGFloat(titleX), y:titleY, width:titleW, height:CGFloat(titleH))
        
        let badgeX = (self.imageView?.frame.maxX)! - 6
        let badgeY = (self.imageView?.frame.minY)! - 2
        let badgeH = 16
        let badgeW = 24
        self.badgeValue?.frame = CGRect(x:badgeX, y:badgeY, width:CGFloat(badgeW), height:CGFloat(badgeH))
    }
}
