# TSTabBar

### 接入
> 初始配置

	//创建模型
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
        
        
        //将model包装在数组内并通过setTabBarInfo方法传给ts_tabbar_config单例
        ts_tabbar_config.setTabBarInfo(info: [model1,model2,model3,model4])
        
        //获取tabBarVC
        let vc = ts_tabbar_config.getTabBarVC()
        
        
        //demo，将window的rootVC设置为VC
        self.window?.rootViewController = vc
    
 > 配置tabBar
 
	 /** 标题的默认颜色 (默认为 #808080) */
    ts_tabbar_config.setNorTitleColor(color: UIColor.blue)
    /** 标题的选中颜色 (默认为 #d81e06)*/
    ts_tabbar_config.setSelTitleColor(color: UIColor.blue)
    /** 图片的size (默认 28*28) */
    ts_tabbar_config.setImageSize(imageSize: CGSize(width: 20, height: 20))
    /** tabBarItem选中动画 */
    ts_tabbar_config.setTabBarAnimtype(type: .TSConfigTabBarAnimTypeRotationY)
    /** 是否展示tabBar顶部线条 */
    ts_tabbar_config.setIsClearTabBarTopLine(state: false)
    /** 设置顶部线条颜色 */
    ts_tabbar_config.setTabBarTopLineColor(color: UIColor.blue)
    /** 设置tabbar背景色 */
    ts_tabbar_config.setBadgeBackgroundColor(color: UIColor.blue)
 
    
 > 配置item badge    
 > ps:  配置badge相关参数时需要保证UI已经渲染结束
     
    //展示红点提示
    ts_tabbar_config.showPointBadgeAtIndex(index: 1)
    //展示圆角 new 标签
    ts_tabbar_config.showNewBadgeAtIndex(index: 2)
    //展示消息条目数量
    ts_tabbar_config.showNumberBadgeValue(badgeValue: "67", index: 4)
    //设置badge背景色
    ts_tabbar_config.setBadgeBackgroundColor(color:UIColor.red)
    //设置badge文案颜色
    ts_tabbar_config.setBadgeTextColor(color: UIColor.blue)
    //设置badge圆角弧度
    ts_tabbar_config.setBadgeRadius(radius: 4)
    //设置badge偏移
    ts_tabbar_config.setBadgeOffset(offset: CGPoint(x: 30, y: 30))
    //设置badge size
    ts_tabbar_config.setBadgeSize(size: CGSize(width: 20, height: 20))
    
    
### tabBarItem样式支持
	enum TSConfigTypeLayout:Int,Codable {
	    case TSConfigTypeLayoutNormal = 0 //默认布局 图片在上 文字在下
	    case TSConfigTypeLayoutImage = 1 //只有图片 (图片居中)
	}
	
	//使用示例
	//无文字 只有图片，默认情况下为文字+图片
    ts_tabbar_config.typeLayout = .TSConfigTypeLayoutNormal;
	
        
### 动画支持
   > tabBarItem选中动画
   
    enum TSConfigTabBarAnimType:Int,Codable {
	    case TSConfigTabBarAnimTypeNormal = 0 //无动画
	    case TSConfigTabBarAnimTypeRotationY = 1 //Y轴旋转
	    case TSConfigTabBarAnimTypeBoundsMin = 2 //缩小
	    case TSConfigTabBarAnimTypeBoundsMax = 3 //放大
	    case TSConfigTabBarAnimTypeScale = 4 //缩放动画
	}
	//使用示例
    //选中时横向翻转动画
	ts_tabbar_config.setTabBarAnimtype(type: .TSConfigTabBarAnimTypeRotationY)
        
> badge动画
	   
	enum TSConfigBadgeAnimType:Int,Codable {
	    case TSConfigBadgeAnimTypeNormal = 0 //无动画
	    case TSConfigBadgeAnimTypeShake = 1 //抖动动画
	    case TSConfigBadgeAnimTypeOpacity = 2 //透明过渡动画
	    case TSConfigBadgeAnimTypeScale = 3 //缩放动画
	}
	//使用示例，抖动动画
	ts_tabbar_config.setbadgeAnimType(type: . TSConfigBadgeAnimTypeShake) 