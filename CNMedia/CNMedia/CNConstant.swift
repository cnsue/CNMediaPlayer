//
//  CNConstant.swift
//  CNMedica
//
//  Created by lisue on 2018/6/20.
//  Copyright © 2018年 lisue. All rights reserved.
//【配合参数】

import UIKit

struct CNConstant {
    
}

///判断设备类型、方向、系统版本
extension CNConstant {
    static let BundleInfo = Bundle.main.infoDictionary
    static let appVersion = BundleInfo?["CFBundleShortVersionString"] as? String ?? "Unknown"
    static let bundleId = BundleInfo?[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
    
    static let systemVersion = Double(UIDevice.current.systemVersion) ?? 0.0
    
    static func isIOSAtLast(_ ver:String) -> Bool {
        return UIDevice.current.systemVersion.compare(ver, options: .numeric, range: nil, locale: nil) != .orderedAscending
    }
    static let aboveIOS8 = systemVersion >= 8.0
    static let aboveIOS10 = systemVersion >= 10.0
    static let aboveIOS11 = systemVersion >= 11.0
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
    
    static let isIPhone = UIDevice.current.model.hasPrefix("iPhone")
    static let isIPad = UIDevice.current.model.hasPrefix("iPad")
    static let isIPhone6Plus = isIPhone && (max(screenWidth, screenHeight) == 736.0)
    static let isIPhone5 = (isIPhone && screenWidth <= 320)
    static let isIPhoneX = isIPhone && (max(screenWidth, screenHeight) >= 812.0)
}


///尺寸(宽、高);位置(x、y);图片大小；元素间距
extension CNConstant{
    static let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    
      static let viewScale: CGFloat = (screenWidth / 375) //UI设计以iPhone6为标准(UIScreenWidth: 375)
    
    // iPhoneX 导航栏(44) + 状态栏(44)高度为 88，其余为64
    static var navBarCustomHeight: CGFloat {
        get {
            return isIPhoneX ? 88 : 64
        }
    }
    
    // iPhoneX tabbar 高度为 83，其余机型为49
    static var tabBarHeight: CGFloat {
        get {
            return isIPhoneX ? 83 : 49
        }
    }
    
    //屏幕底部弧线区高，iPhoneX(83-49)
    static let screenBottomArcHeight: CGFloat = isIPhoneX ? 34 : 0
}

extension CNConstant {
    
    // - 各类图片尺寸的高度
    struct Height {
        static let banner: CGFloat    = viewScale * 290 // 广告
    }
}


// MARK: 规范字体
extension UIFont {
    static func cnFont(_ fname: String, fsize: Float) -> UIFont {
        return UIFont(name: fname, size: CGFloat(fsize))!
    }
    
    static func cnFontSystem(_ fsize: Float) -> UIFont {
        return UIFont.systemFont(ofSize: CGFloat(fsize))
    }
    
    static func cnFontBold(_ fsize: Float) -> UIFont {
        return UIFont.boldSystemFont(ofSize: CGFloat(fsize))
    }
    
    static let system10 = cnFontSystem(20.0) // 类似：重要的问题提醒
}
